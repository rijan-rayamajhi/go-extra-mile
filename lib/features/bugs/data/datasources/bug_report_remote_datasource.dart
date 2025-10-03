import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/service/firebase_firestore_service.dart';
import '../../../../core/service/firebase_storage_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/bug_report_model.dart';

abstract class BugReportRemoteDataSource {
  Future<BugReportModel> submitBugReport(BugReportModel bugReport);
  Future<List<BugReportModel>> getUserBugReports(String userId);
  Future<BugReportModel> getBugReportById(String bugReportId);
  Future<BugReportModel> updateBugReportStatus(
    String bugReportId,
    String status,
    String? adminNotes,
  );
  Future<List<BugReportModel>> getBugReportsByStatus(
    String userId,
    String status,
  );
  Future<Map<String, dynamic>> getUserBugReportStats(String userId);
  Future<void> deleteBugReport(String bugReportId, String userId);
  Future<String> uploadScreenshot(String bugReportId, String imagePath);
  Future<List<BugReportModel>> getAllBugReports();
  Future<BugReportModel> updateBugReportReward(
    String bugReportId,
    int rewardAmount,
  );
  Future<BugReportModel> updateBugReportScreenshots(
    String bugReportId,
    List<String> screenshotUrls,
  );
}

class BugReportRemoteDataSourceImpl implements BugReportRemoteDataSource {
  final FirebaseFirestoreService firestoreService;
  final FirebaseStorageService storageService;
  final FirebaseFirestore firestore;

  BugReportRemoteDataSourceImpl({
    required this.firestoreService,
    required this.storageService,
    required this.firestore,
  });

  static const String _collection = 'bug_reports';

  @override
  Future<BugReportModel> submitBugReport(BugReportModel bugReport) async {
    try {
      final docRef = await firestore
          .collection(_collection)
          .add(bugReport.toFirestore());

      final updatedBugReport = BugReportModel(
        id: docRef.id,
        userId: bugReport.userId,
        title: bugReport.title,
        description: bugReport.description,
        category: bugReport.category,
        priority: bugReport.priority,
        severity: bugReport.severity,
        status: bugReport.status,
        screenshots: bugReport.screenshots,
        stepsToReproduce: bugReport.stepsToReproduce,
        deviceInfo: bugReport.deviceInfo,
        createdAt: bugReport.createdAt,
        updatedAt: bugReport.updatedAt,
        rewardAmount: bugReport.rewardAmount,
        adminNotes: bugReport.adminNotes,
      );

      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return updatedBugReport;
    } catch (e) {
      throw ServerException('Failed to submit bug report: ${e.toString()}');
    }
  }

  @override
  Future<List<BugReportModel>> getUserBugReports(String userId) async {
    try {
      // Fetch all bug reports and filter on client side
      final querySnapshot = await firestore.collection(_collection).get();

      final allReports = querySnapshot.docs
          .map((doc) => BugReportModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Filter by userId and sort by createdAt descending
      final userReports = allReports
          .where((report) => report.userId == userId)
          .toList();

      // Sort by createdAt in descending order
      userReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return userReports;
    } catch (e) {
      throw ServerException('Failed to get user bug reports: ${e.toString()}');
    }
  }

  @override
  Future<BugReportModel> getBugReportById(String bugReportId) async {
    try {
      final doc = await firestore
          .collection(_collection)
          .doc(bugReportId)
          .get();

      if (!doc.exists) {
        throw ServerException('Bug report not found');
      }

      return BugReportModel.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get bug report: ${e.toString()}');
    }
  }

  @override
  Future<BugReportModel> updateBugReportStatus(
    String bugReportId,
    String status,
    String? adminNotes,
  ) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await firestore
          .collection(_collection)
          .doc(bugReportId)
          .update(updateData);

      return await getBugReportById(bugReportId);
    } catch (e) {
      throw ServerException(
        'Failed to update bug report status: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BugReportModel>> getBugReportsByStatus(
    String userId,
    String status,
  ) async {
    try {
      // Fetch all bug reports and filter on client side
      final querySnapshot = await firestore.collection(_collection).get();

      final allReports = querySnapshot.docs
          .map((doc) => BugReportModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Filter by userId and status, then sort by createdAt descending
      final filteredReports = allReports
          .where((report) => report.userId == userId && report.status == status)
          .toList();

      // Sort by createdAt in descending order
      filteredReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredReports;
    } catch (e) {
      throw ServerException(
        'Failed to get bug reports by status: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserBugReportStats(String userId) async {
    try {
      // Fetch all bug reports and filter on client side
      final querySnapshot = await firestore.collection(_collection).get();

      final allReports = querySnapshot.docs
          .map((doc) => BugReportModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Filter by userId
      final reports = allReports
          .where((report) => report.userId == userId)
          .toList();

      int totalReports = reports.length;
      int totalRewards = reports.fold(
        0,
        (sum, report) => sum + report.rewardAmount,
      );
      int fixedReports = reports.where((r) => r.status == 'Fixed').length;
      int pendingReports = reports.where((r) => r.status == 'Pending').length;
      int underReviewReports = reports
          .where((r) => r.status == 'Under Review')
          .length;
      int inProgressReports = reports
          .where((r) => r.status == 'In Progress')
          .length;
      int rejectedReports = reports.where((r) => r.status == 'Rejected').length;

      return {
        'totalReports': totalReports,
        'totalRewards': totalRewards,
        'fixedReports': fixedReports,
        'pendingReports': pendingReports,
        'underReviewReports': underReviewReports,
        'inProgressReports': inProgressReports,
        'rejectedReports': rejectedReports,
      };
    } catch (e) {
      throw ServerException('Failed to get bug report stats: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBugReport(String bugReportId, String userId) async {
    try {
      final doc = await firestore
          .collection(_collection)
          .doc(bugReportId)
          .get();

      if (!doc.exists) {
        throw ServerException('Bug report not found');
      }

      final bugReport = BugReportModel.fromFirestore(doc.id, doc.data()!);

      // Only allow deletion if user owns the report and it's pending
      if (bugReport.userId != userId) {
        throw ServerException('You can only delete your own bug reports');
      }

      if (bugReport.status != 'Pending') {
        throw ServerException('You can only delete pending bug reports');
      }

      await firestore.collection(_collection).doc(bugReportId).delete();
    } catch (e) {
      throw ServerException('Failed to delete bug report: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadScreenshot(String bugReportId, String imagePath) async {
    try {
      final fileName =
          'bug_reports/$bugReportId/screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(imagePath);
      final downloadUrl = await storageService.uploadFile(
        file: file,
        path: fileName,
      );
      return downloadUrl;
    } catch (e) {
      throw ServerException('Failed to upload screenshot: ${e.toString()}');
    }
  }

  @override
  Future<List<BugReportModel>> getAllBugReports() async {
    try {
      // Fetch all bug reports without server-side ordering
      final querySnapshot = await firestore.collection(_collection).get();

      final allReports = querySnapshot.docs
          .map((doc) => BugReportModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Sort by createdAt in descending order on client side
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allReports;
    } catch (e) {
      throw ServerException('Failed to get all bug reports: ${e.toString()}');
    }
  }

  @override
  Future<BugReportModel> updateBugReportReward(
    String bugReportId,
    int rewardAmount,
  ) async {
    try {
      await firestore.collection(_collection).doc(bugReportId).update({
        'rewardAmount': rewardAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getBugReportById(bugReportId);
    } catch (e) {
      throw ServerException(
        'Failed to update bug report reward: ${e.toString()}',
      );
    }
  }

  @override
  Future<BugReportModel> updateBugReportScreenshots(
    String bugReportId,
    List<String> screenshotUrls,
  ) async {
    try {
      await firestore.collection(_collection).doc(bugReportId).update({
        'screenshots': screenshotUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getBugReportById(bugReportId);
    } catch (e) {
      throw ServerException(
        'Failed to update bug report screenshots: ${e.toString()}',
      );
    }
  }
}
