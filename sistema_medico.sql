-- Sistema de Gestión de Datos Médicos - Script PostgreSQL

-- Crear la base de datos
CREATE DATABASE SistemaMedico;
\c SistemaMedico;

-- Tabla de Pacientes
CREATE TABLE Pacientes (
    id_paciente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(10) CHECK (genero IN ('M', 'F', 'Otro')) NOT NULL,
    dni VARCHAR(15) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    direccion VARCHAR(200),
    grupo_sanguineo VARCHAR(5),
    alergias TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Médicos
CREATE TABLE Medicos (
    id_medico SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    num_colegiado VARCHAR(20) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100),
    horario_consulta TEXT
);

-- Tabla de Citas
CREATE TABLE Citas (
    id_cita SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    motivo VARCHAR(200),
    estado VARCHAR(20) CHECK (estado IN ('Programada', 'Realizada', 'Cancelada')) DEFAULT 'Programada',
    notas TEXT,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
);

-- Tabla de Historiales Clínicos
CREATE TABLE HistorialesClinicos (
    id_historial SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);

-- Tabla de Consultas Médicas
CREATE TABLE Consultas (
    id_consulta SERIAL PRIMARY KEY,
    id_cita INT,
    id_historial INT NOT NULL,
    id_medico INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    sintomas TEXT,
    diagnostico TEXT,
    tratamiento TEXT,
    observaciones TEXT,
    FOREIGN KEY (id_cita) REFERENCES Citas(id_cita),
    FOREIGN KEY (id_historial) REFERENCES HistorialesClinicos(id_historial),
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
);

-- Tabla de Medicamentos
CREATE TABLE Medicamentos (
    id_medicamento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    principio_activo VARCHAR(100) NOT NULL,
    presentacion VARCHAR(100),
    dosis_recomendada VARCHAR(100),
    contraindicaciones TEXT
);

-- Tabla de Recetas
CREATE TABLE Recetas (
    id_receta SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL,
    id_medicamento INT NOT NULL,
    dosis VARCHAR(100) NOT NULL,
    duracion VARCHAR(50) NOT NULL,
    indicaciones TEXT,
    fecha_emision DATE NOT NULL,
    FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta),
    FOREIGN KEY (id_medicamento) REFERENCES Medicamentos(id_medicamento)
);

-- Tabla de Pruebas Diagnósticas
CREATE TABLE PruebasDiagnosticas (
    id_prueba SERIAL PRIMARY KEY,
    id_consulta INT NOT NULL,
    tipo_prueba VARCHAR(100) NOT NULL,
    fecha_solicitud DATE NOT NULL,
    fecha_realizacion DATE,
    resultados TEXT,
    observaciones TEXT,
    FOREIGN KEY (id_consulta) REFERENCES Consultas(id_consulta)
);

-- Tabla de Personal Administrativo
CREATE TABLE PersonalAdministrativo (
    id_personal SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    puesto VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(100)
);

-- Tabla de Usuarios del Sistema
CREATE TABLE Usuarios (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20) CHECK (tipo_usuario IN ('Administrador', 'Médico', 'Enfermero', 'Recepcionista', 'Paciente')) NOT NULL,
    id_referencia INT NOT NULL,
    ultimo_acceso TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_pacientes_nombre ON Pacientes(nombre, apellidos);
CREATE INDEX idx_medicos_especialidad ON Medicos(especialidad);
CREATE INDEX idx_citas_fecha ON Citas(fecha_hora);

-- Ejemplos de datos iniciales (opcional)
INSERT INTO Medicos (nombre, apellidos, especialidad, num_colegiado, telefono, email)
VALUES ('Carlos', 'García', 'Cardiología', 'MED-12345', '612345678', 'carlos.garcia@hospital.com');

INSERT INTO Pacientes (nombre, apellidos, fecha_nacimiento, genero, dni, telefono)
VALUES ('Ana', 'Martínez', '1985-06-15', 'F', '12345678A', '698765432');