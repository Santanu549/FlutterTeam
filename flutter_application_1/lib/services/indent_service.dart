import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:cargo_flow/services/appwrite_client.dart';

const String appwriteIndentTableId = 'indent';

class IndentData {
  const IndentData({
    required this.customerName,
    required this.vehicleType,
    required this.itemType,
    required this.itemWeight,
    required this.loadingCharge,
    required this.unloadingCharge,
    required this.executiveName,
    required this.executiveId,
    required this.loadingPoint,
    required this.unloadingPoint,
    this.distanceKm
  });

  final String customerName;
  final String vehicleType;
  final String itemType;
  final String itemWeight;
  final String loadingCharge;
  final String unloadingCharge;
  final String executiveName;
  final String executiveId;
  final String loadingPoint;
  final String unloadingPoint;
  final String? distanceKm;

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    final timeValue =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return {
      'name': customerName,
      'vtype': vehicleType,
      'itype': itemType,
      'iweight': itemWeight,
      'charge': loadingCharge,
      'ucharge': unloadingCharge,
      'exname': executiveName,
      'exid': executiveId,
      'lpoint': loadingPoint,
      'upoint': unloadingPoint,
      'distance': distanceKm,
      'time': timeValue,
    };
  }
}

class IndentService {
  IndentService({TablesDB? tablesDB})
      : _tablesDB = tablesDB ?? TablesDB(client);

  final TablesDB _tablesDB;

  Future<models.Row> createIndent(IndentData indent) async {
    try {
      return await _tablesDB.createRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteIndentTableId,
        rowId: ID.unique(),
        data: indent.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to create indent: $e');
    }
  }

  Future<List<models.Row>> getIndents({
    List<String>? queries,
  }) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: appwriteDatabaseId,
        tableId: appwriteIndentTableId,
        queries: queries,
      );
      return result.rows;
    } catch (e) {
      throw Exception('Failed to fetch indents: $e');
    }
  }
  

  Future<void> updateIndentStatus({
    required String rowId,
    required String status,
  }) async {
    try {
      await _tablesDB.updateRow(
        databaseId: appwriteDatabaseId,
        tableId: appwriteIndentTableId,
        rowId: rowId,
        data: {
          'status': status,
        },
      );
    } catch (e) {
      throw Exception('Failed to update indent status: $e');
    }
  }
}
