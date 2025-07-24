import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  String? get currentUserId => _auth.currentUser?.uid;

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference ref = _storage
          .ref()
          .child('users/$currentUserId/$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Upload project asset
  Future<String> uploadProjectAsset(File file, String projectId, String assetType) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String fileName = '${_uuid.v4()}_${file.path.split('/').last}';
      final Reference ref = _storage
          .ref()
          .child('projects/$projectId/assets/$assetType/$fileName');

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Upload user profile image
  Future<String> uploadProfileImage(File imageFile) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String fileName = 'profile_${_uuid.v4()}.jpg';
      final Reference ref = _storage
          .ref()
          .child('users/$currentUserId/profile/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Delete file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      rethrow;
    }
  }

  // List files in a folder
  Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final Reference ref = _storage.ref().child(folderPath);
      final ListResult result = await ref.listAll();
      return result.items;
    } catch (e) {
      rethrow;
    }
  }

  // Get download URL for a file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles(
    List<File> files, 
    String folder,
  ) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      List<String> downloadUrls = [];
      
      for (File file in files) {
        final String fileName = '${_uuid.v4()}_${file.path.split('/').last}';
        final Reference ref = _storage
            .ref()
            .child('users/$currentUserId/$folder/$fileName');

        final UploadTask uploadTask = ref.putFile(file);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      rethrow;
    }
  }

  // Upload with progress tracking
  Future<String> uploadWithProgress(
    File file, 
    String folder, 
    Function(double) onProgress,
  ) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String fileName = '${_uuid.v4()}_${file.path.split('/').last}';
      final Reference ref = _storage
          .ref()
          .child('users/$currentUserId/$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
} 