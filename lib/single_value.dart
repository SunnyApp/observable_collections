import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart' hide ObservableMap;
import 'package:sunny_dart/sunny_dart.dart';

part 'single_value.g.dart';

/// Simple observable mobx boxed value that can be updated.  This class provides a simpler way to update, instead
/// of having to wrap mutations in runInAction, eg
/// ```
/// # The normal mobx way
/// final observable = Observable("Eric");
/// runInAction(() {
///   observable.value = "Eric Martineau";
/// });
///
/// # Using SingleValue
/// final observable = SingleValue("Eric");
/// observable.update("Eric Martineau");
/// ```
///
class SingleValue<T> extends SingleValueBase<T> with _$SingleValue<T> {
  SingleValue(T value, [String name]) : super(value, name);

  SingleValue.ofValueNotifier(ValueNotifier<T> notifier, {bool sync = false})
      : super(notifier.value) {
    syncToValueNotifier(notifier, this);
    if (sync) {
      syncToSingleValue(this, notifier);
    }
  }

  SingleValue.empty() : this(null);
}

typedef Mutator<T> = T Function(T input);

abstract class SingleValueBase<T> with Disposable, Store {
  final log = Logger("singleValue");
  SingleValueBase(T value, [this.name]) : internalTracked = TrackedValue(value);

  /// A name - can be useful to generate a key based on tracking this value.  Not required
  String name;

  Key get key => name != null ? Key(name) : null;

  @observable
  TrackedValue<T> internalTracked;

  @action
  void update(T value, {bool force = false}) {
    this.internalTracked = this.internalTracked.updated(value, force: force);
  }

  @action
  FutureOr<T> modify(Mutator<T> mutator) {
    final v = mutator(internalTracked.tracked);
    this.internalTracked = this.internalTracked.updated(v, force: true);
    return v;
  }

  @computed
  T get value => internalTracked.tracked;

  T get() => internalTracked.tracked;

  /// Whether or not the underlying value is null
  @computed
  bool get isNull => internalTracked.tracked == null;

  /// Would love extension functions for this
  ValueNotifier<T> toValueNotifier({bool sync = false}) {
    final notifier = ValueNotifier<T>(internalTracked.tracked);
    syncToSingleValue(this as SingleValue<T>, notifier);
    if (sync) {
      syncToValueNotifier(notifier, this as SingleValue<T>);
    }
    return notifier;
  }
}

ReactionDisposer syncToSingleValue<T>(
    SingleValue<T> singleValue, ValueNotifier<T> notifier) {
  return reaction(
      (_) => singleValue.value, (newValue) => notifier.value = newValue as T);
}

ListenerDisposer syncToValueNotifier<T>(
    ValueNotifier<T> notifier, SingleValue<T> singleValue) {
  final updater = () => singleValue.update(notifier.value);
  notifier.addListener(updater);
  return () => notifier.removeListener(updater);
}

typedef ListenerDisposer = void Function();

class StateCounter {
  /// Stores the public value, which may or may not have some smoothing slush applied
  final SingleValue<double> _counter;
  final log = Logger("stateCounter");

  /// The actual value
  double _actual = 0;

  /// A padded value that has some slush applied.  Can be zero
  double _padded = 0;

  StateCounter([String name]) : _counter = SingleValue<double>(0, name);

  /// Delegates the creation of a key to the wrapped [SingleValue].  This is optional
  Key get key => _counter.key;

  /// Keeps the public value in sync with an internal padded value.
  void _sync() {
    _counter.update(math.max(_actual, _padded));
  }

  void increment([double amount]) {
    _actual += (amount ?? 1);
    _sync();
  }

  /// Increments the value by a certain amount over a duration using an exponential backoff.
  /// Helps prevent large pauses while operations are / warming up.
  Future predict(double amount, {Duration step}) async {
    // We don't allow multiple pads to run
    print("Predicting $amount (target of ${_actual + amount})");
    double progress = amount;
    _padded = _actual;
    final target = _actual + amount;
    for (var i = 1; i < 40; i++) {
      if (_actual >= target) {
        log.info("Reached target: $_actual $target -> We had $progress left");
        break;
      }
      if (progress <= 1) {
        log.fine(
            "Progress is less than 1: $progress towards our goal of $target");
        break;
      }

      final p = math.min(3, math.max(0.3, progress / i));
      if (p < 0) {
        log.fine(
            "Reached the negatives? $p towards our progress $progress goal of $target");
        break;
      }
      progress -= p;
      if (progress > 0) {
        log.fine("Predict increment by $p (target $target)");
        _padded += p;
        _sync();
      }
      await Future.delayed(step ?? 100.ms);
    }
  }

  void updateRatio(double ratio) {
    assert(ratio >= 0 && ratio <= 1);
    _actual = 100.0 * ratio;
    _sync();
  }

  void update(double amount) {
    _actual = amount;
    _sync();
  }

  void decrement() {
    _actual -= 1.0;
    _sync();
  }

  void reset() {
    _actual = 0.0;
    _sync();
  }

  void set(double value) {
    _actual = value;
    _sync();
  }

  double get count => _counter.value;
}

class ProgressTracker extends ProgressTrackerBase with _$ProgressTracker {
  /// Creates
  ProgressTracker(num total, [String name]) : super._(total, name);

  /// Instead of counting towards an arbitrary count, we'll base the counter on a percent and the caller will
  /// make sure to send the appropriate ratios
  ProgressTracker.ratio([String name]) : super._(100.0, name);
}

abstract class ProgressTrackerBase extends StateCounter with Store {
  /// The total number of units working towards.  For percent/ratio based tracking, this will be 100
  double _total = 0.0;

  /// Stores what's currently being worked on
  @observable
  String task;

  /// The total number of units working towards.  For percent/ratio based tracking, this will be 100
  double get total => _total;

  @action
  void finishTask(double progress, {String newTask}) {
    this.update(progress);
    if (newTask != null) {
      this.task = newTask;
    }
  }

  @action
  void finishTaskRatio(double progress, {String newTask}) {
    updateRatio(progress);
    if (newTask != null) {
      this.task = newTask;
    }
  }

  @action
  void updateTask(String newTask) {
    this.task = newTask;
  }

  ProgressTrackerBase._(num total, [String name])
      : assert(total != null, total >= 0),
        _total = total.toDouble(),
        super(name);

  /// Returns a percent completed, between 0 and 100
  double get percent {
    if (_total == 0) return 0;
    return math.min(1, math.max(0, count / _total));
  }

  /// Returns the completed percent in textual form, with a % sign
  String get percentText => "${(percent * 100).round()}%";

  /// Marks this counter as complete
  void complete() {
    set(_total.toDouble());
  }
}

/// Allows a tracked value to be forcibly updated by using a timestamp
class TrackedValue<T> {
  final T tracked;
  final int timestamp;

  TrackedValue(this.tracked, [int timestamp])
      : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  TrackedValue<T> updated(T value, {bool force = false}) {
    return TrackedValue(value, force == true ? null : this.timestamp);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedValue &&
          runtimeType == other.runtimeType &&
          tracked == other.tracked &&
          timestamp == other.timestamp;

  @override
  int get hashCode => tracked.hashCode ^ timestamp.hashCode;
}
