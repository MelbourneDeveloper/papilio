import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/container_extensions.dart';
import 'package:papilio/papilio_route_information_parser.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_routing_configuration.dart';
import 'package:papilio/state_holder.dart';

enum Page { increment, decrement }

@immutable
class PageRoute {
  final Page page;

  const PageRoute(this.page);
}

@immutable
class PageState {
  final int counter;
  final int currentIndex;

  const PageState(this.counter, this.currentIndex);

  PageState copyWith({int? counter}) =>
      PageState(counter ?? this.counter, currentIndex);
}

@immutable
class Increment extends BlocEvent {}

@immutable
class Decrement extends BlocEvent {}

@immutable
class NavigateToIndex extends BlocEvent {
  final int index;
  NavigateToIndex(this.index);
}

void main() {
  const incrementName = '/increment';
  const incrementKey = ValueKey(incrementName);
  const decrementName = '/decrement';
  const decrementKey = ValueKey(decrementName);

  final builder = IocContainerBuilder();

  builder.addRouting(
    (container) => PapilioRoutingConfiguration<PageRoute>(
        buildRoutes: (delegateBuilder) => delegateBuilder
          ..addPage<PageState>(
              container: container,
              name: incrementName,
              initialState: (arguments) => const PageState(0, 0),
              pageBody: (context) => const MyHomePage<Increment>(
                  title: "Papilio Sample - Increment"),
              buildBloc: (blocBuilder, container) => blocBuilder
                ..addSyncHandler<Increment>((state, event) =>
                    state.copyWith(counter: state.counter + 1))
                ..addSyncHandler<NavigateToIndex>((state, event) {
                  if (event.index == 0) {
                    state;
                  }
                  container.navigate<PageState, PageRoute>(decrementKey);
                  return state;
                }))
          ..addPage<PageState>(
              container: container,
              name: decrementName,
              initialState: (arguments) => const PageState(10, 1),
              pageBody: (context) => const MyHomePage<Decrement>(
                  title: "Papilio Sample - Decrement"),
              buildBloc: (blocBuilder, container) => blocBuilder
                ..addSyncHandler<Decrement>((state, event) =>
                    state.copyWith(counter: state.counter - 1))
                ..addSyncHandler<NavigateToIndex>((state, event) {
                  if (event.index == 1) {
                    state;
                  }
                  container.navigate<PageState, PageRoute>(incrementKey);
                  return state;
                })),
        currentRouteConfiguration: (page) => page.name == incrementName
            ? const PageRoute(Page.increment)
            : const PageRoute(Page.decrement),
        parseRouteInformation: (routeInformation) async =>
            routeInformation.location == incrementName
                ? const PageRoute(Page.increment)
                : const PageRoute(Page.decrement),
        restoreRouteInformation: (pageRoute) => RouteInformation(
            location: pageRoute.page == Page.increment
                ? incrementName
                : decrementName),
        onInit: (delegate, container) =>
            delegate.navigate<PageState>(incrementKey)),
  );

  final container = builder.toContainer();
  runApp(MyApp(container));
}

class MyApp extends StatelessWidget {
  final IocContainer container;

  MyApp(this.container, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: container.get<PapilioRouterDelegate<PageRoute>>(),
      routeInformationParser:
          container.get<PapilioRouteInformationParser<PageRoute>>(),
    );
  }
}

class MyHomePage<T extends BlocEvent> extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final snapshot = StateHolder.of<Snapshot<PageState>>(context).state;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Stack(children: [
          Align(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                snapshot.state.counter.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                width: double.infinity,
                child: BottomNavigationBar(
                    currentIndex: snapshot.state.currentIndex,
                    onTap: (index) =>
                        snapshot.sendEventSync(NavigateToIndex(index)),
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.add), label: "Increment"),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.remove), label: "Decrement"),
                    ]),
              ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            snapshot.sendEventSync(T == Increment ? Increment() : Decrement()),
        tooltip: T == Increment ? 'Increment' : 'Decrement',
        child: Icon(T == Increment ? Icons.add : Icons.remove),
      ),
    );
  }
}
