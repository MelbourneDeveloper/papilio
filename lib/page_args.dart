import 'package:flutter/material.dart';
import 'package:papilio/bloc.dart';

///Holds details about the page for the route
class PageArgs<TBloc> {

  ///Instantiates a new pageArgs
  PageArgs(this.key, this.pageScope, this.arguments, this.bloc);
  
  ///The key of the page
  final ValueKey<String> key;

  ///The scope of the page. Store mutable state here that you need to dispose on
  ///pop. Prefer immutable state, and prefer not using a scope if you don't need
  /// to.
  final Object? pageScope;

  ///The startup arguments for the page
  final Object? arguments;

  ///No need to access this. We only keep a reference to this so we can
  ///dispose it on pop
  final Bloc<TBloc> bloc;
}
