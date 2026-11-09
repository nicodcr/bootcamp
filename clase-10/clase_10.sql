-- Base: relaciones_db

-- 1:1 - cada conductor tiene un solo vehiculo y cada vehiculo un solo conductor
-- (conductor_id es UNIQUE para que no se repita)
CREATE TABLE conductores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    licencia VARCHAR(20) UNIQUE,
    fecha_ingreso DATE
);

CREATE TABLE vehiculos (
    id SERIAL PRIMARY KEY,
    patente VARCHAR(10) UNIQUE,
    modelo VARCHAR(50),
    conductor_id INT UNIQUE REFERENCES conductores(id)
);

-- 1:N - un profesor dicta muchas clases, cada clase tiene un solo profesor
CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(50),
    fecha_contratacion DATE
);

CREATE TABLE clases (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    horario VARCHAR(50),
    profesor_id INT NOT NULL REFERENCES profesores(id)
);

-- N:N - un paciente puede tener varias enfermedades y una enfermedad muchos pacientes
-- se usa la tabla intermedia pacientes_enfermedades con PK compuesta
CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20)
);

CREATE TABLE enfermedades (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    nivel_gravedad VARCHAR(10) CHECK (nivel_gravedad IN ('leve', 'moderada', 'grave'))
);

CREATE TABLE pacientes_enfermedades (
    paciente_id INT REFERENCES pacientes(id),
    enfermedad_id INT REFERENCES enfermedades(id),
    fecha_diagnostico DATE,
    PRIMARY KEY (paciente_id, enfermedad_id)
);

-- Inserts

INSERT INTO conductores (nombre, licencia, fecha_ingreso) VALUES
('Juan Perez', 'LIC-1001', '2021-03-15'),
('Maria Gomez', 'LIC-1002', '2022-07-01'),
('Carlos Ruiz', 'LIC-1003', '2023-01-10');

INSERT INTO vehiculos (patente, modelo, conductor_id) VALUES
('AB123CD', 'Toyota Corolla', 1),
('AC456EF', 'Ford Ranger', 2),
('AD789GH', 'Volkswagen Gol', 3);

INSERT INTO profesores (nombre, especialidad, fecha_contratacion) VALUES
('Laura Fernandez', 'Matematica', '2019-02-20'),
('Diego Sosa', 'Historia', '2020-08-05'),
('Ana Torres', 'Biologia', '2022-03-01');

INSERT INTO clases (nombre, horario, profesor_id) VALUES
('Algebra', 'Lunes 8:00', 1),
('Calculo', 'Miercoles 10:00', 1),
('Historia Argentina', 'Martes 14:00', 2),
('Biologia Celular', 'Jueves 9:00', 3);

INSERT INTO pacientes (nombre, fecha_nacimiento, telefono) VALUES
('Sofia Martinez', '1985-06-12', '11-4567-8901'),
('Pablo Diaz', '1990-11-30', '11-2345-6789'),
('Lucia Romero', '1978-01-25', '11-9876-5432');

INSERT INTO enfermedades (nombre, descripcion, nivel_gravedad) VALUES
('Gripe', 'Infeccion viral', 'leve'),
('Diabetes', 'Glucosa alta en sangre', 'moderada'),
('Neumonia', 'Infeccion en los pulmones', 'grave');

INSERT INTO pacientes_enfermedades (paciente_id, enfermedad_id, fecha_diagnostico) VALUES
(1, 1, '2024-05-10'),
(1, 2, '2023-09-02'),
(2, 1, '2024-06-15'),
(3, 3, '2024-07-20');

-- Prueba: segundo vehiculo para el conductor 1
-- INSERT INTO vehiculos (patente, modelo, conductor_id) VALUES ('AE000ZZ', 'Fiat Cronos', 1);
-- ERROR:  duplicate key value violates unique constraint "vehiculos_conductor_id_key"
-- DETAIL:  Key (conductor_id)=(1) already exists.
