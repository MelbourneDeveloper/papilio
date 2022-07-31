import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/page_args.dart';
import 'package:papilio/page_builder.dart';
import 'package:papilio/papilio_router_delegate.dart';

class PapilioRouterDelegateBuilder<T> {
  final T Function(Page currentPage) getCurrentConfiguration;
  final Map<String, PageBuilder> _pages = {};
  PapilioRouterDelegateBuilder(this.getCurrentConfiguration);

  void _addPage<TBLoc>(String name, PageBuilder<TBLoc> pageBuilder) =>
      _pages.putIfAbsent(name, () => pageBuilder);

  ///Add a page for routing. [initialEvent] allows you to send an event to the
  ///Bloc when the page first loads. Use onPop to cancel pops or clean up
  ///the pageScope. Use the blocBuilder to add async and sync bloc handlers to
  ///deal with UI changes
  //ignore: long-parameter-list 
  void addPage<TBloc>({
    required IocContainer container,
    required String name,
    required TBloc Function(Object? arguments) initialState,
    required Widget Function(BuildContext context) pageBody,
    required void Function(
      BlocBuilder<TBloc> blocBuilder,
      IocContainer container,
    )
        buildBloc,
    final bool Function(
      Route<dynamic> route,
      // ignore: avoid_annotating_with_dynamic
      dynamic result,
      PageArgs pageArgs,
    )?
        onPopPage,
    BlocEvent? initialEvent,
  }) {
    _addPage(
      name,
      PageBuilder(
        initialEvent: initialEvent,
        builder: pageBody,
        onPopPage: onPopPage,
        blocBuilder: () {
          final blocBuilder = BlocBuilder<TBloc>(initialState);
          buildBloc(blocBuilder, container);
          
          return blocBuilder;
        },
      ),
    );
  }

  PapilioRouterDelegate<T> build(
    Future<void> Function(
      PapilioRouterDelegate<T> delegate,
      T configuration,
    )
        setNewRoutePath,
  ) =>
      PapilioRouterDelegate<T>(
        _pages,
        setNewRoutePath,
        getCurrentConfiguration,
      );
}
