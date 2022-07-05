import 'package:flutter/material.dart';

class PageArgs {
  final ValueKey<String> key;
  final Object? pageScope;
  final Object? arguments;

  PageArgs(this.key, this.pageScope, this.arguments);
}