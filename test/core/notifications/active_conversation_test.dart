import 'package:chat_app/core/notifications/active_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ActiveConversation active;

  setUp(() => active = ActiveConversation());

  test('nothing is active initially', () {
    expect(active.isActive('c1'), isFalse);
  });

  test('tracks the conversation on screen', () {
    active.enter('c1');

    expect(active.isActive('c1'), isTrue);
    expect(active.isActive('c2'), isFalse);
  });

  test('leaving clears it', () {
    active
      ..enter('c1')
      ..leave('c1');

    expect(active.isActive('c1'), isFalse);
  });

  test('a stale leave does not clear the newer conversation', () {
    // Push c2 over c1, then c1 disposes late; c2 must stay active.
    active
      ..enter('c1')
      ..enter('c2')
      ..leave('c1');

    expect(active.isActive('c2'), isTrue);
  });
}
