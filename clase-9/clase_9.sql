-- Parte 1

CREATE TABLE apartments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    bedrooms INT,
    area_m2 NUMERIC(6,2),
    price NUMERIC(10,2),
    available BOOLEAN,
    published_date DATE
);

INSERT INTO apartments (name, address, city, postal_code, bedrooms, area_m2, price, available, published_date) VALUES
('Depto A', 'Av. Siempre Viva 123', 'Buenos Aires', 'C1000', 2, 55.50, 120000, TRUE, '2023-08-01'),
('Depto B', 'Av. Corrientes 1450', 'Buenos Aires', 'C1042', 1, 38.00, 89000, TRUE, '2023-08-03'),
('Depto C', 'Av. Santa Fe 3120', 'Buenos Aires', 'C1425', 3, 82.75, 215000, FALSE, '2023-08-05'),
('Depto D', 'Thames 1780', 'Buenos Aires', 'C1414', 2, 58.00, 165000, TRUE, '2023-08-07'),
('Depto E', 'Av. Cabildo 2245', 'Buenos Aires', 'C1428', 4, 110.00, 298000, TRUE, '2023-08-10'),
('Depto F', 'Defensa 850', 'Buenos Aires', 'C1065', 1, 42.30, 97500, FALSE, '2023-08-12'),
('Depto G', 'Av. Rivadavia 6100', 'Buenos Aires', 'C1406', 2, 64.00, 132000, TRUE, '2023-08-14'),
('Depto H', 'Av. Colón 950', 'Córdoba', 'X5000', 2, 52.00, 78000, TRUE, '2023-08-16'),
('Depto I', 'Bv. San Juan 420', 'Córdoba', 'X5000', 1, 35.50, 54000, TRUE, '2023-08-18'),
('Depto J', 'Rondeau 275', 'Córdoba', 'X5000', 3, 75.00, 112000, FALSE, '2023-08-20'),
('Depto K', 'Av. Hipólito Yrigoyen 310', 'Córdoba', 'X5000', 2, 59.90, 86500, TRUE, '2023-08-22'),
('Depto L', 'Belgrano 640', 'Córdoba', 'X5000', 3, 88.00, 128000, TRUE, '2023-08-24'),
('Depto M', 'Bv. Oroño 1120', 'Rosario', 'S2000', 2, 62.00, 98000, TRUE, '2023-08-26'),
('Depto N', 'Pellegrini 2050', 'Rosario', 'S2000', 1, 40.00, 61000, FALSE, '2023-08-28'),
('Depto O', 'Córdoba 1680', 'Rosario', 'S2000', 2, 48.50, 74000, TRUE, '2023-08-30'),
('Depto P', 'San Lorenzo 890', 'Rosario', 'S2000', 3, 79.00, 121000, TRUE, '2023-09-01'),
('Depto Q', 'Av. del Huerto 1215', 'Rosario', 'S2000', 4, 125.00, 310000, FALSE, '2023-09-03'),
('Depto R', 'Mitre 745', 'Rosario', 'S2000', 1, 36.00, 52500, TRUE, '2023-09-05'),
('Depto S', 'Av. San Martín 1320', 'Mendoza', 'M5500', 2, 57.00, 82000, TRUE, '2023-09-07'),
('Depto T', 'Sarmiento 515', 'Mendoza', 'M5500', 1, 39.00, 58000, TRUE, '2023-09-09'),
('Depto U', 'Av. Arístides Villanueva 480', 'Mendoza', 'M5500', 3, 84.00, 134000, FALSE, '2023-09-11'),
('Depto V', 'Colón 260', 'Mendoza', 'M5500', 2, 66.50, 95000, TRUE, '2023-09-13'),
('Depto W', 'Las Heras 1040', 'Mendoza', 'M5500', 2, 49.00, 71000, TRUE, '2023-09-15'),
('Depto X', 'Junín 1350', 'Corrientes', 'W3400', 2, 54.00, 64000, TRUE, '2023-09-17'),
('Depto Y', 'Av. 3 de Abril 720', 'Corrientes', 'W3400', 1, 37.50, 43000, FALSE, '2023-09-19'),
('Depto Z', 'Carlos Pellegrini 910', 'Corrientes', 'W3400', 3, 72.00, 89000, TRUE, '2023-09-21'),
('Depto AA', 'San Juan 1185', 'Corrientes', 'W3400', 2, 60.00, 69000, TRUE, '2023-09-23'),
('Depto AB', 'Av. Costanera 455', 'Corrientes', 'W3400', 4, 118.00, 185000, TRUE, '2023-09-25'),
('Depto AC', 'Mendoza 630', 'Corrientes', 'W3400', 3, 59.00, 76000, FALSE, '2023-09-27'),
('Depto AD', 'La Rioja 1420', 'Corrientes', 'W3400', 1, 33.00, 39500, TRUE, '2023-09-29');

-- Ejercicio 1
SELECT *
FROM apartments
WHERE available = TRUE
ORDER BY price ASC;

-- Ejercicio 2
SELECT city, ROUND(AVG(price), 2) AS avg_price
FROM apartments
GROUP BY city
ORDER BY avg_price DESC;

-- Ejercicio 3
SELECT *
FROM apartments
WHERE bedrooms >= 2
  AND area_m2 < 60;


-- Parte 2

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product VARCHAR(50),
    category VARCHAR(30),
    price NUMERIC,
    quantity INT,
    sale_date DATE
);

INSERT INTO sales (product, category, price, quantity, sale_date) VALUES
('Mouse', 'Electronics', 15, 4, '2023-07-10'),
('Keyboard', 'Electronics', 30, 2, '2023-07-11'),
('Notebook', 'Stationery', 8, 10, '2023-07-12'),
('Pen', 'Stationery', 2, 25, '2023-07-13'),
('Headphones', 'Electronics', 40, 3, '2023-07-14'),
('Monitor', 'Electronics', 120, 1, '2023-07-15'),
('Desk Chair', 'Furniture', 85, 2, '2023-07-16'),
('Notebook Case', 'Accessories', 25, 3, '2023-07-17'),
('Printer Paper', 'Stationery', 6, 15, '2023-07-18'),
('USB Drive', 'Electronics', 12, 5, '2023-07-19'),
('Desk Lamp', 'Furniture', 35, 4, '2023-07-20'),
('Stapler', 'Stationery', 7, 6, '2023-07-21'),
('Calculator', 'Electronics', 20, 3, '2023-07-22'),
('Water Bottle', 'Accessories', 10, 8, '2023-07-23'),
('Laptop Stand', 'Accessories', 45, 2, '2023-07-24'),
('Office Desk', 'Furniture', 150, 1, '2023-07-25'),
('Whiteboard', 'Furniture', 60, 1, '2023-07-26'),
('Marker Set', 'Stationery', 5, 12, '2023-07-27'),
('Mouse Pad', 'Accessories', 8, 7, '2023-07-28'),
('Webcam', 'Electronics', 50, 2, '2023-07-29'),
('Smartphone', 'Electronics', 300, 1, '2023-07-30'),
('Notebook Pro', 'Electronics', 900, 1, '2023-07-31'),
('File Cabinet', 'Furniture', 120, 1, '2023-08-01'),
('Backpack', 'Accessories', 40, 3, '2023-08-02'),
('Binder', 'Stationery', 4, 20, '2023-08-03'),
('Headset Stand', 'Accessories', 15, 5, '2023-08-04'),
('Desk Organizer', 'Accessories', 12, 6, '2023-08-05'),
('Laptop Sleeve', 'Accessories', 30, 2, '2023-08-06'),
('Paper Clips', 'Stationery', 1, 50, '2023-08-07'),
('Surge Protector', 'Electronics', 25, 3, '2023-08-08'),
('Pen Holder', 'Accessories', 5, 10, '2023-08-09');

-- Ejercicio 1
SELECT *
FROM sales
WHERE category = 'Electronics';

-- Ejercicio 2
SELECT category, SUM(price * quantity) AS total_revenue
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;

-- Ejercicio 3
SELECT category, SUM(price * quantity) AS total_revenue
FROM sales
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;

-- Ejercicio 4
SELECT *
FROM sales
WHERE price > 20;

-- Ejercicio 5
SELECT product, SUM(quantity) AS total_units
FROM sales
GROUP BY product
ORDER BY product;

-- Ejercicio 6
SELECT product, ROUND(AVG(price * quantity), 2) AS avg_revenue
FROM sales
GROUP BY product
ORDER BY product;

-- Ejercicio 7
SELECT product, SUM(quantity) AS total_units
FROM sales
GROUP BY product
ORDER BY total_units DESC
LIMIT 3;

-- Ejercicio 8
SELECT *
FROM sales
WHERE sale_date > '2023-07-12';

-- Ejercicio 9
SELECT category, SUM(price * quantity) AS total_revenue
FROM sales
GROUP BY category
HAVING SUM(price * quantity) > 50;

-- Ejercicio 10
SELECT *
FROM sales
WHERE product LIKE 'H%';

-- Ejercicio 11
SELECT category, ROUND(AVG(quantity), 2) AS avg_quantity
FROM sales
GROUP BY category;

-- Ejercicio 12
SELECT *, price * quantity AS revenue
FROM sales
ORDER BY revenue DESC;

-- Ejercicio 13
SELECT *
FROM sales
WHERE category = 'Electronics'
  AND quantity > 2
  AND price < 40;
