import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_currentUser != null) {
        await _currentUser!.updateDisplayName(displayName);
        await _currentUser!.updatePhotoURL(photoURL);
      }
    } catch (e) {
      rethrow;
    }
  }
} 