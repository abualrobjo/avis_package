# Lib vs avis_package – file-by-file difference report

Generated so you can verify before push. **~130 paired files differ** (mostly imports). Below: **import-only** vs **substantive** (logic/API/design).

---

## Expected differences (imports / DI only)

These differ only by import paths (`/core` → `package:avis_package/src/core`) or by DI (package receives `DioClient` / `Firestore` via constructor). **No action needed** unless you see a bug.

- All `core/services/**/*.dart` (imports + package uses injected DioClient)
- All `core/repositories/**/*.dart` (imports)
- All `core/components/*.dart` except those listed under “Substantive” below
- All `core/data/models/*.dart` except those listed under “Substantive”
- All `core/network/**`, `core/utils/**`, `core/theme/**`, `core/providers/*.dart` (imports)
- `core/routes/app_router.dart` (imports + chat route guard when Firebase not configured)
- `core/services/di_service.dart` (imports + optional `firebaseApp`, Chat only when Firebase set)
- `features/chat/repositories/chat_repository_impl.dart` – lib: no-arg + lazy `_firestore` getter; package: `ChatRepositoryImpl(FirebaseFirestore)` for init control

---

## Substantive differences (fixed or intentional)

| File | Status | Note |
|------|--------|------|
| `core/components/add_promo_code_bottom_sheet.dart` | **SYNCED** | Package now has full StatefulWidget + PromoCodeService + CustomerInfoService + apply logic (same as lib). |
| `core/components/redeem_loyalty_points_bottom_sheet.dart` | **SYNCED** | Package has stateful + CustomerInfoService + CustomerLoyaltyPromoCodeService + optional args + onRedeemed. |
| `core/data/models/customer_info_model.dart` | **SYNCED** | Package has totalLoyalityPoints, maxRedeemablePoints, minimumPointsValueForTransfer. |
| `core/data/models/customer_trip_by_id_model.dart` | **SYNCED** | Package aligned with lib (DateTime? tripDateTime, vehicle/location fields, formatTripDateTime, formatTime, isCancellationAllowed). |
| `features/review_trip/views/page/review_trip_page.dart` | **SYNCED** | Full flow: args, GetChauffeurServicePrices_byRequest, options, BookChauffeurRequest, GetCustomerTripById (via repository), navigate with tripId. |
| `features/review_trip/views/widgets/trip_actions_widget.dart` | **SYNCED** | Promo/loyalty callbacks, applied state, remove. |
| `features/review_trip/views/widgets/trip_bottom_bar_widget.dart` | **SYNCED** | onConfirm nullable. |
| `features/review_trip/models/review_trip_ui_model.dart` | **SYNCED** | ReviewTripOptionUiModel.isSelectable added. |
| `features/my_trips/trip_details_page.dart` | **FIXED** | Updated to use CustomerTripByIdModel new API (pickupLatitude, pickupLatLng, parseLatLng, formatTripDateTime). |

---

## Substantive differences (intentional – package differs by design)

| File | Lib | Package | Reason |
|------|-----|---------|--------|
| `features/my_trips/provider/my_trips_provider.dart` | Uses `CustomerTripsRepository`, `List<CustomerTripDetailModel>`, `getCustomerTripsHistory()`, `getCustomerTripById()` | Uses `CustomerTripsService`, `List<TripMapInfo>`, `setInitial()`, `loadWhenDisplayed()`, `_loadTrips()` | Package uses TripMapInfo and service; lib uses repository and detail model. Both work with their respective pages. |
| `features/my_trips/my_trips_page.dart` | Calls `getCustomerTripsHistory()` in initState; uses `CustomerTripDetailModel` list | Uses `loadWhenDisplayed()`, passes `tripInfo` (TripMapInfo) from route args | Package flow uses route args and TripMapInfo. |
| `features/saved_locations/provider/saved_locations_provider.dart` | Uses `CustomerSavedPlacesRepository` (API) | Uses `SavedLocationsLocalService` (Hive) | Package keeps local-only saved locations; lib can use API. |
| `features/chat/repositories/chat_repository_impl.dart` | No-arg constructor; lazy `_firestore` getter (throws if Firebase not init) | Constructor `(FirebaseFirestore)`; Firestore passed from DI after `Firebase.initializeApp()` | Package needs explicit Firebase init for Chat. |

---

## Substantive differences (not yet synced – may need follow-up)

| File | Lib | Package | Recommendation |
|------|-----|---------|----------------|
| `features/services/services_page.dart` | ~1414 lines: vehicle classes API, builds ReviewTripPageArgs, navigates to review_trip with args | ~1013 lines: simpler; may not build args or call GetVehicleClassesPriceByTripType before review | Sync the “confirm” flow: fetch vehicle classes → build ReviewTripPageArgs → navigate to review_trip with args so review_trip_page receives args. |
| `features/splash/splash_page.dart` | May have different navigation / timing | Shorter / different | Compare and sync if splash behavior should match. |

---

## Files only in lib (not in package)

- `lib/main.dart`, `lib/app.dart`, `lib/bootstrap.dart`, `lib/localization_wrapper.dart` – app entry; not part of the package.

---

## Summary

- **Import-only / DI-only:** Most of the ~130 differing files; safe to ignore for “something missing” if behavior is correct.
- **Synced:** add_promo_code_bottom_sheet, redeem_loyalty_points_bottom_sheet, customer_info_model, customer_trip_by_id_model, review_trip_page, trip_actions_widget, trip_bottom_bar_widget, review_trip_ui_model (isSelectable), trip_details_page (CustomerTripByIdModel usage).
- **Intentional:** MyTripsProvider/MyTripsPage (TripMapInfo vs repository), SavedLocationsProvider (local vs API), ChatRepositoryImpl (Firestore injection).
- **Optional follow-up:** services_page (full booking flow with vehicle classes + args), splash_page.

If you want to be sure nothing is missing before push, run the app and test: **Services → pick trip → Review trip (with args) → Confirm → Ride request**, **Chat** (with Firebase initialized), **My Trips → Trip details**, **Promo code** and **Loyalty redeem** on review trip.
