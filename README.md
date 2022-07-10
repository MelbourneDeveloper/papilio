# Papilio

Build beautiful apps with Flutter

Check out the live sample app [Papilio Note](https://www.papilionote.com) in the browser. All source code is available for the sample app [here](https://github.com/MelbourneDeveloper/papilio_note). Or, check out this package's simple example app [here](https://melbournedeveloper.github.io/papilio). Notice that both samples fully integrate with browser navigation.

<img width="40%" height="40%" alt="Papilio Note" src="https://user-images.githubusercontent.com/16697547/178098531-0c0efbb2-8f57-414a-8512-4f1564f97ef8.png">

### Declaritive Framework for Flutter
Compose your app with ease and leave the plumbing up to the framework

### Separation of Concerns
Separate your app's logic from its presentation

### BloC Approach to State Management
Send events to the business logic component and let the framework handle UI changes from the stream

### Compose Your Dependencies
Access you dependencies with dependency injection when you need them in the app. papilio uses the [ioc_container](https://pub.dev/packages/ioc_container) package

### Declarative Approach to Navigation
Specify page names and `StatelessWidget`s to seamlessly transition between pages. Respond to navigation from BloC handlers instead of UI callbacks

You can compose your app like this. It's nice.

```dart
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
                    return state;
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
                    return state;
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
        onSetNewRoutePath: (delegate, route) async =>
            route.page == Page.increment
                ? delegate.navigate<PageState>(incrementKey)
                : delegate.navigate<PageState>(decrementKey),
        onInit: (delegate, container) =>
            delegate.navigate<PageState>(incrementKey)),
  );

  final container = builder.toContainer();
  runApp(MyApp(container));
}
```