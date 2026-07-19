import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: AppDurations.fast,
        child: isLoading
            ? SizedBox.square(
                dimension: AppDimens.iconM,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimens.textFieldFocusBorderWidth,
                  color: scheme.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
