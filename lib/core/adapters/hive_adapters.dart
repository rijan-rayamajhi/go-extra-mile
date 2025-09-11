import 'package:hive/hive.dart';
import 'geo_point_adapter.dart';
import 'date_time_adapter.dart';
import '../../features/ride/domain/entities/ride_entity.dart';
import '../../features/ride/domain/entities/ride_memory_entity.dart';
import '../../features/ride/data/models/ride_model.dart';
import '../../features/ride/data/models/ride_memory_model.dart';

class HiveAdapters {
  static void registerAdapters() {
    // Register custom type adapters
    Hive.registerAdapter(GeoPointAdapter());
    Hive.registerAdapter(DateTimeAdapter());
    
    // Register entity adapters (generated)
    Hive.registerAdapter(RideEntityAdapter());
    Hive.registerAdapter(RideMemoryEntityAdapter());
    
    // Register model adapters (generated)
    Hive.registerAdapter(RideModelAdapter());
    Hive.registerAdapter(RideMemoryModelAdapter());
  }
}
