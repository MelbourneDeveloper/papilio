import 'dart:async';

import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/page_args.dart';
import 'package:papilio/page_builder.dart';
import 'package:papilio/papilio_route.dart';

import 'package:papilio/state_holder.dart';

class _Stack<E> {
  final list = <E>[];

  E get peek => list.last;

  int get length => list.length;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  void push(E value) => list.add(value);

  E pop() => list.removeLast();

  @override
  String toString() => list.toString();
}

class PapilioRouterDelegate<T> extends RouterDelegate<T>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<T> {
  final T Function(Page currentPage) getCurrentConfiguration;

  final _Stack<MaterialPage> _pageStack = _Stack<MaterialPage>();

  final Map<String, PageBuilder> _pageBuildersByKey;

  final Future<void> Function(
    PapilioRouterDelegate<T> delegate,
    T configuration,
  ) _setNewRoutePath;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  PapilioRouterDelegate(
    this._pageBuildersByKey,
    this._setNewRoutePath,
    this.getCurrentConfiguration,
  ) : navigatorKey = GlobalKey<NavigatorState>();

  ///Pops the current page from the stack and returns the result of the pop.
  ///The page's onPopPage callback will fire when this happens.
  bool pop({
    Route? route,
    // ignore: avoid_annotating_with_dynamic
    dynamic result,
    PageArgs? pageArgs,
    PageBuilder? pageBuilder,
  }) {
    if (_pageStack.length < 2) {
      return false;
    }

    var pop = false;

    if (route == null) {
      final materialPage = _pageStack.peek;
      final pageArgsFromStack = materialPage.arguments! as PageArgs;
      final pageBuilderFromStack =
          _pageBuildersByKey[pageArgsFromStack.key.value];
      pop = pageBuilderFromStack!.onPopPage(
          PapilioRoute(
              settings:
                  RouteSettings(name: materialPage.name, arguments: pageArgs)),
          null,
          pageArgsFromStack);
    } else {
      pop = pageBuilder!.onPopPage(route, result, pageArgs!);
    }

    if (!pop) {
      return false;
    }

    _pageStack.pop();
    notifyListeners();

    return true;
  }

  void navigate<TState>(ValueKey<String> key,
      {Object? arguments, Object? pageScope}) {
    final materialPageBuilder = _pageBuildersByKey[key.value]!;

    var isInitialized = false;

    final bloc = materialPageBuilder
        .blocBuilder()
        .build(arguments: arguments, pageScope: pageScope) as Bloc<TState>;

    _pageStack.push(MaterialPage(
        arguments: PageArgs(key, pageScope, arguments),
        name: key.value,
        child: StreamBuilder<Snapshot<TState>>(
            stream: bloc.stream,
            initialData: Snapshot<TState>(
                bloc.initialState, bloc.addEvent, bloc.addEventSync),
            builder: (context, asyncSnapshot) {
              //We put the initial event on the post frame callback
              //because otherwise it may execute before the StreamBuilder
              //starts listening to events
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!isInitialized &&
                    materialPageBuilder.initialEvent != null) {
                  isInitialized = true;

                  await bloc.addEvent(materialPageBuilder.initialEvent!);
                }
              });

              return StateHolder<Snapshot<TState>>(
                  state: asyncSnapshot.data!,
                  child: materialPageBuilder.builder(context));
            })));

    notifyListeners();
  }

  @override
  T get currentConfiguration => _pageStack.isNotEmpty
      ? getCurrentConfiguration(_pageStack.peek)
      : throw Exception(
          "There are currently no pages. This probably happened because you "
          "didn't navigate to a page onInit. "
          "Call delegate.navigate in the body "
          "of onInit in PapilioRoutingConfiguration");

  List<Page<dynamic>> get pages => _pageStack.list.toList();

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, result) {
          final materialPage = route.settings;
          final pageArgs = materialPage.arguments! as PageArgs;
          final materialPageBuilder = _pageBuildersByKey[pageArgs.key.value]!;

          return pop(
              route: route,
              result: result,
              pageArgs: pageArgs,
              pageBuilder: materialPageBuilder);
        },
      );

  //TODO: put a test around this
  @override
  Future<void> setNewRoutePath(T configuration) =>
      _setNewRoutePath(this, configuration);
}
