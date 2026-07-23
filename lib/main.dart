import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/network/socket_lifecycle_observer.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/notifications/notification_navigator.dart';
import 'package:chat_app/core/notifications/notification_service.dart';
import 'package:chat_app/core/storage/fresh_install_guard.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  await configureDependencies();
  await getIt<FreshInstallGuard>().clearCredentialsIfReinstalled();
  await getIt<NotificationService>().initialise();

  WidgetsBinding.instance.addObserver(
    SocketLifecycleObserver(getIt<SocketService>(), getIt<TokenStorage>()),
  );

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<GoRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<FriendRequestsBloc>()),
      ],
      child: NotificationNavigator(
        notificationService: getIt<NotificationService>(),
        router: router,
        authBloc: getIt<AuthBloc>(),
        child: MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }
}
