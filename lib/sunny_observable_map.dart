import 'dart:async';
import 'dart:ui';

import 'package:collection_diff/collection_diff.dart';
import 'package:collection_diff/map_diff.dart';
import 'package:collection_diff_isolate/collection_diff_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart' hide ObservableMap, MapChange;
import 'package:sunny_dart/sunny_dart.dart';
import 'package:sunny_dart/typedefs.dart';

import 'observable_extensions.dart';
import 'observable_map_extended.dart';
import 'sunny_observable_list.dart';

/// The normal [ObservableMap] class doesn't observe changes to the values bound to a key, eg "Let me know if contact 53 changes",
/// so this class offers some additional connected observers that report changes to map keys
class SunnyObservableMap<K, V> extends ObservableMap<K, V> with LoggingMixin {
  String debugLabel;

  StreamSubscription _subscribedTo;

  set subscribedTo(StreamSubscription subscription) {
    if (_subscribedTo != null) {
      _subscribedTo.cancel();
    }
    _subscribedTo = subscription;
  }

  /// This doesn't affect the keys in the map - rather it's used when doing list diffs of the
  /// values in the map - to know whether one list item represents the _same_ list item (but with
  /// different values).  This is typically the primary key, but can be a different key or combination
  final DiffEquality<V> _diffEquality;

  @override
  String get loggerName => debugLabel ?? super.loggerName;

  SunnyObservableMap.of(Map<K, V> map, {String debugLabel, DiffEquality<V> diffDelegator})
      : _diffEquality = diffDelegator ?? DiffEquality(),
        debugLabel = debugLabel ?? "ObservableMap<$K, $V>",
        super.of(map) {
    _initialize();
  }

  SunnyObservableMap({String debugLabel, DiffEquality<V> diffDelegator})
      : this.of(<K, V>{}, debugLabel: debugLabel, diffDelegator: diffDelegator);

  SunnyObservableMap.ofStream(Map<K, V> initial, Stream<Map<K, V>> stream,
      {this.debugLabel, DiffEquality<V> diffEquality})
      : _diffEquality = diffEquality ?? DiffEquality(),
        super.of(initial) {
    _initialize();
    syncAndListenFrom(stream, start: initial);
  }

  SunnyObservableMap.ofVStream(ValueStream<Map<K, V>> stream, {this.debugLabel, DiffEquality<V> diffEquality})
      : _diffEquality = diffEquality ?? DiffEquality(),
        super() {
    _initialize();
    syncAndListenFrom(stream.after, start: stream.get());
  }

  _initialize() {
    _keys = changeController.stream.map((changes) {
      return [...this.keys];
    });
    _values = changeController.stream.map((changes) {
      return [...this.values];
    });
  }

  Stream<Iterable<K>> _keys;
  Stream<Iterable<V>> _values;

  @protected
  final StreamController<MapDiffs<K, V>> changeController = StreamController.broadcast();

  Stream<MapDiffs<K, V>> get changeStream => changeController.stream;

  final List<VoidCallback> _disposers = [];

  Future dispose() async {
    _disposers.forEach((fn) => fn());
    await [_subscribedTo?.cancel(), changeController.close()].awaitAll();
  }

  addDisposer(VoidCallback dispose) {
    if (dispose != null) {
      _disposers.add(dispose);
    }
  }

  @override
  String toString() {
    return 'SunnyObservableMap{$debugLabel}';
  }

  @protected
  MapDiffs<K, V> newBuilder() => MapDiffs.builder({...this}, valueEquality: _diffEquality, checkValues: true);

  HStream<V> watchKey(K key) => HStream(this[key], changeStream.map((changes) => changes.args.replacement[key]));

  V call(K key) {
    return this[key];
  }

  HStream<Map<K, V>> get stream => HStream({...this}, changeStream.map((changes) => changes.args.replacement));

  Dispose observeKey(K key, Consumer<V> react, {bool fireImmediately}) {
    if (fireImmediately == true) {
      react(this[key]);
    }
    return changeController.stream.listen((_) {
      if (_.any((change) => change.key == key)) {
        react(this[key]);
      }
    }).cancel;
  }

  /// Allows for observation of the maps keys as a list.  Provides a means
  /// of disposing
  HStream<Iterable<K>> get keysStream => HStream(this.keys, _keys);

  /// Allows for observation of a single map key.
  HStream<V> keyStream(K key) => HStream<V>(
      this[key],
      changeStream.expand((changes) => changes).where((change) => change.key == key).map((change) {
        switch (change.type) {
          case MapDiffType.unset:
            return null;
            break;
          case MapDiffType.change:
            return change.value;
            break;
          case MapDiffType.set:
            return change.value;
            break;
          default:
            throw "Invalid type - must be a known MapDiff type";
        }
      }));

  /// Allows for observation of the values as a list.  Provides a means
  /// of disposing
  ValueStream<Iterable<V>> get valueStream {
    return ValueStream.of({...values}, _values);
  }

  Future<MapDiffs<K, V>> sync(FutureOr<Map<K, V>> newMap, {bool async = true}) async {
    final nm = await newMap;

    try {
      if (async) {
        final changes = await this.differencesAsync(
          nm,
          checkValues: true,
          debugName: debugLabel,
          valueEquality: _diffEquality,
        );
        applyChanges(changes);
        return changes;
      } else {
        final changes = this.differences(
          nm,
          checkValues: true,
          valueEquality: _diffEquality,
        );
        applyChanges(changes);
        return changes;
      }
    } catch (e, stack) {
      // ignore: unnecessary_brace_in_string_interps
      log.severe("has issues syncing ${nm.length} records: $e", e, stack);
      return MapDiffs.builder(this);
    }
  }

  void applyChanges(MapDiffs<K, V> changes) {
    for (final change in changes) {
      switch (change.type) {
        case MapDiffType.set:
          super[change.key] = change.value;
          break;
        case MapDiffType.unset:
          super.remove(change.key);
          break;
        case MapDiffType.change:
          super[change.key] = change.value;
          break;
      }
    }
    changeController.add(changes);
  }

  @override
  V putIfAbsent(K key, V ifAbsent()) {
    if (!containsKey(key)) {
      return _buildChanges((_) {
        final newValue = ifAbsent?.call();
        _.set(key, newValue);

        /// Make sure you use super to avoid stack overflows
        /// with subclasses
        super[key] = newValue;
        return newValue;
      });
    } else {
      /// Make sure you use super to avoid stack overflows
      /// with subclasses
      return super[key];
    }
  }

  Set<K> removes(Map<K, dynamic> newData) {
    final currKeys = this.keys.toSet();
    return currKeys.difference(newData.keys.toSet());
  }

  R _buildChanges<R>(R builder(MapDiffs<K, V> _)) {
    final changes = MapDiffs<K, V>.builder(this, valueEquality: _diffEquality, checkValues: true);
    final returnValue = builder(changes);
    changeController.add(changes);
    return returnValue;
  }

  @override
  push(Object key, V value) {
    _buildChanges((_) {
      _.change(key as K, value);
      super.push(key, value);
    });
  }

  @override
  V remove(Object key) {
    return _buildChanges((_) {
      _.remove(key as K);
      return super.remove(key);
    });
  }

  @override
  void addAll(Map<K, V> other) {
    final combined = {...this, ...?other};
    this.sync(combined);
  }

  @override
  V update(K key, V update(V value), {V ifAbsent()}) {
    return _buildChanges((_) {
      if (this.containsKey(key)) {
        final newValue = update(this[key]);
        _.change(key, newValue);
        this[key] = newValue;
        return newValue;
      } else {
        final newValue = ifAbsent?.call();
        if (newValue != null) {
          _.set(key, newValue);
        }
        this[key] = newValue;
        return newValue;
      }
    });
  }

  @override
  void updateAll(V update(K key, V value)) {
    final values = {...this};
    values.forEach((k, v) => values[k] = update(k, v));
    this.sync(values);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    this.addAll(Map.fromEntries(newEntries));
  }

  @override
  void removeWhere(bool test(K key, V value)) {
    return _buildChanges((_) {
      this.forEach((k, v) {
        if (test(k, v) == true) {
          _.remove(k);
        }
      });

      super.remove(test);
    });
  }

  @override
  void operator []=(K key, V value) {
    /// These changes should not be tracked
    super[key] = value;
  }

  /// Doesn't trigger observers
  void removeQuiet(Object key) {
    this.remove(key);
  }

  Future syncAndListenFrom(Stream<Map<K, V>> stream, {final FutureOr<Map<K, V>> start}) async {
    Stream<Map<K, V>> _stream = stream;
    if (start != null) {
      await this.sync(start);
    }
    this.subscribedTo = _stream.where((_) => _ != null).asyncMap((replacement) {
      return this.sync(replacement);
    }).listen((_) {}, cancelOnError: false);
  }

  FutureOr<V> getOrPut(K key, FutureOr<V> factory(K id)) {
    final existing = this[key];
    if (existing != null) return existing;

    final newInstance = factory(key) ?? nullPointer<V>("Factory produced null value");
    return newInstance.thenOr((resolved) {
      // After resolved, add to this map
      this.push(key, resolved);
      return resolved;
    });
  }
}

class SunnyObservableMapList<K, L> extends SunnyObservableMap<K, SunnyObservableList<L>> {
  SunnyObservableMapList([String debugLabel, this.listDiffDelegator])
      : _log = Logger("mapList.$debugLabel"),
        super(debugLabel: debugLabel, diffDelegator: DiffEquality());

  final DiffEquality<L> listDiffDelegator;
  final Logger _log;

  @override
  String toString() {
    return 'map{$debugLabel}';
  }

  @override
  void operator []=(K key, SunnyObservableList<L> value) => illegalState("No direct updates are possible for this "
      "map. You must use the get operations instead");

  @override
  SunnyObservableList<L> operator [](Object key) {
    final k = key as K;
    return putIfAbsent(k, () {
      final list =
          SunnyObservableList<L>(debugLabel: "$debugLabel[$key]", diffEquality: listDiffDelegator ?? DiffEquality());
      addDisposer(list.changeStream.listen((changes) {
        _log.fine("Found change to mapList - ${changes.length}");
        changeController.add(newBuilder()..change(k, list));
      }).cancel);
      return list;
    });
  }

  reset() async {
    for (final v in [...values]) {
      await v.sync([]);
      await v.dispose();
    }

    [...keys].forEach((k) => removeQuiet(k));
  }

  takeFromMapList(Map<K, Iterable<L>> replacement) async {
    _log.info(
        "sync: ${replacement.isEmpty ? 'empty' : replacement.entries.map((e) => "${e.key}=>${e.value.length}").join(", ")}");
    // Now, let's apply all the childThreads.  This will make sure to remove anything that needs removing, etc.
    await this.removes(replacement).map((removedKey) async {
      _log.fine("sync: key=$removedKey");

      // Instead of removing, just clear out the list.  This ensures that everybody knows about it.
      await this[removedKey].sync(<L>[]);
    }).awaitAll();

    await replacement.entries.map((e) async {
      _log.fine("sync: key=$e count${e.value.length}");
      final childThreads = this[e.key];
      await childThreads.sync(e.value ?? []);
    }).awaitAll();
  }

  Future<SunnyObservableMap<K, SunnyObservableList<L>>> syncFromMapList(
      ValueStream<Map<K, List<L>>> replacement) async {
    final first = replacement.get();
    if (first is! Future) {
      await takeFromMapList(first as Map<K, Iterable<L>>);
      this.subscribedTo = replacement.after.listen(takeFromMapList, cancelOnError: false);
    } else {
      final _first = await first;
      await takeFromMapList(_first);
      this.subscribedTo = replacement.after.listen(takeFromMapList, cancelOnError: false);
    }

    return this;
  }
}

class SunnyObservableMapMap<K1, K, V> extends SunnyObservableMap<K1, SunnyObservableMap<K, V>> {
  SunnyObservableMapMap([String debugLabel, this.listDiffDelegator])
      : log = Logger("mapMap[${debugLabel ?? '-'}"),
        super(debugLabel: debugLabel, diffDelegator: DiffEquality());

  final DiffEquality<V> listDiffDelegator;

  final Logger log;

  @override
  void operator []=(K1 key, SunnyObservableMap<K, V> value) => illegalState("No direct updates are possible for this "
      "map. You must use the get operations instead");

  @override
  String toString() {
    return 'SunnyObservableMapMap{$debugLabel}';
  }

  @override
  SunnyObservableMap<K, V> operator [](Object key) {
    final k = key as K1;
    return putIfAbsent(key as K1, () {
      final map = SunnyObservableMap<K, V>(
        diffDelegator: listDiffDelegator,
        debugLabel: "$debugLabel[$key]",
      );
      addDisposer(map.changeStream.listen((changes) {
        changeController.add(newBuilder()..change(k, map));
      }).cancel);
      return map;
    });
  }

  void takeFromMapMap(Map<K1, Map<K, V>> replacement) {
    // Now, let's apply all the childThreads.  This will make sure to remove anything that needs removing, etc.
    removes(replacement).forEach((removedKey) {
      // Instead of removing, just clear out the list.  This ensures that everybody knows about it.
      this[removedKey].sync(<K, V>{});
    });

    replacement.forEach((key, list) {
      final childThreads = this[key];

      childThreads.sync(list);
    });
  }

  SunnyObservableMap<K1, SunnyObservableMap<K, V>> syncFromMapList(HStream<Map<K1, Map<K, V>>> replacement) {
    this.takeFromMapMap(replacement.first);
    this.subscribedTo = replacement.listen(takeFromMapMap);
    return this;
  }
}
