import 'package:collection_diff/collection_diff.dart';
import 'package:collection_diff/map_diff_model.dart';
import 'package:sunny_dart/sunny_dart.dart';

import 'sunny_observable_list.dart';
import 'sunny_observable_map.dart';

extension ValueStreamIterable_ObservableExtension<X> on ValueStream<Iterable<X>> {
  SunnyObservableList<X> observeList([String debugLabel, DiffEquality<X> diffEquality = const DiffEquality()]) {
    return SunnyObservableList.ofVStream(this, diffEquality: diffEquality, debugLabel: debugLabel);
  }
}

extension SunnyObservableMapExtension<K, V> on SunnyObservableMap<K, V> {
  SunnyObservableMap<KK, VV> mapObserved<KK, VV>(MapEntry<KK, VV> mapper(K key, V value),
      {String debugLabel, DiffEquality<VV> valueEquality}) {
    return SunnyObservableMap<KK, VV>.ofStream(
      this.map(mapper),
      this.changeStream.map((changes) => changes.replacement.map(mapper)),
      diffEquality: valueEquality,
    );
  }
}

extension ValueStreamFutureIterableExtensions<X> on ValueStream<Future<Iterable<X>>> {
  SunnyObservableList<X> observeListSampled([String debugLabel, DiffEquality<X> diffDelegator]) {
    return SunnyObservableList<X>.ofVStream(this.sampled(), debugLabel: debugLabel, diffEquality: diffDelegator);
  }

  ValueStream<Future<Iterable<R>>> thenMapEach<R>(R mapper(X input)) {
    return this.map((item) async {
      final resolved = await item;
      return resolved.map((each) => mapper(each));
    });
  }
}

extension ValueStreamOfMapExtensions<K, V> on ValueStream<Map<K, V>> {
  SunnyObservableMap<K, V> observe([String debugLabel, DiffEquality<V> diffEquality]) {
    return SunnyObservableMap.ofVStream(
      this,
      debugLabel: debugLabel,
      diffEquality: diffEquality,
    );
  }
}

extension ValueStreamFutureMapListExtensions<K, L> on ValueStream<Future<Map<K, List<L>>>> {
  SunnyObservableMapList<K, L> observeDeep([String debugLabel, DiffEquality<L> diffDelegator]) {
    return SunnyObservableMapList<K, L>(debugLabel, diffDelegator)..syncFromMapList(this.sampled());
  }
}

extension ValueStreamMapListExtensions<K, L> on ValueStream<Map<K, List<L>>> {
  SunnyObservableMapList<K, L> observeDeep([String debugLabel, DiffEquality<L> diffDelegator]) {
    return SunnyObservableMapList<K, L>(debugLabel, diffDelegator)..syncFromMapList(this);
  }
}

//extension RecordIterables<V extends Entity> on Iterable<Record<V>> {
//  Future<Iterable<V>> resolveAll() async => await Future.wait(this.map((record) => record.future));
//
//  Iterable<V> get resolved => where((r) => r.isResolved).map((r) => r.value);
//  List<V> get resolvedList => where((r) => r.isResolved).map((r) => r.value).toList();
//}

Map<K, List<V>> groupByKey<K, V>(Iterable<MapEntry<K, V>> input) {
  Map<K, List<V>> results = {};
  input.forEach((e) {
    results.putIfAbsent(e.key, () => <V>[]).add(e.value);
  });
  return results;
}

extension SunnyObservableMapExtensions<K, V> on SunnyObservableMap<K, V> {
  Future syncFromVStream(ValueStream<Map<K, V>> stream) {
    return syncAndListenFrom(stream.after, start: stream.get());
  }
}

extension MapDiffsExt<K, V> on MapDiffs<K, V> {
  String get summary {
    return groupByType().entries.map((entry) {
      return "${entry.key.simpleName}=${entry.value.length}";
    }).join(", ");
  }

  void set(K key, V item) {
    add(MapDiff.set(args, key, item));
  }

  void unset(K key) {
    add(MapDiff.unset(args, key, args.original[key]));
  }

  void change(K key, V newItem) {
    add(MapDiff.change(args, key, newItem, args.original[key]));
  }
}
