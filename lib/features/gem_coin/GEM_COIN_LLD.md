# Gem Coin Feature - Low Level Design (LLD)

## Metadata

| Field | Value |
|-------|-------|
| **Feature Name** | Gem Coin Management |
| **Version** | 1.0.0 |
| **Last Updated** | December 2024 |
| **Architecture Pattern** | Clean Architecture (Domain-Driven Design) |
| **State Management** | BLoC Pattern |
| **Backend Service** | Firebase Firestore |
| **Supported Platforms** | Android, iOS |
| **Dependencies** | cloud_firestore, flutter_bloc, dartz, equatable |

## Overview

The Gem Coin feature manages the virtual currency system in the Go Extra Mile application. It handles transaction history tracking, reward management, and provides users with ways to earn and track their gem coins through various activities.

### Key Features
- **Transaction History**: Complete tracking of all gem coin transactions
- **Reward System**: Multiple reward types (daily, ride, product, event, referral)
- **Transaction Types**: Credit and debit operations
- **Filtering & Search**: Advanced filtering by type, reward category, and time range
- **Balance Tracking**: Real-time balance calculation after each transaction
- **Earning Opportunities**: Multiple ways for users to earn gem coins

### Architecture Components
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: BLoC, screens, and widgets

## Data Models

### 1. GEMCoinHistoryEntity (Domain Entity)
```dart
class GEMCoinHistoryEntity extends Equatable {
  final String id;                                    // Unique transaction ID
  final GEMCoinTransactionType type;                 // Credit or Debit
  final GEMCoinTransactionRewardType rewardType;     // Type of reward
  final int amount;                                   // Transaction amount
  final int? balanceAfter;                           // Balance after transaction
  final String reason;                               // Transaction description
  final DateTime date;                               // Transaction timestamp
}
```

**Purpose**: Core transaction data representation in the domain layer
**Properties**:
- `id`: Unique identifier for each transaction
- `type`: Transaction type (credit/debit)
- `rewardType`: Specific reward category
- `amount`: Number of gem coins involved
- `balanceAfter`: User's balance after this transaction
- `reason`: Human-readable description
- `date`: When the transaction occurred

### 2. GEMCoinTransactionType (Enum)
```dart
enum GEMCoinTransactionType {
  credit,    // Adding coins to wallet
  debit,     // Removing coins from wallet
}
```

**Purpose**: Defines the direction of gem coin flow
**Values**:
- `credit`: Coins added to user's wallet
- `debit`: Coins removed from user's wallet

### 3. GEMCoinTransactionRewardType (Enum)
```dart
enum GEMCoinTransactionRewardType {
  dailyReward,      // Daily check-in rewards
  rideReward,       // Rewards from completing rides
  productReward,    // Rewards from product purchases
  eventReward,      // Special event rewards
  referralReward,   // Referral program rewards
  otherReward,      // Miscellaneous rewards
}
```

**Purpose**: Categorizes different types of rewards
**Values**:
- `dailyReward`: Daily check-in bonuses
- `rideReward`: Rewards for completing rides
- `productReward`: Rewards from product transactions
- `eventReward`: Special promotional rewards
- `referralReward`: Referral program bonuses
- `otherReward`: Other miscellaneous rewards

### 4. GEMCoinHistoryModel (Data Model)
```dart
class GEMCoinHistoryModel extends GEMCoinHistoryEntity {
  // Inherits all properties from GEMCoinHistoryEntity
  
  factory GEMCoinHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GEMCoinHistoryModel(
      id: doc.id,
      type: GEMCoinTransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => GEMCoinTransactionType.credit,
      ),
      rewardType: GEMCoinTransactionRewardType.values.firstWhere(
        (e) => e.toString().split('.').last == data['rewardType'],
        orElse: () => GEMCoinTransactionRewardType.otherReward,
      ),
      amount: (data['amount'] ?? 0).toInt(),
      balanceAfter: data['balanceAfter']?.toInt(),
      reason: data['reason'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'rewardType': rewardType.toString().split('.').last,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'reason': reason,
      'date': Timestamp.fromDate(date),
    };
  }
}
```

**Purpose**: Data layer representation with Firestore integration
**Key Features**:
- Extends `GEMCoinHistoryEntity` for domain consistency
- Firestore serialization/deserialization
- Enum handling for database storage
- Timestamp conversion for Firestore compatibility

### 5. Gem Coin States (BLoC States)
```dart
abstract class GemCoinState extends Equatable {}

class GemCoinInitial extends GemCoinState {}           // Initial state
class GemCoinLoading extends GemCoinState {}           // Loading state
class GemCoinLoaded extends GemCoinState {             // Successfully loaded
  final List<GEMCoinHistoryEntity> history;
}
class GemCoinError extends GemCoinState {              // Error state
  final String message;
}
```

**Purpose**: State management for gem coin operations
**State Types**:
- **Initial**: Default state when feature loads
- **Loading**: During data fetching operations
- **Loaded**: Transaction history successfully loaded
- **Error**: When operations fail

### 6. Gem Coin Events (BLoC Events)
```dart
abstract class GemCoinEvent extends Equatable {}

class LoadGemCoinHistory extends GemCoinEvent {        // Load transaction history
  final String uid;
}
```

**Purpose**: User actions and system events
**Event Types**:
- **LoadGemCoinHistory**: Fetch user's transaction history

## Technical Implementation Details

### File Structure
```
lib/features/gem_coin/
├── data/
│   ├── datasource/
│   │   └── gem_coin_remote_datasource.dart
│   ├── model/
│   │   └── gem_coin_history_model.dart
│   └── repository/
│       └── gem_coin_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── gem_coin_history_entity.dart
│   ├── repositories/
│   │   └── gem_coin_repository.dart
│   └── usecases/
│       └── get_transaction_history.dart
└── presentation/
    ├── bloc/
    │   ├── gem_coin_bloc.dart
    │   ├── gem_coin_event.dart
    │   └── gem_coin_state.dart
    └── screens/
        ├── earn_gem_coin_screen.dart
        └── gem_coins_history_screen.dart
```

### Key Classes and Their Responsibilities

#### 1. GemCoinBloc
**Location**: `lib/features/gem_coin/presentation/bloc/gem_coin_bloc.dart`
**Responsibilities**:
- Handle gem coin events
- Manage transaction history state
- Coordinate between use cases and UI
- Handle error scenarios

**Key Methods**:
- `_onLoadGemCoinHistory()`: Handles loading transaction history

#### 2. GemCoinRepositoryImpl
**Location**: `lib/features/gem_coin/data/repository/gem_coin_repository_impl.dart`
**Responsibilities**:
- Implement domain repository interface
- Handle data source coordination
- Manage error handling and data transformation
- Provide clean data layer abstraction

#### 3. GemCoinRemoteDataSourceImpl
**Location**: `lib/features/gem_coin/data/datasource/gem_coin_remote_datasource.dart`
**Responsibilities**:
- Handle Firestore operations
- Manage transaction history queries
- Handle data serialization/deserialization
- Provide raw data from Firebase

#### 4. GetTransactionHistory (Use Case)
**Location**: `lib/features/gem_coin/domain/usecases/get_transaction_history.dart`
**Responsibilities**:
- Encapsulate business logic for fetching transaction history
- Coordinate with repository layer
- Handle use case specific operations

### Transaction History Flow

#### Load Transaction History Flow
1. User navigates to gem coin history screen
2. `LoadGemCoinHistory` event is dispatched with user UID
3. `GemCoinBloc` calls `GetTransactionHistory` use case
4. Use case calls `GemCoinRepository.getTransactionHistory()`
5. Repository calls `GemCoinRemoteDataSource.getTransactionHistory()`
6. Data source queries Firestore: `users/{uid}/gem_coin_history`
7. Firestore returns documents ordered by date (descending)
8. Documents are converted to `GEMCoinHistoryModel` instances
9. Models are returned as `GEMCoinHistoryEntity` list
10. Success state is emitted with transaction history
11. UI displays filtered and formatted transaction list

### Data Storage Structure

#### Firestore Collection Structure
```
users/
  {uid}/
    gem_coin_history/
      {transactionId}/
        - type: "credit" | "debit"
        - rewardType: "dailyReward" | "rideReward" | etc.
        - amount: number
        - balanceAfter: number (optional)
        - reason: string
        - date: Timestamp
```

#### Query Optimization
- **Ordering**: Transactions ordered by date (descending) for latest first
- **Indexing**: Firestore indexes on `date` field for efficient querying
- **Pagination**: Ready for pagination implementation if needed

### Error Handling

#### Exception Types
- `ServerFailure`: Firestore operation errors
- `NetworkException`: Network connectivity issues
- `DataParsingException`: Data transformation errors

#### Error Scenarios
1. **Network Failure**: No internet connection
2. **Firestore Error**: Database operation failures
3. **Data Parsing Error**: Invalid data format
4. **User Not Found**: Invalid user UID

### State Management

#### State Transitions
```
GemCoinInitial → GemCoinLoading → GemCoinLoaded/GemCoinError
```

#### State Handling in UI
- `GemCoinInitial`: Show empty state or loading
- `GemCoinLoading`: Show loading indicator
- `GemCoinLoaded`: Display transaction history with filters
- `GemCoinError`: Show error message with retry option

### UI Components

#### Gem Coins History Screen
**Features**:
- Transaction history list with filtering
- Filter by transaction type (All, Credit, Debit)
- Filter by reward type (Daily, Ride, Product, Event, Referral, Other)
- Filter by time range (All Time, Today, This Week, This Month, Last 3 Months)
- Transaction details display
- Balance tracking

#### Earn Gem Coin Screen
**Features**:
- Multiple earning opportunities
- Navigation to different reward screens:
  - Daily Reward (Scratch & Earn)
  - Referral Program
  - Ride Rewards
  - Find & Earn
  - Insure & Earn
- Premium earning options

### Testing Strategy

#### Unit Tests
- Test individual use cases
- Test repository implementations
- Test data source methods
- Test model serialization/deserialization
- Test enum conversions

#### Widget Tests
- Test transaction history screen
- Test filtering functionality
- Test state handling in UI
- Test user interactions

#### Integration Tests
- Test complete transaction history flow
- Test Firestore integration
- Test state management
- Test filtering and search functionality

### Data Flow Architecture

```
Presentation Layer (BLoC)
    ↓
Domain Layer (Use Cases)
    ↓
Data Layer (Repository Implementation)
    ↓
Data Sources (Firestore)
```

### Key Data Relationships

1. **Transaction Lifecycle**:
   - User Action → Transaction Creation → Firestore Storage → History Display
   - Balance calculation maintained throughout transaction chain

2. **Reward System Integration**:
   - Different reward types create specific transaction records
   - Each reward type has distinct transaction metadata

3. **Data Persistence**:
   - All transactions stored in Firestore
   - Real-time updates for balance tracking
   - Historical data maintained for analytics

### Filtering and Search Capabilities

#### Filter Options
- **Transaction Type**: All, Credit, Debit
- **Reward Type**: Daily, Ride, Product, Event, Referral, Other, Premium
- **Time Range**: All Time, Today, This Week, This Month, Last 3 Months

#### Implementation
- Client-side filtering for performance
- Real-time filter application
- Combined filter support (type + reward + time)
- Search functionality for transaction descriptions
