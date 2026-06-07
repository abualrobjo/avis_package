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

class _AppCustomDropdownState<T> extends State<AppCustomDropdown<T>>
    with WidgetsBindingObserver {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  OverlayEntry? _overlayEntry;
  bool isOpen = false;
  T? selected;

  @override
  void initState() {
    selected = widget.selectedValue;
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (isOpen) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  @override
  void didUpdateWidget(covariant AppCustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      selected = widget.selectedValue;
    }
    if (isOpen &&
        (widget.items != oldWidget.items ||
            widget.enableSearch != oldWidget.enableSearch)) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _onSearchChanged() {
    _overlayEntry?.markNeedsBuild();
  }

  void _toggleDropdown() {
    isOpen ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    _searchController.clear();
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void _closeDropdown() {
    _searchController.clear();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isOpen = false);
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

  ({
    bool openUpward,
    double maxHeight,
    double width,
  }) _overlayLayout(BuildContext context) {
    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final position = renderBox.localToGlobal(Offset.zero);
    final dropdownTop = position.dy;
    final dropdownBottom = dropdownTop + renderBox.size.height;
    final mediaQuery = MediaQuery.of(context);
    final keyboardTop = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final topPadding = mediaQuery.padding.top;

    const minHeight = 120.0;
    final maxPreferred = widget.enableSearch ? 280.h : 200.h;
    const searchFieldHeight = 64.0;

    final spaceBelow = keyboardTop - dropdownBottom - 8.w;
    final spaceAbove = dropdownTop - topPadding - 8.w;

    var openUpward = false;
    var available = spaceBelow;

    if (widget.enableSearch && spaceBelow < minHeight + searchFieldHeight) {
      if (spaceAbove > spaceBelow) {
        openUpward = true;
        available = spaceAbove;
      }
    } else if (spaceBelow < minHeight && spaceAbove > spaceBelow) {
      openUpward = true;
      available = spaceAbove;
    }

    final maxHeight = available.clamp(minHeight, maxPreferred);

    return (
      openUpward: openUpward,
      maxHeight: maxHeight,
      width: width,
    );
  }

  Widget _buildSearchField(BuildContext overlayContext) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: AppTextStyles.bodyMedium.copyWith(
          color: overlayContext.colors.primaryText,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: overlayContext.colors.tertiaryText,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: overlayContext.colors.secondaryText,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: overlayContext.colors.inputBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: overlayContext.colors.inputBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: overlayContext.colors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext overlayContext,
    List<T> filteredItems,
  ) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextWidget(
            'No results found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: overlayContext.colors.secondaryText,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredItems.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: overlayContext.colors.divider,
      ),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final itemText =
            widget.itemAsString?.call(item) ?? item.toString();

        return InkWell(
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
        );
      },
    );
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (overlayContext) {
        final layout = _overlayLayout(overlayContext);
        final filteredItems = _filteredItems();
        final openUpward = layout.openUpward;

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
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
                      borderRadius: widget.borderRadius,
                      child: Container(
                        width: layout.width,
                        height: layout.maxHeight,
                        decoration: BoxDecoration(
                          color: overlayContext.colors.surface,
                          borderRadius: widget.borderRadius,
                          border: Border.all(
                            color: widget.borderColor ??
                                overlayContext.colors.inputBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (widget.enableSearch && !openUpward) ...[
                              _buildSearchField(overlayContext),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: overlayContext.colors.divider,
                              ),
                            ],
                            Expanded(
                              child: _buildItemsList(
                                overlayContext,
                                filteredItems,
                              ),
                            ),
                            if (widget.enableSearch && openUpward) ...[
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: overlayContext.colors.divider,
                              ),
                              _buildSearchField(overlayContext),
                            ],
                          ],
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
