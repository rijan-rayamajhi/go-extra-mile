import 'package:hive/hive.dart';
import 'geo_point_adapter.dart';
import 'date_time_adapter.dart';

class HiveAdapters {
  static void registerAdapters() {
    // Register custom type adapters
    Hive.registerAdapter(GeoPointAdapter());
    Hive.registerAdapter(DateTimeAdapter());
  }
}
