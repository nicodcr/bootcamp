-- Clase 13 - SQL avanzado (minimercado)
-- Antes de empezar recree la base corriendo datasets/minimercado.sql


-- VISTAS

-- 1
CREATE OR REPLACE VIEW vista_detalle_ventas AS
SELECT v.id AS venta_id,
       v.fecha,
       c.nombre AS cliente,
       mp.nombre AS metodo_pago,
       pr.nombre AS producto,
       pv.nombre AS proveedor,
       vp.cantidad,
       vp.precio_unitario,
       vp.cantidad * vp.precio_unitario AS subtotal
FROM ventas v
JOIN clientes c ON c.id = v.cliente_id
JOIN metodos_pago mp ON mp.id = v.metodo_pago_id
JOIN venta_productos vp ON vp.venta_id = v.id
JOIN productos pr ON pr.id = vp.producto_id
JOIN proveedores pv ON pv.id = pr.proveedor_id;

SELECT * FROM vista_detalle_ventas ORDER BY venta_id LIMIT 10;

-- 2
-- total gastado por cliente
SELECT cliente, SUM(subtotal) AS total_gastado
FROM vista_detalle_ventas
GROUP BY cliente
ORDER BY total_gastado DESC;

-- productos mas vendidos
SELECT producto, SUM(cantidad) AS unidades
FROM vista_detalle_ventas
GROUP BY producto
ORDER BY unidades DESC;

-- 3
CREATE OR REPLACE VIEW vista_stock_bajo AS
SELECT pr.id, pr.nombre, pr.stock,
       pv.nombre AS proveedor,
       pv.telefono AS telefono_proveedor
FROM productos pr
JOIN proveedores pv ON pv.id = pr.proveedor_id
WHERE pr.stock < 10;

SELECT * FROM vista_stock_bajo ORDER BY stock;

-- 4
CREATE MATERIALIZED VIEW mv_ventas_por_mes AS
SELECT DATE_TRUNC('month', fecha)::date AS mes,
       COUNT(*) AS cantidad_ventas,
       SUM(total) AS total_vendido
FROM ventas
GROUP BY 1
ORDER BY 1;

SELECT * FROM mv_ventas_por_mes;

-- venta nueva en noviembre 2026 (no habia ventas ese mes)
INSERT INTO ventas (cliente_id, metodo_pago_id, fecha, total)
VALUES (7, 3, '2026-11-20 10:00:00', 50.00);

-- no cambia, la vista materializada queda guardada como estaba al crearla
SELECT * FROM mv_ventas_por_mes;

REFRESH MATERIALIZED VIEW mv_ventas_por_mes;

-- ahora si aparece 2026-11 con 1 venta de 50
SELECT * FROM mv_ventas_por_mes;


-- INDICES

-- 5
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename;

-- tienen indice los id de cada tabla (las primary key), el email de clientes
-- porque es UNIQUE, y venta_id + producto_id en venta_productos que es la PK.
-- postgres los crea solo para las PK y los UNIQUE. las foreign key no tienen
-- indice salvo que lo crees vos.

-- 6
CREATE TABLE prueba_indices AS
SELECT gs AS id,
       (random() * 9999 + 1)::int AS cliente_id,
       DATE '2024-01-01' + (random() * 730)::int AS fecha,
       ROUND((random() * 1000)::numeric, 2) AS total
FROM generate_series(1, 1000000) gs;

EXPLAIN ANALYZE SELECT * FROM prueba_indices WHERE cliente_id = 1234;

CREATE INDEX idx_prueba_cliente_id ON prueba_indices (cliente_id);

EXPLAIN ANALYZE SELECT * FROM prueba_indices WHERE cliente_id = 1234;

-- sin indice: Parallel Seq Scan, Execution Time 2448 ms
-- con indice: Bitmap Index Scan (+ Bitmap Heap Scan), Execution Time 112 ms
-- sin indice lee todas las filas, con indice va directo a las del cliente

DROP TABLE prueba_indices;

-- 7
CREATE INDEX idx_ventas_cliente_id ON ventas (cliente_id);
CREATE INDEX idx_venta_productos_producto ON venta_productos (producto_id);
CREATE INDEX idx_ventas_fecha ON ventas (fecha);

SELECT tablename, indexname
FROM pg_indexes
WHERE indexname LIKE 'idx_%';


-- FUNCIONES Y PROCEDIMIENTOS

-- 8
CREATE OR REPLACE FUNCTION fn_total_gastado(p_cliente_id INT)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(vp.cantidad * vp.precio_unitario), 0)
    FROM ventas v
    JOIN venta_productos vp ON vp.venta_id = v.id
    WHERE v.cliente_id = p_cliente_id;
$$;

SELECT id, nombre, fn_total_gastado(id) AS total_gastado
FROM clientes
ORDER BY total_gastado DESC;

-- 9
CREATE OR REPLACE PROCEDURE sp_aumentar_precios(p_proveedor_id INT, p_porcentaje NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filas INT;
BEGIN
    UPDATE productos
    SET precio = ROUND(precio * (1 + p_porcentaje / 100), 2)
    WHERE proveedor_id = p_proveedor_id;

    GET DIAGNOSTICS v_filas = ROW_COUNT;
    RAISE NOTICE 'Se actualizaron % productos', v_filas;
END;
$$;

-- Lacteos del Valle es el proveedor 8
SELECT id, nombre, precio FROM productos WHERE proveedor_id = 8 ORDER BY id;

CALL sp_aumentar_precios(8, 10);   -- Se actualizaron 6 productos

SELECT id, nombre, precio FROM productos WHERE proveedor_id = 8 ORDER BY id;


-- TRIGGERS

-- 10
CREATE OR REPLACE FUNCTION fn_descontar_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.producto_id;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON venta_productos
FOR EACH ROW
EXECUTE FUNCTION fn_descontar_stock();

SELECT id, nombre, stock FROM productos WHERE id = 1;   -- leche entera, stock 100

INSERT INTO ventas (cliente_id, metodo_pago_id)
VALUES (1, 3)
RETURNING id;   -- me dio 152

INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
VALUES (152, 1, 3, 1.65);

SELECT id, nombre, stock FROM productos WHERE id = 1;   -- queda en 97

-- 11
INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
VALUES (152, 25, 1, 3.10);

-- da error: violates check constraint "productos_stock_check"
-- el jamon tiene stock 0, el trigger lo quiere dejar en -1 y la tabla tiene
-- CHECK (stock >= 0). como el trigger es parte del mismo insert, falla todo
-- junto y la linea no se guarda. la venta 152 queda solo con la leche:
SELECT * FROM venta_productos WHERE venta_id = 152;
