import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/container_extensions.dart';
import 'package:papilio/papilio_route_information_parser.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_routing_configuration.dart';
import 'package:papilio/state_holder.dart';

enum PageNumber { one, two }

class PageRoute {
  final PageNumber pageNumber;

  PageRoute(this.pageNumber);
}

@immutable
class Increment extends BlocEvent {}

@immutable
class Decrement extends BlocEvent {}

void main() {
  const homePageName = '/home';
  const homeKey = ValueKey(homePageName);

  final builder = IocContainerBuilder();

  builder.addRouting(
    (container) => PapilioRoutingConfiguration<PageRoute>(
        buildRoutes: (delegate) => delegate.addPage<int>(
            container: container,
            name: homePageName,
            initialState: (arguments) => 0,
            pageBody: (context) => const MyHomePage<Increment>(
                title: "Papilio Sample - Increment"),
            buildBloc: (blocBuilder, container) => blocBuilder
                .addSyncHandler<Increment>((state, event) => state + 1)),
        currentRouteConfiguration: (page) => page.name == homePageName
            ? PageRoute(PageNumber.one)
            : PageRoute(PageNumber.two),
        parseRouteInformation: (routeInformation) async =>
            routeInformation.location == homePageName
                ? PageRoute(PageNumber.one)
                : PageRoute(PageNumber.two),
        restoreRouteInformation: (pageRoute) => RouteInformation(
            location:
                pageRoute.pageNumber == PageNumber.one ? homePageName : null),
        onInit: (delegate, container) => delegate.navigate<int>(homeKey)),
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
    final snapshot = StateHolder.of<Snapshot<int>>(context).state;

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
                snapshot.state.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: BottomNavigationBar(items: [
                  BottomNavigationBarItem(icon: Icon(Icons.add), label: "Increment"),
                  BottomNavigationBarItem(icon: Icon(Icons.remove), label: "Decrement"),
                ]),
                color: Colors.red,
                height: 100,
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
