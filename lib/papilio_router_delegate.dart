import 'dart:async';

import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/page_args.dart';
import 'package:papilio/page_builder.dart';

import 'package:papilio/state_holder.dart';

class _Stack<E> {
  final list = <E>[];

  void push(E value) => list.add(value);

  E pop() => list.removeLast();

  E get peek => list.last;

  int get length => list.length;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

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
      PapilioRouterDelegate<T> delegate, T configuration) _setNewRoutePath;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  PapilioRouterDelegate(this._pageBuildersByKey, this._setNewRoutePath,
      this.getCurrentConfiguration)
      : navigatorKey = GlobalKey<NavigatorState>();

  void pop() {
    if (_pageStack.length < 2) {
      return;
    }

    final materialPage = _pageStack.peek;
    final pageArgs = materialPage.arguments! as PageArgs;
    final materialPageBuilder = _pageBuildersByKey[pageArgs.key.value]!;
    if (materialPageBuilder.onPop != null) {
      //TODO: Put tests around this
      final pop = materialPageBuilder.onPop!(pageArgs.pageScope);
      if (!pop) {
        return;
      }
    }

    _pageStack.pop();
    notifyListeners();
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
  T get currentConfiguration => getCurrentConfiguration(_pageStack.peek);

  List<Page<dynamic>> get pages {
    if (_pageStack.length == 0) {
      return [
        const MaterialPage(
            child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ))
      ];
    }

    return _pageStack.list.toList();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        //TODO: Put the stack of pages here
        pages: pages,
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          notifyListeners();

          return true;
        },
      );

  //TODO: put a test around this
  @override
  Future<void> setNewRoutePath(T configuration) =>
      _setNewRoutePath(this, configuration);
}
