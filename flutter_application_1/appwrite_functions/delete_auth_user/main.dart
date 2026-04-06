import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(final context) async {
  try {
    final bodyText = context.req.bodyText;
    final payload = bodyText.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(bodyText) as Map<String, dynamic>;
    final userId = (payload['userId'] ?? '').toString().trim();

    if (userId.isEmpty) {
      return context.res.json(
        {'ok': false, 'message': 'userId is required'},
        status: 400,
      );
    }

    final client = Client()
        .setEndpoint(
          Platform.environment['https://sgp.cloud.appwrite.io/v1'] ?? '',
        )
        .setProject(
          Platform.environment['69bae4790030cded7cad'] ?? '',
        )
        .setKey(
          Platform.environment['standard_d0aa3e45f756f0d67e32b5dbd0db10f363f1829dc664190834b42649e81bdbc9f864fa8037a916ff1834857204d66982cbae0cc1d96bbfd88ff586d83a029c3de561209a12e0e6693a9a79100e5003da342e354835b2c699fa809549e1094cb9a4efdf621f6202acc71223ed3cad34f3a80db9fbd902adbb23848e82b8f71c9c'] ?? '',
        );

    final users = Users(client);
    await users.delete(userId: userId);

    return context.res.json(
      {'ok': true, 'userId': userId},
      status: 200,
    );
  } catch (e, stackTrace) {
    context.error('Delete auth user failed: $e');
    context.error(stackTrace.toString());

    return context.res.json(
      {'ok': false, 'message': 'Delete auth user failed: $e'},
      status: 500,
    );
  }
}
