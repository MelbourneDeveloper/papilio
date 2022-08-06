import "package:flutter/material.dart";

class PapilioRouteInformationParser<T> extends RouteInformationParser<T> {
  PapilioRouteInformationParser(
    this._parseRouteInformation,
    this._restoreRouteInformation,
  );
  final Future<T> Function(RouteInformation routeInformation)
      _parseRouteInformation;

  final RouteInformation? Function(T configuration) _restoreRouteInformation;

  @override
  Future<T> parseRouteInformation(RouteInformation routeInformation) =>
      _parseRouteInformation(routeInformation);

  @override
  RouteInformation? restoreRouteInformation(T configuration) =>
      _restoreRouteInformation(configuration);
}
