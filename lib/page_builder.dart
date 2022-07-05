import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';


class PageBuilder<TState> {
  final Widget Function(BuildContext context) builder;
  final BlocBuilder<TState> Function() blocBuilder;
  BlocEvent? initialEvent;
  bool Function(Object? pageScope)? onPop;

  PageBuilder(
      {required this.builder,
      required this.blocBuilder,
      this.initialEvent,
      this.onPop});
}
