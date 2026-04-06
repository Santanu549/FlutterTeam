import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AuthServiceAppwrite {
  late Client _client;
  late Account _account;
  late TablesDB _tablesDB;
  late Functions _functions;

  final String databaseId = '69bb460700129db0814c';
  final String usersTableId = '69c81ded0005b45e194d';
  final String deleteAuthUserFunctionId = 'delete-auth-user';

  AuthServiceAppwrite() {
    _client = Client()
        .setEndpoint('https://sgp.cloud.appwrite.io/v1')
        .setProject('69bae4790030cded7cad');

    _account = Account(_client);
    _tablesDB = TablesDB(_client);
    _functions = Functions(_client);
  }

 
  //  REGISTER ADMIN

  Future<User> register(String email, String password) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      // Account creation does not automatically create a session.
      // Create a session first so the same user can write their row.
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      await _tablesDB.createRow(
        databaseId: databaseId,
        tableId: usersTableId,
        rowId: user.$id,
        data: {
          'userid': user.$id,
          'Email': email,
          'Role': 'admin',
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.write(Role.user(user.$id)),
        ],
      );

      return user;
    } catch (e) {
      if (e is AppwriteException) {
        if (e.code == 409) {
          throw Exception("User already exists. Please login.");
        }
      }
      throw Exception("Registration failed: $e");
    }
  }

//REGISTER DRIVER/EXECUTIVE BY ADMIN
Future<User> registerUser(String email, String password, String role) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      await _tablesDB.createRow(
        databaseId: databaseId,
        tableId: usersTableId,
        rowId: user.$id,
        data: {
          'userid': user.$id,
          'Email': email,
          'Role': role,
        },
        permissions: [
          Permission.read(Role.users()),
          Permission.write(Role.users()),
        ],
      );

      return user;
    } catch (e) {
      if (e is AppwriteException) {
        if (e.code == 409) {
          throw Exception("User already exists. Please login.");
        }
      }
      throw Exception("Registration failed: $e");
    }
  }


  //  LOGIN

  Future<void> login(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      if (e.type == 'user_session_already_exists' ||
          e.message?.toLowerCase().contains('session is active') == true) {
        await _account.deleteSession(sessionId: 'current');
        await _account.createEmailPasswordSession(
          email: email,
          password: password,
        );
        return;
      }
      throw Exception(e.message ?? e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //  GET USER

  Future<User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      return null;
    }
  }


  //  GET ROLE

  Future<String?> getUserRole() async {
    try {
      final user = await _account.get();

      final row = await _tablesDB.getRow(
        databaseId: databaseId,
        tableId: usersTableId,
        rowId: user.$id,
      );

      return row.data['Role'];
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: databaseId,
        tableId: usersTableId,
      );

      return result.rows.map((row) {
        return {
          'id': row.$id,
          'userid': row.data['userid'],
          'email': row.data['Email'] ?? '',
          'role': row.data['Role'] ?? 'driver',
        };
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch users: $e");
    }
  }


  //  UPDATE ROLE
 
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _tablesDB.updateRow(
        databaseId: databaseId,
        tableId: usersTableId,
        rowId: userId,
        data: {
          'Role': newRole,
        },
      );
    } catch (e) {
      throw Exception("Role update failed: $e");
    }
  }

  Future<void> deleteUser({
    required String rowId,
    required String authUserId,
  }) async {
    try {
      final execution = await _functions.createExecution(
        functionId: deleteAuthUserFunctionId,
        body: jsonEncode({'userId': authUserId}),
        xasync: false,
      );

      if (execution.responseStatusCode >= 400) {
        throw Exception(
          execution.responseBody.isNotEmpty
              ? execution.responseBody
              : 'Failed to delete auth user.',
        );
      }

      Map<String, dynamic> responseData = {};
      if (execution.responseBody.isNotEmpty) {
        responseData =
            jsonDecode(execution.responseBody) as Map<String, dynamic>;
      }

      if (responseData['ok'] != true) {
        throw Exception(
          responseData['message']?.toString() ?? 'Auth user was not deleted.',
        );
      }

      await _tablesDB.deleteRow(
        databaseId: databaseId,
        tableId: usersTableId,
        rowId: rowId,
      );
    } catch (e) {
      throw Exception("Delete failed: $e");
    }
  }

  
  //  LOGOUT

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }
}
