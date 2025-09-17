# Referral Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Referral Program Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, firebase_auth, flutter_bloc, equatable |

## Overview

The Referral feature manages the referral program in the Go Extra Mile application. It handles referral code generation, submission, tracking, and provides users with comprehensive referral management capabilities including QR code generation and referral analytics.

### Key Features
- **Referral Code Generation**: Automatic referral code creation for users
- **Referral Code Submission**: Submit and validate referral codes
- **Referral Tracking**: Track who used your referral code
- **Device-based Validation**: Prevent duplicate referrals from same device
- **Referral Analytics**: View referral statistics and history
- **QR Code Generation**: Generate QR codes for easy sharing
- **Referral Rewards**: Track referral-based rewards and benefits

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. MyReferralUserEntity (Domain Entity)
```dart
class MyReferralUserEntity extends Equatable {
  final String userId;                // User ID of referred person
  final String referralCode;          // Referral code used
  final String? displayName;         // Display name of referred user
  final String? photoUrl;            // Profile photo of referred user
  final DateTime? createdAt;          // When referral was made
}
```

**Purpose**: Represents a user who was referred by the current user
**Properties**:
- `userId`: Unique identifier of the referred user
- `referralCode`: The referral code that was used
- `displayName`: Display name of the referred user (optional)
- `photoUrl`: Profile photo URL of the referred user (optional)
- `createdAt`: Timestamp when the referral was made (optional)

### 2. MyReferralUserModel (Data Model)
```dart
class MyReferralUserModel extends MyReferralUserEntity {
  // Inherits all properties from MyReferralUserEntity
  
  factory MyReferralUserModel.fromMap(Map<String, dynamic> map) {
    return MyReferralUserModel(
      userId: map['userId'] ?? '',
      referralCode: map['referralCode'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory MyReferralUserModel.fromFirestoreData(
    Map<String, dynamic> referralData, 
    Map<String, dynamic> userData
  ) {
    return MyReferralUserModel(
      userId: referralData['userId'] ?? '',
      referralCode: referralData['referralCode'] ?? '',
      displayName: userData['displayName'],
      photoUrl: userData['photoUrl'],
      createdAt: (userData['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `MyReferralUserEntity` for domain consistency
- Firestore serialization/deserialization
- Timestamp handling for Firestore compatibility
- Support for both direct mapping and Firestore data combination

### 3. Referral States (BLoC States)
```dart
abstract class ReferralState extends Equatable {}

class ReferralInitial extends ReferralState {}              // Initial state
class ReferralLoading extends ReferralState {}              // Loading state
class ReferralSuccess extends ReferralState {               // Successfully submitted
  final String message;
}
class ReferralDataLoaded extends ReferralState {             // Data successfully loaded
  final String referralCode;
  final List<MyReferralUserEntity> myReferalUsers;
}
class ReferralError extends ReferralState {                 // Error state
  final String message;
}
```

**Purpose**: State management for referral operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Success**: Referral code successfully submitted
- **DataLoaded**: Referral data successfully loaded
- **Error**: When operations fail

### 4. Referral Events (BLoC Events)
```dart
abstract class ReferralEvent extends Equatable {}

class SubmitReferralCodeEvent extends ReferralEvent {       // Submit referral code
  final String referralCode;
}
class GetReferralDataEvent extends ReferralEvent {}         // Get referral data
class ResetReferralEvent extends ReferralEvent {}          // Reset referral state
```

**Purpose**: User actions and system events
**Event Types**:
- **SubmitReferralCodeEvent**: Submit a referral code for validation
- **GetReferralDataEvent**: Fetch user's referral data
- **ResetReferralEvent**: Reset referral state

## Technical Implementation Details

### File Structure
```
lib/features/referral/
├── data/
│   ├── datasources/
│   │   └── referral_remote_datasource.dart
│   ├── models/
│   │   └── my_referral_user_model.dart
│   └── repositories/
│       └── referral_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── my_referral_user_entity.dart
│   ├── referal_repositories.dart
│   └── usecases/
│       ├── get_my_referral_data.dart
│       └── submit_referral_code.dart
└── presentation/
    ├── bloc/
    │   ├── referral_bloc.dart
    │   ├── referral_event.dart
    │   └── referral_state.dart
    └── screens/
        ├── my_referal_qrcode_screen.dart
        ├── refer_and_earn_screen.dart
        └── referral_screen.dart
```

### Key Classes and Their Responsibilities

#### 1. ReferralBloc
**Location**: `lib/features/referral/presentation/bloc/referral_bloc.dart`
**Responsibilities**:
- Handle referral events
- Manage referral state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onSubmitReferralCode()`: Handles referral code submission
- `_onGetReferralData()`: Handles fetching referral data
- `_onResetReferral()`: Handles state reset

#### 2. ReferralRepositoryImpl
**Location**: `lib/features/referral/data/repositories/referral_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. ReferralRemoteDataSourceImpl
**Location**: `lib/features/referral/data/datasources/referral_remote_datasource.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage referral code validation
- Handle device-based validation
- Provide raw data from Firebase

#### 4. Use Cases
**Location**: `lib/features/referral/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `SubmitReferralCode`: Submit and validate referral code
- `GetMyReferralData`: Fetch user's referral data and statistics

### Referral Management Flow

#### Submit Referral Code Flow
1. User enters referral code in the app
2. `SubmitReferralCodeEvent` is dispatched with referral code
3. `ReferralBloc` emits `ReferralLoading` state
4. `SubmitReferralCode` use case is called
5. Use case calls `ReferralRepository.submitReferralCode()`
6. Repository calls `ReferralRemoteDataSource.submitReferralCode()`
7. Data source performs complex validation:
   - Find referrer by referral code
   - Validate referral code exists
   - Check if user is trying to use own code
   - Verify user hasn't already used a referral
   - Check device ID hasn't been used before
   - Validate referrer's device tracking
8. If validation passes, Firestore transaction updates:
   - Current user: Mark referral as used, store referrer info
   - Referrer user: Add referral info, increment count
9. Success state is emitted
10. UI shows success message

#### Get Referral Data Flow
1. User navigates to referral screen
2. `GetReferralDataEvent` is dispatched
3. `ReferralBloc` emits `ReferralLoading` state
4. `GetMyReferralData` use case is called
5. Use case calls `ReferralRepository.getMyReferralData()`
6. Repository calls data source methods:
   - `getReferralCode()`: Get user's referral code
   - `getMyReferalUsers()`: Get list of referred users
7. Data is aggregated and returned
8. Success state is emitted with referral data
9. UI displays referral code and referred users list

### Data Storage Structure

#### Firestore Document Structure
```
users/
  {uid}/
    - referral: {
        referralCode: string,                    // User's referral code
        hasUsedReferral: boolean,                // Whether user used referral
        referralUsedTimestamp: timestamp,         // When referral was used
        referralCodeUsed: string,                 // Code that was used
        referredBy: string,                       // Who referred this user
        deviceId: string,                        // Device ID for validation
        referralUsedBy: [                        // Array of referral records
          {
            userId: string,                      // Referred user ID
            deviceId: string,                    // Referred user's device ID
            timestamp: timestamp,                // When referral was made
            referralCode: string                 // Referral code used
          }
        ],
        totalReferrals: number,                  // Total referrals made
        lastReferralTimestamp: timestamp         // Last referral timestamp
      }
```

### Referral Code Generation

#### Code Generation Strategy
- **Automatic Generation**: Codes generated when user first accesses referral feature
- **Unique Format**: Typically based on user ID or random generation
- **Length**: Usually 6-8 characters for easy sharing
- **Character Set**: Alphanumeric characters for readability

#### Code Validation
- **Existence Check**: Verify referral code exists in database
- **Self-Referral Prevention**: Users cannot use their own codes
- **One-Time Use**: Each user can only use one referral code
- **Device Validation**: Prevent multiple accounts from same device

### Device-based Validation

#### Device Tracking
- **Unique Device ID**: Generated using DeviceInfoService
- **Device Registration**: Track which device used which referral
- **Duplicate Prevention**: Same device cannot be used for multiple referrals
- **Cross-User Validation**: Check device usage across all users

#### Validation Rules
1. **Device Uniqueness**: Each device can only be used once for referrals
2. **User Validation**: Each user can only use one referral code
3. **Referrer Tracking**: Track which devices used each referrer's code
4. **Transaction Safety**: Use Firestore transactions for data consistency

### Error Handling

#### Exception Types
- `InvalidReferralCodeException`: Referral code doesn't exist
- `SelfReferralException`: User trying to use own code
- `AlreadyUsedReferralException`: User already used a referral
- `DeviceAlreadyUsedException`: Device already used for referral
- `ServerFailure`: Firestore operation errors

#### Error Scenarios
1. **Invalid Code**: Referral code doesn't exist
2. **Self Referral**: User trying to use own referral code
3. **Already Used**: User already used a referral code
4. **Device Used**: Device already used for referral
5. **Network Error**: Connection issues during submission

### State Management

#### State Transitions
```
ReferralInitial → ReferralLoading → ReferralSuccess/ReferralError
ReferralInitial → ReferralLoading → ReferralDataLoaded/ReferralError
```

#### State Handling in UI
- `ReferralInitial`: Show initial state or form
- `ReferralLoading`: Show loading indicator
- `ReferralSuccess`: Show success message
- `ReferralDataLoaded`: Display referral data and statistics
- `ReferralError`: Show error message with retry option

### UI Components

#### ReferralScreen
**Features**:
- Referral code input form
- Submit button
- Success/error message display
- Referral statistics display

#### ReferAndEarnScreen
**Features**:
- Referral program information
- Benefits and rewards display
- How to refer instructions
- Share referral code options

#### MyReferralQRCodeScreen
**Features**:
- QR code generation for referral code
- Share options (social media, messaging)
- Referral code display
- Copy to clipboard functionality

### Referral Analytics

#### Statistics Tracking
- **Total Referrals**: Count of successful referrals
- **Referral History**: List of all referred users
- **Recent Activity**: Latest referral activities
- **Reward Tracking**: Referral-based rewards earned

#### Data Aggregation
- **Real-time Updates**: Live referral count updates
- **Historical Data**: Maintain referral history
- **Performance Metrics**: Track referral success rates

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test referral code validation logic

#### Widget Tests
- Test referral screen rendering
- Test state-based UI updates
- Test form validation
- Test error state handling

#### Integration Tests
- Test complete referral flow
- Test Firestore integration
- Test device validation
- Test state management
- Test transaction handling

### Data Flow Architecture

```
Presentation Layer (ReferralBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore)
```

### Key Data Relationships

1. **Referral Lifecycle**:
   - Code Generation → Code Sharing → Code Submission → Validation → Reward

2. **Device Tracking**:
   - Device Registration → Referral Usage → Validation → Prevention

3. **User Relationships**:
   - Referrer → Referral Code → Referred User → Reward Distribution

4. **Data Persistence**:
   - Referral data stored in user documents
   - Real-time synchronization
   - Transaction-based updates
   - Historical data maintained
