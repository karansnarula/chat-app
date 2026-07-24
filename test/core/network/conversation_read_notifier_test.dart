import 'package:chat_app/core/network/conversation_read_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifyRead emits on the onRead stream', () {
    final notifier = ConversationReadNotifier();

    expect(notifier.onRead, emits(anything));

    notifier.notifyRead();
  });

  test('supports multiple listeners', () {
    final notifier = ConversationReadNotifier();

    expect(notifier.onRead, emits(anything));
    expect(notifier.onRead, emits(anything));

    notifier.notifyRead();
  });
}
