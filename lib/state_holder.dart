import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///Passes state to any widget that is wrapped in StateHolder.
class StateHolder<T> extends InheritedWidget {
  ///Constructs a new [StateHolder]. This isn's something you need to construct
  const StateHolder({
    required this.state,
    required Widget child,
    final Key? key,
  }) : super(key: key, child: child);

  ///The current state
  final T state;

  ///Gets the current state from the [BuildContext]
  static StateHolder<T> of<T>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<StateHolder<T>>();
    assert(result != null, 'No state of type $T found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(covariant final InheritedWidget oldWidget) =>
      state != (oldWidget as StateHolder<T>).state;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('state', state));
  }
}
