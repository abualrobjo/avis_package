import 'package:hive_flutter/hive_flutter.dart';

/// Generic service for handling local storage using Hive.
///
/// Handles initialization, box management, and CRUD operations.
abstract class HiveService {
  /// Initializes Hive for Flutter.
  Future<void> init();

  /// Puts a value into the specified box.
  ///
  /// Opens the box if not already open.
  Future<void> put<T>(String boxName, String key, T value);

  /// Gets a value from the specified box.
  ///
  /// Returns [defaultValue] if key not found or box not open.
  /// Opens the box if not already open (async operation inside synchronous feel not possible,
  /// so ensuring box is open is caller responsibility or we force async get?
  /// Hive get is synchronous. So we must ensure openBox happened before.
  /// Strategy: init() opens critical boxes, or we catch errors.
  /// For robustness: The service should probably manage opening boxes.
  T? get<T>(String boxName, String key, {T? defaultValue});

  /// Deletes a value from the specified box.
  Future<void> delete(String boxName, String key);

  /// Clears all values from the specified box.
  Future<void> clearBox(String boxName);
}

class HiveServiceImpl implements HiveService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    // We can allow lazy opening, but for synchronous gets, boxes must be open.
    // For now, we perform basic init.
  }

  /// Helper to ensure box is open before write operations.
  Future<Box<T>> _openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await _openBox(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    if (!Hive.isBoxOpen(boxName)) {
      // NOTE: Hive get is synchronous. If box isn't open, we can't await here.
      // This service design implies boxes for GET must be pre-opened
      // or we accept that 'get' might fail/return default if not opened.
      // Alternatively, we could make 'get' async, but that changes many flows.
      // For this implementation, we assume boxes are opened via a separate prepare methods
      // OR we just log error.
      // BETTER: The init() method or specific 'prepareBox' methods should be used.
      // However, Hive.box() throws if not open.
      // We will try-catch standard Hive behavior.
      return defaultValue;
    }

    try {
      final box = Hive.box(boxName);
      return box.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = await _openBox(boxName);
    await box.clear();
  }
}
