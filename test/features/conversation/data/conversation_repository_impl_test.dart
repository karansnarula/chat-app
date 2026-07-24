import 'package:chat_app/core/network/conversation_read_notifier.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/features/conversation/data/datasources/messages_api.dart';
import 'package:chat_app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesApi extends Mock implements MessagesApi {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockSocketService extends Mock implements SocketService {}

void main() {
  late MockMessagesApi api;
  late ConversationReadNotifier readNotifier;
  late ConversationRepositoryImpl repository;

  setUp(() {
    api = MockMessagesApi();
    readNotifier = ConversationReadNotifier();
    repository = ConversationRepositoryImpl(
      api,
      MockTokenStorage(),
      MockSocketService(),
      readNotifier,
    );
  });

  test('marking read notifies so the chats list can refresh', () async {
    when(() => api.markAsRead('c1')).thenAnswer((_) async {});

    expect(readNotifier.onRead, emits(anything));

    await repository.markAsRead('c1');
  });

  test('a failed mark-read does not notify', () async {
    when(() => api.markAsRead('c1')).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );

    var notified = false;
    readNotifier.onRead.listen((_) => notified = true);

    await repository.markAsRead('c1');
    await Future<void>.delayed(Duration.zero);

    expect(notified, isFalse);
  });
}
