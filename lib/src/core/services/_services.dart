// app auth services
export 'app_auth/app_auth_service.dart';
export 'app_auth/auth_local_service.dart';

// customer trips
export 'customer_trips/customer_trips_service.dart';
export 'customer_trips/customer_trips_service_impl.dart';

// customer saved places (used in service page and elsewhere)
export 'customer_saved_places/customer_saved_places_service.dart';
export 'customer_saved_places/customer_saved_places_service_impl.dart';

// customer info (used in multiple places)
export 'customer_info/customer_info_service.dart';
export 'customer_info/customer_info_service_impl.dart';

// latest trip rate (check if customer should rate a trip - service page and elsewhere)
export 'latest_trip_rate/latest_trip_rate_service.dart';
export 'latest_trip_rate/latest_trip_rate_service_impl.dart';

// customer favorite drivers (rate dialog: mark driver as favourite)
export 'customer_favorite_drivers/customer_favorite_drivers_service.dart';
export 'customer_favorite_drivers/customer_favorite_drivers_service_impl.dart';

// customer rate driver (rate dialog submit)
export 'customer_rate_driver/customer_rate_driver_service.dart';
export 'customer_rate_driver/customer_rate_driver_service_impl.dart';

// lookup (GetByCategoryId — rate reasons, etc.)
export 'lookup_service/lookup_service.dart';
export 'lookup_service/lookup_service_impl.dart';

// trips type (service page tabs/config)
export 'trips_type/trips_type_service.dart';
export 'trips_type/trips_type_service_impl.dart';

// flight names (service page dropdown)
export 'flight_names/flight_names_service.dart';
export 'flight_names/flight_names_service_impl.dart';

// airports (service page place list when requiresFlightNumber)
export 'airports/airports_service.dart';
export 'airports/airports_service_impl.dart';

// vehicle classes price (service page -> confirm: get vehicles by trip details)
export 'vehicle_classes_price/vehicle_classes_price_service.dart';
export 'vehicle_classes_price/vehicle_classes_price_service_impl.dart';

// allowed polygons (map place picker: restrict selection to service areas)
export 'allowed_polygons/allowed_polygons_service.dart';
export 'allowed_polygons/allowed_polygons_service_impl.dart';

// promo code (review trip: check promo code validity)
export 'promo_code/promo_code_service.dart';
export 'promo_code/promo_code_service_impl.dart';

// customer loyalty promo code (review trip: redeem points → generate promo code)
export 'customer_loyalty_promo_code/customer_loyalty_promo_code_service.dart';
export 'customer_loyalty_promo_code/customer_loyalty_promo_code_service_impl.dart';

// chauffeur service prices (review trip: get price by request / options)
export 'chauffeur_service_prices/chauffeur_service_prices_service.dart';
export 'chauffeur_service_prices/chauffeur_service_prices_service_impl.dart';

// chauffeur request (review trip: confirm booking)
export 'chauffeur_request/chauffeur_request_service.dart';
export 'chauffeur_request/chauffeur_request_service_impl.dart';

// terms and conditions (review trip: open T&C PDF)
export 'terms_and_conditions/terms_and_conditions_service.dart';
export 'terms_and_conditions/terms_and_conditions_service_impl.dart';

// local database services
export 'local_database/hive_service.dart';
export 'local_database/settings_local_service.dart';
export 'local_database/payment_cards_local_service.dart';

// service locator
export 'di_service.dart';

// cancellation
export 'cancellation/cancellation_service.dart';
export 'cancellation/cancellation_service_impl.dart';
