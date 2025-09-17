# License Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Driving License Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore + Firebase Storage |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, firebase_storage, flutter_bloc, dartz, equatable |

## Overview

The License feature manages driving license verification and submission in the Go Extra Mile application. It handles license document upload, verification status tracking, and provides users with a way to submit and manage their driving licenses for verification.

### Key Features
- **License Submission**: Upload front and back images of driving license
- **Verification Status**: Track verification status (pending, rejected, verified)
- **Document Management**: Store license images in Firebase Storage
- **Data Persistence**: Store license data in Firestore
- **Status Tracking**: Real-time verification status updates
- **Image Handling**: Front and back image upload and management

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. DrivingLicenseEntity (Domain Entity)
```dart
class DrivingLicenseEntity extends Equatable {
  final String licenseType;                              // Type of license (A, B, C, etc.)
  final String frontImagePath;                          // Path to front image in storage
  final String backImagePath;                           // Path to back image in storage
  final DateTime dob;                                   // Date of birth from license
  final DrivingLicenseVerificationStatus verificationStatus; // Verification status
}
```

**Purpose**: Core driving license data representation in the domain layer
**Properties**:
- `licenseType`: Type of driving license (A, B, C, etc.)
- `frontImagePath`: Firebase Storage path to front image
- `backImagePath`: Firebase Storage path to back image
- `dob`: Date of birth extracted from license
- `verificationStatus`: Current verification status

### 2. DrivingLicenseVerificationStatus (Enum)
```dart
enum DrivingLicenseVerificationStatus {
  pending,    // License submitted, awaiting verification
  rejected,   // License rejected by admin
  verified    // License verified and approved
}
```

**Purpose**: Defines the verification status of a driving license
**Values**:
- `pending`: License submitted and awaiting admin verification
- `rejected`: License rejected due to invalid information or images
- `verified`: License verified and approved by admin

### 3. DrivingLicenseModel (Data Model)
```dart
class DrivingLicenseModel extends DrivingLicenseEntity {
  // Inherits all properties from DrivingLicenseEntity
  
  factory DrivingLicenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DrivingLicenseModel(
      licenseType: data['licenseType'] ?? '',
      frontImagePath: data['frontImagePath'] ?? '',
      backImagePath: data['backImagePath'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      verificationStatus: DrivingLicenseVerificationStatus.values.firstWhere(
        (e) => e.name == (data['verificationStatus'] ?? 'pending'),
        orElse: () => DrivingLicenseVerificationStatus.pending,
      ),
    );
  }

  factory DrivingLicenseModel.fromMap(Map<String, dynamic> data) {
    return DrivingLicenseModel(
      licenseType: data['licenseType'] ?? '',
      frontImagePath: data['frontImagePath'] ?? '',
      backImagePath: data['backImagePath'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      verificationStatus: DrivingLicenseVerificationStatus.values.firstWhere(
        (e) => e.name == (data['verificationStatus'] ?? 'pending'),
        orElse: () => DrivingLicenseVerificationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'licenseType': licenseType,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'dob': Timestamp.fromDate(dob),
      'verificationStatus': verificationStatus.name,
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `DrivingLicenseEntity` for domain consistency
- Firestore serialization/deserialization
- Enum handling for database storage
- Timestamp conversion for Firestore compatibility

### 4. Driving License States (BLoC States)
```dart
abstract class DrivingLicenseState extends Equatable {}

class DrivingLicenseInitial extends DrivingLicenseState {}     // Initial state
class DrivingLicenseLoading extends DrivingLicenseState {}     // Loading state
class DrivingLicenseLoaded extends DrivingLicenseState {      // Successfully loaded
  final DrivingLicenseEntity? license;
}
class DrivingLicenseError extends DrivingLicenseState {        // Error state
  final String message;
}
class DrivingLicenseSubmitted extends DrivingLicenseState {    // Successfully submitted
  final DrivingLicenseEntity license;
}
```

**Purpose**: State management for driving license operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: License data successfully loaded (can be null if no license)
- **Error**: When operations fail
- **Submitted**: License successfully submitted

### 5. Driving License Events (BLoC Events)
```dart
abstract class DrivingLicenseEvent extends Equatable {}

class GetDrivingLicenseEvent extends DrivingLicenseEvent {}     // Get license data
class SubmitDrivingLicenseEvent extends DrivingLicenseEvent {  // Submit license
  final DrivingLicenseEntity license;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **GetDrivingLicenseEvent**: Fetch user's driving license data
- **SubmitDrivingLicenseEvent**: Submit new or updated license

### 6. DrivingLicenseParams (Use Case Parameter)
```dart
class DrivingLicenseParams extends Equatable {
  final DrivingLicenseEntity license;

  const DrivingLicenseParams({
    required this.license,
  });

  @override
  List<Object> get props => [license];
}
```

**Purpose**: Parameter wrapper for use case operations
**Properties**:
- `license`: The driving license entity to process

## Technical Implementation Details

### File Structure
```
lib/features/license/
├── data/
│   ├── models/
│   │   └── driving_license_model.dart
│   └── repositories/
│       └── driving_license_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── driving_license.dart
│   ├── repositories/
│   │   └── driving_license_repository.dart
│   └── usecases/
│       ├── get_driving_license.dart
│       └── submit_driving_license.dart
└── presentation/
    ├── bloc/
    │   ├── driving_license_bloc.dart
    │   ├── driving_license_event.dart
    │   └── driving_license_state.dart
    ├── screens/
    │   └── my_driving_license_screen.dart
    └── widgets/
```

### Key Classes and Their Responsibilities

#### 1. DrivingLicenseBloc
**Location**: `lib/features/license/presentation/bloc/driving_license_bloc.dart`
**Responsibilities**:
- Handle driving license events
- Manage license state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onGetDrivingLicenseEvent()`: Handles fetching license data
- `_onSubmitDrivingLicenseEvent()`: Handles license submission

#### 2. DrivingLicenseRepositoryImpl
**Location**: `lib/features/license/data/repositories/driving_license_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle Firestore operations
- Manage Firebase Storage operations
- Handle user authentication
- Manage error handling and data transformation

**Key Methods**:
- `getDrivingLicense()`: Fetch user's driving license
- `submitDrivingLicense()`: Submit new or updated license

#### 3. Use Cases
**Location**: `lib/features/license/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetDrivingLicense`: Fetch driving license data
- `SubmitDrivingLicense`: Submit driving license for verification

### License Management Flow

#### Get License Data Flow
1. User navigates to driving license screen
2. `GetDrivingLicenseEvent` is dispatched
3. `DrivingLicenseBloc` emits `DrivingLicenseLoading` state
4. `GetDrivingLicense` use case is called
5. Use case calls `DrivingLicenseRepository.getDrivingLicense()`
6. Repository queries Firestore: `users/{uid}` document
7. Repository checks for `drivingLicenses` field in user document
8. If field exists: converts to `DrivingLicenseModel`
9. If field doesn't exist: returns null
10. Success state is emitted with license data (or null)
11. UI displays license information or submission form

#### Submit License Flow
1. User fills license form and selects images
2. `SubmitDrivingLicenseEvent` is dispatched with license data
3. `DrivingLicenseBloc` emits `DrivingLicenseLoading` state
4. `SubmitDrivingLicense` use case is called with license data
5. Use case calls `DrivingLicenseRepository.submitDrivingLicense()`
6. Repository uploads images to Firebase Storage:
   - Front image: `licenses/{uid}/front_{timestamp}.jpg`
   - Back image: `licenses/{uid}/back_{timestamp}.jpg`
7. Repository updates Firestore user document with license data
8. License data is stored in `drivingLicenses` field
9. Success state is emitted with submitted license
10. UI shows success message and updated license status

### Data Storage Structure

#### Firestore Document Structure
```
users/
  {uid}/
    - drivingLicenses: {
        licenseType: "B",
        frontImagePath: "licenses/{uid}/front_1234567890.jpg",
        backImagePath: "licenses/{uid}/back_1234567890.jpg",
        dob: Timestamp,
        verificationStatus: "pending"
      }
```

#### Firebase Storage Structure
```
licenses/
  {uid}/
    front_{timestamp}.jpg    // Front image of license
    back_{timestamp}.jpg      // Back image of license
```

### Image Upload Process

#### Image Upload Strategy
1. **Image Selection**: User selects front and back images
2. **Image Processing**: Images are compressed and resized
3. **Storage Upload**: Images uploaded to Firebase Storage
4. **Path Generation**: Unique paths generated with timestamp
5. **Database Update**: Image paths stored in Firestore
6. **Status Update**: Verification status set to "pending"

#### Image Management
- **Unique Naming**: Timestamp-based naming prevents conflicts
- **User Isolation**: Each user has separate storage folder
- **Path Storage**: Storage paths stored in Firestore for retrieval
- **Cleanup**: Old images can be deleted when new ones uploaded

### Error Handling

#### Exception Types
- `ServerFailure`: Firestore operation errors
- `StorageFailure`: Firebase Storage upload errors
- `AuthenticationException`: User authentication errors
- `ValidationException`: License data validation errors

#### Error Scenarios
1. **Image Upload Failure**: Network issues during image upload
2. **Firestore Error**: Database operation failures
3. **Authentication Error**: User not logged in
4. **Validation Error**: Invalid license data
5. **Storage Quota**: Firebase Storage quota exceeded

### State Management

#### State Transitions
```
DrivingLicenseInitial → DrivingLicenseLoading → DrivingLicenseLoaded/DrivingLicenseError
DrivingLicenseLoaded → DrivingLicenseLoading → DrivingLicenseSubmitted/DrivingLicenseError
```

#### State Handling in UI
- `DrivingLicenseInitial`: Show loading or empty state
- `DrivingLicenseLoading`: Show loading indicator
- `DrivingLicenseLoaded`: Display license data or submission form
- `DrivingLicenseError`: Show error message with retry option
- `DrivingLicenseSubmitted`: Show success message and updated data

### UI Components

#### MyDrivingLicenseScreen
**Features**:
- License status display
- License submission form
- Image upload interface
- Verification status indicator
- License details display

#### License Form Components
**Features**:
- License type selection
- Date of birth input
- Front image upload
- Back image upload
- Form validation
- Submit button

### Verification Process

#### Admin Verification Flow
1. **License Submission**: User submits license with images
2. **Status Update**: Status set to "pending"
3. **Admin Review**: Admin reviews license images and data
4. **Decision**: Admin approves or rejects license
5. **Status Update**: Status updated to "verified" or "rejected"
6. **User Notification**: User notified of verification result

#### Status Management
- **Pending**: Default status for new submissions
- **Verified**: License approved and active
- **Rejected**: License rejected, user can resubmit

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test model serialization/deserialization
- Test enum conversions
- Test image upload logic

#### Widget Tests
- Test license screen rendering
- Test state-based UI updates
- Test form validation
- Test image upload interface

#### Integration Tests
- Test complete license submission flow
- Test Firestore integration
- Test Firebase Storage integration
- Test state management

### Data Flow Architecture

```
Presentation Layer (DrivingLicenseBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore + Firebase Storage)
```

### Key Data Relationships

1. **License Lifecycle**:
   - License Creation → Image Upload → Database Storage → Verification → Status Update

2. **Image Management**:
   - Image Selection → Storage Upload → Path Storage → Database Reference

3. **Verification Process**:
   - Submission → Admin Review → Status Update → User Notification

4. **Data Persistence**:
   - License data stored in user document
   - Images stored in Firebase Storage
   - Status tracked in real-time
