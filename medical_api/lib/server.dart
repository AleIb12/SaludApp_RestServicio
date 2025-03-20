// Importaciones necesarias para el funcionamiento del servidor
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'services/database_service.dart';
import 'routes/patient_routes.dart';
import 'routes/doctor_routes.dart';
import 'routes/appointment_routes.dart';

void main() async {
  // Cargar variables de entorno
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Inicializar servicio de base de datos
  final dbService = DatabaseService(
    host: env['DB_HOST']!,
    port: int.parse(env['DB_PORT']!),
    database: env['DB_NAME']!,
    username: env['DB_USER']!,
    password: env['DB_PASSWORD']!,
  );

  // Conectar a la base de datos
  try {
    await dbService.connect();
    print('Conexión exitosa a la base de datos');
  } catch (e) {
    print('Error al conectar a la base de datos: $e');
    exit(1);
  }

  // Crear router
  final app = Router();

  // Inicializar rutas
  app.mount('/api/patients', PatientRoutes(dbService).router);
  app.mount('/api/doctors', DoctorRoutes(dbService).router);
  app.mount('/api/appointments', AppointmentRoutes(dbService).router);

  // Crear servidor
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(app);

  final port = int.parse(Platform.environment['PORT'] ??
      '3000'); // Cambiar puerto por defecto a 3000
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Servidor escuchando en el puerto ${server.port}');
}

/// Middleware para configurar los headers CORS (Cross-Origin Resource Sharing)
/// Permite el acceso a la API desde diferentes orígenes
Middleware _corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        });
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        ...response.headers,
      });
    },
  );
}
