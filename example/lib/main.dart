import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/bloc.dart';
import 'package:papilio/container_extensions.dart';
import 'package:papilio/papilio_route_information_parser.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_routing_configuration.dart';

enum PageNumber { one, two }

class PageRoute {
  final PageNumber pageNumber;

  PageRoute(this.pageNumber);
}

@immutable
class Increment extends BlocEvent {}

void main() {
  const homeKey = ValueKey('/home');

  final builder = IocContainerBuilder();

  builder.addRouting(
    (container) => PapilioRoutingConfiguration<PageRoute>(
        buildRoutes: (delegate) => delegate.addPage<int>(
            container: container,
            name: '/home',
            initialState: (arguments) => 0,
            pageBody: (context) => const MyHomePage(title: "Papilio Sample"),
            buildBloc: (blocBuilder, container) => blocBuilder
                .addSyncHandler<Increment>((state, event) => state++)),
        currentRouteConfiguration: (page) => page.name == '/home'
            ? PageRoute(PageNumber.one)
            : PageRoute(PageNumber.two),
        parseRouteInformation: (routeInformation) async =>
            routeInformation.location == '/home'
                ? PageRoute(PageNumber.one)
                : PageRoute(PageNumber.two),
        restoreRouteInformation: (pageRoute) => RouteInformation(
            location: pageRoute.pageNumber == PageNumber.one ? "/home" : null),
        onInit: (delegate, container) => delegate.navigate(homeKey)),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
