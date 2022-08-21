import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/papilio_route_information_parser.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_router_delegate_builder.dart';
import 'package:papilio/papilio_routing_configuration.dart';

///Use the extensions to add Papilio routing with the [IocContainerBuilder]
extension ContainerBuilderExtensions on IocContainerBuilder {
  ///Adds a [PapilioRouterDelegate] to the [IocContainer] so that you can use it
  ///in your [MaterialApp]. This is the main method for wiring up your Papilio
  ///app
  void addRouting<T>(
    PapilioRoutingConfiguration<T> Function(IocContainer container)
        getRoutingFunctions,
  ) {
    addSingleton(getRoutingFunctions);

    _addDelegate<T>();

    addSingleton((container) {
      final routingFunctions = container.get<PapilioRoutingConfiguration<T>>();

      return PapilioRouteInformationParser<T>(
        routingFunctions.parseRouteInformation,
        routingFunctions.restoreRouteInformation,
      );
    });
  }

  void _addDelegate<T>() => addSingleton((container) {
        final routingFunctions =
            container.get<PapilioRoutingConfiguration<T>>();
        final delegateBuilder = PapilioRouterDelegateBuilder<T>(
          routingFunctions.currentRouteConfiguration,
        );
        routingFunctions.buildRoutes(delegateBuilder);

        final delegate = delegateBuilder.build(
          routingFunctions.onSetNewRoutePath ?? (d, t) => Future.value(),
        );
        routingFunctions.onInit(delegate, container);

        return delegate;
      });
}

///Use these extensions to navigate using the [IocContainer] with papilio
extension ContainerExtensions on IocContainer {
  ///Navigates to a new page. Specify the page key, type of your state, and type
  /// argument for your router delegate
  void navigate<T, T2>(
    ValueKey<String> key, {
    Object? arguments,
    Object? pageScope,
  }) =>
      get<PapilioRouterDelegate<T2>>()
          .navigate<T>(key, arguments: arguments, pageScope: pageScope);
}
