// Importaciones necesarias para el funcionamiento del servicio de base de datos
import 'package:postgres/postgres.dart';

/// Clase que proporciona servicios de acceso a la base de datos PostgreSQL
/// Maneja la conexión y las operaciones con la base de datos
class DatabaseService {
  // Instancia de la conexión a la base de datos
  late PostgreSQLConnection _connection;

  /// Constructor que recibe los parámetros de conexión a la base de datos
  /// y establece la conexión
  DatabaseService({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  /// Inicializa la conexión a la base de datos
  /// Debe llamarse antes de realizar cualquier operación
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

  /// Ejecuta una consulta SQL en la base de datos
  /// @param query - Consulta SQL a ejecutar
  /// @param params - Parámetros de la consulta (opcional)
  /// Retorna los resultados de la consulta
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

  /// Cierra la conexión a la base de datos
  /// Debe llamarse cuando ya no se necesite la conexión
  Future<void> close() async {
    await _connection.close();
  }
}
