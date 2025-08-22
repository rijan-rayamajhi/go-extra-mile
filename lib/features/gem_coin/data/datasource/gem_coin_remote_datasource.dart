import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/gem_coin/data/model/gem_coin_history_model.dart';

abstract class GemCoinRemoteDataSource {
  /// Fetch user's GEM coin transaction history from Firestore
  Future<List<GEMCoinHistoryModel>> getTransactionHistory(String uid);
}

class GemCoinRemoteDataSourceImpl implements GemCoinRemoteDataSource {
  final FirebaseFirestore firestore;

  GemCoinRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<GEMCoinHistoryModel>> getTransactionHistory(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('gem_coin_history')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GEMCoinHistoryModel.fromFirestore(doc))
        .toList();
  }
}