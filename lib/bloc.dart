import "dart:async";

import "package:meta/meta.dart";

///Resend the current state to trigger a rebuild. This is the
///equivalent of setState
@immutable
class RebuildEvent extends BlocEvent {}

///Business Logic Component
class Bloc<T> {
  ///You can construct a Bloc here, but you're probably better off using a
  ///BlocBuilder
  Bloc(
    this.initialState,
    this._handlersByEvent,
    this._syncHandlersByEvent, {
    this.pageScope,
  }) : _state = initialState;
  bool _isDisposed = false;

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

  String _unhandledErrorMessage(BlocEvent event) =>
      "There is no handler for the type ${event.runtimeType}";

  ///The stream of state updates. Listen to this with a StreamBuilder<T>
  Stream<Snapshot<T>> get stream => _streamController.stream;

  ///Send an async event to the bloc
  Future<void> addEvent(BlocEvent event) async {
    if (_isDisposed) {
      return;
    }
    _state = await _executeHandler(() => _state, event, _updateState);
    _streamController.sink.add(Snapshot(_state, addEvent, addEventSync));

    return;
  }

  ///Send a synchronous event to the bloc
  T addEventSync<Tb extends BlocEvent>(Tb event) {
    if (_isDisposed) {
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
    _isDisposed = true;
    // TODO(): Perhaps we should do something with the return result here?
    //ignore: avoid-ignoring-return-values
    _streamController.close();
  }

  void _updateState(T state) {
    if (_isDisposed) {
      return;
    }

    _state = state;
    _streamController.sink.add(Snapshot<T>(state, addEvent, addEventSync));
  }

  T _executeHandlerSync(T state, final BlocEvent event) {
    if (_syncHandlersByEvent.containsKey(event.runtimeType)) {
      return _syncHandlersByEvent[event.runtimeType]!(state, event);
    }
    throw UnsupportedError(_unhandledErrorMessage(event));
  }

  Future<T> _executeHandler(
    T Function() getState,
    BlocEvent event,
    void Function(T) updateState,
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
  ///Creates a snapshot
  Snapshot(this.state, this.sendEvent, this.sendEventSync);

  ///The current state of the bloc
  final T state;

  ///Send an async event to the bloc
  final Future<void> Function(BlocEvent event) sendEvent;

  ///Send a synchronous event to the bloc
  final void Function<Tb extends BlocEvent>(Tb event) sendEventSync;
}

@immutable

///An event that can be sent to the bloc
abstract class BlocEvent {
  ///The base class for all events
  const BlocEvent();
}

@immutable

///Builds Blocs. You should use this instead of constructing a Bloc directly
///Use [addHandler] to handle async events and [addSyncHandler] to handle
///synchronous events
class BlocBuilder<T> {
  ///Creates a BlocBuilder with an initial state
  BlocBuilder(this.initialState);

  ///The state of the Bloc upon initialization
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

  ///Add an async Bloc event handler.
  ///getState gets the current Bloc state. Because this function is async, the
  ///the state may change between async calls.
  ///The event is the event that was sent to the Bloc.
  ///updateState is a function that updates the Bloc state. Call this to
  ///set state on things like progress indicators in a long running process.
  ///pageScope is an optional object that can be used for the lifetime of the
  ///page.
  void addHandler<TEvent extends BlocEvent>(
    Future<T> Function(
      T Function() getState,
      TEvent event,
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

  ///Add a sync event handler.
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
