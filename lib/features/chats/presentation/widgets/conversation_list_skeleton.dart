import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/widgets/shimmer.dart';
import 'package:flutter/material.dart';

class ConversationListSkeleton extends StatelessWidget {
  const ConversationListSkeleton({super.key});

  static const _placeholderCount = 8;
  static const _nameWidth = 140.0;
  static const _previewWidth = 220.0;
  static const _lineHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
        itemCount: _placeholderCount,
        itemBuilder: (context, _) => const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceM,
            vertical: AppDimens.spaceM,
          ),
          child: Row(
            children: [
              ShimmerBox.circle(size: AppDimens.avatarRadius * 2),
              SizedBox(width: AppDimens.spaceM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: _nameWidth, height: _lineHeight),
                  SizedBox(height: AppDimens.spaceS),
                  ShimmerBox(width: _previewWidth, height: _lineHeight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
