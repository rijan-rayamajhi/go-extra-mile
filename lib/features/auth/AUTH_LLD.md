# Auth Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Authentication (Auth) |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Authentication + Firestore |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | firebase_auth, google_sign_in, sign_in_with_apple, cloud_firestore, flutter_bloc |

## Overview

The Auth feature is responsible for managing user authentication and account lifecycle in the Go Extra Mile application. It implements a comprehensive authentication system that supports multiple sign-in methods, user management, and account recovery mechanisms.

### Key Features
- **Multi-Provider Authentication**: Google Sign-In and Apple Sign-In
- **User Lifecycle Management**: New user creation, existing user authentication
- **Account Management**: Account deletion, restoration, and soft deletion tracking
- **FCM Token Management**: Push notification token handling
- **State Management**: Comprehensive BLoC-based state handling
- **Error Handling**: Robust error management with user-friendly messages

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. UserEntity (Domain Entity)
```dart
class UserEntity extends Equatable {
  final String uid;           // Unique user identifier
  final String? displayName;  // User's display name
  final String? email;        // User's email address
  final String? photoUrl;     // User's profile photo URL
  final String? userName;     // User's username
}
```

**Purpose**: Core user data representation in the domain layer
**Properties**:
- `uid`: Firebase UID (required)
- `displayName`: User's preferred display name (optional)
- `email`: User's email address (optional)
- `photoUrl`: URL to user's profile picture (optional)
- `userName`: Username for the application (optional)

### 2. UserModel (Data Model)
```dart
class UserModel extends UserEntity {
  // Inherits all properties from UserEntity
  
  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      userName: user.displayName,
    );
  }
}
```

**Purpose**: Data layer representation with Firebase integration
**Key Features**:
- Extends `UserEntity` for domain consistency
- Factory constructor for Firebase User conversion
- Handles data transformation between Firebase and domain layers

### 3. AccountDeletionInfo (Domain Entity)
```dart
class AccountDeletionInfo {
  final String uid;           // User's unique identifier
  final String reason;        // Reason for account deletion
  final DateTime createdAt;   // Deletion timestamp
}
```

**Purpose**: Tracks soft-deleted accounts for potential restoration
**Properties**:
- `uid`: Reference to the deleted user
- `reason`: Reason provided for account deletion
- `createdAt`: Timestamp when account was deleted

### 4. AccountDeletionInfoModel (Data Model)
```dart
class AccountDeletionInfoModel extends AccountDeletionInfo {
  factory AccountDeletionInfoModel.fromFirestore(Map<String, dynamic> data) {
    final timestamp = data['createdAt'] as Timestamp?;
    
    return AccountDeletionInfoModel(
      uid: data['uid'] as String,
      reason: data['reason'] as String,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
```

**Purpose**: Firestore integration for account deletion tracking
**Key Features**:
- Firestore serialization/deserialization
- Timestamp handling for Firestore compatibility
- Extends domain entity for consistency

### 5. Authentication States (BLoC States)
```dart
abstract class KAuthState extends Equatable {}

class KAuthInitial extends KAuthState {}           // Initial state
class KAuthLoading extends KAuthState {}            // Loading state
class KAuthFailure extends KAuthState {             // Error state
  final String message;
}
class KAuthAuthenticated extends KAuthState {}      // Successfully authenticated
class KAuthDeletedUser extends KAuthState {         // Soft-deleted user
  final AccountDeletionInfo deletionInfo;
}
class KAuthNewUser extends KAuthState {}            // New user registration
```

**Purpose**: State management for authentication flow
**State Types**:
- **Initial**: Default state when app starts
- **Loading**: During authentication operations
- **Failure**: When authentication fails
- **Authenticated**: User successfully signed in
- **DeletedUser**: User account is soft-deleted
- **NewUser**: New user needs to complete registration

### 6. Authentication Events (BLoC Events)
```dart
abstract class KAuthEvent extends Equatable {}

class KSignInWithGoogleEvent extends KAuthEvent {}     // Google sign-in
class KSignInWithAppleEvent extends KAuthEvent {}      // Apple sign-in
class KSignOutEvent extends KAuthEvent {}              // Sign out
class KDeleteAccountEvent extends KAuthEvent {         // Delete account
  final String uid;
  final String reason;
}
class KCheckAuthStatusEvent extends KAuthEvent {}       // Check auth status
class KRestoreAccountEvent extends KAuthEvent {         // Restore account
  final String uid;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **Sign In Events**: Trigger authentication flows
- **Sign Out**: User logout
- **Account Management**: Delete/restore account operations
- **Status Check**: Verify current authentication state

## Technical Implementation Details

### File Structure
```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   └── user_firestore_datasource.dart
│   ├── models/
│   │   ├── account_deletion_info_model.dart
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── account_deletion_info.dart
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── check_if_account_deleted.dart
│       ├── check_if_user_exists.dart
│       ├── clear_fcm_token.dart
│       ├── create_new_user.dart
│       ├── delete_account.dart
│       ├── restore_account.dart
│       ├── sign_in_with_apple.dart
│       ├── sign_in_with_google.dart
│       ├── sign_out.dart
│       └── update_fcm_token.dart
└── presentation/
    ├── bloc/
    │   ├── kauth_bloc.dart
    │   ├── kauth_event.dart
    │   └── kauth_state.dart
    ├── screens/
    │   ├── account_deleted_screen.dart
    │   ├── auth_screen.dart
    │   ├── auth_wrapper.dart
    │   └── delete_account_screen.dart
    └── widgets/
        └── auth_terms_condition.dart
```

### Key Classes and Their Responsibilities

#### 1. KAuthBloc
**Location**: `lib/features/auth/presentation/bloc/kauth_bloc.dart`
**Responsibilities**:
- Handle authentication events
- Manage authentication state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onSignInWithGoogle()`: Handles Google sign-in flow
- `_onSignInWithApple()`: Handles Apple sign-in flow
- `_onSignOut()`: Handles user sign-out
- `_onDeleteAccount()`: Handles account deletion
- `_onRestoreAccount()`: Handles account restoration

#### 2. AuthRepositoryImpl
**Location**: `lib/features/auth/data/repositories/auth_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Coordinate between Firebase Auth and Firestore
- Handle data transformation
- Manage FCM token operations

#### 3. FirebaseAuthDataSource
**Location**: `lib/features/auth/data/datasources/firebase_auth_datasource.dart`
**Responsibilities**:
- Handle Firebase Authentication operations
- Manage Google Sign-In configuration
- Handle Apple Sign-In integration
- Provide authentication credentials

#### 4. UserFirestoreDataSource
**Location**: `lib/features/auth/data/datasources/user_firestore_datasource.dart`
**Responsibilities**:
- Manage user data in Firestore
- Handle account deletion/restoration
- Manage FCM token storage
- Handle user profile operations

### Authentication Flow

#### Google Sign-In Flow
1. User taps Google Sign-In button
2. `KSignInWithGoogleEvent` is dispatched
3. `KAuthBloc` calls `SignInWithGoogle` use case
4. Use case calls `AuthRepository.signInWithGoogle()`
5. Repository calls `FirebaseAuthDataSource.signInWithGoogle()`
6. Data source handles Google authentication
7. User data is transformed to `UserModel`
8. Repository checks if user exists in Firestore
9. If new user: creates user profile
10. If existing user: updates FCM token
11. Appropriate state is emitted

#### Apple Sign-In Flow
1. User taps Apple Sign-In button
2. `KSignInWithAppleEvent` is dispatched
3. `KAuthBloc` calls `SignInWithApple` use case
4. Use case calls `AuthRepository.signInWithApple()`
5. Repository calls `FirebaseAuthDataSource.signInWithApple()`
6. Data source handles Apple authentication
7. User data is transformed to `UserModel`
8. Repository checks if user exists in Firestore
9. If new user: creates user profile
10. If existing user: updates FCM token
11. Appropriate state is emitted

### Error Handling

#### Exception Types
- `AuthenticationException`: Firebase authentication errors
- `NetworkException`: Network connectivity issues
- `FirestoreException`: Firestore operation errors

#### Error Scenarios
1. **Authentication Failure**: Invalid credentials, network issues
2. **User Not Found**: User doesn't exist in Firestore
3. **Account Deleted**: User account is soft-deleted
4. **FCM Token Update Failure**: Push notification token update fails

### State Management

#### State Transitions
```
KAuthInitial → KAuthLoading → KAuthAuthenticated/KAuthNewUser/KAuthDeletedUser/KAuthFailure
```

#### State Handling in UI
- `KAuthInitial`: Show authentication screen
- `KAuthLoading`: Show loading indicator
- `KAuthAuthenticated`: Navigate to main screen
- `KAuthNewUser`: Navigate to referral screen
- `KAuthDeletedUser`: Show account deleted screen
- `KAuthFailure`: Show error message

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization

#### Widget Tests
- Test authentication screens
- Test state handling in UI
- Test user interactions

#### Integration Tests
- Test complete authentication flows
- Test Firebase integration
- Test state management

### Data Flow Architecture

```
Presentation Layer (BLoC)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firebase Auth + Firestore)
```

### Key Data Relationships

1. **User Authentication Flow**:
   - Firebase User → UserModel → UserEntity
   - Authentication state tracked through BLoC states

2. **Account Lifecycle**:
   - Active User → Soft Deleted (AccountDeletionInfo) → Restored User
   - FCM token management throughout lifecycle

3. **Data Persistence**:
   - User profiles stored in Firestore
   - Account deletion info maintained for restoration
   - FCM tokens updated for push notifications
