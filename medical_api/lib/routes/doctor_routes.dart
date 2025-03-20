// Importaciones necesarias para el funcionamiento del módulo
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

/// Clase que maneja todas las rutas relacionadas con los médicos
/// Implementa los endpoints para CRUD (Crear, Leer, Actualizar, Eliminar) de médicos
class DoctorRoutes {
  // Servicio de base de datos inyectado para realizar operaciones con la BD
  final DatabaseService _db;
  // Getter para acceder al router desde fuera de la clase
  Router get router => _router;
  // Instancia del router que manejará las rutas
  final _router = Router();

  /// Constructor que inicializa las rutas disponibles para los médicos
  DoctorRoutes(this._db) {
    _router.get('/', _getAllDoctors); // Obtener todos los médicos
    _router.get('/<id>', _getDoctorById); // Obtener un médico por ID
    _router.post('/', _createDoctor); // Crear un nuevo médico
    _router.put('/<id>', _updateDoctor); // Actualizar un médico existente
    _router.delete('/<id>', _deleteDoctor); // Eliminar un médico
  }

  /// Obtiene todos los médicos de la base de datos
  /// Retorna un JSON con la lista de médicos o un error si falla
  Future<Response> _getAllDoctors(Request request) async {
    try {
      final doctors = await _db.query('SELECT * FROM Medicos');
      return Response.ok(
        json.encode(doctors),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Obtiene un médico específico por su ID
  /// @param id - ID del médico a buscar
  /// Retorna el médico encontrado o un error 404 si no existe
  Future<Response> _getDoctorById(Request request, String id) async {
    try {
      final doctors = await _db.query(
        'SELECT * FROM Medicos WHERE id_medico = @id',
        [int.parse(id)],
      );

      if (doctors.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Doctor not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(doctors.first),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Crea un nuevo médico en la base de datos
  /// Espera recibir en el body todos los datos del médico en formato JSON
  /// Retorna el médico creado con su ID asignado
  Future<Response> _createDoctor(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      // Query para insertar el nuevo médico con todos sus campos
      final result = await _db.query(
        '''INSERT INTO Medicos 
           (nombre, apellidos, especialidad, num_colegiado, telefono, email, horario_consulta)
           VALUES (@nombre, @apellidos, @especialidad, @num_colegiado, @telefono, @email, @horario_consulta)
           RETURNING *''',
        [
          data['nombre'],
          data['apellidos'],
          data['especialidad'],
          data['num_colegiado'],
          data['telefono'],
          data['email'],
          data['horario_consulta'],
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

  /// Actualiza los datos de un médico existente
  /// @param id - ID del médico a actualizar
  /// Espera recibir en el body los campos a actualizar en formato JSON
  /// Retorna el médico con sus datos actualizados
  Future<Response> _updateDoctor(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      // Query para actualizar solo los campos permitidos del médico
      final result = await _db.query(
        '''UPDATE Medicos 
           SET nombre = @nombre, 
               apellidos = @apellidos,
               especialidad = @especialidad,
               telefono = @telefono,
               email = @email,
               horario_consulta = @horario_consulta
           WHERE id_medico = @id
           RETURNING *''',
        [
          data['nombre'],
          data['apellidos'],
          data['especialidad'],
          data['telefono'],
          data['email'],
          data['horario_consulta'],
          int.parse(id),
        ],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Doctor not found'}),
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

  /// Elimina un médico de la base de datos
  /// @param id - ID del médico a eliminar
  /// Retorna un mensaje de éxito o error 404 si el médico no existe
  Future<Response> _deleteDoctor(Request request, String id) async {
    try {
      final result = await _db.query(
        'DELETE FROM Medicos WHERE id_medico = @id RETURNING id_medico',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Doctor not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({'message': 'Doctor deleted successfully'}),
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
