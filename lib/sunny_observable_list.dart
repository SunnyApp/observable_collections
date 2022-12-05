import 'dart:async';

import 'package:collection_diff/collection_diff.dart';
import 'package:collection_diff/diff_algorithm.dart';
import 'package:collection_diff/list_diff_model.dart';
import 'package:collection_diff_worker/collection_diff_worker.dart';
import 'package:mobx/mobx.dart' hide ObservableMap, ListChange;
import 'package:sunny_dart/sunny_dart.dart'
    show LoggingMixin, Disposable, ValueStream;
import 'package:sunny_dart/extensions.dart';
import 'empty_callback.dart';

/// Extension of [ObservableList] that supports syncing internal items from an external list.  When dart 2.6 comes
/// out, this can move to an extension function
class SunnyObservableList<V> extends ObservableList<V>
    with LoggingMixin, Disposable {
  SunnyObservableList.of(Iterable<V> map,
      {this.diffAlgorithm,
      this.diffEquality = const DiffEquality(),
      String? debugLabel})
      : debugLabel = debugLabel ?? "List<$V>",
        super.of(map);

  SunnyObservableList(
      {this.diffAlgorithm,
      this.diffEquality = const DiffEquality(),
      String? debugLabel})
      : debugLabel = debugLabel ?? "List<$V>",
        super();

  SunnyObservableList.ofStream(Stream<Iterable<V>> stream,
      {FutureOr<Iterable<V>>? start,
      this.diffAlgorithm,
      this.diffEquality = const DiffEquality(),
      String? debugLabel})
      : debugLabel = debugLabel ?? "stream[${V.simpleName}]",
        super() {
    this.sync(start).then((_) {
      final subscription = stream.asyncMap((newList) {
        try {
          log.fine(
              "got sync event from upstream with ${newList.length} records");
          this.sync(newList);
        } catch (e) {
          print(e);
        }
      }).listen(
        (_) {},
        cancelOnError: false,
      );
      disposers.add(subscription.cancel);
    });
  }

  SunnyObservableList.ofVStream(ValueStream<Iterable<V>> stream,
      {this.diffEquality = const DiffEquality(), String? debugLabel})
      : debugLabel = debugLabel ?? "stream[${V.name}]",
        super() {
    this.sync(stream.get()).then((_) {
      final subscription = stream.listen(
        (newList) {
          try {
            log.info(
                "[$debugLabel] got sync event from upstream with ${newList.length} records");
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

  void subscribeTo(Stream<Iterable<V>> other, {bool sync = false}) {
    disposers.add(other.asyncMap((items) async {
      await this.sync(items, async: sync != true);
    }).listen((_) {
      // nothing to do
    }, cancelOnError: false).cancel);
  }

  @override
  String get loggerName => debugLabel;

  String debugLabel;

  DiffEquality diffEquality;
  ListDiffAlgorithm? diffAlgorithm;

  StreamController<ListDiffs<V>> _changes = StreamController.broadcast();

  ValueStream<ListDiffs<V>> get changeStream {
    return ValueStream.of(<V>[].differences(this), _changes.stream);
//    return ValueStream.of(<V>[].differencesAsync(this), _changes.stream);
  }

  ValueStream<Iterable<V>> get stream => ValueStream.of(
      [...this], _changes.stream.map((changes) => changes.newList));

  /// Optional
  final List<EmptyCallback> disposers = [];

  @override
  void registerDisposer(EmptyCallback callback) {
    disposers.add(callback);
  }

  Future dispose() async {
    disposers.forEach((fn) => fn());
    disposers.clear();
    await _changes.close();
  }

  /// Syncs the values of this list with a replacement list, and emits modification events in the form of
  /// [ListChange]
  Future<ListDiffs<V>> sync(FutureOr<Iterable<V>?> newItemsFuture,
      {bool async = true}) async {
    final SunnyObservableList<V> _items = this;
    final newItems = await newItemsFuture;

    ListDiffs<V> diff;
    if (async) {
      diff = await _items.differencesAsync(
        [...newItems!],
        algorithm: diffAlgorithm ?? ListDiffAlgorithm.myers,
        equality: diffEquality,
        debugName: debugLabel,
      );
    } else {
      diff = _items.differences(
        [...newItems!],
        algorithm: diffAlgorithm ?? ListDiffAlgorithm.myers,
        equality: diffEquality,
      );
    }

    /// Apply patches may do some modification
    applyPatches(diff);
    return diff;
  }

  void applyPatches(ListDiffs<V> diffs) {
    try {
      diffs.forEach(applyPatch);
      if (!_changes.isClosed) {
        _changes.add(diffs);
      } else {
        log.warning(
            "Not propagating $diffs because the broadcast stream has closed");
      }
    } catch (e, stack) {
      log.severe("Error updating state for $debugLabel: $e", e, stack);
      rethrow;
    }
  }

  void applyPatch(ListDiff<V> change) {
    try {
      if (change is DeleteDiff<V>) {
        for (int d = 0; d < change.delete.size; d++) {
          if (change.delete.index! < this.length) {
            super.removeAt(change.delete.index!);
          }
        }
      } else if (change is InsertDiff<V>) {
        var start = change.index!;
        for (final item in change.items) {
          super.insert(start++, item);
        }
      } else if (change is ReplaceDiff<V>) {
        var start = change.index;
        for (final item in change.items) {
          super[start!] = item;
        }
      }
    } catch (e, stack) {
      // ignore: unnecessary_brace_in_string_interps
      log.severe("Error updating statse for $debugLabel: $e", e, stack);
      rethrow;
    }
  }
}
