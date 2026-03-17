import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if a driver's details exist in the 'drivers' collection
  Future<bool> isDriverRegistered(String uid) async {
    try {
      final doc = await _db.collection('drivers').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking driver registration: $e');
      return false;
    }
  }

  /// Save or update driver registration details
  Future<void> registerDriver(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('drivers').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error registering driver: $e');
      rethrow;
    }
  }
}
