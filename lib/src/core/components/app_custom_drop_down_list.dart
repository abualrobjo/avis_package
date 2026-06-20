import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avis_package/src/core/_core.dart';

class AppCustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String title;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemAsString;
  final bool Function(T item, String query)? filterItem;
  final double height;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final Widget? iconWidget;
  final TextStyle? selectedTextStyle;
  final String? hintText;
  final bool enableSearch;
  final String searchHintText;

  const AppCustomDropdown({
    super.key,
    required this.items,
    required this.title,
    required this.onChanged,
    this.selectedValue,
    this.itemAsString,
    this.filterItem,
    this.height = 70,
    this.borderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.iconWidget,
    this.selectedTextStyle,
    this.hintText,
    this.enableSearch = false,
    this.searchHintText = 'Search...',
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
    if (isOpen &&
        !widget.enableSearch &&
        (widget.items != oldWidget.items ||
            widget.enableSearch != oldWidget.enableSearch)) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _toggleDropdown() {
    isOpen ? _closeDropdown() : _openDropdown();
  }

  Future<void> _openDropdown() async {
    if (widget.enableSearch) {
      await _openSearchBottomSheet();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _DropdownOverlayPanel<T>(
        dropdownKey: _dropdownKey,
        layerLink: _layerLink,
        items: widget.items,
        itemAsString: widget.itemAsString,
        borderColor: widget.borderColor,
        borderRadius: widget.borderRadius,
        onClose: _closeDropdown,
        onSelect: _selectItem,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  Future<void> _openSearchBottomSheet() async {
    setState(() => isOpen = true);

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SearchableDropdownSheet<T>(
        title: widget.title,
        items: widget.items,
        itemAsString: widget.itemAsString,
        filterItem: widget.filterItem,
        searchHintText: widget.searchHintText,
        selectedValue: selected,
      ),
    );

    if (!mounted) return;
    setState(() => isOpen = false);

    if (result != null) {
      _selectItem(result);
    }
  }

  void _selectItem(T item) {
    setState(() => selected = item);
    widget.onChanged(item);
    _closeDropdown();
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => isOpen = false);
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
          height: widget.title.isEmpty ? widget.height.w : null,
          constraints: widget.title.isEmpty
              ? null
              : BoxConstraints(minHeight: widget.height.w),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.title.isEmpty ? 10 : 12,
          ),
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

class _SearchableDropdownSheet<T> extends StatefulWidget {
  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.itemAsString,
    required this.filterItem,
    required this.searchHintText,
    required this.selectedValue,
  });

  final String title;
  final List<T> items;
  final String Function(T)? itemAsString;
  final bool Function(T item, String query)? filterItem;
  final String searchHintText;
  final T? selectedValue;

  @override
  State<_SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T> extends State<_SearchableDropdownSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _matchesSearch(T item, String query) {
    if (query.isEmpty) return true;
    if (widget.filterItem != null) {
      return widget.filterItem!(item, query);
    }
    final itemText =
        widget.itemAsString?.call(item) ?? item.toString();
    return itemText.toLowerCase().contains(query);
  }

  List<T> _filteredItems() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => _matchesSearch(item, query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetHeight = (screenHeight * 0.75).clamp(320.0, screenHeight - 48);
    final filteredItems = _filteredItems();

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpaces.medium),
            const Center(child: BottomSheetHandle()),
            if (widget.title.isNotEmpty) ...[
              const SizedBox(height: AppSpaces.medium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(
                    widget.title,
                    style: AppTextStyles.bodyLargeBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHintText,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.tertiaryText,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: context.colors.secondaryText,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.colors.inputBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.colors.inputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: TextWidget(
                        'No results found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.secondaryText,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.manual,
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: context.colors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final itemText = widget.itemAsString?.call(item) ??
                            item.toString();
                        final isSelected = widget.selectedValue == item;

                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            color: isSelected
                                ? context.colors.primary.withValues(alpha: 0.08)
                                : null,
                            alignment: Alignment.centerLeft,
                            child: TextWidget(
                              itemText,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownOverlayPanel<T> extends StatelessWidget {
  const _DropdownOverlayPanel({
    required this.dropdownKey,
    required this.layerLink,
    required this.items,
    required this.itemAsString,
    required this.borderColor,
    required this.borderRadius,
    required this.onClose,
    required this.onSelect,
  });

  final GlobalKey dropdownKey;
  final LayerLink layerLink;
  final List<T> items;
  final String Function(T)? itemAsString;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final VoidCallback onClose;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final renderBox =
        dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final position = renderBox.localToGlobal(Offset.zero);
    final dropdownTop = position.dy;
    final dropdownBottom = dropdownTop + renderBox.size.height;
    final mediaQuery = MediaQuery.of(context);
    final keyboardTop = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final topPadding = mediaQuery.padding.top;

    const minHeight = 120.0;
    final maxPreferred = 200.h;

    final spaceBelow = keyboardTop - dropdownBottom - 8.w;
    final spaceAbove = dropdownTop - topPadding - 8.w;

    var openUpward = false;
    var available = spaceBelow;

    if (spaceBelow < minHeight && spaceAbove > spaceBelow) {
      openUpward = true;
      available = spaceAbove;
    }

    final maxHeight = available.clamp(minHeight, maxPreferred);

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onClose,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor: openUpward
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              followerAnchor: openUpward
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              offset: Offset(0, openUpward ? -6.w : 6.w),
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  elevation: 8,
                  borderRadius: borderRadius,
                  child: Container(
                    width: width,
                    height: maxHeight,
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: borderColor ?? context.colors.inputBorder,
                        width: 1.2,
                      ),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: context.colors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final itemText =
                            itemAsString?.call(item) ?? item.toString();

                        return InkWell(
                          onTap: () => onSelect(item),
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
