import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:appwrite/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cargo_flow/services/appwrite_client.dart';

class AppUser {
  final String id;
  final String email;
  final String role;

  AppUser({required this.id, required this.email, required this.role});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _db = TablesDB(client);
    _initSession();
  }
  late final TablesDB _db;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('auth_uid');
    final email = prefs.getString('auth_email');
    final role = prefs.getString('auth_role');

    if (uid != null && email != null && role != null) {
      _currentUser = AppUser(id: uid, email: email, role: role);
    } else {
      _currentUser = null;
    }
    _authStateController.add(_currentUser);
  }

  Future<void> _saveSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', user.id);
    await prefs.setString('auth_email', user.email);
    await prefs.setString('auth_role', user.role);
    _currentUser = user;
    _authStateController.add(_currentUser);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_uid');
    await prefs.remove('auth_email');
    await prefs.remove('auth_role');
    _currentUser = null;
    _authStateController.add(null);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final result = await _db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      queries: [Query.equal('email', email)],
    );
    if (result.rows.isNotEmpty) {
      throw Exception('email-already-in-use');
    }

    try {
      final userDoc = await _db.createRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteUsersCollectionId,
        rowId: ID.unique(),
        data: {
          'email': email,
          'password': _hashPassword(password),
          'role': 'admin',
        },
      );
      final user = AppUser(id: userDoc.$id, email: email, role: 'admin');
      await _saveSession(user);
      return user;
    } catch (e) {
      print(e);
      throw Exception('Failed to sign up');
    }
  }

  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String role,
  }) async {
    final result = await _db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      queries: [Query.equal('email', email)],
    );
    if (result.rows.isNotEmpty) {
      throw Exception('email-already-in-use');
    }

    try {
      await _db.createRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteUsersCollectionId,
        rowId: ID.unique(),
        data: {
          'email': email,
          'password': _hashPassword(password),
          'role': role,
        },
      );
    } catch (e) {
      print(e);
      throw Exception('Failed to create user');
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _db.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteUsersCollectionId,
      queries: [Query.equal('email', email)],
    );

    if (result.rows.isEmpty) {
      throw Exception('user-not-found');
    }

    final doc = result.rows.first;
    if (doc.data['password'] != _hashPassword(password)) {
      throw Exception('wrong-password');
    }

    final String role = doc.data['role'] ?? 'driver'; // fallback 

    final user = AppUser(id: doc.$id, email: email, role: role);
    await _saveSession(user);
    return user;
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      final result = await _db.listRows(
        databaseId: appwriteDatabaseId,
        tableId: appwriteUsersCollectionId,
      );
      
      return result.rows.map((doc) => AppUser(
        id: doc.$id,
        email: doc.data['email'] ?? 'Unknown',
        role: doc.data['role'] ?? 'driver',
      )).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> signOut() async {
    await _clearSession();
  }
}
