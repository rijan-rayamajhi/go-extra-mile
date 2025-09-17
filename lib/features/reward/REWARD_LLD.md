# Reward Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Daily Reward System |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, flutter_bloc, dartz, equatable |

## Overview

The Reward feature manages the daily reward system in the Go Extra Mile application. It handles daily check-in rewards, streak tracking, reward calculations, and provides users with gamified daily engagement through scratch card mechanics.

### Key Features
- **Daily Rewards**: Daily check-in rewards with gem coins
- **Streak Tracking**: Track consecutive daily rewards
- **Scratch Card Interface**: Interactive scratch card for daily rewards
- **Reward Calculation**: Dynamic reward amount calculation
- **Cooldown Management**: 24-hour cooldown between rewards
- **Progress Tracking**: Visual progress indicators
- **Reward History**: Track reward history and statistics

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. DailyRewardEntity (Domain Entity)
```dart
class DailyRewardEntity extends Equatable {
  final DateTime? lastScratchAt;       // When user last scratched
  final int rewardAmount;             // Amount of gem coins rewarded
  final DateTime nextAvailableAt;     // When next reward is available
  final int streak;                   // Current streak count
}
```

**Purpose**: Core daily reward data representation in the domain layer
**Properties**:
- `lastScratchAt`: Timestamp of last reward claim (optional)
- `rewardAmount`: Number of gem coins to be rewarded
- `nextAvailableAt`: When the next reward becomes available
- `streak`: Current consecutive daily reward streak

### 2. DailyRewardModel (Data Model)
```dart
class DailyRewardModel extends DailyRewardEntity {
  // Inherits all properties from DailyRewardEntity
  
  factory DailyRewardModel.fromMap(Map<String, dynamic> map) {
    return DailyRewardModel(
      lastScratchAt: map['lastScratchAt'] != null 
          ? (map['lastScratchAt'] as Timestamp).toDate() 
          : null,
      rewardAmount: map['rewardAmount']?.toInt() ?? 0,
      nextAvailableAt: map['nextAvailableAt'] != null 
          ? (map['nextAvailableAt'] as Timestamp).toDate() 
          : DateTime.now(),
      streak: map['streak']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastScratchAt': lastScratchAt != null 
          ? Timestamp.fromDate(lastScratchAt!) 
          : null,
      'rewardAmount': rewardAmount,
      'nextAvailableAt': Timestamp.fromDate(nextAvailableAt),
      'streak': streak,
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `DailyRewardEntity` for domain consistency
- Firestore serialization/deserialization
- Timestamp handling for Firestore compatibility
- Default value handling for missing data

### 3. Daily Reward States (BLoC States)
```dart
abstract class DailyRewardState extends Equatable {}

class DailyRewardInitial extends DailyRewardState {}        // Initial state
class DailyRewardLoading extends DailyRewardState {}        // Loading state
class DailyRewardLoaded extends DailyRewardState {          // Successfully loaded
  final DailyRewardEntity reward;
}
class DailyRewardClaimed extends DailyRewardState {          // Successfully claimed
  final DailyRewardEntity reward;
  final int coinsEarned;
}
class DailyRewardError extends DailyRewardState {           // Error state
  final String message;
}
```

**Purpose**: State management for daily reward operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data operations
- **Loaded**: Reward data successfully loaded
- **Claimed**: Reward successfully claimed
- **Error**: When operations fail

### 4. Daily Reward Events (BLoC Events)
```dart
abstract class DailyRewardEvent extends Equatable {}

class GetUserDailyRewardEvent extends DailyRewardEvent {}   // Get reward data
class UpdateRewardEvent extends DailyRewardEvent {          // Update reward
  final DailyRewardEntity reward;
}
class ClaimRewardEvent extends DailyRewardEvent {}          // Claim reward
```

**Purpose**: User actions and system events
**Event Types**:
- **GetUserDailyRewardEvent**: Fetch user's daily reward data
- **UpdateRewardEvent**: Update reward information
- **ClaimRewardEvent**: Claim the daily reward

## Technical Implementation Details

### File Structure
```
lib/features/reward/
├── daily_reward.dart                 // Main reward screen
├── data/
│   ├── models/
│   │   └── daily_reward_model.dart
│   └── repositories/
│       └── daily_reward_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── daily_reward_entity.dart
│   ├── repositories/
│   │   └── daily_reward_repository.dart
│   └── usecases/
│       ├── get_user_daily_reward.dart
│       └── update_reward.dart
└── presentation/
    ├── bloc/
    │   ├── daily_reward_bloc.dart
    │   ├── daily_reward_event.dart
    │   └── daily_reward_state.dart
```

### Key Classes and Their Responsibilities

#### 1. DailyRewardBloc
**Location**: `lib/features/reward/presentation/bloc/daily_reward_bloc.dart`
**Responsibilities**:
- Handle daily reward events
- Manage reward state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onGetUserDailyReward()`: Handles fetching reward data
- `_onUpdateReward()`: Handles reward updates
- `_onClaimReward()`: Handles reward claiming

#### 2. DailyRewardRepositoryImpl
**Location**: `lib/features/reward/data/repositories/daily_reward_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. Use Cases
**Location**: `lib/features/reward/domain/usecases/`
**Responsibilities**:
- Encapsulate business logic
- Provide clean interfaces for data operations
- Handle use case specific operations

**Use Cases**:
- `GetUserDailyReward`: Fetch user's daily reward data
- `UpdateReward`: Update reward information

### Daily Reward Management Flow

#### Get Daily Reward Flow
1. User navigates to daily reward screen
2. `GetUserDailyRewardEvent` is dispatched
3. `DailyRewardBloc` emits `DailyRewardLoading` state
4. `GetUserDailyReward` use case is called
5. Use case calls `DailyRewardRepository.getUserDailyReward()`
6. Repository queries Firestore for user's reward data
7. If no data exists, creates default reward data
8. Reward data is converted to `DailyRewardModel`
9. Model is returned as `DailyRewardEntity`
10. Success state is emitted with reward data
11. UI displays reward information and availability

#### Claim Reward Flow
1. User taps scratch card or claim button
2. `ClaimRewardEvent` is dispatched
3. `DailyRewardBloc` emits `DailyRewardLoading` state
4. System validates reward availability:
   - Check if 24 hours have passed since last claim
   - Verify reward is not already claimed today
5. If valid, reward is processed:
   - Update user's gem coin balance
   - Update streak count
   - Set next available time
   - Record claim timestamp
6. `DailyRewardClaimed` state is emitted with reward data
7. UI shows success animation and updated reward info

### Data Storage Structure

#### Firestore Document Structure
```
users/
  {uid}/
    - dailyReward: {
        lastScratchAt: timestamp,        // Last reward claim time
        rewardAmount: number,            // Current reward amount
        nextAvailableAt: timestamp,      // Next available time
        streak: number                   // Current streak count
      }
```

### Reward Calculation Logic

#### Base Reward Amount
- **Minimum Reward**: Base amount (e.g., 10 gem coins)
- **Streak Bonus**: Additional coins for consecutive days
- **Random Factor**: Small random variation for excitement

#### Streak System
- **Streak Increment**: Increases with consecutive daily claims
- **Streak Reset**: Resets if user misses a day
- **Streak Bonus**: Higher rewards for longer streaks
- **Maximum Streak**: Cap on streak benefits

#### Cooldown Management
- **24-Hour Cooldown**: 24 hours between reward claims
- **Next Available Time**: Calculated from last claim time
- **Grace Period**: Small buffer for timezone differences

### Scratch Card Interface

#### Interactive Elements
- **Scratch Surface**: Interactive scratchable area
- **Reveal Animation**: Smooth reveal of reward amount
- **Particle Effects**: Visual feedback for claiming
- **Sound Effects**: Audio feedback for interactions

#### Visual Design
- **Card Design**: Attractive scratch card appearance
- **Progress Indicators**: Visual streak and cooldown indicators
- **Reward Display**: Clear reward amount presentation
- **Status Messages**: Informative text about availability

### Error Handling

#### Exception Types
- `RewardNotAvailableException`: Reward not yet available
- `AlreadyClaimedException`: Reward already claimed today
- `ServerFailure`: Firestore operation errors
- `NetworkException`: Network connectivity issues

#### Error Scenarios
1. **Reward Not Available**: User tries to claim before cooldown ends
2. **Already Claimed**: User already claimed today's reward
3. **Network Error**: Connection issues during claim
4. **Data Corruption**: Invalid reward data

### State Management

#### State Transitions
```
DailyRewardInitial → DailyRewardLoading → DailyRewardLoaded/DailyRewardError
DailyRewardLoaded → DailyRewardLoading → DailyRewardClaimed/DailyRewardError
```

#### State Handling in UI
- `DailyRewardInitial`: Show loading or empty state
- `DailyRewardLoading`: Show loading indicator
- `DailyRewardLoaded`: Display reward information and scratch card
- `DailyRewardClaimed`: Show success animation and updated data
- `DailyRewardError`: Show error message with retry option

### UI Components

#### DailyRewardScreen
**Features**:
- Scratch card interface
- Streak display
- Cooldown timer
- Reward amount display
- Claim button/scratch area

#### Scratch Card Widget
**Features**:
- Interactive scratch surface
- Reveal animation
- Particle effects
- Sound feedback
- Visual rewards display

#### Progress Indicators
**Features**:
- Streak counter
- Cooldown timer
- Next reward countdown
- Progress bar for streak

### Gamification Elements

#### Engagement Features
- **Visual Feedback**: Attractive animations and effects
- **Progress Tracking**: Clear progress indicators
- **Achievement System**: Streak milestones
- **Social Elements**: Share achievements

#### Psychological Hooks
- **Daily Habit**: Encourages daily app usage
- **FOMO**: Fear of missing out on rewards
- **Progression**: Visible progress and improvement
- **Surprise Element**: Random reward variations

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test reward calculation logic
- Test model serialization/deserialization
- Test streak management

#### Widget Tests
- Test reward screen rendering
- Test state-based UI updates
- Test scratch card interactions
- Test error state handling

#### Integration Tests
- Test complete reward flow
- Test Firestore integration
- Test state management
- Test reward claiming process

### Data Flow Architecture

```
Presentation Layer (DailyRewardBloc)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore)
```

### Key Data Relationships

1. **Reward Lifecycle**:
   - Reward Generation → Availability Check → User Claim → Cooldown → Next Reward

2. **Streak Management**:
   - Daily Claim → Streak Increment → Bonus Calculation → Streak Display

3. **Cooldown System**:
   - Claim Time → Cooldown Calculation → Next Available Time → Availability Check

4. **Data Persistence**:
   - Reward data stored in user document
   - Real-time synchronization
   - Historical data maintained
   - Streak tracking preserved
