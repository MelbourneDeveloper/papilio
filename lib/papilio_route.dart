import 'package:flutter/material.dart';

///Simple implementation of [Route] purely to provide info about the
///current route
class PapilioRoute<T> extends Route<T> {
  PapilioRoute({RouteSettings? settings}) : super(settings: settings);
}
