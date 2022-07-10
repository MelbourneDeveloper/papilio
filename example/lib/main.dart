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
  final Key selectedRoute;

  const PageState(this.counter, this.selectedRoute);

  PageState copyWith({int? counter}) =>
      PageState(counter ?? this.counter, selectedRoute);
}

@immutable
class Increment extends BlocEvent {}

@immutable
class Decrement extends BlocEvent {}

@immutable
class NavigateToIncrement extends BlocEvent {}

@immutable
class NavigateToDecrement extends BlocEvent {}

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
              initialState: (arguments) => const PageState(0, incrementKey),
              pageBody: (context) => const MyHomePage<Increment>(
                  title: "Papilio Sample - Increment"),
              buildBloc: (blocBuilder, container) =>
                  blocBuilder.addSyncHandler<Increment>((state, event) =>
                      state.copyWith(counter: state.counter + 1)))
          ..addPage<PageState>(
              container: container,
              name: decrementName,
              initialState: (arguments) => const PageState(0, decrementKey),
              pageBody: (context) => const MyHomePage<Decrement>(
                  title: "Papilio Sample - Decrement"),
              buildBloc: (blocBuilder, container) =>
                  blocBuilder.addSyncHandler<Increment>((state, event) =>
                      state.copyWith(counter: state.counter - 1))),
        currentRouteConfiguration: (page) => page.name == incrementName
            ? PageRoute(Page.increment)
            : PageRoute(Page.decrement),
        parseRouteInformation: (routeInformation) async =>
            routeInformation.location == incrementName
                ? PageRoute(Page.increment)
                : PageRoute(Page.decrement),
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
                child: BottomNavigationBar(items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add), label: "Increment"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.remove), label: "Decrement"),
                ]),
                height: 80,
                width: double.infinity,
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
