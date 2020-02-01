import 'dart:async';
import 'dart:ui';

import 'package:collection_diff/collection_diff.dart';
import 'package:collection_diff/list_diff_model.dart';
import 'package:collection_diff_isolate/collection_diff_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart' hide ObservableMap, ListChange;
import 'package:sunny_dart/sunny_dart.dart';

/// Extension of [ObservableList] that supports syncing internal items from an external list.  When dart 2.6 comes
/// out, this can move to an extension function
class SunnyObservableList<V> extends ObservableList<V> with LoggingMixin, Disposable {
  SunnyObservableList.of(Iterable<V> map, {this.diffEquality = const DiffEquality(), String debugLabel})
      : assert(diffEquality != null),
        debugLabel = debugLabel ?? "List<$V>",
        super.of(map);

  SunnyObservableList({this.diffEquality = const DiffEquality(), String debugLabel})
      : assert(diffEquality != null),
        debugLabel = debugLabel ?? "List<$V>",
        super();

  SunnyObservableList.ofStream(Stream<Iterable<V>> stream,
      {@required FutureOr<Iterable<V>> start, this.diffEquality = const DiffEquality(), String debugLabel})
      : assert(diffEquality != null),
        debugLabel = debugLabel ?? "stream[${V.simpleName}]",
        super() {
    this.sync(start).then((_) {
      final subscription = stream.listen(
        (newList) {
          try {
            log.fine("got sync event from upstream with ${newList.length} records");
            this.sync(newList);
          } catch (e) {
            print(e);
          }
        },
        cancelOnError: false,
      );
      disposers.add(subscription.cancel);
    });
  }

  SunnyObservableList.ofVStream(ValueStream<Iterable<V>> stream,
      {this.diffEquality = const DiffEquality(), String debugLabel})
      : debugLabel = debugLabel ?? "stream[${V.name}]",
        assert(diffEquality != null),
        super() {
    this.sync(stream.get()).then((_) {
      final subscription = stream.listen(
        (newList) {
          try {
            log.info("[$debugLabel] got sync event from upstream with ${newList.length} records");
            this.sync(newList);
          } catch (e) {
            print(e);
          }
        },
      );
      disposers.add(subscription.cancel);
    });
  }

  @override
  String toString() {
    return 'SunnyObservableList{$debugLabel}';
  }

  String get loggerName => debugLabel ?? super.loggerName;

  String debugLabel;

  DiffEquality<V> diffEquality;

  StreamController<ListDiffs<V>> _changes = StreamController.broadcast();

  ValueStream<ListDiffs<V>> get changeStream {
    return ValueStream.of(<V>[].differences(this), _changes.stream);
//    return ValueStream.of(<V>[].differencesAsync(this), _changes.stream);
  }

  ValueStream<Iterable<V>> get stream => ValueStream.of([...this], _changes.stream.map((changes) => changes.newList));

  /// Optional
  final List<VoidCallback> disposers = [];

  registerDisposer(VoidCallback callback) {
    if (callback != null) {
      disposers.add(callback);
    }
  }

  dispose() {
    disposers.forEach((fn) => fn());
    disposers.clear();
  }

  /// Syncs the values of this list with a replacement list, and emits modification events in the form of
  /// [ListChange]
  Future<ListDiffs<V>> sync(FutureOr<Iterable<V>> newItemsFuture) async {
    final _items = this;
    final newItems = await newItemsFuture;

    ListDiffs<V> diff = await _items.differencesAsync([...newItems], equality: diffEquality, debugName: debugLabel);

    /// Apply patches may do some modification
    applyPatches(diff);
    return diff;
  }

  void applyPatches(ListDiffs<V> diffs) {
    try {
      diffs.forEach(applyPatch);
      _changes.add(diffs);
    } catch (e, stack) {
      log.severe("Error updating state for $debugLabel: $e", e, stack);
      rethrow;
    }
  }

  void applyPatch(ListDiff<V> change) {
    try {
      if (change is DeleteDiff<V>) {
        for (int d = 0; d < change.delete.size; d++) {
          this.safeRemove(change.delete.index);
        }
      } else if (change is InsertDiff<V>) {
        var start = change.index;
        for (final item in change.items) {
          this.insert(start++, item);
        }
      } else if (change is ReplaceDiff<V>) {
        var start = change.index;
        for (final item in change.items) {
          this[start] = item;
        }
      }
    } catch (e, stack) {
      // ignore: unnecessary_brace_in_string_interps
      log.severe("Error updating statse for $debugLabel: $e", e, stack);
      rethrow;
    }
  }
}
