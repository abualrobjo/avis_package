import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:avis_package/src/core/_core.dart';

class AppTextFormFieldComponent extends StatelessWidget {
  const AppTextFormFieldComponent({
    super.key,
    this.title,
    this.titleStyle,
    this.readOnly = false,
    this.focusNode,
    this.autofocus = false,
    this.controller,
    this.onTap,
    this.minLines,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textFieldTextStyle,
    this.suffix,
    this.suffixIcon,
    this.prefix,
    this.prefixIcon,
    this.hintText,
    this.label,
    this.labelText,
    this.contentPadding,
    this.hasBorder = true,
    this.warningMsg,
    this.focusedBorderSameAsEnabled = false,
  });

  // Title properties
  final String? title;
  final TextStyle? titleStyle;

  // TextFormField properties
  final bool readOnly;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final int? minLines;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final String obscuringCharacter;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textFieldTextStyle;

  // Decoration properties
  final Widget? suffix;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? prefixIcon;
  final String? hintText;
  final Widget? label;
  final String? labelText;
  final EdgeInsetsGeometry? contentPadding;
  final String? warningMsg;
  final bool hasBorder;
  /// When true, focused border uses the same color as enabled (no orange/primary on focus).
  final bool focusedBorderSameAsEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        if (title != null) ...[_title(context), const SizedBox(height: 4)],

        /// Text Field
        _textField(context),

        /// Warning Message
        if (warningMsg != null) ...[
          const SizedBox(height: 4),
          TextWidget(
            '$warningMsg',
            style: AppTextStyles.bodyXSmallBold.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _title(BuildContext context) => TextWidget(
    '$title',
    style:
        titleStyle ??
        AppTextStyles.bodyLargeBold.copyWith(
          color: warningMsg != null
              ? context.colors.error
              : context.colors.primaryText,
        ),
  );

  Widget _textField(BuildContext context) => ColoredBox(
    color: warningMsg != null
        ? context.colors.errorBackground
        : Colors.transparent,
    child: TextFormField(
      readOnly: readOnly,
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      cursorColor: warningMsg != null
          ? context.colors.error
          : context.colors.secondary,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style:
          textFieldTextStyle ??
          AppTextStyles.bodyMediumBold.copyWith(
            color: context.colors.primaryText,
          ),
      decoration: _buildInputDecoration(context),
    ),
  );

  InputDecoration _buildInputDecoration(BuildContext context) =>
      InputDecoration(
        suffix: suffix,
        suffixIcon: suffixIcon,
        prefix: prefix,
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: context.colors.secondaryText,
        ),
        label: label,
        labelText: labelText,
        prefixIconConstraints: const BoxConstraints(
          minWidth: AppSpaces.onSides,
          minHeight: AppSpaces.onSides,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppSpaces.onSides,
          minHeight: AppSpaces.onSides,
        ),
        labelStyle: AppTextStyles.bodySmallBold.copyWith(
          color: context.colors.primaryText,
        ),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(
              vertical: AppSpaces.onSides,
              horizontal: AppSpaces.medium,
            ),
        border: _buildBorder(context.colors.inputFocusedBorder),
        focusedBorder: warningMsg != null
            ? _buildBorder(context.colors.error)
            : _buildBorder(focusedBorderSameAsEnabled
                ? context.colors.inputBorder
                : context.colors.inputFocusedBorder),
        enabledBorder: warningMsg != null
            ? _buildBorder(context.colors.error)
            : _buildBorder(context.colors.inputBorder),
        errorBorder: _buildBorder(context.colors.error),
        focusedErrorBorder: _buildBorder(context.colors.error),
        disabledBorder: _buildBorder(context.colors.inputFocusedBorder),
        errorStyle: const TextStyle(height: -1),
      );

  InputBorder _buildBorder(Color color) => hasBorder
      ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: color),
          gapPadding: 0,
        )
      : InputBorder.none;
}
