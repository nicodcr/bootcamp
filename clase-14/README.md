# Clase 14 - Restaurar Northwind

Cargue northwind.sql en el postgres de docker:

```
docker exec my_postgres_bootcamp createdb -U myuser northwind
docker cp .\northwind.sql my_postgres_bootcamp:/tmp/northwind.sql
docker exec my_postgres_bootcamp psql -U myuser -d northwind -q -f /tmp/northwind.sql
docker exec my_postgres_bootcamp psql -U myuser -d northwind -c "\dt"
```

\dt:

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

Verificacion:

```
 customers | orders | order_details | products | employees
-----------+--------+---------------+----------+-----------
        91 |    830 |          2155 |       77 |         9
(1 row)
```
