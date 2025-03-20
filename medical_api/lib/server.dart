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
  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Initialize database service
  final dbService = DatabaseService(
    host: env['DB_HOST']!,
    port: int.parse(env['DB_PORT']!),
    database: env['DB_NAME']!,
    username: env['DB_USER']!,
    password: env['DB_PASSWORD']!,
  );

  // Connect to database
  try {
    await dbService.connect();
    print('Successfully connected to database');
  } catch (e) {
    print('Failed to connect to database: $e');
    exit(1);
  }

  // Create router
  final app = Router();

  // Initialize routes
  app.mount('/api/patients', PatientRoutes(dbService).router);
  app.mount('/api/doctors', DoctorRoutes(dbService).router);
  app.mount('/api/appointments', AppointmentRoutes(dbService).router);

  // Create server
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(app);

  final port = int.parse(
      Platform.environment['PORT'] ?? '3000'); // Changed default port to 3000
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');
}

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
