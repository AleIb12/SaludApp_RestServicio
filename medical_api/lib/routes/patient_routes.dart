// Importaciones necesarias para el funcionamiento del módulo
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

/// Clase que maneja todas las rutas relacionadas con los pacientes
/// Implementa los endpoints para CRUD (Crear, Leer, Actualizar, Eliminar) de pacientes
class PatientRoutes {
  // Servicio de base de datos inyectado para realizar operaciones con la BD
  final DatabaseService _db;
  // Getter para acceder al router desde fuera de la clase
  Router get router => _router;
  // Instancia del router que manejará las rutas
  final _router = Router();

  /// Constructor que inicializa las rutas disponibles para los pacientes
  PatientRoutes(this._db) {
    _router.get('/', _getAllPatients); // Obtener todos los pacientes
    _router.get('/<id>', _getPatientById); // Obtener un paciente por ID
    _router.post('/', _createPatient); // Crear un nuevo paciente
    _router.put('/<id>', _updatePatient); // Actualizar un paciente existente
    _router.delete('/<id>', _deletePatient); // Eliminar un paciente
  }

  /// Obtiene todos los pacientes de la base de datos
  /// Retorna un JSON con la lista de pacientes o un error si falla
  Future<Response> _getAllPatients(Request request) async {
    try {
      final patients = await _db.query('SELECT * FROM Pacientes');
      return Response.ok(
        json.encode(patients),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Obtiene un paciente específico por su ID
  /// @param id - ID del paciente a buscar
  /// Retorna el paciente encontrado o un error 404 si no existe
  Future<Response> _getPatientById(Request request, String id) async {
    try {
      final patients = await _db.query(
        'SELECT * FROM Pacientes WHERE id_paciente = @id',
        [int.parse(id)],
      );

      if (patients.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Patient not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(patients.first),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Crea un nuevo paciente en la base de datos
  /// Espera recibir en el body todos los datos del paciente en formato JSON
  /// Retorna el paciente creado con su ID asignado
  Future<Response> _createPatient(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      // Query para insertar el nuevo paciente con todos sus campos
      final result = await _db.query(
        '''INSERT INTO Pacientes 
           (nombre, apellidos, fecha_nacimiento, genero, dni, telefono, email, direccion, grupo_sanguineo, alergias)
           VALUES (@nombre, @apellidos, @fecha_nacimiento, @genero, @dni, @telefono, @email, @direccion, @grupo_sanguineo, @alergias)
           RETURNING *''',
        [
          data['nombre'],
          data['apellidos'],
          data['fecha_nacimiento'],
          data['genero'],
          data['dni'],
          data['telefono'],
          data['email'],
          data['direccion'],
          data['grupo_sanguineo'],
          data['alergias'],
        ],
      );

      return Response.ok(
        json.encode(result.first),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Actualiza los datos de un paciente existente
  /// @param id - ID del paciente a actualizar
  /// Espera recibir en el body los campos a actualizar en formato JSON
  /// Retorna el paciente con sus datos actualizados
  Future<Response> _updatePatient(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      // Query para actualizar solo los campos permitidos del paciente
      final result = await _db.query(
        '''UPDATE Pacientes 
           SET nombre = @nombre, 
               apellidos = @apellidos,
               telefono = @telefono,
               email = @email,
               direccion = @direccion,
               grupo_sanguineo = @grupo_sanguineo,
               alergias = @alergias
           WHERE id_paciente = @id
           RETURNING *''',
        [
          data['nombre'],
          data['apellidos'],
          data['telefono'],
          data['email'],
          data['direccion'],
          data['grupo_sanguineo'],
          data['alergias'],
          int.parse(id),
        ],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Patient not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(result.first),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Elimina un paciente de la base de datos
  /// @param id - ID del paciente a eliminar
  /// Retorna un mensaje de éxito o error 404 si el paciente no existe
  Future<Response> _deletePatient(Request request, String id) async {
    try {
      final result = await _db.query(
        'DELETE FROM Pacientes WHERE id_paciente = @id RETURNING id_paciente',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Patient not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({'message': 'Patient deleted successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
