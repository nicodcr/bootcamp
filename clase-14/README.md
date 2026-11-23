# Semana 7 · Clase 14 · Restaurar Northwind

Base `northwind` restaurada en el Postgres de Docker (contenedor `my_postgres_bootcamp`).

## Comandos (PowerShell, desde la carpeta `datasets`)

```powershell
docker exec my_postgres_bootcamp createdb -U myuser northwind
docker cp .\northwind.sql my_postgres_bootcamp:/tmp/northwind.sql
docker exec my_postgres_bootcamp psql -U myuser -d northwind -q -f /tmp/northwind.sql
docker exec my_postgres_bootcamp psql -U myuser -d northwind -c "\dt"
```

## Salida de `\dt`

```
                List of relations
 Schema |          Name          | Type  | Owner
--------+------------------------+-------+--------
 public | categories             | table | myuser
 public | customer_customer_demo | table | myuser
 public | customer_demographics  | table | myuser
 public | customers              | table | myuser
 public | employee_territories   | table | myuser
 public | employees              | table | myuser
 public | order_details          | table | myuser
 public | orders                 | table | myuser
 public | products               | table | myuser
 public | region                 | table | myuser
 public | shippers               | table | myuser
 public | suppliers              | table | myuser
 public | territories            | table | myuser
 public | us_states              | table | myuser
(14 rows)
```

## Consulta de verificación

```sql
SELECT
    (SELECT COUNT(*) FROM customers)     AS customers,
    (SELECT COUNT(*) FROM orders)        AS orders,
    (SELECT COUNT(*) FROM order_details) AS order_details,
    (SELECT COUNT(*) FROM products)      AS products,
    (SELECT COUNT(*) FROM employees)     AS employees;
```

```
 customers | orders | order_details | products | employees
-----------+--------+---------------+----------+-----------
        91 |    830 |          2155 |       77 |         9
(1 row)
```

Coincide con el resultado esperado.
