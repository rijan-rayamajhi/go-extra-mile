# Profile Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | User Profile Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore + Firebase Storage |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, firebase_storage, flutter_bloc, equatable |

## Overview

The Profile feature manages user profile information in the Go Extra Mile application. It handles profile creation, updates, image management, privacy settings, and provides users with comprehensive profile management capabilities.

### Key Features
- **Profile Management**: Complete user profile information management
- **Image Upload**: Profile photo upload and management
- **Privacy Settings**: Control profile visibility and social links
- **Social Links**: Instagram, YouTube, WhatsApp integration
- **Statistics Display**: User ride statistics and achievements
- **Username Management**: Unique username validation and management
- **Profile Editing**: Comprehensive profile editing interface
- **Ride Memories**: User's ride memory gallery

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. ProfileEntity (Domain Entity)
```dart
class ProfileEntity extends Equatable {
  final String uid;                    // User's unique identifier
  final String displayName;           // User's display name
  final String email;                  // User's email address
  final String photoUrl;              // Profile photo URL
  final String? userName;             // Unique username
  final String? gender;               // User's gender
  final double? totalGemCoins;        // Total gem coins earned
  final DateTime? dateOfBirth;        // Date of birth
  final bool? privateProfile;         // Profile privacy setting
  final double? totalDistance;        // Total distance traveled
  final int? totalRide;               // Total rides completed
  final DateTime? createdAt;          // Account creation date
  final DateTime? updatedAt;          // Last update date
  final String? bio;                  // User biography
  final List<String>? interests;      // User interests
  final String? address;              // User address
  final String? instagramLink;        // Instagram profile link
  final String? youtubeLink;          // YouTube channel link
  final String? whatsappLink;         // WhatsApp contact
  final bool? showInstagram;          // Show Instagram publicly
  final bool? showYoutube;            // Show YouTube publicly
  final bool? showWhatsapp;           // Show WhatsApp publicly
  final String? referralCode;          // User's referral code
}
```

**Purpose**: Core user profile data representation in the domain layer
**Properties**:
- `uid`: Firebase UID (required)
- `displayName`: User's preferred display name (required)
- `email`: User's email address (required)
- `photoUrl`: URL to user's profile picture (required)
- `userName`: Unique username for the application (optional)
- `gender`: User's gender (optional)
- `totalGemCoins`: Total gem coins earned (optional)
- `dateOfBirth`: User's date of birth (optional)
- `privateProfile`: Whether profile is private (optional)
- `totalDistance`: Total distance traveled (optional)
- `totalRide`: Total rides completed (optional)
- `createdAt`: Account creation timestamp (optional)
- `updatedAt`: Last update timestamp (optional)
- `bio`: User biography/description (optional)
- `interests`: List of user interests (optional)
- `address`: User's address (optional)
- `instagramLink`: Instagram profile URL (optional)
- `youtubeLink`: YouTube channel URL (optional)
- `whatsappLink`: WhatsApp contact (optional)
- `showInstagram`: Public Instagram visibility (optional)
- `showYoutube`: Public YouTube visibility (optional)
- `showWhatsapp`: Public WhatsApp visibility (optional)
- `referralCode`: User's unique referral code (optional)

### 2. ProfileModel (Data Model)
```dart
class ProfileModel extends ProfileEntity {
  // Inherits all properties from ProfileEntity
  
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      userName: map['userName'],
      gender: map['gender'],
      totalGemCoins: map['totalGemCoins']?.toDouble(),
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate() 
          : null,
      privateProfile: map['privateProfile'],
      totalDistance: map['totalDistance']?.toDouble(),
      totalRide: map['totalRide']?.toInt(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      bio: map['bio'],
      interests: map['interests'] != null 
          ? List<String>.from(map['interests']) 
          : null,
      address: map['address'],
      instagramLink: map['instagramLink'],
      youtubeLink: map['youtubeLink'],
      whatsappLink: map['whatsappLink'],
      showInstagram: map['showInstagram'],
      showYoutube: map['showYoutube'],
      showWhatsapp: map['showWhatsapp'],
      referralCode: map['referralCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'userName': userName,
      'gender': gender,
      'totalGemCoins': totalGemCoins,
      'dateOfBirth': dateOfBirth != null 
          ? Timestamp.fromDate(dateOfBirth!) 
          : null,
      'privateProfile': privateProfile,
      'totalDistance': totalDistance,
      'totalRide': totalRide,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : null,
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!) 
          : null,
      'bio': bio,
      'interests': interests,
      'address': address,
      'instagramLink': instagramLink,
      'youtubeLink': youtubeLink,
      'whatsappLink': whatsappLink,
      'showInstagram': showInstagram,
      'showYoutube': showYoutube,
      'showWhatsapp': showWhatsapp,
      'referralCode': referralCode,
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `ProfileEntity` for domain consistency
- Firestore serialization/deserialization
- Timestamp handling for Firestore compatibility
- Null safety and type conversion

### 3. Profile States (BLoC States)
```dart
abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {}              // Initial state
class ProfileLoading extends ProfileState {}               // Loading state
class ProfileLoaded extends ProfileState {                 // Successfully loaded
  final ProfileEntity profile;
}
class ProfileUpdating extends ProfileState {               // Currently updating
  final ProfileEntity profile;
}
class ProfileUpdated extends ProfileState {                 // Successfully updated
  final ProfileEntity profile;
}
class ProfileError extends ProfileState {                  // Error state
  final String message;
}
class ProfileNotFound extends ProfileState {               // Profile not found
  final String message;
}
class UsernameAvailabilityChecking extends ProfileState {} // Checking username
class UsernameAvailabilityResult extends ProfileState {    // Username check result
  final String username;
  final bool isAvailable;
}
```

**Purpose**: State management for profile operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: Profile data successfully loaded
- **Updating**: Profile currently being updated
- **Updated**: Profile successfully updated
- **Error**: When operations fail
- **NotFound**: Profile doesn't exist
- **UsernameAvailabilityChecking**: Checking username availability
- **UsernameAvailabilityResult**: Username availability result

### 4. Profile Events (BLoC Events)
```dart
abstract class ProfileEvent extends Equatable {}

class GetProfileEvent extends ProfileEvent {               // Get profile data
  final String uid;
}
class UpdateProfileEvent extends ProfileEvent {             // Update profile
  final ProfileEntity profile;
  final File? profilePhotoImageFile;
}
class ResetProfileEvent extends ProfileEvent {}            // Reset profile state
class RefreshProfileEvent extends ProfileEvent {           // Refresh profile
  final String uid;
}
class ToggleProfilePrivacyEvent extends ProfileEvent {     // Toggle privacy
  final String uid;
  final bool isPrivate;
}
class CheckUsernameAvailabilityEvent extends ProfileEvent { // Check username
  final String username;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **GetProfileEvent**: Fetch user profile data
- **UpdateProfileEvent**: Update profile with optional image
- **ResetProfileEvent**: Reset profile state
- **RefreshProfileEvent**: Refresh profile data
- **ToggleProfilePrivacyEvent**: Toggle profile privacy setting
- **CheckUsernameAvailabilityEvent**: Check username availability

## Technical Implementation Details

### File Structure
```
lib/features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_data_source.dart
│   ├── model/
│   │   └── profile_model.dart
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── profile_entity.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── check_username_availability.dart
│       ├── get_profile.dart
│       └── update_profile.dart
└── presentation/
    ├── bloc/
    │   ├── profile_bloc.dart
    │   ├── profile_event.dart
    │   └── profile_state.dart
    ├── screens/
    │   ├── edit_profile_screen.dart
    │   ├── my_profile_screen.dart
    │   ├── profile_ride_memory_details_screen.dart
    │   └── profile_shimmer_loading.dart
    └── widgets/
        ├── edit_profile_address.dart
        ├── edit_profile_bio_field.dart
        ├── edit_profile_display_name_field.dart
        ├── edit_profile_dob.dart
        ├── edit_profile_email_field.dart
        ├── edit_profile_gender.dart
        ├── edit_profile_instagram_field.dart
        ├── edit_profile_photo.dart
        ├── edit_profile_username_field.dart
        ├── edit_profile_whatsapp_field.dart
        ├── edit_profile_youtube_field.dart
        ├── profile_ride_memory_gridview.dart
        └── profile_ride_stats.dart
```

### Key Classes and Their Responsibilities

#### 1. ProfileBloc
**Location**: `lib/features/profile/presentation/bloc/profile_bloc.dart`
**Responsibilities**:
- Handle profile events
- Manage profile state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onGetProfile()`: Handles fetching profile data
- `_onUpdateProfile()`: Handles profile updates
- `_onRefreshProfile()`: Handles profile refresh
- `_onCheckUsernameAvailability()`: Handles username validation

#### 2. ProfileRepositoryImpl
**Location**: `lib/features/profile/data/repositories/profile_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. ProfileDataSourceImpl
**Location**: `lib/features/profile/data/datasources/profile_data_source.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage Firebase Storage operations
- Handle profile image uploads
- Provide raw data from Firebase

#### 4. Use Cases
**Location**: `lib/features/profile/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetProfile`: Fetch user profile data
- `UpdateProfile`: Update profile information
- `CheckUsernameAvailability`: Validate username uniqueness

### Profile Management Flow

#### Get Profile Flow
1. User navigates to profile screen
2. `GetProfileEvent` is dispatched with user UID
3. `ProfileBloc` emits `ProfileLoading` state
4. `GetProfile` use case is called
5. Use case calls `ProfileRepository.getProfile()`
6. Repository calls `ProfileDataSource.getProfile()`
7. Data source queries Firestore: `users/{uid}` document
8. Document data is converted to `ProfileModel`
9. Model is returned as `ProfileEntity`
10. Success state is emitted with profile data
11. UI displays profile information

#### Update Profile Flow
1. User edits profile information and optionally selects new image
2. `UpdateProfileEvent` is dispatched with profile data and image file
3. `ProfileBloc` emits `ProfileUpdating` state
4. `UpdateProfile` use case is called
5. Use case calls `ProfileRepository.updateProfile()`
6. Repository calls `ProfileDataSource.updateProfile()`
7. If image file provided:
   - Image uploaded to Firebase Storage
   - New image URL obtained
   - Profile data updated with new image URL
8. Profile data updated in Firestore
9. Success state is emitted with updated profile
10. UI shows success message and updated data

#### Username Availability Check Flow
1. User types username in edit form
2. `CheckUsernameAvailabilityEvent` is dispatched with username
3. `ProfileBloc` emits `UsernameAvailabilityChecking` state
4. `CheckUsernameAvailability` use case is called
5. Use case calls `ProfileRepository.isUsernameAvailable()`
6. Repository queries Firestore for existing username
7. Availability result returned
8. `UsernameAvailabilityResult` state is emitted
9. UI shows availability status

### Data Storage Structure

#### Firestore Document Structure
```
users/
  {uid}/
    - uid: string
    - displayName: string
    - email: string
    - photoUrl: string
    - userName: string (optional)
    - gender: string (optional)
    - totalGemCoins: number (optional)
    - dateOfBirth: timestamp (optional)
    - privateProfile: boolean (optional)
    - totalDistance: number (optional)
    - totalRide: number (optional)
    - createdAt: timestamp (optional)
    - updatedAt: timestamp (optional)
    - bio: string (optional)
    - interests: array (optional)
    - address: string (optional)
    - instagramLink: string (optional)
    - youtubeLink: string (optional)
    - whatsappLink: string (optional)
    - showInstagram: boolean (optional)
    - showYoutube: boolean (optional)
    - showWhatsapp: boolean (optional)
    - referralCode: string (optional)
```

#### Firebase Storage Structure
```
profile_images/
  {uid}/
    profile_{timestamp}.jpg    // Profile image
```

### Image Upload Process

#### Profile Image Upload Strategy
1. **Image Selection**: User selects new profile image
2. **Image Processing**: Image compressed and resized
3. **Storage Upload**: Image uploaded to Firebase Storage
4. **Path Generation**: Unique path generated with timestamp
5. **Database Update**: Image URL updated in Firestore
6. **UI Update**: Profile image updated in UI

#### Image Management
- **Unique Naming**: Timestamp-based naming prevents conflicts
- **User Isolation**: Each user has separate storage folder
- **URL Storage**: Storage URLs stored in Firestore for retrieval
- **Cleanup**: Old images can be deleted when new ones uploaded

### Social Links Integration

#### Supported Platforms
- **Instagram**: Instagram profile links
- **YouTube**: YouTube channel links
- **WhatsApp**: WhatsApp contact information

#### Privacy Controls
- **Individual Toggle**: Each social link can be shown/hidden
- **Public Visibility**: Control which links are visible to others
- **Profile Privacy**: Overall profile privacy setting

### Username Management

#### Username Validation
- **Uniqueness Check**: Ensure username is unique across platform
- **Real-time Validation**: Check availability as user types
- **Format Validation**: Enforce username format rules
- **Reserved Words**: Prevent use of reserved usernames

### Error Handling

#### Exception Types
- `ServerFailure`: Firestore operation errors
- `StorageFailure`: Firebase Storage upload errors
- `ValidationException`: Profile data validation errors
- `UsernameExistsException`: Username already taken

#### Error Scenarios
1. **Image Upload Failure**: Network issues during image upload
2. **Firestore Error**: Database operation failures
3. **Validation Error**: Invalid profile data
4. **Username Conflict**: Username already exists
5. **Storage Quota**: Firebase Storage quota exceeded

### State Management

#### State Transitions
```
ProfileInitial → ProfileLoading → ProfileLoaded/ProfileError
ProfileLoaded → ProfileUpdating → ProfileUpdated/ProfileError
ProfileLoaded → UsernameAvailabilityChecking → UsernameAvailabilityResult
```

#### State Handling in UI
- `ProfileInitial`: Show loading or empty state
- `ProfileLoading`: Show loading indicator
- `ProfileLoaded`: Display profile data
- `ProfileUpdating`: Show updating indicator
- `ProfileUpdated`: Show success message
- `ProfileError`: Show error message with retry option
- `UsernameAvailabilityChecking`: Show checking indicator
- `UsernameAvailabilityResult`: Show availability status

### UI Components

#### MyProfileScreen
**Features**:
- Profile information display
- Statistics overview
- Social links display
- Edit profile navigation
- Ride memories gallery

#### EditProfileScreen
**Features**:
- Comprehensive profile editing form
- Image upload interface
- Username validation
- Social links management
- Privacy settings
- Form validation

#### Profile Widgets
**Features**:
- Specialized editing widgets for each field
- Real-time validation
- Image upload components
- Social link management
- Statistics display

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test username validation logic

#### Widget Tests
- Test profile screen rendering
- Test state-based UI updates
- Test form validation
- Test image upload interface
- Test username availability checking

#### Integration Tests
- Test complete profile management flow
- Test Firestore integration
- Test Firebase Storage integration
- Test state management
- Test image upload process

### Data Flow Architecture

```
Presentation Layer (ProfileBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore + Firebase Storage)
```

### Key Data Relationships

1. **Profile Lifecycle**:
   - Profile Creation → Data Entry → Image Upload → Validation → Storage

2. **Image Management**:
   - Image Selection → Storage Upload → URL Storage → Database Reference

3. **Social Integration**:
   - Link Entry → Privacy Setting → Public Visibility → Profile Display

4. **Username Management**:
   - Username Entry → Availability Check → Validation → Storage

5. **Data Persistence**:
   - Profile data stored in user document
   - Images stored in Firebase Storage
   - Real-time synchronization
   - Historical data maintained
