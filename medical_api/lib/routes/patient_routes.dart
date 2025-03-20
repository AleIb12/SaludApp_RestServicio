import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

class PatientRoutes {
  final DatabaseService _db;
  Router get router => _router;
  final _router = Router();

  PatientRoutes(this._db) {
    _router.get('/', _getAllPatients);
    _router.get('/<id>', _getPatientById);
    _router.post('/', _createPatient);
    _router.put('/<id>', _updatePatient);
    _router.delete('/<id>', _deletePatient);
  }

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

  Future<Response> _createPatient(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

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

  Future<Response> _updatePatient(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

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