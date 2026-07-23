import 'package:chat_app/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late ConnectivityService service;

  setUp(() {
    connectivity = MockConnectivity();
    service = ConnectivityService(connectivity);
  });

  test('reports online when any interface is connected', () async {
    when(connectivity.checkConnectivity)
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    expect(await service.isOnline, isTrue);
  });

  test('reports offline when there is no interface', () async {
    when(connectivity.checkConnectivity)
        .thenAnswer((_) async => [ConnectivityResult.none]);

    expect(await service.isOnline, isFalse);
  });

  test('reports offline for an empty result', () async {
    when(connectivity.checkConnectivity).thenAnswer((_) async => []);

    expect(await service.isOnline, isFalse);
  });

  test('maps connectivity changes to online state', () {
    when(() => connectivity.onConnectivityChanged).thenAnswer(
      (_) => Stream.fromIterable([
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
      ]),
    );

    expect(service.onConnectivityChanged, emitsInOrder([false, true]));
  });
}
