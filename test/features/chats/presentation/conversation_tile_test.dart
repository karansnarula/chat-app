import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/chats/domain/entities/conversation.dart';
import 'package:chat_app/features/chats/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Conversation buildConversation({
  int unreadCount = 0,
  LastMessage? lastMessage,
  String displayName = 'Alice',
}) =>
    Conversation(
      id: 'c1',
      otherUser: ConversationUser(
        id: 'u2',
        displayName: displayName,
        email: 'alice@test.com',
      ),
      unreadCount: unreadCount,
      lastMessage: lastMessage,
    );

Widget wrap(Conversation conversation, {VoidCallback? onTap}) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ConversationTile(
          conversation: conversation,
          onTap: onTap ?? () {},
        ),
      ),
    );

void main() {
  testWidgets('shows name, avatar initial, and last message', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildConversation(
          lastMessage: LastMessage(
            id: 'm1',
            content: 'See you tomorrow',
            senderId: 'u2',
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('See you tomorrow'), findsOneWidget);
  });

  testWidgets('falls back to placeholder when there are no messages',
      (tester) async {
    await tester.pumpWidget(wrap(buildConversation()));

    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('shows the unread badge only when there are unread messages',
      (tester) async {
    await tester.pumpWidget(wrap(buildConversation(unreadCount: 4)));
    expect(find.text('4'), findsOneWidget);

    await tester.pumpWidget(wrap(buildConversation()));
    expect(find.text('0'), findsNothing);
  });

  testWidgets('caps the unread badge at 99+', (tester) async {
    await tester.pumpWidget(wrap(buildConversation(unreadCount: 250)));

    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('reports taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(buildConversation(), onTap: () => tapped = true),
    );

    await tester.tap(find.byType(ConversationTile));
    expect(tapped, isTrue);
  });
}
