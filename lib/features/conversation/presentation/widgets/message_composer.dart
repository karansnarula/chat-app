import 'dart:async';

import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text field with an emoji panel that replaces the keyboard rather than
/// stacking with it.
class MessageComposer extends StatefulWidget {
  const MessageComposer({required this.onSend, super.key});

  final ValueChanged<String> onSend;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _emojiVisible = false;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) setState(() => _canSend = canSend);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _emojiVisible) {
      setState(() => _emojiVisible = false);
    }
  }

  void _toggleEmoji() {
    if (_emojiVisible) {
      setState(() => _emojiVisible = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _emojiVisible = true);
    }
  }

  void _send() {
    if (!_canSend) return;
    unawaited(HapticFeedback.lightImpact());
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.spaceS,
            AppDimens.spaceS,
            AppDimens.spaceS,
            AppDimens.spaceS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: l10n.emoji,
                onPressed: _toggleEmoji,
                icon: Icon(
                  _emojiVisible
                      ? Icons.keyboard_rounded
                      : Icons.emoji_emotions_outlined,
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: AppDimens.composerMaxHeight,
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: l10n.messageHint,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.spaceM,
                        vertical: AppDimens.spaceS,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.spaceS),
              AnimatedScale(
                scale: _canSend ? 1 : 0.8,
                duration: AppDurations.fast,
                child: IconButton.filled(
                  tooltip: l10n.send,
                  onPressed: _canSend ? _send : null,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    disabledBackgroundColor:
                        scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_emojiVisible)
          SizedBox(
            height: AppDimens.emojiPickerHeight,
            child: EmojiPicker(
              textEditingController: _controller,
              config: Config(
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: scheme.surface,
                  columns: 8,
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: scheme.surface,
                  indicatorColor: scheme.primary,
                  iconColorSelected: scheme.primary,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: scheme.surfaceContainerHighest,
                  buttonColor: scheme.primary,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
