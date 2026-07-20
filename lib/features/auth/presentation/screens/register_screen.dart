import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/error/app_exception_l10n.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/widgets/app_button.dart';
import 'package:chat_app/core/widgets/app_text_field.dart';
import 'package:chat_app/features/auth/presentation/auth_validators.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRegisterSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _displayNameController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.localizedMessage(l10n)),
            ),
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spaceL),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.register,
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppDimens.spaceS),
                      Text(
                        l10n.registerSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimens.spaceXl),
                      AppTextField(
                        controller: _displayNameController,
                        label: l10n.displayName,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) =>
                            AuthValidators.displayName(value, l10n),
                      ),
                      const SizedBox(height: AppDimens.spaceM),
                      AppTextField(
                        controller: _emailController,
                        label: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_outline,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) =>
                            AuthValidators.email(value, l10n),
                      ),
                      const SizedBox(height: AppDimens.spaceM),
                      AppTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_outline,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) =>
                            AuthValidators.password(value, l10n),
                      ),
                      const SizedBox(height: AppDimens.spaceL),
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) =>
                            previous.isSubmitting != current.isSubmitting,
                        builder: (context, state) => AppButton(
                          label: l10n.register,
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                      ),
                      const SizedBox(height: AppDimens.spaceL),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.login),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
