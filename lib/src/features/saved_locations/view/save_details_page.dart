import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        AppButton,
        AppContextExtension,
        AppTextStyles,
        TextWidget,
        BackArrowWidget;
import 'package:avis_package/src/core/data/params/add_customer_saved_place_params.dart'; // Will be cleaned by formatter if incorrect
import '../provider/saved_locations_provider.dart';

class SaveDetailsPage extends StatefulWidget {
  const SaveDetailsPage({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String type; // 'home', 'work', 'airport', 'custom'

  @override
  State<SaveDetailsPage> createState() => _SaveDetailsPageState();
}

class _SaveDetailsPageState extends State<SaveDetailsPage> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill nickname if standard type
    if (widget.type != 'custom') {
      _nicknameController.text =
          widget.type[0].toUpperCase() + widget.type.substring(1);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_nicknameController.text.trim().isEmpty) return;

    final inputNickname = _nicknameController.text.trim();

    final params = AddCustomerSavedPlaceParams(
      placeCategoryId: AddCustomerSavedPlaceParams.placeCategory,
      latitude: widget.latitude.toString(),
      longtitude: widget.longitude.toString(),
      placePrimaryName: inputNickname,
      placeSecondaryName: widget.address,
    );

    context.read<SavedLocationsProvider>().addCustomerSavedPlace(
      params: params,
    );

    // Pop back to the SavedLocationsPage list
    Navigator.of(
      context,
    ).popUntil((route) => route.settings.name == '/saved-locations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const BackArrowWidget(),
        title: TextWidget(
          'Add New Place',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: TextWidget(
              'Location nickname',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: context.colors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.colors.divider.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _nicknameController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.primaryText,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Location nickname',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.secondaryText,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: AppButton.primary(
              text: 'Save',
              onPressed: () => _onSave(context),
            ),
          ),
          SizedBox(height: 24.h), // Safe area margin
        ],
      ),
    );
  }
}
