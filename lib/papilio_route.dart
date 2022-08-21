library papilio;



import 'package:flutter/material.dart';

///Simple implementation of [Route] purely to provide info about the
///current route
class PapilioRoute<T> extends Route<T> {
  ///Instantiates a [PapilioRoute] by [RouteSettings]
  PapilioRoute({RouteSettings? settings}) : super(settings: settings);
}
