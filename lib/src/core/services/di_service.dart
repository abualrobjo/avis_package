import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart';

final sl = GetIt.instance;

/// Access DioClient from GetIt (convenience getter)
DioClient get dioClient => sl<DioClient>();

Future<void> init() async {
  // Host apps using the package alone (e.g. demo) must get Maps/Places keys here;
  // acs_customer also loads .env in bootstrap — a second load is harmless.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Initialize Hive
  final hiveService = HiveServiceImpl();
  await hiveService.init();

  // Pre-open boxes for synchronous access
  await Hive.openBox('auth_box');
  await Hive.openBox('settings_box');
  await Hive.openBox('payment_cards_box');

  // Initialize AppConst from storage
  final authStorage = AuthLocalService(hiveService);
  final storedToken = authStorage.getToken();
  if (storedToken != null && storedToken.isNotEmpty) {
    AppConst.accessToken = storedToken;
  }

  // Register DioClient
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      config: DioClientConfig(
        baseUrl: ApiEndpoints.baseUrl,
        enableLogging: true,
        logLevel: LogLevel.body,
        onReAuth: () async {
          // Break circular dependency by using sl() inside the callback
          await sl<AppAuthService>().fetchToken();
        },
      ),
    ),
  );

  // ======================
  // Services
  // ======================
  sl.registerSingleton<HiveService>(hiveService);

  sl.registerLazySingleton<AppAuthService>(
    () => AppAuthServiceImpl(sl<DioClient>(), sl<AuthLocalService>()),
  );

  sl.registerLazySingleton<AuthLocalService>(
    () => AuthLocalService(sl<HiveService>()),
  );

  sl.registerLazySingleton<SettingsLocalService>(
    () => SettingsLocalService(sl<HiveService>()),
  );

  sl.registerLazySingleton<PaymentCardsLocalService>(
    () => PaymentCardsLocalService(sl<HiveService>()),
  );

  sl.registerLazySingleton<CustomerTripsService>(
    () => CustomerTripsServiceImpl(),
  );

  sl.registerLazySingleton<CustomerSavedPlacesService>(
    () => const CustomerSavedPlacesServiceImpl(),
  );

  sl.registerLazySingleton<CustomerInfoService>(
    () => CustomerInfoServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<LatestTripRateService>(
    () => LatestTripRateServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<CustomerFavoriteDriversService>(
    () => CustomerFavoriteDriversServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<TripsTypeService>(
    () => TripsTypeServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<FlightNamesService>(
    () => FlightNamesServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<AirportsService>(
    () => AirportsServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<VehicleClassesPriceService>(
    () => VehicleClassesPriceServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<AllowedPolygonsService>(
    () => AllowedPolygonsServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<PromoCodeService>(
    () => PromoCodeServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<CustomerLoyaltyPromoCodeService>(
    () => CustomerLoyaltyPromoCodeServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<ChauffeurServicePricesService>(
    () => ChauffeurServicePricesServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<ChauffeurRequestService>(
    () => ChauffeurRequestServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<TermsAndConditionsService>(
    () => TermsAndConditionsServiceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<CancellationService>(
    () => CancellationServiceImpl(),
  );

  sl.registerLazySingleton<PaymentService>(
    () => PaymentServiceImpl(),
  );

  // ======================
  // Repositories
  // ======================
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());

  sl.registerLazySingleton<CustomerSavedPlacesRepository>(
    () => CustomerSavedPlacesRepositoryImpl(sl<CustomerSavedPlacesService>()),
  );

  sl.registerLazySingleton<CustomerTripsRepository>(
    () => CustomerTripsRepositoryImpl(sl<CustomerTripsService>()),
  );

  sl.registerLazySingleton<CancellationRepository>(
    () => CancellationRepositoryImpl(sl<CancellationService>()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<PaymentService>()),
  );

  // ======================
  // Providers
  // ======================
  sl.registerFactory<ChatProvider>(() => ChatProvider(sl<ChatRepository>()));

  sl.registerLazySingleton<SplashProvider>(() => SplashProvider());

  sl.registerFactory<LocalizationProvider>(
    () => LocalizationProvider(sl<SettingsLocalService>()),
  );

  sl.registerFactory<NavigatorHandlerProvider>(
    () => NavigatorHandlerProvider(),
  );

  sl.registerFactory<RatingProvider>(
    () => RatingProvider(sl<CustomerFavoriteDriversService>()),
  );

  sl.registerFactory<MapProvider>(
    () => MapProvider(sl<CustomerTripsRepository>()),
  );

  sl.registerFactory<SavedLocationsProvider>(
    () => SavedLocationsProvider(sl<CustomerSavedPlacesRepository>()),
  );

  sl.registerFactory<ReviewTripProvider>(
    () => ReviewTripProvider(
      sl<AuthLocalService>(),
      sl<ChauffeurServicePricesService>(),
      sl<ChauffeurRequestService>(),
      sl<CustomerInfoService>(),
      sl<FlightNamesService>(),
      sl<CustomerTripsRepository>(),
      sl<TermsAndConditionsService>(),
    ),
  );

  sl.registerFactory<ServicesProvider>(
    () => ServicesProvider(
      sl<AuthLocalService>(),
      sl<TripsTypeService>(),
      sl<FlightNamesService>(),
      sl<CustomerSavedPlacesRepository>(),
      sl<CustomerInfoService>(),
      sl<LatestTripRateService>(),
      sl<AirportsService>(),
      sl<AllowedPolygonsService>(),
      sl<VehicleClassesPriceService>(),
    ),
  );

  sl.registerFactory<AddNewCardProvider>(
    () => AddNewCardProvider(sl<PaymentCardsLocalService>()),
  );

  sl.registerFactory<MyTripsProvider>(
    () =>
        MyTripsProvider(sl<CustomerTripsRepository>(), sl<AuthLocalService>()),
  );

  sl.registerFactory<CancellationProvider>(
    () => CancellationProvider(sl<CancellationRepository>()),
  );

  sl.registerFactory<PaymentProvider>(
    () => PaymentProvider(sl<PaymentRepository>()),
  );
}
