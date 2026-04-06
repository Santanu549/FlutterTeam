import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:cargo_flow/services/appwrite_client.dart';

const String appwriteNotificationTableId = 'notifications';

class IndentNotificationData {
  const IndentNotificationData({
    required this.userId,
    required this.userRole,
    required this.title,
    required this.message,
    required this.indentId,
    this.status = 'pending',
  });

  final String userId;
  final String userRole;
  final String title;
  final String message;
  final String indentId;
  final String status;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userRole': userRole,
      'title': title,
      'message': message,
      'indentId': indentId,
      'status': status,
    };
  }
}

class NotificationService {
  NotificationService({TablesDB? tablesDB})
      : _tablesDB = tablesDB ?? TablesDB(client);

  final TablesDB _tablesDB;

  Future<void> createNotification(IndentNotificationData notification) async {
    await _tablesDB.createRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteNotificationTableId,
      rowId: ID.unique(),
      data: notification.toMap(),
      permissions: [
        Permission.read(Role.user(notification.userId)),
        Permission.write(Role.user(notification.userId)),
      ],
    );
  }

  Future<void> createNotificationsForUsers({
    required List<Map<String, dynamic>> users,
    required String indentId,
    required String loadingPoint,
    required String unloadingPoint,
  }) async {
    for (final user in users) {
      final userId = (user['id'] ?? '').toString();
      final role = (user['role'] ?? '').toString();

      if (userId.isEmpty || role == 'admin' || role == 'executive') {
        continue;
      }

      await createNotification(
        IndentNotificationData(
          userId: userId,
          userRole: role,
          indentId: indentId,
          title: 'New Indent',
          message: 'From $loadingPoint to $unloadingPoint',
        ),
      );
    }
  }

  Future<List<models.Row>> getNotificationsForUser(String userId) async {
    final result = await _tablesDB.listRows(
      databaseId: appwriteDatabaseId,
      tableId: appwriteNotificationTableId,
      queries: [
        Query.equal('userId', userId),
      ],
    );

    return result.rows;
  }

  Future<void> updateNotificationStatus({
    required String rowId,
    required String status,
  }) async {
    await _tablesDB.updateRow(
      databaseId: appwriteDatabaseId,
      tableId: appwriteNotificationTableId,
      rowId: rowId,
      data: {
        'status': status,
      },
    );
  }
}
