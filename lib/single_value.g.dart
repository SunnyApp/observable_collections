// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_value.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SingleValue<T> on SingleValueBase<T>, Store {
  Computed<T>? _$valueComputed;

  @override
  T get value => (_$valueComputed ??=
          Computed<T>(() => super.value, name: 'SingleValueBase.value'))
      .value;
  Computed<bool>? _$isNullComputed;

  @override
  bool get isNull => (_$isNullComputed ??=
          Computed<bool>(() => super.isNull, name: 'SingleValueBase.isNull'))
      .value;

  final _$internalTrackedAtom = Atom(name: 'SingleValueBase.internalTracked');

  @override
  TrackedValue<T> get internalTracked {
    _$internalTrackedAtom.reportRead();
    return super.internalTracked;
  }

  @override
  set internalTracked(TrackedValue<T> value) {
    _$internalTrackedAtom.reportWrite(value, super.internalTracked, () {
      super.internalTracked = value;
    });
  }

  final _$SingleValueBaseActionController =
      ActionController(name: 'SingleValueBase');

  @override
  void update(T value, {bool force = false}) {
    final _$actionInfo = _$SingleValueBaseActionController.startAction(
        name: 'SingleValueBase.update');
    try {
      return super.update(value, force: force);
    } finally {
      _$SingleValueBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  FutureOr<T> modify(Mutator<T> mutator) {
    final _$actionInfo = _$SingleValueBaseActionController.startAction(
        name: 'SingleValueBase.modify');
    try {
      return super.modify(mutator);
    } finally {
      _$SingleValueBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
internalTracked: ${internalTracked},
value: ${value},
isNull: ${isNull}
    ''';
  }
}

mixin _$ProgressTracker on ProgressTrackerBase, Store {
  final _$taskAtom = Atom(name: 'ProgressTrackerBase.task');

  @override
  String? get task {
    _$taskAtom.reportRead();
    return super.task;
  }

  @override
  set task(String? value) {
    _$taskAtom.reportWrite(value, super.task, () {
      super.task = value;
    });
  }

  final _$ProgressTrackerBaseActionController =
      ActionController(name: 'ProgressTrackerBase');

  @override
  void finishTask(double progress, {String? newTask}) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction(
        name: 'ProgressTrackerBase.finishTask');
    try {
      return super.finishTask(progress, newTask: newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void finishTaskRatio(double progress, {String? newTask}) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction(
        name: 'ProgressTrackerBase.finishTaskRatio');
    try {
      return super.finishTaskRatio(progress, newTask: newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTask(String newTask) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction(
        name: 'ProgressTrackerBase.updateTask');
    try {
      return super.updateTask(newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
task: ${task}
    ''';
  }
}
