-- =====================================================================
-- Semana 6 · Clase 11 · Tarea — Base de datos transaccional
-- Caso elegido: 1) Biblioteca
-- Base: biblioteca (PostgreSQL)
-- =====================================================================

DROP TABLE IF EXISTS prestamo_libros, prestamos, carnets, socios, libros, autores;

-- Autores
CREATE TABLE autores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

-- Libros
-- Relación 1:N autores -> libros: un autor escribe muchos libros,
-- cada libro tiene un solo autor (FK autor_id).
CREATE TABLE libros (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    anio_publicacion INTEGER CHECK (anio_publicacion BETWEEN 1450 AND 2100),
    ejemplares INTEGER NOT NULL DEFAULT 1 CHECK (ejemplares >= 0),
    autor_id INTEGER NOT NULL REFERENCES autores(id)
);

-- Socios
CREATE TABLE socios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Carnets
-- Relación 1:1 socios <-> carnets: la FK socio_id es UNIQUE, así que
-- cada socio puede tener un solo carnet y cada carnet es de un solo socio.
CREATE TABLE carnets (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(20) NOT NULL UNIQUE,
    fecha_emision DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE NOT NULL,
    socio_id INTEGER NOT NULL UNIQUE REFERENCES socios(id),
    CHECK (fecha_vencimiento > fecha_emision)
);

-- Préstamos
-- Relación 1:N socios -> prestamos: un socio puede tener muchos préstamos,
-- cada préstamo es de un solo socio (FK socio_id).
CREATE TABLE prestamos (
    id SERIAL PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id),
    fecha_prestamo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'devuelto', 'vencido')),
    CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo)
);

-- Préstamo_Libros (tabla intermedia)
-- Relación N:N prestamos <-> libros: un préstamo incluye varios libros y
-- un libro puede estar en varios préstamos. La PK compuesta evita repetir
-- el mismo libro dentro de un préstamo.
CREATE TABLE prestamo_libros (
    prestamo_id INTEGER NOT NULL REFERENCES prestamos(id),
    libro_id INTEGER NOT NULL REFERENCES libros(id),
    cantidad INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    PRIMARY KEY (prestamo_id, libro_id)
);

-- =====================================================================
-- Datos de ejemplo
-- =====================================================================

INSERT INTO autores (nombre, nacionalidad) VALUES
('Jorge Luis Borges', 'Argentina'),
('Julio Cortázar', 'Argentina'),
('Gabriel García Márquez', 'Colombia'),
('Isabel Allende', 'Chile');

INSERT INTO libros (titulo, isbn, anio_publicacion, ejemplares, autor_id) VALUES
('Ficciones', '978-9875666474', 1944, 3, 1),
('El Aleph', '978-9875666481', 1949, 2, 1),
('Rayuela', '978-8437604572', 1963, 2, 2),
('Bestiario', '978-8466331869', 1951, 1, 2),
('Cien años de soledad', '978-0307474728', 1967, 4, 3),
('La casa de los espíritus', '978-1501117015', 1982, 2, 4);

INSERT INTO socios (nombre, dni, email, fecha_alta) VALUES
('Lucía Fernández', '30111222', 'lucia.fernandez@email.com', '2026-01-15'),
('Martín Gómez', '32333444', 'martin.gomez@email.com', '2026-03-02'),
('Sofía Ruiz', '35555666', NULL, '2026-06-20'),
('Diego Sosa', '28777888', 'diego.sosa@email.com', DEFAULT);

INSERT INTO carnets (numero, fecha_emision, fecha_vencimiento, socio_id) VALUES
('CAR-0001', '2026-01-15', '2027-01-15', 1),
('CAR-0002', '2026-03-02', '2027-03-02', 2),
('CAR-0003', '2026-06-20', '2027-06-20', 3),
('CAR-0004', '2026-11-13', '2027-11-13', 4);

INSERT INTO prestamos (socio_id, fecha_prestamo, fecha_devolucion, estado) VALUES
(1, '2026-10-01', '2026-10-15', 'devuelto'),
(1, '2026-11-05', NULL, 'activo'),
(2, '2026-09-10', NULL, 'vencido'),
(3, '2026-11-10', NULL, 'activo');

INSERT INTO prestamo_libros (prestamo_id, libro_id, cantidad) VALUES
(1, 1, 1),   -- Lucía: Ficciones
(1, 3, 1),   -- Lucía: Rayuela
(2, 5, 1),   -- Lucía: Cien años de soledad
(3, 1, 1),   -- Martín: Ficciones (mismo libro en otro préstamo -> N:N)
(3, 6, 1),   -- Martín: La casa de los espíritus
(4, 2, 1);   -- Sofía: El Aleph
