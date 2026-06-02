import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart' show AppContextExtension;
import 'network_image_widget.dart';

class EditableProfileAvatarComponent extends StatelessWidget {
  const EditableProfileAvatarComponent({
    super.key,
    required this.imageUrl,
    required this.onEditTap,
    this.isLoading = false,
    this.localImagePath,
  });

  final String imageUrl;
  final VoidCallback? onEditTap;
  final bool isLoading;

  /// When set, shows this local file instead of [imageUrl] (e.g. picked image before save).
  final String? localImagePath;

  static const double _avatarSize = 67;
  static const double _editButtonSize = 24;
  static const double _editButtonRight = -5;
  static const double _editButtonBottom = -5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _avatarSize.w,
          height: _avatarSize.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.primary, width: 3),
          ),
          child: ClipOval(
            child: localImagePath != null
                ? Image.file(
                    File(localImagePath!),
                    width: _avatarSize.w,
                    height: _avatarSize.w,
                    fit: BoxFit.cover,
                  )
                : imageUrl.isNotEmpty
                ? NetworkImageWidget(
                    url: imageUrl,
                    width: _avatarSize.w,
                    height: _avatarSize.w,
                    fit: BoxFit.cover,
                    errorWidget: _placeholder(context, _avatarSize.w),
                  )
                : _placeholder(context, _avatarSize.w),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: ClipOval(
              child: Container(
                color: Colors.black26,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.inverseText,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: _editButtonRight,
          bottom: _editButtonBottom,
          child: GestureDetector(
            onTap: isLoading ? null : onEditTap,
            child: Container(
              width: _editButtonSize.w,
              height: _editButtonSize.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surface,
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.edit,
                size: 16.w,
                color: context.colors.secondaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: context.colors.inputBackground,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: context.colors.tertiaryText,
      ),
    );
  }
}
