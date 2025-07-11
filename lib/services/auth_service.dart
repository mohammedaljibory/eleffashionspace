import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;

  // Initialize auth state
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        // Update last login
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Sign Up with email (we'll use phone as email format)
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String phoneNumber,
    required String password,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clean the phone number - remove spaces and any other formatting
      final cleanPhoneNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '').trim();

      // Create email format from phone number
      String email = '$cleanPhoneNumber@elef.app';

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore - store clean phone number
        final user = UserModel(
          uid: credential.user!.uid,
          name: name,
          phoneNumber: cleanPhoneNumber, // Store clean version
          latitude: latitude,
          longitude: longitude,
          address: address,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        _currentUser = user;
        _isLoading = false;
        notifyListeners();

        return {'success': true, 'message': 'تم إنشاء الحساب بنجاح'};
      }

      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'فشل إنشاء الحساب'};

    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      // Handle specific Firebase Auth errors
      String message = 'حدث خطأ غير متوقع';
      switch (e.code) {
        case 'weak-password':
          message = 'كلمة المرور ضعيفة جداً';
          break;
        case 'email-already-in-use':
          message = 'رقم الهاتف مسجل بالفعل';
          break;
        case 'invalid-email':
          message = 'رقم الهاتف غير صالح';
          break;
      }

      return {'success': false, 'message': message};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clean the phone number - remove spaces and any other formatting
      final cleanPhoneNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '').trim();

      String email = '$cleanPhoneNumber@elef.app';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'تم تسجيل الدخول بنجاح'};
      }

      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'فشل تسجيل الدخول'};

    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      String message = 'حدث خطأ غير متوقع';
      switch (e.code) {
        case 'user-not-found':
          message = 'لا يوجد حساب بهذا الرقم';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          message = 'رقم الهاتف غير صالح';
          break;
        case 'invalid-credential':
          message = 'بيانات الدخول غير صحيحة';
          break;
        case 'too-many-requests':
          message = 'تم تجاوز عدد المحاولات المسموح. يرجى المحاولة لاحقاً';
          break;
      }

      return {'success': false, 'message': message};
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Update user location
  Future<void> updateUserLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        name: _currentUser!.name,
        phoneNumber: _currentUser!.phoneNumber,
        latitude: latitude,
        longitude: longitude,
        address: address,
        createdAt: _currentUser!.createdAt,
        lastLogin: _currentUser!.lastLogin,
      );

      notifyListeners();
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String phoneNumber) async {
    try {
      // Clean the phone number
      final cleanPhoneNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '').trim();
      String email = '$cleanPhoneNumber@elef.app';

      await _auth.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ غير متوقع';
      if (e.code == 'user-not-found') {
        message = 'لا يوجد حساب بهذا الرقم';
      }
      return {'success': false, 'message': message};
    }
  }

  // Check if phone number is already registered
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final cleanPhoneNumber = phoneNumber.replaceAll(' ', '').replaceAll('-', '').trim();
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: cleanPhoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }
}