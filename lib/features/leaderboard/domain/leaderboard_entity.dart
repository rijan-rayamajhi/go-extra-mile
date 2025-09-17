import 'package:equatable/equatable.dart';

// Core Leaderboard Entity
class LeaderboardEntity extends Equatable {
  final String id;
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final String periodKey; // e.g., "2024_12" for December 2024
  final List<LeaderboardEntryEntity> entries;
  final int totalParticipants;
  final DateTime lastUpdated;
  final DateTime periodStart;
  final DateTime periodEnd;

  const LeaderboardEntity({
    required this.id,
    required this.type,
    required this.period,
    required this.periodKey,
    required this.entries,
    required this.totalParticipants,
    required this.lastUpdated,
    required this.periodStart,
    required this.periodEnd,
  });

  LeaderboardEntity copyWith({
    String? id,
    LeaderboardType? type,
    LeaderboardPeriod? period,
    String? periodKey,
    List<LeaderboardEntryEntity>? entries,
    int? totalParticipants,
    DateTime? lastUpdated,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return LeaderboardEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      period: period ?? this.period,
      periodKey: periodKey ?? this.periodKey,
      entries: entries ?? this.entries,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        period,
        periodKey,
        entries,
        totalParticipants,
        lastUpdated,
        periodStart,
        periodEnd,
      ];
}

// Leaderboard Entry Entity
class LeaderboardEntryEntity extends Equatable {
  final String userId;
  final String displayName;
  final String photoUrl;
  final String address;
  final int rank;
  final int score; // rides, distance, or referrals based on type
  final int gemCoins;
  final DateTime lastUpdated;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.displayName,
    required this.photoUrl,
    required this.address,
    required this.rank,
    required this.score,
    required this.gemCoins,
    required this.lastUpdated,
  });

  LeaderboardEntryEntity copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? address,
    int? rank,
    int? score,
    int? gemCoins,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntryEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      gemCoins: gemCoins ?? this.gemCoins,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        address,
        rank,
        score,
        gemCoins,
        lastUpdated,
      ];
}

// Leaderboard History Entity
class LeaderboardHistoryEntity extends Equatable {
  final String period;
  final LeaderboardPeriod periodType;
  final LeaderboardType leaderboardType;
  final List<LeaderboardEntryEntity> top3;
  final int totalParticipants;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime archivedAt;

  const LeaderboardHistoryEntity({
    required this.period,
    required this.periodType,
    required this.leaderboardType,
    required this.top3,
    required this.totalParticipants,
    required this.periodStart,
    required this.periodEnd,
    required this.archivedAt,
  });

  LeaderboardHistoryEntity copyWith({
    String? period,
    LeaderboardPeriod? periodType,
    LeaderboardType? leaderboardType,
    List<LeaderboardEntryEntity>? top3,
    int? totalParticipants,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? archivedAt,
  }) {
    return LeaderboardHistoryEntity(
      period: period ?? this.period,
      periodType: periodType ?? this.periodType,
      leaderboardType: leaderboardType ?? this.leaderboardType,
      top3: top3 ?? this.top3,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  List<Object?> get props => [
        period,
        periodType,
        leaderboardType,
        top3,
        totalParticipants,
        periodStart,
        periodEnd,
        archivedAt,
      ];
}

// Enums
enum LeaderboardType {
  ride,
  distance,
  referrals;

  String get displayName {
    switch (this) {
      case LeaderboardType.ride:
        return 'Rides';
      case LeaderboardType.distance:
        return 'Distance';
      case LeaderboardType.referrals:
        return 'Referrals';
    }
  }

  String get scoreUnit {
    switch (this) {
      case LeaderboardType.ride:
        return 'rides';
      case LeaderboardType.distance:
        return 'km';
      case LeaderboardType.referrals:
        return 'referrals';
    }
  }
}

enum LeaderboardPeriod {
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.yearly:
        return 'Yearly';
    }
  }

  Duration get duration {
    switch (this) {
      case LeaderboardPeriod.weekly:
        return const Duration(days: 7);
      case LeaderboardPeriod.monthly:
        return const Duration(days: 30);
      case LeaderboardPeriod.yearly:
        return const Duration(days: 365);
    }
  }
}

// User Stats Entity (for leaderboard calculations)
class UserStatsEntity extends Equatable {
  final String userId;
  final String displayName;
  final String photoUrl;
  final String address;
  final int totalRide;
  final int totalDistance;
  final int totalGemCoins;
  final ReferralStatsEntity? referralStats;

  const UserStatsEntity({
    required this.userId,
    required this.displayName,
    required this.photoUrl,
    required this.address,
    required this.totalRide,
    required this.totalDistance,
    required this.totalGemCoins,
    this.referralStats,
  });

  UserStatsEntity copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? address,
    int? totalRide,
    int? totalDistance,
    int? totalGemCoins,
    ReferralStatsEntity? referralStats,
  }) {
    return UserStatsEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      totalRide: totalRide ?? this.totalRide,
      totalDistance: totalDistance ?? this.totalDistance,
      totalGemCoins: totalGemCoins ?? this.totalGemCoins,
      referralStats: referralStats ?? this.referralStats,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        address,
        totalRide,
        totalDistance,
        totalGemCoins,
        referralStats,
      ];
}

// Referral Stats Entity
class ReferralStatsEntity extends Equatable {
  final String referralCode;
  final int totalReferrals;
  final DateTime? lastReferralTimestamp;
  final List<ReferralUsedByEntity> referralUsedBy;

  const ReferralStatsEntity({
    required this.referralCode,
    required this.totalReferrals,
    this.lastReferralTimestamp,
    required this.referralUsedBy,
  });

  ReferralStatsEntity copyWith({
    String? referralCode,
    int? totalReferrals,
    DateTime? lastReferralTimestamp,
    List<ReferralUsedByEntity>? referralUsedBy,
  }) {
    return ReferralStatsEntity(
      referralCode: referralCode ?? this.referralCode,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      lastReferralTimestamp: lastReferralTimestamp ?? this.lastReferralTimestamp,
      referralUsedBy: referralUsedBy ?? this.referralUsedBy,
    );
  }

  @override
  List<Object?> get props => [
        referralCode,
        totalReferrals,
        lastReferralTimestamp,
        referralUsedBy,
      ];
}

// Referral Used By Entity
class ReferralUsedByEntity {
  final String userId;
  final String deviceId;
  final DateTime timestamp;
  final String referralCode;

  const ReferralUsedByEntity({
    required this.userId,
    required this.deviceId,
    required this.timestamp,
    required this.referralCode,
  });

  ReferralUsedByEntity copyWith({
    String? userId,
    String? deviceId,
    DateTime? timestamp,
    String? referralCode,
  }) {
    return ReferralUsedByEntity(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}

// Leaderboard Update Task Entity (for processing)
class LeaderboardUpdateTaskEntity {
  final String id;
  final String userId;
  final LeaderboardType leaderboardType;
  final String reason;
  final int priority;
  final DateTime timestamp;
  final int retryCount;
  final Map<String, dynamic> data;

  const LeaderboardUpdateTaskEntity({
    required this.id,
    required this.userId,
    required this.leaderboardType,
    required this.reason,
    required this.priority,
    required this.timestamp,
    required this.retryCount,
    required this.data,
  });

  LeaderboardUpdateTaskEntity copyWith({
    String? id,
    String? userId,
    LeaderboardType? leaderboardType,
    String? reason,
    int? priority,
    DateTime? timestamp,
    int? retryCount,
    Map<String, dynamic>? data,
  }) {
    return LeaderboardUpdateTaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      leaderboardType: leaderboardType ?? this.leaderboardType,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      data: data ?? this.data,
    );
  }
}

// Leaderboard Configuration Entity
class LeaderboardConfigEntity {
  final int maxConcurrentWorkers;
  final int batchSize;
  final int rateLimitPerMinute;
  final Duration workerTimeout;
  final int maxRetries;
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;
  final int circuitBreakerThreshold;
  final Duration circuitBreakerTimeout;

  const LeaderboardConfigEntity({
    required this.maxConcurrentWorkers,
    required this.batchSize,
    required this.rateLimitPerMinute,
    required this.workerTimeout,
    required this.maxRetries,
    required this.initialRetryDelay,
    required this.maxRetryDelay,
    required this.circuitBreakerThreshold,
    required this.circuitBreakerTimeout,
  });

  LeaderboardConfigEntity copyWith({
    int? maxConcurrentWorkers,
    int? batchSize,
    int? rateLimitPerMinute,
    Duration? workerTimeout,
    int? maxRetries,
    Duration? initialRetryDelay,
    Duration? maxRetryDelay,
    int? circuitBreakerThreshold,
    Duration? circuitBreakerTimeout,
  }) {
    return LeaderboardConfigEntity(
      maxConcurrentWorkers: maxConcurrentWorkers ?? this.maxConcurrentWorkers,
      batchSize: batchSize ?? this.batchSize,
      rateLimitPerMinute: rateLimitPerMinute ?? this.rateLimitPerMinute,
      workerTimeout: workerTimeout ?? this.workerTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      initialRetryDelay: initialRetryDelay ?? this.initialRetryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      circuitBreakerThreshold: circuitBreakerThreshold ?? this.circuitBreakerThreshold,
      circuitBreakerTimeout: circuitBreakerTimeout ?? this.circuitBreakerTimeout,
    );
  }
}
