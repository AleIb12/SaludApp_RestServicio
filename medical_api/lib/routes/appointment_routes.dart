import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

class AppointmentRoutes {
  final DatabaseService _db;
  Router get router => _router;
  final _router = Router();

  AppointmentRoutes(this._db) {
    _router.get('/', _getAllAppointments);
    _router.get('/<id>', _getAppointmentById);
    _router.get('/patient/<patientId>', _getPatientAppointments);
    _router.get('/doctor/<doctorId>', _getDoctorAppointments);
    _router.post('/', _createAppointment);
    _router.put('/<id>', _updateAppointment);
    _router.delete('/<id>', _deleteAppointment);
  }

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

  Future<Response> _getPatientAppointments(Request request, String patientId) async {
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

  Future<Response> _getDoctorAppointments(Request request, String doctorId) async {
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