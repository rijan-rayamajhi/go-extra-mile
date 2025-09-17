# Notification Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Notification Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, flutter_bloc, dartz, equatable |

## Overview

The Notification feature manages in-app notifications for the Go Extra Mile application. It handles notification creation, delivery, read status management, and provides users with a comprehensive notification center.

### Key Features
- **Notification Center**: Centralized view of all user notifications
- **Read Status Management**: Mark individual or all notifications as read
- **Notification Types**: Support for different notification categories
- **Real-time Updates**: Live notification status updates
- **Notification Deletion**: Remove unwanted notifications
- **Unread Count**: Track unread notification count
- **Notification Details**: Detailed view of individual notifications

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. NotificationEntity (Domain Entity)
```dart
class NotificationEntity extends Equatable {
  final String id;                    // Unique notification identifier
  final String title;                 // Notification title
  final String message;               // Notification content
  final DateTime createdAt;           // Creation timestamp
  final bool isRead;                  // Read status
  final String type;                  // Notification type/category
  final String userId;                // Target user ID
  final DateTime updatedAt;           // Last update timestamp
}
```

**Purpose**: Core notification data representation in the domain layer
**Properties**:
- `id`: Unique identifier for each notification
- `title`: Notification headline
- `message`: Detailed notification content
- `createdAt`: When the notification was created
- `isRead`: Whether the user has read the notification
- `type`: Category of notification (general, ride, reward, etc.)
- `userId`: ID of the user who should receive the notification
- `updatedAt`: Last modification timestamp

### 2. NotificationModel (Data Model)
```dart
class NotificationModel extends NotificationEntity {
  // Inherits all properties from NotificationEntity
  
  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return NotificationModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? 
                 _parseDateTime(map['time']) ?? 
                 DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
      userId: map['userId'] ?? '',
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'time': createdAt.toIso8601String(), // Backward compatibility
      'isRead': isRead,
      'type': type,
      'userId': userId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `NotificationEntity` for domain consistency
- Firestore serialization/deserialization
- Flexible DateTime parsing for various formats
- Backward compatibility support

### 3. Notification States (BLoC States)
```dart
abstract class NotificationState extends Equatable {}

class NotificationInitial extends NotificationState {}        // Initial state
class NotificationLoading extends NotificationState {}         // Loading state
class NotificationLoaded extends NotificationState {          // Successfully loaded
  final List<NotificationEntity> notifications;
}
class NotificationDetailLoaded extends NotificationState {     // Single notification loaded
  final NotificationEntity notification;
}
class NotificationError extends NotificationState {           // Error state
  final String message;
}
```

**Purpose**: State management for notification operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: Notification list successfully loaded
- **DetailLoaded**: Single notification detail loaded
- **Error**: When operations fail

### 4. Notification Events (BLoC Events)
```dart
abstract class NotificationEvent extends Equatable {}

class LoadNotifications extends NotificationEvent {            // Load all notifications
  final String userId;
}
class GetNotificationDetail extends NotificationEvent {        // Get single notification
  final String id;
}
class MarkNotificationAsRead extends NotificationEvent {      // Mark as read
  final String id;
}
class MarkAllNotificationsAsRead extends NotificationEvent {  // Mark all as read
  final String userId;
}
class DeleteNotification extends NotificationEvent {          // Delete notification
  final String id;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **LoadNotifications**: Fetch all notifications for a user
- **GetNotificationDetail**: Fetch specific notification details
- **MarkNotificationAsRead**: Mark individual notification as read
- **MarkAllNotificationsAsRead**: Mark all notifications as read
- **DeleteNotification**: Remove a notification

## Technical Implementation Details

### File Structure
```
lib/features/notification/
├── data/
│   ├── datasources/
│   │   └── notification_remote_datasource.dart
│   ├── notification_model.dart
│   └── repositories/
│       └── notification_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── notification_entity.dart
│   ├── notification_repository.dart
│   └── usecases/
│       ├── delete_notification.dart
│       ├── get_notification_by_id.dart
│       ├── get_notifications.dart
│       ├── mark_all_as_read.dart
│       └── mark_as_read.dart
└── presentation/
    ├── bloc/
    │   ├── notification_bloc.dart
    │   ├── notification_event.dart
    │   └── notification_state.dart
    └── notification_screen.dart
```

### Key Classes and Their Responsibilities

#### 1. NotificationBloc
**Location**: `lib/features/notification/presentation/bloc/notification_bloc.dart`
**Responsibilities**:
- Handle notification events
- Manage notification state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onLoadNotifications()`: Handles loading all notifications
- `_onGetNotificationDetail()`: Handles fetching single notification
- `_onMarkNotificationAsRead()`: Handles marking notification as read
- `_onMarkAllAsRead()`: Handles marking all notifications as read
- `_onDeleteNotification()`: Handles notification deletion

#### 2. NotificationRepositoryImpl
**Location**: `lib/features/notification/data/repositories/notification_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. NotificationRemoteDataSourceImpl
**Location**: `lib/features/notification/data/datasources/notification_remote_datasource.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage notification queries
- Handle read status updates
- Provide raw data from Firebase

#### 4. Use Cases
**Location**: `lib/features/notification/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetNotifications`: Fetch all notifications for a user
- `GetNotificationById`: Fetch specific notification
- `MarkAsRead`: Mark notification as read
- `MarkAllAsRead`: Mark all notifications as read
- `DeleteNotification`: Remove notification

### Notification Management Flow

#### Load Notifications Flow
1. User navigates to notification screen
2. `LoadNotifications` event is dispatched with user ID
3. `NotificationBloc` emits `NotificationLoading` state
4. `GetNotifications` use case is called
5. Use case calls `NotificationRepository.getNotifications()`
6. Repository calls `NotificationRemoteDataSource.getNotifications()`
7. Data source queries Firestore: `users/{userId}/notifications`
8. Notifications are ordered by `createdAt` (descending)
9. Documents are converted to `NotificationModel` instances
10. Models are returned as `NotificationEntity` list
11. Success state is emitted with notification list
12. UI displays notification list

#### Mark as Read Flow
1. User taps on notification or mark as read button
2. `MarkNotificationAsRead` event is dispatched with notification ID
3. `NotificationBloc` calls `MarkAsRead` use case
4. Use case calls `NotificationRepository.markAsRead()`
5. Repository calls `NotificationRemoteDataSource.markAsRead()`
6. Data source updates Firestore document: `isRead: true`
7. Success state is emitted
8. UI updates notification status

#### Delete Notification Flow
1. User swipes to delete or taps delete button
2. `DeleteNotification` event is dispatched with notification ID
3. `NotificationBloc` calls `DeleteNotification` use case
4. Use case calls `NotificationRepository.deleteNotification()`
5. Repository calls `NotificationRemoteDataSource.deleteNotification()`
6. Data source deletes Firestore document
7. Success state is emitted
8. UI removes notification from list

### Data Storage Structure

#### Firestore Collection Structure
```
users/
  {userId}/
    notifications/
      {notificationId}/
        - id: string
        - title: string
        - message: string
        - createdAt: timestamp
        - isRead: boolean
        - type: string
        - userId: string
        - updatedAt: timestamp
```

#### Query Optimization
- **Ordering**: Notifications ordered by `createdAt` (descending) for latest first
- **Indexing**: Firestore indexes on `createdAt` and `isRead` fields
- **Pagination**: Ready for pagination implementation if needed

### Notification Types

#### Supported Types
- **General**: General app notifications
- **Ride**: Ride-related notifications
- **Reward**: Reward and gem coin notifications
- **Referral**: Referral program notifications
- **Vehicle**: Vehicle verification notifications
- **License**: License verification notifications

#### Type-based Features
- **Filtering**: Filter notifications by type
- **Styling**: Different UI styling per type
- **Actions**: Type-specific actions and behaviors

### Error Handling

#### Exception Types
- `ServerFailure`: Firestore operation errors
- `NetworkException`: Network connectivity issues
- `DataParsingException`: Data transformation errors

#### Error Scenarios
1. **Network Failure**: No internet connection
2. **Firestore Error**: Database operation failures
3. **Data Parsing Error**: Invalid notification data format
4. **User Not Found**: Invalid user ID

### State Management

#### State Transitions
```
NotificationInitial → NotificationLoading → NotificationLoaded/NotificationError
NotificationLoaded → NotificationLoading → NotificationDetailLoaded/NotificationError
```

#### State Handling in UI
- `NotificationInitial`: Show empty state or loading
- `NotificationLoading`: Show loading indicator
- `NotificationLoaded`: Display notification list
- `NotificationDetailLoaded`: Show notification details
- `NotificationError`: Show error message with retry option

### UI Components

#### NotificationScreen
**Features**:
- Notification list display
- Pull-to-refresh functionality
- Mark all as read button
- Individual notification actions
- Empty state handling

#### Notification List Item
**Features**:
- Notification title and message
- Read/unread status indicator
- Timestamp display
- Type-based styling
- Swipe-to-delete functionality

### Real-time Updates

#### Live Notification Updates
- **Firestore Listeners**: Real-time notification updates
- **Read Status Sync**: Live read status synchronization
- **New Notifications**: Instant new notification delivery
- **Count Updates**: Real-time unread count updates

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test DateTime parsing logic

#### Widget Tests
- Test notification screen rendering
- Test state-based UI updates
- Test user interactions
- Test error state handling

#### Integration Tests
- Test complete notification flow
- Test Firestore integration
- Test state management
- Test real-time updates

### Data Flow Architecture

```
Presentation Layer (NotificationBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore)
```

### Key Data Relationships

1. **Notification Lifecycle**:
   - Notification Creation → Delivery → Read Status → Deletion

2. **User Association**:
   - Each notification belongs to a specific user
   - User-specific notification queries

3. **Status Management**:
   - Read status tracked per notification
   - Bulk read operations supported

4. **Data Persistence**:
   - All notifications stored in Firestore
   - Real-time synchronization
   - Historical data maintained
