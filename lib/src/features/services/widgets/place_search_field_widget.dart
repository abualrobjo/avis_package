import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/services/place_search_helper.dart';

class PlaceSearchFieldWidget extends StatefulWidget {
  const PlaceSearchFieldWidget({
    super.key,
    this.hintText = 'Search for a place or address',
    this.onSuggestionSelected,
    this.onSearchError,
  });

  final String hintText;
  final Future<void> Function(PlaceSuggestion suggestion)? onSuggestionSelected;
  final ValueChanged<String>? onSearchError;

  @override
  State<PlaceSearchFieldWidget> createState() => _PlaceSearchFieldWidgetState();
}

class _PlaceSearchFieldWidgetState extends State<PlaceSearchFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  final List<PlaceSuggestion> _suggestions = [];
  bool _loadingSuggestions = false;
  bool _resolvingSelection = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _suggestions.clear();
            _loadingSuggestions = false;
          });
        }
      });
    }
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(value);
    });
  }

  Future<void> _fetchSuggestions(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _loadingSuggestions = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() => _loadingSuggestions = true);

    final locale = Localizations.localeOf(context);
    final next = await PlaceSearchHelper.fetchSuggestions(
      rawQuery: query,
      languageCode: locale.languageCode,
    );

    if (!mounted || _controller.text.trim() != query) return;
    setState(() {
      _suggestions
        ..clear()
        ..addAll(next);
      _loadingSuggestions = false;
    });
  }

  Future<void> _onSuggestionTap(PlaceSuggestion suggestion) async {
    _focusNode.unfocus();
    setState(() {
      _suggestions.clear();
      _loadingSuggestions = false;
      _controller.text = suggestion.description;
      _controller.selection = TextSelection.collapsed(
        offset: suggestion.description.length,
      );
      _resolvingSelection = true;
    });

    try {
      await widget.onSuggestionSelected?.call(suggestion);
    } finally {
      if (mounted) {
        setState(() => _resolvingSelection = false);
      }
    }
  }

  Widget _buildSuggestionsList({required double maxHeight}) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12.r),
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _loadingSuggestions && _suggestions.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colors.border,
                ),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      Icons.place_outlined,
                      color: context.colors.primary,
                      size: 22.r,
                    ),
                    title: TextWidget(
                      suggestion.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                    onTap: () => _onSuggestionTap(suggestion),
                  );
                },
              ),
      ),
    );
  }

  void _submitSearch() {
    _debounce?.cancel();
    _fetchSuggestions(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions =
        _focusNode.hasFocus && (_loadingSuggestions || _suggestions.isNotEmpty);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final suggestionsMaxHeight = keyboardInset > 0 ? 140.h : 220.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(12.r),
          color: context.colors.surface,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            onEditingComplete: _submitSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.secondaryText,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: context.colors.secondaryText,
                size: 22.r,
              ),
              suffixIcon: _loadingSuggestions || _resolvingSelection
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.primary,
                        ),
                      ),
                    )
                  : (_controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: context.colors.secondaryText,
                            size: 20.r,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              _suggestions.clear();
                              _loadingSuggestions = false;
                            });
                          },
                        )
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.colors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: context.colors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: context.colors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.primaryText,
            ),
          ),
        ),
        if (showSuggestions) ...[
          SizedBox(height: 8.h),
          _buildSuggestionsList(maxHeight: suggestionsMaxHeight),
        ],
      ],
    );
  }
}
