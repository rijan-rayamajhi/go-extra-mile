# Home Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Home Dashboard |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore + Local Storage |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, flutter_bloc, firebase_auth, equatable |

## Overview

The Home feature serves as the main dashboard of the Go Extra Mile application. It aggregates data from multiple features to provide users with a comprehensive overview of their activity, statistics, and quick access to key functionalities.

### Key Features
- **Dashboard Overview**: Centralized view of user data and statistics
- **Profile Integration**: User profile image and personal information
- **Notification Management**: Unread notification count and quick access
- **Vehicle Management**: Unverified vehicle count and management
- **Ride History**: Recent rides from both remote and local storage
- **Statistics Display**: Total gem coins, distance, and rides across all users
- **Referral System**: User's referral code display
- **Quick Navigation**: Grid-based navigation to key features
- **Leaderboard**: Top riders and referral rankings
- **Real-time Updates**: Pull-to-refresh functionality

### Architecture Components
- **Domain Layer**: Repository interfaces and use cases
- **Data Layer**: Repository implementations and data coordination
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. HomeLoaded State (Main Data Container)
```dart
class HomeLoaded extends HomeState {
  final String? userProfileImage;           // User's profile image URL
  final String unreadNotificationCount;    // Number of unread notifications
  final String unverifiedVehicleCount;     // Number of unverified vehicles
  final List<RideEntity> remoteRides;     // Recent rides from Firestore
  final List<RideEntity> localRides;       // Recent rides from local storage
  final bool isRefreshing;                 // Refresh state indicator
  final int totalGemCoins;                 // Total gem coins across all users
  final double totalDistance;              // Total distance across all users
  final int totalRides;                    // Total rides across all users
  final String referralCode;               // User's referral code
}
```

**Purpose**: Main data container for home screen state
**Properties**:
- `userProfileImage`: URL to user's profile picture (optional)
- `unreadNotificationCount`: String representation of unread notifications
- `unverifiedVehicleCount`: String representation of unverified vehicles
- `remoteRides`: Recent rides fetched from Firestore
- `localRides`: Recent rides from local database
- `isRefreshing`: Indicates if data is being refreshed
- `totalGemCoins`: Aggregated gem coins from all users
- `totalDistance`: Aggregated distance from all users
- `totalRides`: Aggregated rides from all users
- `referralCode`: User's unique referral code

### 2. Home States (BLoC States)
```dart
abstract class HomeState extends Equatable {}

class HomeInitial extends HomeState {}      // Initial state
class HomeLoading extends HomeState {}      // Loading state
class HomeLoaded extends HomeState {        // Successfully loaded
  // Contains all home data as shown above
}
class HomeError extends HomeState {         // Error state
  final String message;
}
```

**Purpose**: State management for home operations
**State Types**:
- **Initial**: Default state when home screen loads
- **Loading**: During data fetching operations
- **Loaded**: All home data successfully loaded
- **Error**: When operations fail

### 3. Home Events (BLoC Events)
```dart
abstract class HomeEvent extends Equatable {}

class LoadHomeData extends HomeEvent {}     // Initial data load
class RefreshHomeData extends HomeEvent {} // Pull-to-refresh
class GetRecentRides extends HomeEvent {    // Get specific rides
  final String userId;
  final int limit;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **LoadHomeData**: Initial load of all home data
- **RefreshHomeData**: Refresh all home data
- **GetRecentRides**: Fetch specific ride data

### 4. Statistics Data Structure
```dart
Map<String, dynamic> statisticsData = {
  'totalGemCoins': int,      // Total gem coins across all users
  'totalDistance': double,    // Total distance across all users
  'totalRides': int,         // Total rides across all users
}
```

**Purpose**: Aggregated statistics from all users
**Properties**:
- `totalGemCoins`: Sum of all users' gem coins
- `totalDistance`: Sum of all users' total distance
- `totalRides`: Sum of all users' total rides

### 5. Recent Rides Data Structure
```dart
Map<String, List<RideEntity>> rideData = {
  'remoteRides': List<RideEntity>,  // Rides from Firestore
  'localRides': List<RideEntity>,   // Rides from local storage
}
```

**Purpose**: Recent rides from multiple sources
**Properties**:
- `remoteRides`: Recent rides from Firestore (limit: 1)
- `localRides`: Recent rides from local storage (limit: 1)

### 6. LeaderboardUser (Widget Data Model)
```dart
class LeaderboardUser {
  final String imageUrl;      // User's profile image
  final String name;         // User's display name
  final String address;      // User's address
  final String totalKm;      // Total kilometers
  final int totalRides;      // Total rides count
  final int totalCoins;      // Total gem coins
  final String label;        // Category label
}
```

**Purpose**: Data model for leaderboard display
**Properties**:
- `imageUrl`: User's profile picture URL
- `name`: User's display name
- `address`: User's location
- `totalKm`: Total distance traveled
- `totalRides`: Number of rides completed
- `totalCoins`: Total gem coins earned
- `label`: Category or ranking label

## Technical Implementation Details

### File Structure
```
lib/features/home/
├── data/
│   └── home_reposotries_impl.dart
├── domain/
│   ├── entities/
│   ├── home_repositories.dart
│   └── usecases/
│       ├── get_recent_rides.dart
│       ├── get_referral_code.dart
│       ├── get_statistics.dart
│       ├── get_unread_notification.dart
│       ├── get_unverified_vehicle.dart
│       └── get_user_profile_image.dart
└── presentation/
    ├── bloc/
    │   ├── home_bloc.dart
    │   ├── home_event.dart
    │   └── home_state.dart
    ├── home_screen.dart
    └── widgets/
        ├── home_footer_widget.dart
        ├── home_grid_view.dart
        ├── home_leaderboard_widget.dart
        ├── home_profile_image.dart
        ├── home_recent_ride.dart
        ├── home_ride_progress.dart
        └── home_screen_shimmer.dart
```

### Key Classes and Their Responsibilities

#### 1. HomeBloc
**Location**: `lib/features/home/presentation/bloc/home_bloc.dart`
**Responsibilities**:
- Handle home events
- Coordinate multiple use cases
- Manage home state
- Handle parallel data loading
- Error handling and state management

**Key Methods**:
- `_onLoadHomeData()`: Loads all home data in parallel
- `_onRefreshHomeData()`: Handles pull-to-refresh

#### 2. HomeRepositoriesImpl
**Location**: `lib/features/home/data/home_reposotries_impl.dart`
**Responsibilities**:
- Implement home repository interface
- Coordinate multiple data sources
- Handle user authentication
- Aggregate data from different features
- Manage error handling

**Key Methods**:
- `getUserProfileImage()`: Fetch user profile image
- `getUnreadNotification()`: Get unread notification count
- `getUnverifiedVehicle()`: Get unverified vehicle count
- `getRecentRides()`: Fetch recent rides from multiple sources
- `getStatistics()`: Aggregate statistics from all users
- `getReferralCode()`: Get user's referral code

#### 3. Use Cases
**Location**: `lib/features/home/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetUserProfileImage`: Fetch user profile image
- `GetUnreadNotification`: Get unread notification count
- `GetUnverifiedVehicle`: Get unverified vehicle count
- `GetRecentRidesUseCase`: Fetch recent rides
- `GetStatisticsUseCase`: Get aggregated statistics
- `GetReferralCodeUseCase`: Get referral code

### Data Loading Flow

#### Initial Home Data Load Flow
1. User navigates to home screen
2. `LoadHomeData` event is dispatched
3. `HomeBloc` emits `HomeLoading` state
4. All use cases are called in parallel:
   - `getUserProfileImage()`
   - `getUnreadNotification()`
   - `getUnverifiedVehicle()`
   - `getRecentRides()`
   - `getStatistics()`
   - `getReferralCode()`
5. Repository coordinates with multiple data sources:
   - Profile data source for user image
   - Notification data source for unread count
   - Vehicle data source for unverified count
   - Ride data sources (Firestore + Local) for recent rides
   - Firestore for statistics aggregation
   - Referral repository for referral code
6. All data is aggregated into `HomeLoaded` state
7. UI updates with loaded data

#### Refresh Data Flow
1. User performs pull-to-refresh gesture
2. `RefreshHomeData` event is dispatched
3. `HomeBloc` sets `isRefreshing: true` in state
4. Same parallel loading process as initial load
5. New data replaces existing data in state
6. `isRefreshing` is set to `false`

### Data Sources Integration

#### External Data Sources
- **ProfileDataSource**: User profile image
- **NotificationRemoteDataSource**: Unread notifications
- **VehicleFirestoreDataSource**: Vehicle verification status
- **RideFirestoreDataSource**: Remote ride data
- **RideLocalDatasource**: Local ride data
- **ReferalRepository**: Referral code
- **FirebaseFirestore**: Statistics aggregation

#### Data Aggregation Strategy
- **Parallel Loading**: All data sources called simultaneously
- **Error Handling**: Individual failures don't block other data
- **Fallback Values**: Default values for missing data
- **Caching**: Local data used as fallback for remote data

### UI Components

#### HomeScreen
**Features**:
- Main dashboard layout
- State-based rendering (loading, loaded, error)
- Pull-to-refresh functionality
- Error handling with retry option

#### HomeGridView
**Features**:
- 4-column grid layout
- Quick navigation to key features:
  - My Vehicles (with unverified count badge)
  - My License
  - My Rides
  - Gem Coins History
- Badge indicators for notifications and unverified items

#### HomeLeaderboardWidget
**Features**:
- Top riders display
- Horizontal scrollable categories
- Referral leaderboard
- User ranking display

#### HomeRecentRide
**Features**:
- Recent ride display
- Ride progress tracking
- Quick ride access

#### HomeScreenShimmer
**Features**:
- Loading state animation
- Skeleton loading for better UX
- Matches actual content layout

### Error Handling

#### Error Scenarios
1. **Network Failure**: No internet connection
2. **Authentication Error**: User not logged in
3. **Data Source Error**: Individual data source failures
4. **Firestore Error**: Database operation failures
5. **Local Storage Error**: Local data access issues

#### Error Recovery
- **Retry Mechanism**: Retry button in error state
- **Partial Loading**: Continue with available data
- **Fallback Values**: Default values for missing data
- **User Feedback**: Clear error messages

### State Management

#### State Transitions
```
HomeInitial → HomeLoading → HomeLoaded/HomeError
HomeLoaded → HomeLoaded (isRefreshing: true) → HomeLoaded (isRefreshing: false)
```

#### State Handling in UI
- `HomeInitial`: Show shimmer loading
- `HomeLoading`: Show shimmer loading
- `HomeLoaded`: Display all home data
- `HomeError`: Show error message with retry option

### Performance Optimizations

#### Parallel Data Loading
- All use cases executed simultaneously
- Reduces total loading time
- Better user experience

#### Data Caching
- Local ride data as fallback
- Profile image caching
- Statistics caching

#### Efficient Queries
- Limited recent rides (limit: 1)
- Optimized Firestore queries
- Minimal data transfer

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data aggregation logic
- Test error handling scenarios

#### Widget Tests
- Test home screen rendering
- Test state-based UI updates
- Test user interactions
- Test error state handling

#### Integration Tests
- Test complete data loading flow
- Test multiple data source integration
- Test state management
- Test refresh functionality

### Data Flow Architecture

```
Presentation Layer (HomeBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (HomeRepositoriesImpl)
    ↓
Multiple Data Sources (Profile, Notification, Vehicle, Ride, Referral, Firestore)
```

### Key Data Relationships

1. **User Data Integration**:
   - Profile image from profile service
   - Notification count from notification service
   - Vehicle status from vehicle service

2. **Ride Data Aggregation**:
   - Remote rides from Firestore
   - Local rides from local database
   - Combined recent rides display

3. **Statistics Aggregation**:
   - All users' data aggregated
   - Real-time statistics calculation
   - Global metrics display

4. **Cross-Feature Integration**:
   - Home coordinates with multiple features
   - Centralized data aggregation
   - Unified user experience
