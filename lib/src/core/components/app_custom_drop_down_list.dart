import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avis_package/src/core/_core.dart';

class AppCustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String title;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemAsString;
  final double height;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final Widget? iconWidget;
  final TextStyle? selectedTextStyle;
  final String? hintText;

  const AppCustomDropdown({
    super.key,
    required this.items,
    required this.title,
    required this.onChanged,
    this.selectedValue,
    this.itemAsString,
    this.height = 70,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.iconWidget,
    this.selectedTextStyle,
    this.hintText,
  });

  @override
  State<AppCustomDropdown<T>> createState() => _AppCustomDropdownState<T>();
}

class _AppCustomDropdownState<T> extends State<AppCustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool isOpen = false;
  T? selected;

  @override
  void initState() {
    selected = widget.selectedValue;
    super.initState();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppCustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      selected = widget.selectedValue;
    }
  }

  void _toggleDropdown() {
    isOpen ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isOpen = false);
  }

  OverlayEntry _createOverlay() {
    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    return OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  offset: Offset(0, widget.height.w + 6.w),
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: 8,
                    borderRadius: widget.borderRadius,
                    child: Container(
                      width: width,
                      constraints: BoxConstraints(maxHeight: 200.h),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: widget.borderRadius,
                        border: Border.all(
                          color:
                              widget.borderColor ?? context.colors.inputBorder,
                          width: 1.2,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.items.length, (index) {
                            final item = widget.items[index];
                            final itemText =
                                widget.itemAsString?.call(item) ??
                                item.toString();

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() => selected = item);
                                    widget.onChanged(item);
                                    _closeDropdown();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      itemText,
                                      textAlign: TextAlign.start,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ),
                                if (index != widget.items.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: context.colors.divider,
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = selected != null
        ? (widget.itemAsString?.call(selected as T) ?? selected.toString())
        : widget.hintText ?? 'Select value';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          key: _dropdownKey,
          width: double.infinity,
          height: widget.height.w,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: widget.borderColor ?? context.colors.inputBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.title.isNotEmpty)
                      TextWidget(
                        widget.title,
                        style: AppTextStyles.labelBold.copyWith(
                          color: context.colors.secondaryText,
                        ),
                      ),
                    if (widget.title.isNotEmpty) SizedBox(height: 4.w),
                    TextWidget(
                      selectedText,
                      style: widget.selectedTextStyle ?? AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.iconWidget != null)
                widget.iconWidget!
              else
                Container(
                  height: 45.w,
                  width: 45.w,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppCornerRadius.medium),
                    ),
                  ),
                  child: AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 30.w,
                      color: context.colors.inverseText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
