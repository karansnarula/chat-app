import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/widgets/app_text_field.dart';
import 'package:chat_app/features/auth/presentation/auth_validators.dart';
import 'package:flutter/material.dart';

/// Collects a new display name; returns it via [Navigator.pop] when valid.
class DisplayNameDialog extends StatefulWidget {
  const DisplayNameDialog({super.key});

  @override
  State<DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<DisplayNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.displayName),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: l10n.displayName,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.person_outline,
          validator: (value) => AuthValidators.displayName(value, l10n),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
