# Ride Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Ride Tracking and Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore + Local Storage (Hive) |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, hive, flutter_bloc, dartz, equatable |

## Overview

The Ride feature manages ride tracking, recording, and management in the Go Extra Mile application. It handles ride capture, GPS tracking, ride memories, odometer readings, and provides comprehensive ride analytics and history.

### Key Features
- **Ride Tracking**: Real-time GPS tracking during rides
- **Ride Recording**: Capture and store ride data
- **Ride Memories**: Photo and video memories during rides
- **Odometer Integration**: Track vehicle odometer readings
- **Ride Analytics**: Distance, speed, time, and gem coin calculations
- **Local Storage**: Offline ride storage with Hive
- **Cloud Sync**: Synchronize rides with Firestore
- **Ride History**: Comprehensive ride history and details

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. RideEntity (Domain Entity)
```dart
@HiveType(typeId: 2)
class RideEntity extends Equatable {
  // Identity
  @HiveField(0)
  final String id;                    // Unique ride identifier
  @HiveField(1)
  final String userId;                // User who took the ride
  @HiveField(2)
  final String vehicleId;             // Vehicle used for ride
  @HiveField(3)
  final String status;                // Ride status (active, completed, etc.)
  @HiveField(4)
  final DateTime startedAt;           // Ride start time
  @HiveField(5)
  final GeoPoint startCoordinates;    // Starting location
  @HiveField(6)
  final GeoPoint? endCoordinates;    // Ending location
  @HiveField(7)
  final DateTime? endedAt;            // Ride end time
  @HiveField(8)
  final double? totalDistance;       // Total distance traveled
  @HiveField(9)
  final double? totalTime;           // Total ride duration
  @HiveField(10)
  final double? totalGEMCoins;       // Gem coins earned
  
  // Ride Details
  @HiveField(11)
  final List<RideMemoryEntity>? rideMemories; // Photos/videos during ride
  @HiveField(12)
  final String? rideTitle;           // Custom ride title
  @HiveField(13)
  final String? rideDescription;     // Ride description
  @HiveField(14)
  final double? topSpeed;            // Maximum speed reached
  @HiveField(15)
  final double? averageSpeed;        // Average speed
  @HiveField(16)
  final List<GeoPoint>? routePoints; // GPS route points
  @HiveField(17)
  final bool? isPublic;              // Public visibility
}
```

**Purpose**: Core ride data representation in the domain layer
**Properties**:
- `id`: Unique identifier for each ride
- `userId`: ID of the user who took the ride
- `vehicleId`: ID of the vehicle used
- `status`: Current status of the ride
- `startedAt`: When the ride started
- `startCoordinates`: Starting GPS coordinates
- `endCoordinates`: Ending GPS coordinates (optional)
- `endedAt`: When the ride ended (optional)
- `totalDistance`: Total distance traveled in kilometers
- `totalTime`: Total duration in minutes
- `totalGEMCoins`: Gem coins earned from this ride
- `rideMemories`: Photos and videos captured during ride
- `rideTitle`: Custom title for the ride
- `rideDescription`: Detailed description
- `topSpeed`: Maximum speed achieved
- `averageSpeed`: Average speed throughout ride
- `routePoints`: GPS coordinates of the route
- `isPublic`: Whether ride is visible to others

### 2. RideMemoryEntity (Domain Entity)
```dart
@HiveType(typeId: 3)
class RideMemoryEntity extends Equatable {
  @HiveField(0)
  final String id;                   // Memory identifier
  @HiveField(1)
  final String rideId;               // Associated ride ID
  @HiveField(2)
  final String type;                 // Memory type (photo, video)
  @HiveField(3)
  final String filePath;             // Local file path
  @HiveField(4)
  final String? cloudUrl;            // Cloud storage URL
  @HiveField(5)
  final DateTime capturedAt;          // When memory was captured
  @HiveField(6)
  final GeoPoint? location;          // Where memory was captured
  @HiveField(7)
  final String? caption;             // Memory caption
}
```

**Purpose**: Represents photos and videos captured during rides
**Properties**:
- `id`: Unique identifier for the memory
- `rideId`: ID of the associated ride
- `type`: Type of memory (photo or video)
- `filePath`: Local file path
- `cloudUrl`: Cloud storage URL (optional)
- `capturedAt`: When the memory was captured
- `location`: GPS coordinates where captured
- `caption`: User-provided caption

### 3. OdometerEntity (Domain Entity)
```dart
@HiveType(typeId: 4)
class OdometerEntity extends Equatable {
  @HiveField(0)
  final String id;                   // Odometer reading ID
  @HiveField(1)
  final String vehicleId;            // Associated vehicle
  @HiveField(2)
  final double reading;              // Odometer reading value
  @HiveField(3)
  final DateTime recordedAt;          // When reading was taken
  @HiveField(4)
  final String? imagePath;           // Photo of odometer
  @HiveField(5)
  final String? notes;               // Additional notes
}
```

**Purpose**: Represents odometer readings for vehicles
**Properties**:
- `id`: Unique identifier for the reading
- `vehicleId`: ID of the associated vehicle
- `reading`: Odometer reading value
- `recordedAt`: When the reading was taken
- `imagePath`: Photo of the odometer (optional)
- `notes`: Additional notes (optional)

### 4. Ride States (BLoC States)
```dart
abstract class RideState extends Equatable {}

class RideInitial extends RideState {}                    // Initial state
class RideLoading extends RideState {}                    // Loading state
class RideLoaded extends RideState {                      // Successfully loaded
  final List<RideEntity> rides;
}
class RideActive extends RideState {                      // Active ride
  final RideEntity currentRide;
}
class RideCompleted extends RideState {                   // Ride completed
  final RideEntity completedRide;
}
class RideError extends RideState {                       // Error state
  final String message;
}
```

**Purpose**: State management for ride operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: Ride data successfully loaded
- **Active**: Currently tracking a ride
- **Completed**: Ride successfully completed
- **Error**: When operations fail

### 5. Ride Events (BLoC Events)
```dart
abstract class RideEvent extends Equatable {}

class StartRideEvent extends RideEvent {                  // Start new ride
  final String vehicleId;
  final GeoPoint startLocation;
}
class EndRideEvent extends RideEvent {                    // End current ride
  final GeoPoint endLocation;
}
class SaveRideEvent extends RideEvent {                   // Save ride data
  final RideEntity ride;
}
class GetRidesEvent extends RideEvent {                   // Get ride history
  final String userId;
}
class UploadRideEvent extends RideEvent {                // Upload to cloud
  final RideEntity ride;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **StartRideEvent**: Start tracking a new ride
- **EndRideEvent**: End the current ride
- **SaveRideEvent**: Save ride data locally
- **GetRidesEvent**: Fetch ride history
- **UploadRideEvent**: Upload ride to cloud storage

## Technical Implementation Details

### File Structure
```
lib/features/ride/
├── data/
│   ├── datasources/
│   │   ├── ride_firestore_datasource.dart
│   │   └── ride_local_datasource.dart
│   ├── models/
│   │   ├── odometer_model.dart
│   │   ├── ride_memory_model.dart
│   │   └── ride_model.dart
│   └── repositories/
│       └── ride_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── odometer_entity.dart
│   │   ├── ride_entity.dart
│   │   └── ride_memory_entity.dart
│   ├── repositories/
│   │   └── ride_repository.dart
│   └── usecases/
│       ├── get_all_rides_by_user_id.dart
│       ├── get_recent_ride_memories_by_user_id.dart
│       ├── get_recent_rides_by_user_id.dart
│       ├── get_ride_locally.dart
│       ├── save_ride_locally.dart
│       └── upload_ride.dart
└── presentation/
    ├── bloc/
    │   ├── ride_bloc.dart
    │   ├── ride_event.dart
    │   └── ride_state.dart
    ├── screens/
    │   ├── my_ride_screen.dart
    │   ├── odometer_camera_screen.dart
    │   ├── odometer_preview_screen.dart
    │   ├── ride_details_screen.dart
    │   ├── ride_screen.dart
    │   ├── ride_vehicle_screen.dart
    │   └── save_ride_screen.dart
    └── widgets/
        ├── ride_capture_memory_button.dart
        ├── ride_memories_gallery.dart
        ├── ride_sos_dilogue.dart
        ├── save_ride_info_row.dart
        └── save_ride_section.dart
```

### Key Classes and Their Responsibilities

#### 1. RideBloc
**Location**: `lib/features/ride/presentation/bloc/ride_bloc.dart`
**Responsibilities**:
- Handle ride events
- Manage ride state
- Coordinate between use cases and UI
- Handle GPS tracking
- Manage ride lifecycle

**Key Methods**:
- `_onStartRide()`: Handles starting a new ride
- `_onEndRide()`: Handles ending the current ride
- `_onSaveRide()`: Handles saving ride data
- `_onGetRides()`: Handles fetching ride history
- `_onUploadRide()`: Handles uploading ride to cloud

#### 2. RideRepositoryImpl
**Location**: `lib/features/ride/data/repositories/ride_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Coordinate between local and remote data sources
- Handle data synchronization
- Manage error handling and data transformation

#### 3. RideFirestoreDataSource
**Location**: `lib/features/ride/data/datasources/ride_firestore_datasource.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage ride data in cloud
- Handle ride synchronization
- Provide cloud data access

#### 4. RideLocalDataSource
**Location**: `lib/features/ride/data/datasources/ride_local_datasource.dart`
**Responsibilities**:
- Handle Hive local storage operations
- Manage offline ride data
- Handle local data persistence
- Provide offline data access

### Ride Management Flow

#### Start Ride Flow
1. User selects vehicle and taps "Start Ride"
2. `StartRideEvent` is dispatched with vehicle ID and start location
3. `RideBloc` emits `RideLoading` state
4. System creates new `RideEntity` with:
   - Unique ID generated
   - Current timestamp
   - Start coordinates
   - Status set to "active"
5. GPS tracking begins
6. `RideActive` state is emitted with current ride
7. UI shows active ride interface with tracking

#### End Ride Flow
1. User taps "End Ride" button
2. `EndRideEvent` is dispatched with end location
3. `RideBloc` emits `RideLoading` state
4. System calculates ride metrics:
   - Total distance from GPS points
   - Total time from start to end
   - Average and top speeds
   - Gem coins earned based on distance
5. Ride status updated to "completed"
6. Ride data saved locally
7. `RideCompleted` state is emitted
8. UI shows ride summary and save options

#### Save Ride Flow
1. User reviews ride data and taps "Save Ride"
2. `SaveRideEvent` is dispatched with ride data
3. `RideBloc` calls `SaveRideLocally` use case
4. Use case calls `RideRepository.saveRideLocally()`
5. Repository calls `RideLocalDataSource.saveRide()`
6. Ride data stored in Hive local database
7. Success state is emitted
8. UI shows success message

#### Upload Ride Flow
1. User taps "Upload to Cloud" or automatic sync triggers
2. `UploadRideEvent` is dispatched with ride data
3. `RideBloc` calls `UploadRide` use case
4. Use case calls `RideRepository.uploadRide()`
5. Repository calls `RideFirestoreDataSource.uploadRide()`
6. Ride data uploaded to Firestore
7. Local ride marked as synced
8. Success state is emitted

### Data Storage Structure

#### Firestore Collection Structure
```
rides/
  {rideId}/
    - id: string
    - userId: string
    - vehicleId: string
    - status: string
    - startedAt: timestamp
    - startCoordinates: geopoint
    - endCoordinates: geopoint
    - endedAt: timestamp
    - totalDistance: number
    - totalTime: number
    - totalGEMCoins: number
    - rideTitle: string
    - rideDescription: string
    - topSpeed: number
    - averageSpeed: number
    - routePoints: array of geopoints
    - isPublic: boolean
    - createdAt: timestamp
    - updatedAt: timestamp
```

#### Hive Local Storage Structure
```
ride_box/
  {rideId}/
    - Same structure as Firestore
    - Additional fields for local sync status
```

### GPS Tracking

#### Location Services
- **High Accuracy**: GPS tracking with high precision
- **Background Tracking**: Continue tracking when app is backgrounded
- **Battery Optimization**: Efficient location updates
- **Route Recording**: Continuous GPS point collection

#### Data Collection
- **Location Updates**: Regular GPS coordinate updates
- **Speed Calculation**: Real-time speed calculation
- **Distance Tracking**: Cumulative distance calculation
- **Route Visualization**: Visual route representation

### Ride Memories

#### Memory Capture
- **Photo Capture**: Take photos during rides
- **Video Recording**: Record videos during rides
- **Location Tagging**: Tag memories with GPS coordinates
- **Caption Support**: Add captions to memories

#### Memory Management
- **Local Storage**: Store memories locally first
- **Cloud Upload**: Upload memories to cloud storage
- **Compression**: Optimize file sizes for storage
- **Metadata**: Store capture time and location

### Odometer Integration

#### Odometer Reading
- **Manual Entry**: User enters odometer reading
- **Photo Capture**: Take photo of odometer
- **Validation**: Validate reading accuracy
- **History Tracking**: Track odometer history

#### Reading Management
- **Vehicle Association**: Link readings to specific vehicles
- **Timestamp Recording**: Record when reading was taken
- **Notes Support**: Add notes to readings
- **Image Storage**: Store odometer photos

### Error Handling

#### Exception Types
- `LocationPermissionException`: GPS permission denied
- `LocationServiceException`: Location services unavailable
- `StorageException`: Local storage errors
- `NetworkException`: Network connectivity issues
- `SyncException`: Cloud sync errors

#### Error Scenarios
1. **GPS Permission**: Location permission denied
2. **Location Services**: GPS services disabled
3. **Storage Full**: Local storage full
4. **Network Error**: No internet for cloud sync
5. **Data Corruption**: Invalid ride data

### State Management

#### State Transitions
```
RideInitial → RideLoading → RideLoaded/RideError
RideLoaded → RideLoading → RideActive
RideActive → RideLoading → RideCompleted
RideCompleted → RideLoading → RideLoaded
```

#### State Handling in UI
- `RideInitial`: Show initial state or ride history
- `RideLoading`: Show loading indicator
- `RideLoaded`: Display ride history
- `RideActive`: Show active ride tracking interface
- `RideCompleted`: Show ride completion summary
- `RideError`: Show error message with retry option

### UI Components

#### RideScreen
**Features**:
- Vehicle selection
- Start ride button
- Active ride tracking
- End ride functionality

#### MyRideScreen
**Features**:
- Ride history list
- Ride details view
- Filter and search options
- Statistics overview

#### RideDetailsScreen
**Features**:
- Detailed ride information
- Route visualization
- Memory gallery
- Statistics display

#### SaveRideScreen
**Features**:
- Ride summary
- Edit ride details
- Add memories
- Save and upload options

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test GPS calculation logic

#### Widget Tests
- Test ride screen rendering
- Test state-based UI updates
- Test GPS tracking interface
- Test error state handling

#### Integration Tests
- Test complete ride flow
- Test Firestore integration
- Test Hive local storage
- Test GPS tracking
- Test state management

### Data Flow Architecture

```
Presentation Layer (RideBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore + Hive Local Storage)
```

### Key Data Relationships

1. **Ride Lifecycle**:
   - Ride Start → GPS Tracking → Data Collection → Ride End → Save → Upload

2. **Memory Management**:
   - Memory Capture → Local Storage → Cloud Upload → Association with Ride

3. **Odometer Integration**:
   - Reading Entry → Photo Capture → Validation → Storage → Vehicle Association

4. **Data Synchronization**:
   - Local Storage → Cloud Upload → Sync Status → Conflict Resolution

5. **Data Persistence**:
   - Rides stored locally and in cloud
   - Real-time synchronization
   - Offline capability
   - Historical data maintained
