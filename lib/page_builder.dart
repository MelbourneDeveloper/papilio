import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/page_args.dart';

class PageBuilder<TState> {
  final Widget Function(BuildContext context) builder;
  final BlocBuilder<TState> Function() blocBuilder;
  BlocEvent? initialEvent;
  // ignore: avoid_annotating_with_dynamic
  final bool Function(Route<dynamic> route, dynamic result, PageArgs pageArgs)
      onPopPage;

  PageBuilder({
    required this.builder,
    required this.blocBuilder,
    this.initialEvent,
    // ignore: avoid_annotating_with_dynamic
    bool Function(Route<dynamic> route, dynamic result, PageArgs pageArgs)?
        onPopPage,
  }) : onPopPage =
            onPopPage ?? ((route, result, pageArgs) => route.didPop(result));
}
