import 'package:go_extra_mile_new/features/leaderboard/domain/leaderboard_entity.dart';

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.id,
    required super.type,
    required super.period,
    required super.periodKey,
    required super.entries,
    required super.totalParticipants,
    required super.lastUpdated,
    required super.periodStart,
    required super.periodEnd,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'] as String,
      type: LeaderboardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LeaderboardType.ride,
      ),
      period: LeaderboardPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => LeaderboardPeriod.weekly,
      ),
      periodKey: json['periodKey'] as String,
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalParticipants: json['totalParticipants'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'period': period.name,
      'periodKey': periodKey,
      'entries': entries.map((e) => (e as LeaderboardEntryModel).toJson()).toList(),
      'totalParticipants': totalParticipants,
      'lastUpdated': lastUpdated.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  LeaderboardModel copyWith({
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
    return LeaderboardModel(
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
}

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.userId,
    required super.displayName,
    required super.photoUrl,
    required super.address,
    required super.rank,
    required super.score,
    required super.gemCoins,
    required super.lastUpdated,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String,
      address: json['address'] as String,
      rank: json['rank'] as int,
      score: json['score'] as int,
      gemCoins: json['gemCoins'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'address': address,
      'rank': rank,
      'score': score,
      'gemCoins': gemCoins,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  LeaderboardEntryModel copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? address,
    int? rank,
    int? score,
    int? gemCoins,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntryModel(
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
}

class LeaderboardHistoryModel extends LeaderboardHistoryEntity {
  const LeaderboardHistoryModel({
    required super.period,
    required super.periodType,
    required super.leaderboardType,
    required super.top3,
    required super.totalParticipants,
    required super.periodStart,
    required super.periodEnd,
    required super.archivedAt,
  });

  factory LeaderboardHistoryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardHistoryModel(
      period: json['period'] as String,
      periodType: LeaderboardPeriod.values.firstWhere(
        (e) => e.name == json['periodType'],
        orElse: () => LeaderboardPeriod.weekly,
      ),
      leaderboardType: LeaderboardType.values.firstWhere(
        (e) => e.name == json['leaderboardType'],
        orElse: () => LeaderboardType.ride,
      ),
      top3: (json['top3'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalParticipants: json['totalParticipants'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      archivedAt: DateTime.parse(json['archivedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'periodType': periodType.name,
      'leaderboardType': leaderboardType.name,
      'top3': top3.map((e) => (e as LeaderboardEntryModel).toJson()).toList(),
      'totalParticipants': totalParticipants,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'archivedAt': archivedAt.toIso8601String(),
    };
  }

  LeaderboardHistoryModel copyWith({
    String? period,
    LeaderboardPeriod? periodType,
    LeaderboardType? leaderboardType,
    List<LeaderboardEntryEntity>? top3,
    int? totalParticipants,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? archivedAt,
  }) {
    return LeaderboardHistoryModel(
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
}

class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({
    required super.userId,
    required super.displayName,
    required super.photoUrl,
    required super.address,
    required super.totalRide,
    required super.totalDistance,
    required super.totalGemCoins,
    super.referralStats,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String,
      address: json['address'] as String,
      totalRide: json['totalRide'] as int,
      totalDistance: json['totalDistance'] as int,
      totalGemCoins: json['totalGemCoins'] as int,
      referralStats: json['referralStats'] != null
          ? ReferralStatsModel.fromJson(json['referralStats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'address': address,
      'totalRide': totalRide,
      'totalDistance': totalDistance,
      'totalGemCoins': totalGemCoins,
      'referralStats': referralStats != null
          ? (referralStats as ReferralStatsModel).toJson()
          : null,
    };
  }

  UserStatsModel copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? address,
    int? totalRide,
    int? totalDistance,
    int? totalGemCoins,
    ReferralStatsEntity? referralStats,
  }) {
    return UserStatsModel(
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
}

class ReferralStatsModel extends ReferralStatsEntity {
  const ReferralStatsModel({
    required super.referralCode,
    required super.totalReferrals,
    super.lastReferralTimestamp,
    required super.referralUsedBy,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      referralCode: json['referralCode'] as String,
      totalReferrals: json['totalReferrals'] as int,
      lastReferralTimestamp: json['lastReferralTimestamp'] != null
          ? DateTime.parse(json['lastReferralTimestamp'] as String)
          : null,
      referralUsedBy: (json['referralUsedBy'] as List<dynamic>?)
          ?.map((e) => ReferralUsedByModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'totalReferrals': totalReferrals,
      'lastReferralTimestamp': lastReferralTimestamp?.toIso8601String(),
      'referralUsedBy': referralUsedBy.map((e) => (e as ReferralUsedByModel).toJson()).toList(),
    };
  }

  ReferralStatsModel copyWith({
    String? referralCode,
    int? totalReferrals,
    DateTime? lastReferralTimestamp,
    List<ReferralUsedByEntity>? referralUsedBy,
  }) {
    return ReferralStatsModel(
      referralCode: referralCode ?? this.referralCode,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      lastReferralTimestamp: lastReferralTimestamp ?? this.lastReferralTimestamp,
      referralUsedBy: referralUsedBy ?? this.referralUsedBy,
    );
  }
}

class ReferralUsedByModel extends ReferralUsedByEntity {
  const ReferralUsedByModel({
    required super.userId,
    required super.deviceId,
    required super.timestamp,
    required super.referralCode,
  });

  factory ReferralUsedByModel.fromJson(Map<String, dynamic> json) {
    return ReferralUsedByModel(
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      referralCode: json['referralCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'referralCode': referralCode,
    };
  }

  ReferralUsedByModel copyWith({
    String? userId,
    String? deviceId,
    DateTime? timestamp,
    String? referralCode,
  }) {
    return ReferralUsedByModel(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}

class LeaderboardUpdateTaskModel extends LeaderboardUpdateTaskEntity {
  const LeaderboardUpdateTaskModel({
    required super.id,
    required super.userId,
    required super.leaderboardType,
    required super.reason,
    required super.priority,
    required super.timestamp,
    required super.retryCount,
    required super.data,
  });

  factory LeaderboardUpdateTaskModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUpdateTaskModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      leaderboardType: LeaderboardType.values.firstWhere(
        (e) => e.name == json['leaderboardType'],
        orElse: () => LeaderboardType.ride,
      ),
      reason: json['reason'] as String,
      priority: json['priority'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'leaderboardType': leaderboardType.name,
      'reason': reason,
      'priority': priority,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'data': data,
    };
  }

  LeaderboardUpdateTaskModel copyWith({
    String? id,
    String? userId,
    LeaderboardType? leaderboardType,
    String? reason,
    int? priority,
    DateTime? timestamp,
    int? retryCount,
    Map<String, dynamic>? data,
  }) {
    return LeaderboardUpdateTaskModel(
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

class LeaderboardConfigModel extends LeaderboardConfigEntity {
  const LeaderboardConfigModel({
    required super.maxConcurrentWorkers,
    required super.batchSize,
    required super.rateLimitPerMinute,
    required super.workerTimeout,
    required super.maxRetries,
    required super.initialRetryDelay,
    required super.maxRetryDelay,
    required super.circuitBreakerThreshold,
    required super.circuitBreakerTimeout,
  });

  factory LeaderboardConfigModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardConfigModel(
      maxConcurrentWorkers: json['maxConcurrentWorkers'] as int,
      batchSize: json['batchSize'] as int,
      rateLimitPerMinute: json['rateLimitPerMinute'] as int,
      workerTimeout: Duration(milliseconds: json['workerTimeout'] as int),
      maxRetries: json['maxRetries'] as int,
      initialRetryDelay: Duration(milliseconds: json['initialRetryDelay'] as int),
      maxRetryDelay: Duration(milliseconds: json['maxRetryDelay'] as int),
      circuitBreakerThreshold: json['circuitBreakerThreshold'] as int,
      circuitBreakerTimeout: Duration(milliseconds: json['circuitBreakerTimeout'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxConcurrentWorkers': maxConcurrentWorkers,
      'batchSize': batchSize,
      'rateLimitPerMinute': rateLimitPerMinute,
      'workerTimeout': workerTimeout.inMilliseconds,
      'maxRetries': maxRetries,
      'initialRetryDelay': initialRetryDelay.inMilliseconds,
      'maxRetryDelay': maxRetryDelay.inMilliseconds,
      'circuitBreakerThreshold': circuitBreakerThreshold,
      'circuitBreakerTimeout': circuitBreakerTimeout.inMilliseconds,
    };
  }

  LeaderboardConfigModel copyWith({
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
    return LeaderboardConfigModel(
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