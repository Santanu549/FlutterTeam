import 'package:appwrite/appwrite.dart';
import 'package:cargo_flow/services/appwrite_client.dart';

class DatabaseService {
  final Databases _db = Databases(client);

  /// Check if a driver's details exist in the 'drivers' collection
  Future<bool> isDriverRegistered(String uid) async {
    try {
      await _db.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteDriverCollectionId,
        documentId: uid,
      );
      return true;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return false;
      }
      print('Error checking driver registration: $e');
      return false;
    } catch (e) {
      print('Error checking driver registration: $e');
      return false;
    }
  }

  /// Save or update driver registration details
  Future<void> registerDriver(String uid, Map<String, dynamic> data) async {
    try {
      await _db.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: appwriteDriverCollectionId,
        documentId: uid,
        data: data,
      );
    } catch (e) {
      print('Error registering driver: $e');
      rethrow;
    }
  }
}
