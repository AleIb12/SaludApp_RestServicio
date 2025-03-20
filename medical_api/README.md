# Medical API 🏥

A powerful REST API for managing medical services built with Dart. This API provides a comprehensive solution for managing patients, doctors, and appointments in a medical environment.

## 🚀 Features

- 👥 Patient Management
- 👨‍⚕️ Doctor Management
- 📅 Appointment Scheduling
- 🔒 Secure Database Integration
- ⚡ High Performance
- 🛠️ Easy to Configure

## 🛠️ Tech Stack

- 🎯 Dart
- 📦 Shelf (HTTP Server)
- 🗄️ PostgreSQL
- 🔐 Environment Variables Support

## 🚀 Getting Started

### Prerequisites

- Dart SDK (Latest Version)
- PostgreSQL Database

### Installation

1. Clone the repository
```bash
git clone [https://github.com/AleIb12/SaludApp_RestServicio.git]
```

2. Copy the environment file
```bash
cp .env.example .env
```

3. Update the `.env` file with your database credentials

4. Install dependencies
```bash
dart pub get
```

5. Run the server
```bash
dart run lib/server.dart
```

## 🔗 API Endpoints

### Patients 👤
- `GET /api/patients` - Get all patients
- `GET /api/patients/{id}` - Get patient by ID
- `POST /api/patients` - Create new patient
- `PUT /api/patients/{id}` - Update patient
- `DELETE /api/patients/{id}` - Delete patient

### Doctors 👨‍⚕️
- `GET /api/doctors` - Get all doctors
- `GET /api/doctors/{id}` - Get doctor by ID
- `POST /api/doctors` - Create new doctor
- `PUT /api/doctors/{id}` - Update doctor
- `DELETE /api/doctors/{id}` - Delete doctor

### Appointments 📅
- `GET /api/appointments` - Get all appointments
- `GET /api/appointments/{id}` - Get appointment by ID
- `GET /api/appointments/patient/{patientId}` - Get patient's appointments
- `GET /api/appointments/doctor/{doctorId}` - Get doctor's appointments
- `POST /api/appointments` - Create new appointment
- `PUT /api/appointments/{id}` - Update appointment
- `DELETE /api/appointments/{id}` - Delete appointment

## 📝 Environment Variables

Copy `.env.example` to `.env` and update the values:

```env
DB_HOST=your_host
DB_PORT=your_port
DB_NAME=your_database_name
DB_USER=your_username
DB_PASSWORD=your_password
```

## 🔒 Security

- Environment variables are used for sensitive data
- CORS middleware implemented
- Input validation for all endpoints
- Secure password handling

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details

---
⌨️ with ❤️ by [Ali]