-- =====================================================================
-- PREGUNTA 1. Diseño e implementación del modelo de datos
-- =====================================================================
-- Carga previa (host -> namenode -> HDFS):
--   docker cp data/superstore_antho.csv docker-hadoop-hive-parquet-namenode-1:/tmp/
--   docker exec -it docker-hadoop-hive-parquet-namenode-1 bash
--   hdfs dfs -mkdir -p /user/hive/warehouse/staging
--   hdfs dfs -put /tmp/superstore_antho.csv /user/hive/warehouse/staging/
--   hdfs dfs -ls /user/hive/warehouse/staging/
-- Acceso a Hive:
--   docker exec -it docker-hadoop-hive-parquet-hive-server-1 beeline -u jdbc:hive2://localhost:10000
-- =====================================================================

CREATE DATABASE IF NOT EXISTS db_antho;
USE db_antho;

-- Tabla de staging: lee el CSV tal cual (campos entre comillas con comas)
DROP TABLE IF EXISTS superstore_raw;
CREATE TABLE superstore_raw (
  row_id STRING, order_id STRING, order_date STRING, ship_date STRING,
  ship_mode STRING, customer_id STRING, customer_name STRING, segment STRING,
  country STRING, city STRING, state STRING, postal_code STRING,
  region STRING, product_id STRING, category STRING, sub_category STRING,
  product_name STRING, sales STRING, quantity STRING, discount STRING,
  profit STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ("separatorChar" = ",", "quoteChar" = "\"")
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count" = "1");

LOAD DATA INPATH '/user/hive/warehouse/staging/superstore_antho.csv'
INTO TABLE superstore_raw;

-- Tabla analítica con tipos de datos correctos
DROP TABLE IF EXISTS superstore;
CREATE TABLE superstore (
  row_id        INT,
  order_id      STRING,
  order_date    DATE,
  ship_date     DATE,
  ship_mode     STRING,
  customer_id   STRING,
  customer_name STRING,
  segment       STRING,
  country       STRING,
  city          STRING,
  state         STRING,
  postal_code   STRING,
  region        STRING,
  product_id    STRING,
  category      STRING,
  sub_category  STRING,
  product_name  STRING,
  sales         DOUBLE,
  quantity      INT,
  discount      DOUBLE,
  profit        DOUBLE
)
STORED AS ORC;

INSERT OVERWRITE TABLE superstore
SELECT
  CAST(row_id AS INT),
  order_id,
  TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(order_date, 'M/d/yyyy'))),
  TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(ship_date,  'M/d/yyyy'))),
  ship_mode, customer_id, customer_name, segment, country, city, state,
  postal_code, region, product_id, category, sub_category, product_name,
  CAST(sales AS DOUBLE),
  CAST(quantity AS INT),
  CAST(discount AS DOUBLE),
  CAST(profit AS DOUBLE)
FROM superstore_raw;

-- Evidencia de registros importados
DESCRIBE FORMATTED superstore;
SELECT COUNT(*) AS registros_raw FROM superstore_raw;
SELECT COUNT(*) AS registros_superstore FROM superstore;
SELECT row_id, order_id, order_date, ship_date, customer_id, region,
       category, sales, quantity, discount, profit
FROM superstore LIMIT 5;

-- =====================================================================
-- RESULTADO
-- =====================================================================
-- registros_raw         : 9994
-- registros_superstore  : 9994
-- Rango de fechas       : 2014-01-03 a 2017-12-30
--
-- row_id | order_id       | order_date | ship_date  | customer_id | region | category        | sales    | quantity | discount | profit
-- 1      | CA-2016-152156 | 2016-11-08 | 2016-11-11 | CG-12520    | South  | Furniture       | 261.96   | 2        | 0.0      | 41.9136
-- 2      | CA-2016-152156 | 2016-11-08 | 2016-11-11 | CG-12520    | South  | Furniture       | 731.94   | 3        | 0.0      | 219.582
-- 3      | CA-2016-138688 | 2016-06-12 | 2016-06-16 | DV-13045    | West   | Office Supplies | 14.62    | 2        | 0.0      | 6.8714
-- 4      | US-2015-108966 | 2015-10-11 | 2015-10-18 | SO-20335    | South  | Furniture       | 957.5775 | 5        | 0.45     | -383.031
-- 5      | US-2015-108966 | 2015-10-11 | 2015-10-18 | SO-20335    | South  | Office Supplies | 22.368   | 2        | 0.2      | 2.5164
