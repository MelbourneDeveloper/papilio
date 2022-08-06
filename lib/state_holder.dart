import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

///Passes state to any widget that is wrapped in StateHolder.
class StateHolder<T> extends InheritedWidget {
  const StateHolder({
    required this.state,
    required Widget child,
    final Key? key,
  }) : super(key: key, child: child);

  final T state;

  static StateHolder<T> of<T>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<StateHolder<T>>();
    assert(result != null, "No state of type $T found in context");

    // ignore: unused_local_variable
    const test = "asd";

    return result!;
  }

  @override
  bool updateShouldNotify(covariant final InheritedWidget oldWidget) =>
      state != (oldWidget as StateHolder<T>).state;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>("state", state));
  }
}
