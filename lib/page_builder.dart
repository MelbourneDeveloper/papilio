import 'package:flutter/material.dart';
import 'package:papilio/page_args.dart';
import 'package:papilio_bloc/bloc.dart';

///Builds a page route that will mint pages when the user
///navigates to them
class PageBuilder<TState> {
  ///Constructs a new page builder
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

  ///Builds the page
  final Widget Function(BuildContext context) builder;

  ///Returns a [BlocBuilder] for the page
  final BlocBuilder<TState> Function() blocBuilder;

  ///The event to send to the Bloc when the page first loads
  BlocEvent? initialEvent;

  ///This gets called when the page is popped. You can use this to clean up
  final bool Function(
    Route<dynamic> route,
    // ignore: avoid_annotating_with_dynamic
    dynamic result,
    PageArgs<dynamic> pageArgs,
  ) onPopPage;
}
