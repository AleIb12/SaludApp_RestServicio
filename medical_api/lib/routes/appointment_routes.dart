// Importaciones necesarias para el funcionamiento del módulo
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

/// Clase que maneja todas las rutas relacionadas con las citas médicas
/// Implementa los endpoints para CRUD (Crear, Leer, Actualizar, Eliminar) de citas
class AppointmentRoutes {
  // Servicio de base de datos inyectado para realizar operaciones con la BD
  final DatabaseService _db;
  // Getter para acceder al router desde fuera de la clase
  Router get router => _router;
  // Instancia del router que manejará las rutas
  final _router = Router();

  /// Constructor que inicializa las rutas disponibles para las citas
  AppointmentRoutes(this._db) {
    _router.get('/', _getAllAppointments); // Obtener todas las citas
    _router.get('/<id>', _getAppointmentById); // Obtener una cita por ID
    _router.get('/patient/<patientId>',
        _getPatientAppointments); // Obtener citas de un paciente
    _router.get('/doctor/<doctorId>',
        _getDoctorAppointments); // Obtener citas de un médico
    _router.post('/', _createAppointment); // Crear una nueva cita
    _router.put('/<id>', _updateAppointment); // Actualizar una cita existente
    _router.delete('/<id>', _deleteAppointment); // Eliminar una cita
  }

  /// Obtiene todas las citas de la base de datos
  /// Retorna un JSON con la lista de citas o un error si falla
  Future<Response> _getAllAppointments(Request request) async {
    try {
      final appointments = await _db.query('''
        SELECT c.*, 
               p.nombre as nombre_paciente, 
               p.apellidos as apellidos_paciente,
               m.nombre as nombre_medico, 
               m.apellidos as apellidos_medico,
               m.especialidad
        FROM Citas c
        JOIN Pacientes p ON c.id_paciente = p.id_paciente
        JOIN Medicos m ON c.id_medico = m.id_medico
      ''');
      return Response.ok(
        json.encode(appointments),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Obtiene una cita específica por su ID
  /// @param id - ID de la cita a buscar
  /// Retorna la cita encontrada o un error 404 si no existe
  Future<Response> _getAppointmentById(Request request, String id) async {
    try {
      final appointments = await _db.query(
        '''SELECT c.*, 
                  p.nombre as nombre_paciente, 
                  p.apellidos as apellidos_paciente,
                  m.nombre as nombre_medico, 
                  m.apellidos as apellidos_medico,
                  m.especialidad
           FROM Citas c
           JOIN Pacientes p ON c.id_paciente = p.id_paciente
           JOIN Medicos m ON c.id_medico = m.id_medico
           WHERE c.id_cita = @id''',
        [int.parse(id)],
      );

      if (appointments.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Appointment not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(appointments.first),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Obtiene todas las citas de un paciente específico
  /// @param patientId - ID del paciente
  /// Retorna un JSON con la lista de citas o un error si falla
  Future<Response> _getPatientAppointments(
      Request request, String patientId) async {
    try {
      final appointments = await _db.query(
        '''SELECT c.*, 
                  m.nombre as nombre_medico, 
                  m.apellidos as apellidos_medico,
                  m.especialidad
           FROM Citas c
           JOIN Medicos m ON c.id_medico = m.id_medico
           WHERE c.id_paciente = @id
           ORDER BY c.fecha_hora''',
        [int.parse(patientId)],
      );

      return Response.ok(
        json.encode(appointments),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Obtiene todas las citas de un médico específico
  /// @param doctorId - ID del médico
  /// Retorna un JSON con la lista de citas o un error si falla
  Future<Response> _getDoctorAppointments(
      Request request, String doctorId) async {
    try {
      final appointments = await _db.query(
        '''SELECT c.*, 
                  p.nombre as nombre_paciente, 
                  p.apellidos as apellidos_paciente
           FROM Citas c
           JOIN Pacientes p ON c.id_paciente = p.id_paciente
           WHERE c.id_medico = @id
           ORDER BY c.fecha_hora''',
        [int.parse(doctorId)],
      );

      return Response.ok(
        json.encode(appointments),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Crea una nueva cita en la base de datos
  /// Espera recibir en el body todos los datos de la cita en formato JSON
  /// Retorna la cita creada con su ID asignado
  Future<Response> _createAppointment(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      final result = await _db.query(
        '''INSERT INTO Citas 
           (id_paciente, id_medico, fecha_hora, motivo, estado, notas)
           VALUES (@id_paciente, @id_medico, @fecha_hora, @motivo, @estado, @notas)
           RETURNING *''',
        [
          data['id_paciente'],
          data['id_medico'],
          data['fecha_hora'],
          data['motivo'],
          data['estado'] ?? 'Programada',
          data['notas'],
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

  /// Actualiza los datos de una cita existente
  /// @param id - ID de la cita a actualizar
  /// Espera recibir en el body los campos a actualizar en formato JSON
  /// Retorna la cita con sus datos actualizados
  Future<Response> _updateAppointment(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

      final result = await _db.query(
        '''UPDATE Citas 
           SET fecha_hora = @fecha_hora,
               motivo = @motivo,
               estado = @estado,
               notas = @notas
           WHERE id_cita = @id
           RETURNING *''',
        [
          data['fecha_hora'],
          data['motivo'],
          data['estado'],
          data['notas'],
          int.parse(id),
        ],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Appointment not found'}),
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

  /// Elimina una cita de la base de datos
  /// @param id - ID de la cita a eliminar
  /// Retorna un mensaje de éxito o error 404 si la cita no existe
  Future<Response> _deleteAppointment(Request request, String id) async {
    try {
      final result = await _db.query(
        'DELETE FROM Citas WHERE id_cita = @id RETURNING id_cita',
        [int.parse(id)],
      );

      if (result.isEmpty) {
        return Response.notFound(
          json.encode({'error': 'Appointment not found'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({'message': 'Appointment deleted successfully'}),
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
