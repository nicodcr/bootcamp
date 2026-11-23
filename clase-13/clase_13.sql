-- =====================================================================
-- Semana 7 · Clase 13 · Tarea — SQL avanzado sobre el minimercado
-- Base: minimercado (recreada desde cero con datasets/minimercado.sql)
-- =====================================================================


-- ---------------------------------------------------------------------
-- VISTAS
-- ---------------------------------------------------------------------

-- Ejercicio 1: vista con una fila por cada producto vendido.
CREATE OR REPLACE VIEW vista_detalle_ventas AS
SELECT v.id                            AS venta_id,
       v.fecha,
       c.nombre                        AS cliente,
       mp.nombre                       AS metodo_pago,
       pr.nombre                       AS producto,
       pv.nombre                       AS proveedor,
       vp.cantidad,
       vp.precio_unitario,
       vp.cantidad * vp.precio_unitario AS subtotal
FROM ventas v
INNER JOIN clientes c         ON c.id = v.cliente_id
INNER JOIN metodos_pago mp    ON mp.id = v.metodo_pago_id
INNER JOIN venta_productos vp ON vp.venta_id = v.id
INNER JOIN productos pr       ON pr.id = vp.producto_id
INNER JOIN proveedores pv     ON pv.id = pr.proveedor_id;

SELECT * FROM vista_detalle_ventas ORDER BY venta_id LIMIT 10;


-- Ejercicio 2a: total gastado por cada cliente, de mayor a menor.
SELECT cliente,
       SUM(subtotal) AS total_gastado
FROM vista_detalle_ventas
GROUP BY cliente
ORDER BY total_gastado DESC;

-- Ejercicio 2b: productos más vendidos (unidades), de mayor a menor.
SELECT producto,
       SUM(cantidad) AS unidades_vendidas
FROM vista_detalle_ventas
GROUP BY producto
ORDER BY unidades_vendidas DESC;


-- Ejercicio 3: productos con menos de 10 unidades en stock.
CREATE OR REPLACE VIEW vista_stock_bajo AS
SELECT pr.id,
       pr.nombre,
       pr.stock,
       pv.nombre   AS proveedor,
       pv.telefono AS telefono_proveedor
FROM productos pr
INNER JOIN proveedores pv ON pv.id = pr.proveedor_id
WHERE pr.stock < 10;

SELECT * FROM vista_stock_bajo ORDER BY stock;


-- Ejercicio 4: vista materializada de ventas por mes.
CREATE MATERIALIZED VIEW mv_ventas_por_mes AS
SELECT DATE_TRUNC('month', fecha)::date AS mes,
       COUNT(*)                         AS cantidad_ventas,
       SUM(total)                       AS total_vendido
FROM ventas
GROUP BY DATE_TRUNC('month', fecha)
ORDER BY mes;

-- 4.1 Consulta inicial
SELECT * FROM mv_ventas_por_mes;

-- 4.2 Venta nueva en un mes que todavía no tiene ventas
INSERT INTO ventas (cliente_id, metodo_pago_id, fecha, total)
VALUES (7, 3, '2026-11-20 10:00:00', 50.00);

-- 4.3 Volver a consultar: NO cambió. La vista materializada guarda el
-- resultado como una foto del momento en que se creó; no se entera de
-- los cambios en la tabla ventas hasta que se la refresca.
SELECT * FROM mv_ventas_por_mes;

-- 4.4 Refrescar y consultar: ahora aparece el mes 2026-11 con 1 venta y 50.00.
REFRESH MATERIALIZED VIEW mv_ventas_por_mes;

SELECT * FROM mv_ventas_por_mes;


-- ---------------------------------------------------------------------
-- ÍNDICES
-- ---------------------------------------------------------------------

-- Ejercicio 5: índices que ya tiene la base.
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Ya tienen índice:
--   * La columna id de clientes, proveedores, productos, metodos_pago y ventas
--     (índices *_pkey).
--   * clientes.email (clientes_email_key).
--   * venta_productos (venta_id, producto_id) (venta_productos_pkey).
-- Por qué: PostgreSQL crea un índice automáticamente para cada PRIMARY KEY
-- y cada UNIQUE, porque lo necesita para verificar rápido que no se repitan
-- valores. Las FOREIGN KEY (cliente_id, producto_id, etc.) NO generan
-- índice solas: hay que crearlos a mano (ejercicio 7).


-- Ejercicio 6: tabla de 1 millón de filas para medir el efecto de un índice.
CREATE TABLE prueba_indices AS
SELECT gs                                              AS id,
       (random() * 9999 + 1)::int                      AS cliente_id,
       DATE '2024-01-01' + (random() * 730)::int       AS fecha,
       ROUND((random() * 1000)::numeric, 2)            AS total
FROM generate_series(1, 1000000) AS gs;

ANALYZE prueba_indices;

-- 6.1 Sin índice
EXPLAIN ANALYZE
SELECT * FROM prueba_indices WHERE cliente_id = 1234;

CREATE INDEX idx_prueba_cliente_id ON prueba_indices (cliente_id);

-- 6.2 Con índice
EXPLAIN ANALYZE
SELECT * FROM prueba_indices WHERE cliente_id = 1234;

-- Resultados:
--   Sin índice: Parallel Seq Scan (recorre el millón de filas)  — Execution Time: 2448.084 ms
--   Con índice: Bitmap Index Scan + Bitmap Heap Scan          — Execution Time: 112.726 ms
-- El índice evita leer toda la tabla: va directo a las ~100 filas de ese
-- cliente. Unas 20 veces más rápido. (Los datos son aleatorios, así que en
-- cada ejecución los tiempos cambian un poco.)

DROP TABLE prueba_indices;


-- Ejercicio 7: índices sobre las columnas que más se usan para buscar y unir.
CREATE INDEX idx_ventas_cliente_id         ON ventas (cliente_id);
CREATE INDEX idx_venta_productos_producto  ON venta_productos (producto_id);
CREATE INDEX idx_ventas_fecha              ON ventas (fecha);

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN ('idx_ventas_cliente_id', 'idx_venta_productos_producto', 'idx_ventas_fecha');


-- ---------------------------------------------------------------------
-- FUNCIONES Y PROCEDIMIENTOS
-- ---------------------------------------------------------------------

-- Ejercicio 8: total gastado por un cliente (0 si nunca compró).
CREATE OR REPLACE FUNCTION fn_total_gastado(p_cliente_id INT)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(vp.cantidad * vp.precio_unitario), 0)
    FROM ventas v
    INNER JOIN venta_productos vp ON vp.venta_id = v.id
    WHERE v.cliente_id = p_cliente_id;
$$;

SELECT id,
       nombre,
       fn_total_gastado(id) AS total_gastado
FROM clientes
ORDER BY total_gastado DESC, nombre;


-- Ejercicio 9: aumentar en un porcentaje los precios de un proveedor.
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

-- 9.1 Precios antes (Lácteos del Valle)
SELECT pr.id, pr.nombre, pr.precio
FROM productos pr
INNER JOIN proveedores pv ON pv.id = pr.proveedor_id
WHERE pv.nombre = 'Lácteos del Valle'
ORDER BY pr.id;

-- 9.2 Aumento del 10 %. Lácteos del Valle es el proveedor id 8
-- (CALL no acepta subconsultas como argumento, por eso va el id directo).
CALL sp_aumentar_precios(8, 10);
-- NOTICE: Se actualizaron 6 productos

-- 9.3 Precios después
SELECT pr.id, pr.nombre, pr.precio
FROM productos pr
INNER JOIN proveedores pv ON pv.id = pr.proveedor_id
WHERE pv.nombre = 'Lácteos del Valle'
ORDER BY pr.id;


-- ---------------------------------------------------------------------
-- TRIGGERS
-- ---------------------------------------------------------------------

-- Ejercicio 10: descontar stock después de cada INSERT en venta_productos.
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

-- 10.1 Stock antes
SELECT id, nombre, stock FROM productos WHERE nombre = 'Leche Entera 1L';

-- 10.2 Venta nueva (RETURNING muestra el id que se generó)
INSERT INTO ventas (cliente_id, metodo_pago_id, total)
VALUES (1, 3, NULL)
RETURNING id;

-- 10.3 Agregarle 3 Leches Enteras. currval() devuelve el último id
-- generado por la secuencia de ventas en esta sesión (el de 10.2).
INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
SELECT currval('ventas_id_seq'), id, 3, precio
FROM productos
WHERE nombre = 'Leche Entera 1L';

-- 10.4 Stock después: bajó de 100 a 97.
SELECT id, nombre, stock FROM productos WHERE nombre = 'Leche Entera 1L';


-- Ejercicio 11: agregar a la misma venta el Jamón Cocido (stock 0).
INSERT INTO venta_productos (venta_id, producto_id, cantidad, precio_unitario)
SELECT currval('ventas_id_seq'), id, 1, precio
FROM productos
WHERE nombre = 'Jamón Cocido 200g';

-- Resultado:
--   ERROR: new row for relation "productos" violates check constraint "productos_stock_check"
-- Qué pasa: el INSERT en venta_productos se hace, pero enseguida el trigger
-- intenta dejar el stock del jamón en 0 - 1 = -1, y la tabla productos tiene
-- CHECK (stock >= 0). Ese UPDATE falla, y como el trigger corre dentro de la
-- misma sentencia que el INSERT, PostgreSQL deshace todo junto.
-- ¿Se guardó la línea? NO. La venta queda solo con la leche:
SELECT * FROM venta_productos WHERE venta_id = currval('ventas_id_seq');
SELECT id, nombre, stock FROM productos WHERE nombre = 'Jamón Cocido 200g';
-- (en pgAdmin, ejecutar estas dos consultas aparte, porque el error corta el script)
