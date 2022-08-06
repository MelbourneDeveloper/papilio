import "package:flutter/material.dart";
import "package:papilio/bloc.dart";
import "package:papilio/page_args.dart";

class PageBuilder<TState> {
  PageBuilder({
    required this.builder,
    required this.blocBuilder,
    this.initialEvent,
    // ignore: avoid_annotating_with_dynamic
    bool Function(
      Route<dynamic> route,
      // ignore: avoid_annotating_with_dynamic
      dynamic result,
      PageArgs<dynamic> pageArgs,
    )?
        onPopPage,
  }) : onPopPage = onPopPage ??
            ((
              route,
              // ignore: implicit_dynamic_parameter
              result,
              pageArgs,
            ) =>
                route.didPop(result));
  final Widget Function(BuildContext context) builder;
  final BlocBuilder<TState> Function() blocBuilder;
  BlocEvent? initialEvent;

  ///This gets called when the page is popped. You can use this to clean up
  final bool Function(
    Route<dynamic> route,
    // ignore: avoid_annotating_with_dynamic
    dynamic result,
    PageArgs<dynamic> pageArgs,
  ) onPopPage;
}
