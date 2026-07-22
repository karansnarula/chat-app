import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/network/socket_lifecycle_observer.dart';
import 'package:chat_app/core/network/socket_service.dart';
import 'package:chat_app/core/storage/token_storage.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  WidgetsBinding.instance.addObserver(
    SocketLifecycleObserver(getIt<SocketService>(), getIt<TokenStorage>()),
  );
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<FriendRequestsBloc>()),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
