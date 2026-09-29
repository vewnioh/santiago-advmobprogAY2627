import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart' as app_user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      data['loginType'] = 'dummyjson';
      await saveUserData(data);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  /// **Save User Data to SharedPreferences**
  /// Save user data from API response based on User model
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = app_user.User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    await prefs.setString('loginType', userData['loginType'] ?? 'dummyjson');

    // Support generic token key if present in API response
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// **Save Firebase Auth Session to SharedPreferences**
  Future<void> saveFirebaseUserData({
    required User user,
    Map<String, dynamic>? extraDetails,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String displayName = user.displayName ?? extraDetails?['username'] ?? user.email?.split('@').first ?? 'User';
    final List<String> nameParts = displayName.split(' ');
    final String firstName = extraDetails?['fName'] ?? nameParts.first;
    final String lastName = extraDetails?['lName'] ?? (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    await prefs.setInt('id', extraDetails?['age'] != null ? int.tryParse(extraDetails!['age'].toString()) ?? 1 : 1);
    await prefs.setString('username', extraDetails?['username'] ?? displayName);
    await prefs.setString('email', user.email ?? extraDetails?['emailAddress'] ?? '');
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('gender', extraDetails?['gender'] ?? 'Not Specified');
    await prefs.setString('contactNo', extraDetails?['contactNo'] ?? '');
    await prefs.setString('image', user.photoURL ?? '');
    await prefs.setString('accessToken', user.uid);
    await prefs.setString('token', user.uid);
    await prefs.setString('loginType', 'firebase');

    // Lab 6: Mirror the profile into Firestore so other users can find this account in the chat list
    // A Firestore failure (e.g. rules not published yet) must not block signing in
    try {
      await saveUserToFirestore(
        user: user,
        firstName: firstName,
        lastName: lastName,
        username: extraDetails?['username'],
      );
    } catch (e) {
      debugPrint('Failed to save user to Firestore: $e');
    }
  }

  /// **Lab 6: Upsert the `Users/{uid}` document used by the chat list**
  /// Merge keeps fields written at sign up (e.g. username) when signing in later
  Future<void> saveUserToFirestore({
    required User user,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email ?? '',
      if (firstName.isNotEmpty) 'firstName': firstName,
      if (lastName.isNotEmpty) 'lastName': lastName,
      if (username != null && username.isNotEmpty) 'username': username,
      'lastSignIn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Retrieve user data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      // Lab 6: Firebase Auth UID, used to build chat room IDs
      'uid': currentUser?.uid ?? '',
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? (currentUser?.displayName ?? ''),
      'email': prefs.getString('email') ?? (currentUser?.email ?? ''),
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'contactNo': prefs.getString('contactNo') ?? '',
      'image': prefs.getString('image') ?? (currentUser?.photoURL ?? ''),
      'accessToken': prefs.getString('accessToken') ?? (currentUser?.uid ?? ''),
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? (currentUser?.uid ?? ''),
      'loginType': prefs.getString('loginType') ?? (currentUser != null ? 'firebase' : 'dummyjson'),
    };
  }

  /// Retrieve User model from SharedPreferences
  Future<app_user.User> getUser() async {
    final userData = await getUserData();
    return app_user.User.fromJson(userData);
  }

  /// **Check if User is Logged In**
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return (token != null && token.isNotEmpty) || currentUser != null;
  }

  /// **Logout and Clear User Data**
  Future<void> logout() async {
    try {
      if (currentUser != null) {
        await firebaseAuth.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }

  // Firebase Authentication Integration
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await saveFirebaseUserData(user: credential.user!);
    }
    return credential;
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> updateUsername({required String username}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
