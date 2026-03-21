import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AuthServiceAppwrite {
  late Client _client;
  late Account _account;

  // Constructor
  AuthServiceAppwrite() {
    _client = Client()
        .setEndpoint('https://sgp.cloud.appwrite.io/v1') 
        .setProject('69bae4790030cded7cad'); 

    _account = Account(_client);
  }


  // REGISTER USER

  Future<User> register(String email, String password) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  
  // LOGIN USER
  
  Future<Session> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

 
  // GET CURRENT USER
 
  Future<User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      return null;
    }
  }


  // LOGOUT
  
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }
}