import 'package:injectable/injectable.dart';

/// Tracks which conversation is on screen, so an arriving message for that
/// thread is not also announced as a notification.
@lazySingleton
class ActiveConversation {
  String? _conversationId;

  String? get id => _conversationId;

  bool isActive(String conversationId) => _conversationId == conversationId;

  // ignore: use_setters_to_change_properties — pairs with leave()
  void enter(String conversationId) => _conversationId = conversationId;

  void leave(String conversationId) {
    if (_conversationId == conversationId) _conversationId = null;
  }
}
