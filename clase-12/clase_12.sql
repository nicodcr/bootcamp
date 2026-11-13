-- =====================================================================
-- Semana 6 · Clase 12 · Tarea — JOINs sobre el minimercado
-- Base: minimercado (cargada con datasets/minimercado.sql)
-- =====================================================================


-- ---------------------------------------------------------------------
-- INNER JOIN
-- ---------------------------------------------------------------------

-- Ejercicio 1: cada proveedor con los nombres de sus productos
-- (solo proveedores que tienen productos).
SELECT pv.nombre AS proveedor,
       pr.nombre AS producto
FROM proveedores pv
INNER JOIN productos pr ON pr.proveedor_id = pv.id
ORDER BY pv.nombre, pr.nombre;


-- ---------------------------------------------------------------------
-- LEFT JOIN
-- ---------------------------------------------------------------------

-- Ejercicio 2: todos los proveedores y cuántos productos tiene cada uno
-- (incluye los que tienen 0).
SELECT pv.id,
       pv.nombre AS proveedor,
       COUNT(pr.id) AS cantidad_productos
FROM proveedores pv
LEFT JOIN productos pr ON pr.proveedor_id = pv.id
GROUP BY pv.id, pv.nombre
ORDER BY cantidad_productos DESC, pv.nombre;


-- Ejercicio 3: ventas que no tienen ningún producto en venta_productos.
SELECT v.id AS venta_id,
       v.fecha,
       v.total
FROM ventas v
LEFT JOIN venta_productos vp ON vp.venta_id = v.id
WHERE vp.venta_id IS NULL
ORDER BY v.id;


-- ---------------------------------------------------------------------
-- RIGHT JOIN
-- ---------------------------------------------------------------------

-- Ejercicio 4: todos los métodos de pago y cuántas ventas tiene cada uno.
-- metodos_pago queda a la derecha, así aparecen también los que nunca se usaron.
SELECT mp.nombre AS metodo_pago,
       COUNT(v.id) AS cantidad_ventas
FROM ventas v
RIGHT JOIN metodos_pago mp ON v.metodo_pago_id = mp.id
GROUP BY mp.id, mp.nombre
ORDER BY cantidad_ventas DESC, mp.nombre;


-- ---------------------------------------------------------------------
-- FULL OUTER JOIN
-- ---------------------------------------------------------------------

-- Ejercicio 5: productos que nunca se vendieron.
-- Del lado de venta_productos quedan en NULL los productos sin ventas.
SELECT p.id,
       p.nombre AS producto
FROM productos p
FULL OUTER JOIN venta_productos vp ON vp.producto_id = p.id
WHERE vp.producto_id IS NULL
ORDER BY p.id;


-- ---------------------------------------------------------------------
-- CROSS JOIN
-- ---------------------------------------------------------------------

-- Ejercicio 6: todas las combinaciones de productos y métodos de pago.
SELECT p.nombre AS producto,
       p.precio,
       mp.nombre AS metodo_pago
FROM productos p
CROSS JOIN metodos_pago mp
ORDER BY p.nombre, mp.nombre;
-- Devuelve 336 filas: 42 productos x 8 métodos de pago.
-- El CROSS JOIN no usa condición: combina cada fila de una tabla con
-- todas las filas de la otra (producto cartesiano).


-- ---------------------------------------------------------------------
-- JOIN múltiple
-- ---------------------------------------------------------------------

-- Ejercicio 7: cliente, fecha y cantidad total de unidades de cada venta.
SELECT v.id AS venta_id,
       c.nombre AS cliente,
       v.fecha,
       SUM(vp.cantidad) AS unidades
FROM ventas v
INNER JOIN clientes c ON c.id = v.cliente_id
INNER JOIN venta_productos vp ON vp.venta_id = v.id
GROUP BY v.id, c.nombre, v.fecha
ORDER BY v.fecha, v.id;


-- Ejercicio 8: total facturado por proveedor, de mayor a menor.
SELECT pv.nombre AS proveedor,
       SUM(vp.cantidad * vp.precio_unitario) AS total_facturado
FROM proveedores pv
INNER JOIN productos pr ON pr.proveedor_id = pv.id
INNER JOIN venta_productos vp ON vp.producto_id = pr.id
GROUP BY pv.id, pv.nombre
ORDER BY total_facturado DESC;


-- ---------------------------------------------------------------------
-- JOIN múltiple combinando INNER y LEFT
-- ---------------------------------------------------------------------

-- Ejercicio 9: todos los productos con su proveedor y unidades vendidas
-- (los que nunca se vendieron aparecen con 0).
SELECT pr.nombre AS producto,
       pv.nombre AS proveedor,
       COALESCE(SUM(vp.cantidad), 0) AS unidades_vendidas
FROM productos pr
INNER JOIN proveedores pv ON pv.id = pr.proveedor_id
LEFT JOIN venta_productos vp ON vp.producto_id = pr.id
GROUP BY pr.id, pr.nombre, pv.nombre
ORDER BY unidades_vendidas DESC, pr.nombre;


-- Ejercicio 10: todas las ventas con cliente, método de pago y cantidad
-- de productos distintos (las ventas sin productos aparecen con 0).
SELECT v.id AS venta_id,
       c.nombre AS cliente,
       mp.nombre AS metodo_pago,
       COUNT(DISTINCT vp.producto_id) AS productos_distintos
FROM ventas v
INNER JOIN clientes c ON c.id = v.cliente_id
INNER JOIN metodos_pago mp ON mp.id = v.metodo_pago_id
LEFT JOIN venta_productos vp ON vp.venta_id = v.id
GROUP BY v.id, c.nombre, mp.nombre
ORDER BY v.id;


-- Ejercicio 11: todos los proveedores y en cuántas ventas distintas se
-- vendió algún producto suyo (0 si nunca).
SELECT pv.id,
       pv.nombre AS proveedor,
       COUNT(DISTINCT vp.venta_id) AS ventas_distintas
FROM proveedores pv
LEFT JOIN productos pr ON pr.proveedor_id = pv.id
LEFT JOIN venta_productos vp ON vp.producto_id = pr.id
GROUP BY pv.id, pv.nombre
ORDER BY ventas_distintas DESC, pv.nombre;

-- Ejercicio 11 (variante): el segundo LEFT JOIN cambiado por INNER JOIN.
SELECT pv.id,
       pv.nombre AS proveedor,
       COUNT(DISTINCT vp.venta_id) AS ventas_distintas
FROM proveedores pv
LEFT JOIN productos pr ON pr.proveedor_id = pv.id
INNER JOIN venta_productos vp ON vp.producto_id = pr.id
GROUP BY pv.id, pv.nombre
ORDER BY ventas_distintas DESC, pv.nombre;
-- Con LEFT JOIN salen los 11 proveedores; con INNER JOIN salen 9.
-- Desaparecen "Bebidas del Litoral" (id 10) y "Panificadora San Juan" (id 11),
-- que no tienen productos: el primer LEFT JOIN los deja con pr.id en NULL,
-- y el INNER JOIN contra venta_productos descarta esas filas porque
-- NULL no coincide con ningún producto_id.
-- Los proveedores de productos nunca vendidos (ids 36 a 40) no desaparecen
-- porque también tienen otros productos que sí se vendieron.
