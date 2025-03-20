import 'package:postgres/postgres.dart';

class DatabaseService {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  late PostgreSQLConnection _connection;

  DatabaseService({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });

  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      host,
      port,
      database,
      username: username,
      password: password,
    );
    await _connection.open();
  }

  Future<List<Map<String, dynamic>>> query(String query,
      [List<dynamic>? params]) async {
    final Map<String, dynamic> substitutionValues = {};
    if (params != null) {
      for (var i = 0; i < params.length; i++) {
        substitutionValues[i.toString()] = params[i];
      }
    }
    final results = await _connection.mappedResultsQuery(
        query.replaceAll('@', '@\$'),
        substitutionValues: substitutionValues);

    // Convert results and handle DateTime serialization
    return results.map((row) {
      Map<String, dynamic> mapped = Map<String, dynamic>.from(row.values.first);
      return mapped.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        }
        return MapEntry(key, value);
      });
    }).toList();
  }

  Future<void> close() async {
    await _connection.close();
  }
}
