import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import '../leaderboard_entity.dart';

/// Repository interface for leaderboard operations
/// Handles all leaderboard-related data operations including CRUD, real-time updates, and calculations
abstract class LeaderboardRepository {
  // ==================== CORE LEADERBOARD OPERATIONS ====================
  
  /// Get current leaderboard for a specific type and period
  /// Returns the most recent leaderboard data
  Future<Either<Failure, LeaderboardEntity>> getCurrentLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  /// Get leaderboard by specific period key (e.g., "2024_12" for December 2024)
  Future<Either<Failure, LeaderboardEntity>> getLeaderboardByPeriod({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required String periodKey,
  });

  /// Create or update a leaderboard entry
  Future<Either<Failure, void>> upsertLeaderboard(LeaderboardEntity leaderboard);

  /// Delete a leaderboard by ID
  Future<Either<Failure, void>> deleteLeaderboard(String leaderboardId);

  // ==================== LEADERBOARD HISTORY OPERATIONS ====================
  
  /// Get leaderboard history for a specific type and period
  /// Returns list of historical leaderboards sorted by period (most recent first)
  Future<Either<Failure, List<LeaderboardHistoryEntity>>> getLeaderboardHistory({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int limit = 10,
  });

  /// Archive current leaderboard to history
  Future<Either<Failure, void>> archiveLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required String periodKey,
  });

  /// Get specific historical leaderboard
  Future<Either<Failure, LeaderboardHistoryEntity>> getHistoricalLeaderboard({
    required String period,
    required LeaderboardType type,
  });

  // ==================== USER STATS OPERATIONS ====================
  
  /// Get user statistics for leaderboard calculations
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId);

  /// Get multiple users' statistics for batch leaderboard calculations
  Future<Either<Failure, List<UserStatsEntity>>> getUsersStats(List<String> userIds);

  /// Update user statistics (typically called after ride completion or referral)
  Future<Either<Failure, void>> updateUserStats(UserStatsEntity userStats);

  /// Get top N users for a specific leaderboard type
  Future<Either<Failure, List<UserStatsEntity>>> getTopUsers({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int limit = 100,
  });

  // ==================== REAL-TIME OPERATIONS ====================
  
  /// Stream real-time leaderboard updates
  /// Returns a stream that emits leaderboard updates as they happen
  Stream<Either<Failure, LeaderboardEntity>> streamLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  /// Stream leaderboard entry updates for a specific user
  Stream<Either<Failure, LeaderboardEntryEntity>> streamUserLeaderboardEntry({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });

  // ==================== LEADERBOARD CALCULATION OPERATIONS ====================
  
  /// Calculate and update leaderboard for a specific type and period
  /// This method recalculates all rankings based on current user stats
  Future<Either<Failure, LeaderboardEntity>> calculateLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required String periodKey,
  });

  /// Update leaderboard entry for a specific user
  /// Typically called when user completes a ride or gets a referral
  Future<Either<Failure, void>> updateUserLeaderboardEntry({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required String periodKey,
  });

  /// Batch update multiple users' leaderboard entries
  Future<Either<Failure, void>> batchUpdateLeaderboardEntries({
    required List<String> userIds,
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required String periodKey,
  });

  // ==================== LEADERBOARD CONFIGURATION OPERATIONS ====================
  
  /// Get leaderboard configuration settings
  Future<Either<Failure, LeaderboardConfigEntity>> getLeaderboardConfig();

  /// Update leaderboard configuration settings
  Future<Either<Failure, void>> updateLeaderboardConfig(LeaderboardConfigEntity config);

  // ==================== TASK MANAGEMENT OPERATIONS ====================
  
  /// Queue a leaderboard update task
  Future<Either<Failure, void>> queueLeaderboardUpdateTask(LeaderboardUpdateTaskEntity task);

  /// Get pending leaderboard update tasks
  Future<Either<Failure, List<LeaderboardUpdateTaskEntity>>> getPendingUpdateTasks({
    int limit = 50,
  });

  /// Mark a leaderboard update task as completed
  Future<Either<Failure, void>> markTaskCompleted(String taskId);

  /// Mark a leaderboard update task as failed
  Future<Either<Failure, void>> markTaskFailed(String taskId, String error);

  /// Retry a failed leaderboard update task
  Future<Either<Failure, void>> retryTask(String taskId);

  // ==================== UTILITY OPERATIONS ====================
  
  /// Get leaderboard period key for current time
  /// Returns formatted period key (e.g., "2024_12" for December 2024)
  String getCurrentPeriodKey(LeaderboardPeriod period);

  /// Get leaderboard period key for a specific date
  String getPeriodKeyForDate(DateTime date, LeaderboardPeriod period);

  /// Check if a leaderboard period has ended
  bool isPeriodEnded(String periodKey, LeaderboardPeriod period);

  /// Get next period key
  String getNextPeriodKey(String currentPeriodKey, LeaderboardPeriod period);

  /// Get previous period key
  String getPreviousPeriodKey(String currentPeriodKey, LeaderboardPeriod period);

  // ==================== ANALYTICS OPERATIONS ====================
  
  /// Get leaderboard participation statistics
  Future<Either<Failure, Map<String, dynamic>>> getParticipationStats({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int limit = 10,
  });

  /// Get user's leaderboard performance over time
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserPerformanceHistory({
    required String userId,
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int limit = 12,
  });

  /// Get leaderboard trends (growth, participation rates, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getLeaderboardTrends({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int periodsBack = 6,
  });
}
