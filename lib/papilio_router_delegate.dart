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

///Paplilio router delegate. This is the main class that you pass to the
///[MaterialApp] to use papilio routing.
class PapilioRouterDelegate<T> extends RouterDelegate<T>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<T> {
  ///Constructs a new router delegate. You should use
  ///PapilioRouterDelegateBuilder
  PapilioRouterDelegate(
    this._pageBuildersByKey,
    this._setNewRoutePath,
    this._getCurrentConfiguration,
  ) : navigatorKey = GlobalKey<NavigatorState>();
  final T Function(Page<dynamic> currentPage) _getCurrentConfiguration;

  final _Stack<MaterialPage<dynamic>> _pageStack =
      _Stack<MaterialPage<dynamic>>();

  final Map<String, PageBuilder<dynamic>> _pageBuildersByKey;

  ///Called by the [Router] when the [Router.routeInformationProvider] reports
  ///that a new route has been pushed to the application
  ///by the operating system.
  ///See [RouterDelegate] for more information.
  final Future<void> Function(
    PapilioRouterDelegate<T> delegate,
    T configuration,
  ) _setNewRoutePath;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  T get currentConfiguration => _pageStack.isNotEmpty
      ? _getCurrentConfiguration(_pageStack.peek)
      : throw Exception(
          'There are currently no pages. This probably happened because you '
          "didn't navigate to a page onInit. "
          'Call delegate.navigate in the body '
          'of onInit in PapilioRoutingConfiguration',
        );

  // ignore: public_member_api_docs
  List<Page<dynamic>> get pages => _pageStack.list.toList();

  ///Pops the current page from the stack and returns the result of the pop.
  ///The page's onPopPage callback will fire when this happens.
  bool pop({
    final Route<dynamic>? route,
    // ignore: avoid_annotating_with_dynamic
    dynamic result,
    PageArgs<dynamic>? pageArgs,
    PageBuilder<dynamic>? pageBuilder,
  }) {
    //TODO: This method is pretty filthy. Clean it up.

    if (_pageStack.length < 2) {
      return false;
    }

    var pop = false;

    if (route == null) {
      pop = _popNullRoute(pageArgs);
    } else {
      pop = pageBuilder!.onPopPage(route, result, pageArgs!);
      if (pop) {
        pageArgs.bloc.dispose();
      }
    }

    if (!pop) {
      return false;
    }

    //TODO: Log the popped page
    //ignore: avoid-ignoring-return-values
    _pageStack.pop();

    notifyListeners();

    return pop;
  }

  bool _popNullRoute(PageArgs<dynamic>? pageArgs) {
    final materialPage = _pageStack.peek;
    final pageArgsFromStack = materialPage.arguments! as PageArgs;
    final pageBuilderFromStack =
        _pageBuildersByKey[pageArgsFromStack.key.value];
    final pop = pageBuilderFromStack!.onPopPage(
      PapilioRoute<T>(
        settings: RouteSettings(name: materialPage.name, arguments: pageArgs),
      ),
      null,
      pageArgsFromStack,
    );

    if (pop) {
      pageArgsFromStack.bloc.dispose();
    }

    return pop;
  }

  ///Pushes a new page onto the stack and navigates to it. You must specify a
  ///the type of state so the [StateHolder] knows what to pass in.
  void navigate<TState>(
    ValueKey<String> key, {
    Object? arguments,
    Object? pageScope,
  }) {
    assert(
      TState != dynamic,
      'You must specify a type argument for navigate. navigate passes the '
      'type argument to inherited widgets so the StateHolder '
      'can retrieve the state',
    );

    final materialPageBuilder = _pageBuildersByKey[key.value]!;

    var isInitialized = false;

    final bloc = materialPageBuilder
        .blocBuilder()
        .build(arguments: arguments, pageScope: pageScope) as Bloc<TState>;

    _pageStack.push(
      MaterialPage<TState>(
        arguments: PageArgs<TState>(key, pageScope, arguments, bloc),
        name: key.value,
        child: StreamBuilder<Snapshot<TState>>(
          stream: bloc.stream,
          initialData: Snapshot<TState>(
            bloc.initialState,
            bloc.addEvent,
            bloc.addEventSync,
          ),
          builder: (context, final asyncSnapshot) {
            //We put the initial event on the post frame callback
            //because otherwise it may execute before the StreamBuilder
            //starts listening to events
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!isInitialized && materialPageBuilder.initialEvent != null) {
                isInitialized = true;

                await bloc.addEvent(materialPageBuilder.initialEvent!);
              }
            });

            return StateHolder<Snapshot<TState>>(
              state: asyncSnapshot.data!,
              child: materialPageBuilder.builder(context),
            );
          },
        ),
      ),
    );

    notifyListeners();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (
          final route,
          //ignore: implicit_dynamic_parameter
          final result,
        ) {
          final materialPage = route.settings;
          final pageArgs = materialPage.arguments! as PageArgs;
          final materialPageBuilder = _pageBuildersByKey[pageArgs.key.value]!;

          return pop(
            route: route,
            result: result,
            pageArgs: pageArgs,
            pageBuilder: materialPageBuilder,
          );
        },
      );

  //TODO: put a test around this
  @override
  Future<void> setNewRoutePath(T configuration) =>
      _setNewRoutePath(this, configuration);
}
