import 'package:flutter/material.dart';

///Passes state to any widget that is wrapped in StateHolder.
class StateHolder<T> extends InheritedWidget {
  const StateHolder({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final T state;

  static StateHolder<T> of<T>(BuildContext context) {
    final StateHolder<T>? result =
        context.dependOnInheritedWidgetOfExactType<StateHolder<T>>();
    assert(result != null, 'No state of type $T found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      state != (oldWidget as StateHolder<T>).state;
}
