import 'package:flutter/foundation.dart';

@immutable
class BasicPageRoute {
  final ValueKey<String> pageKey;
  final String argument;

  const BasicPageRoute(this.pageKey, {String? argument})
      : argument = argument ?? '';
}
