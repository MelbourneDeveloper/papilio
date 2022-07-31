import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/page_args.dart';

class PageBuilder<TState> {
  final Widget Function(BuildContext context) builder;
  final BlocBuilder<TState> Function() blocBuilder;
  BlocEvent? initialEvent;

  final bool Function(
    Route<dynamic> route,
    // ignore: avoid_annotating_with_dynamic
    dynamic result,
    PageArgs<TState> pageArgs,
  ) onPopPage;

  PageBuilder({
    required this.builder,
    required this.blocBuilder,
    this.initialEvent,
    // ignore: avoid_annotating_with_dynamic
    bool Function(
      Route<dynamic> route,
      // ignore: avoid_annotating_with_dynamic
      dynamic result,
      PageArgs<TState> pageArgs,
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
}
