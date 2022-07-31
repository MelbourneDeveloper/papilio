import 'dart:async';

import 'package:flutter/material.dart';

///Resend the current state to trigger a rebuild. This is the
///equivalent of setState
@immutable
class RebuildEvent extends BlocEvent {}

///Business Logic Component
class Bloc<T> {
  bool isDisposed = false;

  ///The current state of the bloc
  T _state;

  //the controller for the state stream
  final StreamController<Snapshot<T>> _streamController =
      StreamController<Snapshot<T>>.broadcast();

  ///Sync handlers as a map by type
  final Map<Type, T Function(T state, Object event)> _syncHandlersByEvent;

  ///Async handlers as a map by type
  final Map<
      Type,
      Future<T> Function(
    T Function() state,
    Object,
    void Function(T) updateState,
    Object? pageScope,
  )> _handlersByEvent;

  ///The initial state of the bloc
  final T initialState;

  ///Put short lived objected that need disposal here
  final Object? pageScope;

  Bloc(
    this.initialState,
    this._handlersByEvent,
    this._syncHandlersByEvent, {
    this.pageScope,
  }) : _state = initialState;

  String _unhandledErrorMessage(BlocEvent event) =>
      'There is no handler for the type ${event.runtimeType}';

  ///The stream of state updates. Listen to this with a StreamBuilder<T>
  Stream<Snapshot<T>> get stream => _streamController.stream;

  ///Send an async event to the bloc
  Future<T> addEvent(BlocEvent event) async {
    if (isDisposed) {
      return _state;
    }
    _state = await _executeHandler(() => _state, event, _updateState);
    _streamController.sink.add(Snapshot(_state, addEvent, addEventSync));

    return _state;
  }

  ///Send a synchronous event to the bloc
  T addEventSync<Tb extends BlocEvent>(Tb event) {
    if (isDisposed) {
      return _state;
    }

    if (event is! RebuildEvent) {
      _state = _executeHandlerSync(_state, event);
    }
    _streamController.sink.add(Snapshot(_state, addEvent, addEventSync));

    return _state;
  }

  ///Close the stream
  void dispose() {
    isDisposed = true;
    _streamController.close();
  }

  void _updateState(T state) {
    if (isDisposed) {
      return;
    }

    _state = state;
    _streamController.sink.add(Snapshot(state, addEvent, addEventSync));
  }

  T _executeHandlerSync(T state, BlocEvent event) {
    if (_syncHandlersByEvent.containsKey(event.runtimeType)) {
      return _syncHandlersByEvent[event.runtimeType]!(state, event);
    }
    throw UnsupportedError(_unhandledErrorMessage(event));
  }

  Future<T> _executeHandler(
    T Function() getState,
    BlocEvent event,
    Function(T) updateState,
  ) {
    if (_handlersByEvent.containsKey(event.runtimeType)) {
      return _handlersByEvent[event.runtimeType]!(
        () => _state,
        event,
        updateState,
        pageScope,
      );
    }
    throw UnsupportedError(_unhandledErrorMessage(event));
  }
}

///A snapshot of the state from the stream with the ability to send events to
///the Bloc
class Snapshot<T> {
  final T state;
  final Future<T> Function(BlocEvent event) sendEvent;

  final void Function<Tb extends BlocEvent>(Tb event) sendEventSync;

  Snapshot(this.state, this.sendEvent, this.sendEventSync);
}

@immutable
class BlocEvent {
  const BlocEvent();
}

class BlocBuilder<T> {
  final T Function(Object? arguments) initialState;

  ///Sync handlers as a map by type
  final Map<Type, T Function(T, Object)> _syncHandlersByEvent = {};

  ///Async handlers as a map by type
  final Map<
      Type,
      Future<T> Function(
    T Function() state,
    Object,
    void Function(T) updateState,
    Object? pageScope,
  )> _handlersByEvent = {};

  BlocBuilder(this.initialState);

  ///Add an async event handler
  void addHandler<TEvent extends BlocEvent>(
    Future<T> Function(
      T Function() getState,
      TEvent,
      void Function(T) updateState,
      Object? pageScope,
    )
        handler,
  ) =>
      _handlersByEvent.putIfAbsent(
        TEvent,
        () => (getState, event, updateState, pageScope) =>
            handler(getState, event as TEvent, updateState, pageScope),
      );

  ///Add a sync event handler. Note: context is necessary for navigation but
  ///you should not use it unless you know what you are doing
  void addSyncHandler<TEvent extends BlocEvent>(
    T Function(T state, TEvent event) handler,
  ) =>
      _syncHandlersByEvent.putIfAbsent(
        TEvent,
        () => (s, e) => handler(s, e as TEvent),
      );

  ///Build the Bloc
  Bloc<T> build({Object? arguments, Object? pageScope}) => Bloc<T>(
        initialState(arguments),
        _handlersByEvent,
        _syncHandlersByEvent,
        pageScope: pageScope,
      );
}
