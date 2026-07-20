import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimens.stateViewIconCircle,
              height: AppDimens.stateViewIconCircle,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              ),
              child: Icon(
                Icons.chat_bubble_rounded,
                size: AppDimens.iconXl,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.spaceL),
            Text(
              AppLocalizations.of(context).appTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
