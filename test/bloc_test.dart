import 'package:flutter_test/flutter_test.dart';

import 'package:papilio/bloc.dart';

class DummyEvent extends BlocEvent {}

void main() {
  test('Test Bloc', () async {
    final bloc = Bloc<String>("asd", {}, {});
    expect(() => bloc.addEvent(DummyEvent()), throwsA(isA<UnsupportedError>()));
    expect(() => bloc.addEventSync(DummyEvent()),
        throwsA(isA<UnsupportedError>()),);
  });
}
