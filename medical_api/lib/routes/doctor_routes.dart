import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

class DoctorRoutes {
  final DatabaseService _db;
  Router get router => _router;
  final _router = Router();

  DoctorRoutes(this._db) {
    _router.get('/', _getAllDoctors);
    _router.get('/<id>', _getDoctorById);
    _router.post('/', _createDoctor);
    _router.put('/<id>', _updateDoctor);
    _router.delete('/<id>', _deleteDoctor);
  }

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

  Future<Response> _createDoctor(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

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

  Future<Response> _updateDoctor(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);

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