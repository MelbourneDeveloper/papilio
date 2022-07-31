import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/basic_page_route.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/container_extensions.dart';
import 'package:papilio/papilio_route_information_parser.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_routing_configuration.dart';
import 'package:papilio/state_holder.dart';



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

  //We use an Ioc Container to store the RouterDelegate, RouteInformationParser
  //Blocs, state and other services
  final builder = IocContainerBuilder();

  //This is the main method for adding papilio routing to your app.
  builder.addRouting(
    (container) => PapilioRoutingConfiguration<BasicPageRoute>(
        buildRoutes: (delegateBuilder) => delegateBuilder
          //We add the Increment page here
          ..addPage<PageState>(
              container: container,
              name: incrementName,
              initialState: (arguments) => const PageState(0, 0),
              //The page body is always a stateless widget
              pageBody: (context) => const MyHomePage<Increment>(
                  title: "Papilio Sample - Increment"),
              //This is how we define the business logic with Bloc.
              //We add handlers for the Navigate, Increment and Decrement
              //events.
              buildBloc: (blocBuilder, container) => blocBuilder
                ..addSyncHandler<Increment>((state, event) =>
                    //We use non-destructive mutation (copyWith) to increment
                    state.copyWith(counter: state.counter + 1))
                ..addSyncHandler<NavigateToIndex>((state, event) {
                  if (event.index == 0) {
                    return state;
                  }
                  container.navigate<PageState, BasicPageRoute>(decrementKey);
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
                    return state;
                  }
                  container.navigate<PageState, BasicPageRoute>(incrementKey);
                  return state;
                })),
        //This is plumbing for browsers etc. The next version of papilio will
        //have a basic page route that doesn't require this.
        currentRouteConfiguration: (page) => page.name == incrementName
            ? const BasicPageRoute(incrementKey)
            : const BasicPageRoute(decrementKey),
        parseRouteInformation: (routeInformation) async =>
            routeInformation.location == incrementName
                ? const BasicPageRoute(incrementKey)
                : const BasicPageRoute(decrementKey),
        restoreRouteInformation: (pageRoute) => RouteInformation(
            location: pageRoute.pageKey == incrementKey
                ? incrementName
                : decrementName),
        onSetNewRoutePath: (delegate, route) async =>
            route.pageKey == incrementKey
                ? delegate.navigate<PageState>(incrementKey)
                : delegate.navigate<PageState>(decrementKey),
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
      routerDelegate: container.get<PapilioRouterDelegate<BasicPageRoute>>(),
      routeInformationParser:
          container.get<PapilioRouteInformationParser<BasicPageRoute>>(),
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
              child: SizedBox(
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
