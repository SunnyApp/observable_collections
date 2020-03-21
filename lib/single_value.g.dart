// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_value.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SingleValue<T> on SingleValueBase<T>, Store {
  Computed<T> _$valueComputed;

  @override
  T get value => (_$valueComputed ??= Computed<T>(() => super.value)).value;
  Computed<bool> _$isNullComputed;

  @override
  bool get isNull => (_$isNullComputed ??= Computed<bool>(() => super.isNull)).value;

  final _$_trackedAtom = Atom(name: 'SingleValueBase._tracked');

  @override
  TrackedValue<T> get internalTracked {
    _$_trackedAtom.context.enforceReadPolicy(_$_trackedAtom);
    _$_trackedAtom.reportObserved();
    return super.internalTracked;
  }

  @override
  set internalTracked(TrackedValue<T> value) {
    _$_trackedAtom.context.conditionallyRunInAction(() {
      super.internalTracked = value;
      _$_trackedAtom.reportChanged();
    }, _$_trackedAtom, name: '${_$_trackedAtom.name}_set');
  }

  final _$SingleValueBaseActionController = ActionController(name: 'SingleValueBase');

  @override
  dynamic update(T value, {bool force = false}) {
    final _$actionInfo = _$SingleValueBaseActionController.startAction();
    try {
      return super.update(value, force: force);
    } finally {
      _$SingleValueBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  FutureOr<T> modify(Mutator<T> mutator) {
    final _$actionInfo = _$SingleValueBaseActionController.startAction();
    try {
      return super.modify(mutator);
    } finally {
      _$SingleValueBaseActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$ProgressTracker on ProgressTrackerBase, Store {
  final _$taskAtom = Atom(name: 'ProgressTrackerBase.task');

  @override
  String get task {
    _$taskAtom.context.enforceReadPolicy(_$taskAtom);
    _$taskAtom.reportObserved();
    return super.task;
  }

  @override
  set task(String value) {
    _$taskAtom.context.conditionallyRunInAction(() {
      super.task = value;
      _$taskAtom.reportChanged();
    }, _$taskAtom, name: '${_$taskAtom.name}_set');
  }

  final _$ProgressTrackerBaseActionController = ActionController(name: 'ProgressTrackerBase');

  @override
  dynamic finishTask(double progress, {String newTask}) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction();
    try {
      return super.finishTask(progress, newTask: newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic finishTaskRatio(double progress, {String newTask}) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction();
    try {
      return super.finishTaskRatio(progress, newTask: newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateTask(String newTask) {
    final _$actionInfo = _$ProgressTrackerBaseActionController.startAction();
    try {
      return super.updateTask(newTask);
    } finally {
      _$ProgressTrackerBaseActionController.endAction(_$actionInfo);
    }
  }
}
