import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// A wrapper service around Firebase Cloud Storage
/// to centralize storage operations and make them reusable.
class FirebaseStorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage at the given [path].
  /// 
  /// Returns the download URL on success.
  Future<String> uploadFile({
    required File file,
    required String path,
    SettableMetadata? metadata,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final uploadTask = ref.putFile(file, metadata);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException {
      // Handle Firebase-specific errors here if needed
      rethrow;
    }
  }

  /// Deletes a file at the given [path].
  Future<void> deleteFile({required String path}) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      await ref.delete();
    } on FirebaseException  {
      rethrow;
    }
  }

  /// Gets the download URL for the file at [path].
  Future<String> getDownloadUrl({required String path}) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException {
      rethrow;
    }
  }

  /// Upload bytes data to Firebase Storage at [path].
  /// Returns the download URL.
  Future<String> uploadData({
    required List<int> data,
    required String path,
    SettableMetadata? metadata,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final uploadTask = ref.putData(data as Uint8List, metadata);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException {
      rethrow;
    }
  }
}
