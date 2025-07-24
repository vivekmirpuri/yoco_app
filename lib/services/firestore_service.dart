import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/asset.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Projects Collection
  CollectionReference<Map<String, dynamic>> get projectsCollection =>
      _firestore.collection('projects');

  // Assets Collection
  CollectionReference<Map<String, dynamic>> get assetsCollection =>
      _firestore.collection('assets');

  // User Data Collection
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Projects CRUD Operations
  Future<void> createProject(Project project) async {
    try {
      await projectsCollection.add(project.toMap());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    try {
      await projectsCollection.doc(projectId).update(data);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await projectsCollection.doc(projectId).delete();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Project>> getUserProjects() {
    if (currentUserId == null) return Stream.value([]);
    
    return projectsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Assets CRUD Operations
  Future<void> createAsset(Asset asset) async {
    try {
      await assetsCollection.add(asset.toMap());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAsset(String assetId, Map<String, dynamic> data) async {
    try {
      await assetsCollection.doc(assetId).update(data);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAsset(String assetId) async {
    try {
      await assetsCollection.doc(assetId).delete();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Asset>> getProjectAssets(String projectId) {
    return assetsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Asset.fromMap(doc.data(), doc.id))
            .toList());
  }

  // User Profile Operations
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    if (currentUserId == null) return;
    
    try {
      await usersCollection.doc(currentUserId).set(userData);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    if (currentUserId == null) return;
    
    try {
      await usersCollection.doc(currentUserId).update(userData);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Stream<Map<String, dynamic>?> getUserProfile() {
    if (currentUserId == null) return Stream.value(null);
    
    return usersCollection
        .doc(currentUserId)
        .snapshots()
        .map((doc) => doc.data());
  }

  // Analytics Data
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _firestore.collection('analytics').add({
        'eventName': eventName,
        'parameters': parameters,
        'userId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Analytics logging should not break the app
      debugPrint('Failed to log analytics event: $e');
    }
  }

  // Search functionality
  Stream<List<Project>> searchProjects(String query) {
    if (currentUserId == null || query.isEmpty) return Stream.value([]);
    
    return projectsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + '\uf8ff')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }
} 