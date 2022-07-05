import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';
import 'package:papilio/papilio_router_delegate.dart';
import 'package:papilio/papilio_router_delegate_builder.dart';

class PapilioRoutingConfiguration<T> {
  PapilioRoutingConfiguration(
      {required this.buildRoutes,
      required this.currentRouteConfiguration,
      required this.parseRouteInformation,
      required this.restoreRouteInformation,
      required this.onInit,
      this.onSetNewRoutePath});

  ///Call addPage on the delegateBuilder to add a page to the router.
  final void Function(PapilioRouterDelegateBuilder<T> delegateBuilder)
      buildRoutes;

  ///Get the route configuration from the current page
  final T Function(Page currentPage) currentRouteConfiguration;

  ///Get the route configuration from the route information
  final Future<T> Function(RouteInformation routeInformation)
      parseRouteInformation;

  ///Get the route information from the route configuration
  final RouteInformation? Function(T configuration) restoreRouteInformation;

  ///Use this to navigate to the first page in the app
  void Function(PapilioRouterDelegate delegate, IocContainer container) onInit;
  Future<void> Function(PapilioRouterDelegate<T> delegate, T configuration)?
      onSetNewRoutePath;
}
