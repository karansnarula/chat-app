abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String chats = '/chats';
  static const String friendRequests = '/chats/friend-requests';
  static const String settings = '/settings';
  static const String conversation = '/conversation/:id';

  static String conversationWithId(String id) => '/conversation/$id';

  /// Contact name, passed so the app bar has a title before the thread
  /// loads.
  static const String conversationTitleParam = 'title';
}
