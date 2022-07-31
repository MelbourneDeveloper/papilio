import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';

class PageArgs<TBloc> {
  final ValueKey<String> key;
  final Object? pageScope;
  final Object? arguments;

  ///No need to access this. We only keep a reference to this so we can
  ///dispose it on pop
  final Bloc<TBloc> bloc;

  PageArgs(this.key, this.pageScope, this.arguments, this.bloc);
}
