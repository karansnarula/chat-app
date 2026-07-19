import 'package:chat_app/core/constants/app_strings.dart';
import 'package:chat_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots and shows the placeholder shell', (tester) async {
    await tester.pumpWidget(const ChatApp());

    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}
