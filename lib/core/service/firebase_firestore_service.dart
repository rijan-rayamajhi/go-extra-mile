import 'package:cloud_firestore/cloud_firestore.dart';

/// Wrapper service for Firebase Firestore operations.
class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a document with [data] to collection [collectionPath].
  /// Returns the created document's ID.
  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore.collection(collectionPath).add(data);
    return docRef.id;
  }

  /// Sets (creates or overwrites) a document at [docPath] with [data].
  Future<void> setDocument({
    required String docPath,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore.doc(docPath).set(data, SetOptions(merge: merge));
  }

  /// Updates an existing document at [docPath] with [data].
  Future<void> updateDocument({
    required String docPath,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.doc(docPath).update(data);
  }

  /// Deletes the document at [docPath].
  Future<void> deleteDocument({required String docPath}) async {
    await _firestore.doc(docPath).delete();
  }

  /// Retrieves a single document at [docPath].
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({required String docPath}) async {
    return await _firestore.doc(docPath).get();
  }

  /// Retrieves all documents from a collection at [collectionPath].
  /// Optionally pass a [queryBuilder] to filter/sort results.
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  /// Listen to realtime updates on a document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream({required String docPath}) {
    return _firestore.doc(docPath).snapshots();
  }

  /// Listen to realtime updates on a collection.
  /// Optionally pass a [queryBuilder] to filter/sort results.
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  /// Adds a document with [data] to a subcollection [subcollectionName] under document [docPath].
  /// Returns the created document's ID.
  Future<String> addDocumentToSubcollection({
    required String docPath,
    required String subcollectionName,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore.doc(docPath).collection(subcollectionName).add(data);
    return docRef.id;
  }

  /// Sets (creates or overwrites) a document in a subcollection [subcollectionName] under document [docPath].
  Future<void> setDocumentInSubcollection({
    required String docPath,
    required String subcollectionName,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore.doc(docPath).collection(subcollectionName).doc(documentId).set(data, SetOptions(merge: merge));
  }

  /// Updates an existing document in a subcollection [subcollectionName] under document [docPath].
  Future<void> updateDocumentInSubcollection({
    required String docPath,
    required String subcollectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.doc(docPath).collection(subcollectionName).doc(documentId).update(data);
  }

  /// Deletes a document from a subcollection [subcollectionName] under document [docPath].
  Future<void> deleteDocumentFromSubcollection({
    required String docPath,
    required String subcollectionName,
    required String documentId,
  }) async {
    await _firestore.doc(docPath).collection(subcollectionName).doc(documentId).delete();
  }

  /// Retrieves a single document from a subcollection [subcollectionName] under document [docPath].
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentFromSubcollection({
    required String docPath,
    required String subcollectionName,
    required String documentId,
  }) async {
    return await _firestore.doc(docPath).collection(subcollectionName).doc(documentId).get();
  }

  /// Retrieves all documents from a subcollection [subcollectionName] under document [docPath].
  /// Optionally pass a [queryBuilder] to filter/sort results.
  Future<QuerySnapshot<Map<String, dynamic>>> getSubcollection({
    required String docPath,
    required String subcollectionName,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.doc(docPath).collection(subcollectionName);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  /// Listen to realtime updates on a document in a subcollection.
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentInSubcollectionStream({
    required String docPath,
    required String subcollectionName,
    required String documentId,
  }) {
    return _firestore.doc(docPath).collection(subcollectionName).doc(documentId).snapshots();
  }

  /// Listen to realtime updates on a subcollection.
  /// Optionally pass a [queryBuilder] to filter/sort results.
  Stream<QuerySnapshot<Map<String, dynamic>>> subcollectionStream({
    required String docPath,
    required String subcollectionName,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.doc(docPath).collection(subcollectionName);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}
