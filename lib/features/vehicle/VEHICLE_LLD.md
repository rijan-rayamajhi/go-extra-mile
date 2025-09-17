# Vehicle Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Vehicle Management System |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore + Firebase Storage |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, firebase_storage, flutter_bloc, dartz, equatable |

## Overview

The Vehicle feature manages vehicle registration, verification, and management in the Go Extra Mile application. It handles vehicle information, document uploads, verification status tracking, and provides comprehensive vehicle management capabilities.

### Key Features
- **Vehicle Registration**: Add and register new vehicles
- **Document Management**: Upload vehicle documents (RC, Insurance, etc.)
- **Verification System**: Admin verification of vehicle documents
- **Vehicle Types**: Support for different vehicle types (2-wheeler, 4-wheeler)
- **Image Management**: Upload and manage vehicle images
- **Verification Status**: Track verification status (pending, verified, rejected)
- **Vehicle Analytics**: Track vehicle usage and statistics

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. VehicleEntity (Domain Entity)
```dart
class VehicleEntity extends Equatable {
  final String id;                           // Unique vehicle identifier
  final String vehicleType;                  // Type of vehicle (2-wheeler, 4-wheeler)
  final String vehicleBrandImage;            // Brand logo/image URL
  final String vehicleBrandName;             // Brand name
  final String vehicleModelName;             // Model name
  final String vehicleRegistrationNumber;    // Registration number
  final String vehicleTyreType;              // Tyre type
  final VehicleVerificationStatus verificationStatus; // Verification status
  
  // Document Images
  final List<String>? vehicleSlideImages;    // Side view images
  final String? vehicleInsuranceImage;       // Insurance document
  final String? vehicleFrontImage;           // Front view image
  final String? vehicleBackImage;            // Back view image
  final String? vehicleRCFrontImage;         // RC front image
  final String? vehicleRCBackImage;          // RC back image
}
```

**Purpose**: Core vehicle data representation in the domain layer
**Properties**:
- `id`: Unique identifier for each vehicle
- `vehicleType`: Type of vehicle (2-wheeler, 4-wheeler, etc.)
- `vehicleBrandImage`: URL to brand logo/image
- `vehicleBrandName`: Name of the vehicle brand
- `vehicleModelName`: Name of the vehicle model
- `vehicleRegistrationNumber`: Vehicle registration number
- `vehicleTyreType`: Type of tyres (tubeless, tube, etc.)
- `verificationStatus`: Current verification status
- `vehicleSlideImages`: List of side view images
- `vehicleInsuranceImage`: Insurance document image
- `vehicleFrontImage`: Front view image
- `vehicleBackImage`: Back view image
- `vehicleRCFrontImage`: RC document front image
- `vehicleRCBackImage`: RC document back image

### 2. VehicleVerificationStatus (Enum)
```dart
enum VehicleVerificationStatus {
  pending,      // Vehicle submitted, awaiting verification
  rejected,     // Vehicle rejected by admin
  verified,     // Vehicle verified and approved
  notVerified   // Vehicle not yet submitted for verification
}
```

**Purpose**: Defines the verification status of a vehicle
**Values**:
- `pending`: Vehicle submitted and awaiting admin verification
- `rejected`: Vehicle rejected due to invalid documents or information
- `verified`: Vehicle verified and approved by admin
- `notVerified`: Vehicle not yet submitted for verification

### 3. VehicleModel (Data Model)
```dart
class VehicleModel extends VehicleEntity {
  // Inherits all properties from VehicleEntity
  
  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      vehicleBrandImage: map['vehicleBrandImage'] ?? '',
      vehicleBrandName: map['vehicleBrandName'] ?? '',
      vehicleModelName: map['vehicleModelName'] ?? '',
      vehicleRegistrationNumber: map['vehicleRegistrationNumber'] ?? '',
      vehicleTyreType: map['vehicleTyreType'] ?? '',
      verificationStatus: VehicleVerificationStatus.values.firstWhere(
        (e) => e.name == (map['verificationStatus'] ?? 'notVerified'),
        orElse: () => VehicleVerificationStatus.notVerified,
      ),
      vehicleSlideImages: map['vehicleSlideImages'] != null 
          ? List<String>.from(map['vehicleSlideImages']) 
          : null,
      vehicleInsuranceImage: map['vehicleInsuranceImage'],
      vehicleFrontImage: map['vehicleFrontImage'],
      vehicleBackImage: map['vehicleBackImage'],
      vehicleRCFrontImage: map['vehicleRCFrontImage'],
      vehicleRCBackImage: map['vehicleRCBackImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'vehicleBrandImage': vehicleBrandImage,
      'vehicleBrandName': vehicleBrandName,
      'vehicleModelName': vehicleModelName,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'vehicleTyreType': vehicleTyreType,
      'verificationStatus': verificationStatus.name,
      'vehicleSlideImages': vehicleSlideImages,
      'vehicleInsuranceImage': vehicleInsuranceImage,
      'vehicleFrontImage': vehicleFrontImage,
      'vehicleBackImage': vehicleBackImage,
      'vehicleRCFrontImage': vehicleRCFrontImage,
      'vehicleRCBackImage': vehicleRCBackImage,
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `VehicleEntity` for domain consistency
- Firestore serialization/deserialization
- Enum handling for database storage
- Null safety and type conversion

### 4. Vehicle States (BLoC States)
```dart
abstract class VehicleState extends Equatable {}

class VehicleInitial extends VehicleState {}              // Initial state
class VehicleLoading extends VehicleState {}              // Loading state
class VehicleLoaded extends VehicleState {                 // Successfully loaded
  final List<VehicleEntity> vehicles;
}
class VehicleAdded extends VehicleState {                  // Successfully added
  final VehicleEntity vehicle;
}
class VehicleUpdated extends VehicleState {                // Successfully updated
  final VehicleEntity vehicle;
}
class VehicleDeleted extends VehicleState {                // Successfully deleted
  final String vehicleId;
}
class VehicleError extends VehicleState {                  // Error state
  final String message;
}
```

**Purpose**: State management for vehicle operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: Vehicle data successfully loaded
- **Added**: Vehicle successfully added
- **Updated**: Vehicle successfully updated
- **Deleted**: Vehicle successfully deleted
- **Error**: When operations fail

### 5. Vehicle Events (BLoC Events)
```dart
abstract class VehicleEvent extends Equatable {}

class GetUserVehiclesEvent extends VehicleEvent {}        // Get user vehicles
class AddVehicleEvent extends VehicleEvent {               // Add new vehicle
  final VehicleEntity vehicle;
}
class UpdateVehicleEvent extends VehicleEvent {            // Update vehicle
  final VehicleEntity vehicle;
}
class DeleteVehicleEvent extends VehicleEvent {            // Delete vehicle
  final String vehicleId;
}
class VerifyVehicleEvent extends VehicleEvent {           // Verify vehicle
  final String vehicleId;
}
class UploadVehicleImageEvent extends VehicleEvent {       // Upload image
  final String vehicleId;
  final String imageType;
  final File imageFile;
}
class DeleteVehicleImageEvent extends VehicleEvent {       // Delete image
  final String vehicleId;
  final String imageType;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **GetUserVehiclesEvent**: Fetch user's vehicles
- **AddVehicleEvent**: Add new vehicle
- **UpdateVehicleEvent**: Update existing vehicle
- **DeleteVehicleEvent**: Delete vehicle
- **VerifyVehicleEvent**: Submit vehicle for verification
- **UploadVehicleImageEvent**: Upload vehicle image
- **DeleteVehicleImageEvent**: Delete vehicle image

## Technical Implementation Details

### File Structure
```
lib/features/vehicle/
├── data/
│   ├── datasource/
│   │   └── vehicle_firestore_datasource.dart
│   ├── model/
│   │   └── vehicle_model.dart
│   └── repositories/
│       └── vehicle_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── vehicle_entiry.dart
│   ├── repositories/
│   │   └── vehicle_repository.dart
│   └── usecases/
│       ├── add_vehicle.dart
│       ├── delete_vehicle_image.dart
│       ├── delete_vehicle.dart
│       ├── get_user_vehicles.dart
│       ├── upload_vehicle_image.dart
│       └── verify_vehicle.dart
└── presentation/
    ├── bloc/
    │   ├── vehicle_bloc.dart
    │   ├── vehicle_event.dart
    │   └── vehicle_state.dart
    ├── screens/
    │   ├── enter_vehicle_details_screen.dart
    │   ├── my_vechile_screen.dart
    │   ├── my_vehicle_details_screen.dart
    │   ├── my_vehicle_list_screen.dart
    │   ├── my_vehicle_no_vehicle_screen.dart
    │   ├── select_vehicle_type_screen.dart
    │   ├── vehicle_brand_screen.dart
    │   ├── vehicle_model_screen.dart
    │   └── verify_and_earn_screen.dart
    └── widgets/
        ├── my_vehicle_details_insurance_image_widget.dart
        ├── my_vehicle_details_slide_image_widget.dart
        ├── my_vehicle_details_vehicle_image_widget.dart
        ├── my_vehicle_details_vehicle_rc_image_widget.dart
        ├── my_vehicle_grid_view_widget.dart
        └── my_vehicle_list_view_widget.dart
```

### Key Classes and Their Responsibilities

#### 1. VehicleBloc
**Location**: `lib/features/vehicle/presentation/bloc/vehicle_bloc.dart`
**Responsibilities**:
- Handle vehicle events
- Manage vehicle state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onGetUserVehicles()`: Handles fetching user vehicles
- `_onAddVehicle()`: Handles adding new vehicle
- `_onUpdateVehicle()`: Handles updating vehicle
- `_onDeleteVehicle()`: Handles deleting vehicle
- `_onUploadVehicleImage()`: Handles image uploads
- `_onVerifyVehicle()`: Handles vehicle verification

#### 2. VehicleRepositoryImpl
**Location**: `lib/features/vehicle/data/repositories/vehicle_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. VehicleFirestoreDataSource
**Location**: `lib/features/vehicle/data/datasource/vehicle_firestore_datasource.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage vehicle data in cloud
- Handle image uploads to Firebase Storage
- Provide cloud data access

#### 4. Use Cases
**Location**: `lib/features/vehicle/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetUserVehicles`: Fetch user's vehicles
- `AddVehicle`: Add new vehicle
- `DeleteVehicle`: Delete vehicle
- `UploadVehicleImage`: Upload vehicle image
- `DeleteVehicleImage`: Delete vehicle image
- `VerifyVehicle`: Submit vehicle for verification

### Vehicle Management Flow

#### Add Vehicle Flow
1. User navigates to add vehicle screen
2. User selects vehicle type (2-wheeler/4-wheeler)
3. User selects brand and model
4. User enters vehicle details (registration number, tyre type)
5. `AddVehicleEvent` is dispatched with vehicle data
6. `VehicleBloc` emits `VehicleLoading` state
7. `AddVehicle` use case is called
8. Use case calls `VehicleRepository.addVehicle()`
9. Repository calls `VehicleFirestoreDataSource.addVehicle()`
10. Vehicle data stored in Firestore
11. `VehicleAdded` state is emitted
12. UI shows success message and navigates to vehicle list

#### Upload Vehicle Image Flow
1. User selects image type (front, back, RC, insurance, etc.)
2. User selects image from gallery or camera
3. `UploadVehicleImageEvent` is dispatched with vehicle ID, image type, and file
4. `VehicleBloc` emits `VehicleLoading` state
5. `UploadVehicleImage` use case is called
6. Use case calls `VehicleRepository.uploadVehicleImage()`
7. Repository calls `VehicleFirestoreDataSource.uploadVehicleImage()`
8. Image uploaded to Firebase Storage
9. Image URL updated in Firestore vehicle document
10. Success state is emitted
11. UI shows success message and updated image

#### Verify Vehicle Flow
1. User completes all required vehicle information and images
2. User taps "Submit for Verification"
3. `VerifyVehicleEvent` is dispatched with vehicle ID
4. `VehicleBloc` emits `VehicleLoading` state
5. `VerifyVehicle` use case is called
6. Use case calls `VehicleRepository.verifyVehicle()`
7. Repository calls `VehicleFirestoreDataSource.verifyVehicle()`
8. Vehicle verification status updated to "pending"
9. Admin notification sent for verification
10. Success state is emitted
11. UI shows verification pending message

### Data Storage Structure

#### Firestore Collection Structure
```
vehicles/
  {vehicleId}/
    - id: string
    - vehicleType: string
    - vehicleBrandImage: string
    - vehicleBrandName: string
    - vehicleModelName: string
    - vehicleRegistrationNumber: string
    - vehicleTyreType: string
    - verificationStatus: string
    - vehicleSlideImages: array of strings
    - vehicleInsuranceImage: string
    - vehicleFrontImage: string
    - vehicleBackImage: string
    - vehicleRCFrontImage: string
    - vehicleRCBackImage: string
    - userId: string
    - createdAt: timestamp
    - updatedAt: timestamp
```

#### Firebase Storage Structure
```
vehicle_images/
  {vehicleId}/
    front_{timestamp}.jpg          // Front view image
    back_{timestamp}.jpg           // Back view image
    rc_front_{timestamp}.jpg       // RC front image
    rc_back_{timestamp}.jpg         // RC back image
    insurance_{timestamp}.jpg       // Insurance image
    slide_{index}_{timestamp}.jpg  // Side view images
```

### Vehicle Types and Categories

#### Supported Vehicle Types
- **2-Wheeler**: Motorcycles, scooters, bikes
- **4-Wheeler**: Cars, SUVs, trucks

#### Vehicle Categories
- **Personal**: Personal use vehicles
- **Commercial**: Commercial vehicles
- **Electric**: Electric vehicles

### Document Management

#### Required Documents
- **RC (Registration Certificate)**: Front and back images
- **Insurance**: Insurance document image
- **Vehicle Images**: Front, back, and side view images

#### Document Validation
- **Image Quality**: Ensure clear, readable images
- **Document Completeness**: Verify all required documents
- **Format Validation**: Check image formats and sizes
- **Content Validation**: Verify document content matches vehicle info

### Image Upload Process

#### Image Upload Strategy
1. **Image Selection**: User selects image from gallery or camera
2. **Image Processing**: Images compressed and resized
3. **Storage Upload**: Images uploaded to Firebase Storage
4. **Path Generation**: Unique paths generated with timestamp
5. **Database Update**: Image URLs stored in Firestore
6. **UI Update**: Images displayed in vehicle details

#### Image Management
- **Unique Naming**: Timestamp-based naming prevents conflicts
- **Vehicle Isolation**: Each vehicle has separate storage folder
- **URL Storage**: Storage URLs stored in Firestore for retrieval
- **Cleanup**: Old images can be deleted when new ones uploaded

### Verification Process

#### Admin Verification Flow
1. **Vehicle Submission**: User submits vehicle for verification
2. **Status Update**: Status set to "pending"
3. **Admin Review**: Admin reviews vehicle documents and images
4. **Decision**: Admin approves or rejects vehicle
5. **Status Update**: Status updated to "verified" or "rejected"
6. **User Notification**: User notified of verification result

#### Verification Criteria
- **Document Completeness**: All required documents present
- **Image Quality**: Clear, readable images
- **Information Accuracy**: Vehicle details match documents
- **Compliance**: Vehicle meets platform requirements

### Error Handling

#### Exception Types
- `ServerFailure`: Firestore operation errors
- `StorageFailure`: Firebase Storage upload errors
- `ValidationException`: Vehicle data validation errors
- `ImageUploadException`: Image upload failures

#### Error Scenarios
1. **Image Upload Failure**: Network issues during image upload
2. **Firestore Error**: Database operation failures
3. **Validation Error**: Invalid vehicle data
4. **Storage Quota**: Firebase Storage quota exceeded
5. **Permission Error**: Insufficient permissions

### State Management

#### State Transitions
```
VehicleInitial → VehicleLoading → VehicleLoaded/VehicleError
VehicleLoaded → VehicleLoading → VehicleAdded/VehicleError
VehicleLoaded → VehicleLoading → VehicleUpdated/VehicleError
VehicleLoaded → VehicleLoading → VehicleDeleted/VehicleError
```

#### State Handling in UI
- `VehicleInitial`: Show loading or empty state
- `VehicleLoading`: Show loading indicator
- `VehicleLoaded`: Display vehicle list
- `VehicleAdded`: Show success message and updated list
- `VehicleUpdated`: Show success message and updated data
- `VehicleDeleted`: Show success message and updated list
- `VehicleError`: Show error message with retry option

### UI Components

#### MyVehicleScreen
**Features**:
- Vehicle list display
- Add vehicle button
- Vehicle status indicators
- Quick actions

#### VehicleDetailsScreen
**Features**:
- Detailed vehicle information
- Document image gallery
- Verification status display
- Edit vehicle options

#### AddVehicleScreen
**Features**:
- Vehicle type selection
- Brand and model selection
- Vehicle details form
- Document upload interface

#### VerifyAndEarnScreen
**Features**:
- Verification status display
- Document upload interface
- Verification progress
- Reward information

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test image upload logic

#### Widget Tests
- Test vehicle screen rendering
- Test state-based UI updates
- Test form validation
- Test image upload interface
- Test error state handling

#### Integration Tests
- Test complete vehicle management flow
- Test Firestore integration
- Test Firebase Storage integration
- Test state management
- Test image upload process

### Data Flow Architecture

```
Presentation Layer (VehicleBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore + Firebase Storage)
```

### Key Data Relationships

1. **Vehicle Lifecycle**:
   - Vehicle Creation → Document Upload → Verification → Status Update

2. **Image Management**:
   - Image Selection → Storage Upload → URL Storage → Database Reference

3. **Verification Process**:
   - Submission → Admin Review → Decision → Status Update → Notification

4. **Data Persistence**:
   - Vehicle data stored in Firestore
   - Images stored in Firebase Storage
   - Real-time synchronization
   - Historical data maintained
