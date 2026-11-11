# tem1_2mom_Arevalo_Anthony_Alberth

Examen práctico individual – 2do momento. Análisis del dataset **Superstore Sales (Sample Superstore)** con Apache Hive.

**Estudiante:** Anthony Alberth Arevalo

## Objetivo
Modelar, cargar, auditar y analizar el dataset Superstore con HiveQL (preguntas 1 a 6).

## Requisitos
- Docker y Docker Compose (≥ 8 GB RAM para los contenedores).
- Dataset: https://www.kaggle.com/datasets/vivek468/superstore-dataset-final (`Sample - Superstore.csv`, 9994 registros, 21 columnas).

## Estructura
```
docker-hadoop-hive-parquet/   stack Hadoop 3 + Hive 4 + Hue (docker compose)
  data/                       aquí va el CSV (no se sube al repo)
sql/pregunta_01.sql ... pregunta_06.sql   consulta + resultado de cada pregunta
diccionario_datos.md          diccionario de datos
```

## Procedimiento de ejecución
1. Levantar el stack:
   ```bash
   cd docker-hadoop-hive-parquet
   docker compose up -d --wait
   docker ps
   ```
2. Convertir el CSV a UTF-8 y renombrarlo:
   ```bash
   iconv -f WINDOWS-1252 -t UTF-8 "data/Sample - Superstore.csv" > data/superstore_antho.csv
   ```
3. Copiarlo al namenode y subirlo a HDFS:
   ```bash
   docker cp data/superstore_antho.csv docker-hadoop-hive-parquet-namenode-1:/tmp/
   docker exec -it docker-hadoop-hive-parquet-namenode-1 bash
   hdfs dfs -mkdir -p /user/hive/warehouse/staging
   hdfs dfs -put /tmp/superstore_antho.csv /user/hive/warehouse/staging/
   ```
4. Entrar a Hive y ejecutar los scripts en orden (`sql/pregunta_01.sql` primero):
   ```bash
   docker exec -it docker-hadoop-hive-parquet-hive-server-1 beeline -u jdbc:hive2://localhost:10000
   ```

## Preguntas
| Nro | Tema | Archivo |
|-----|------|---------|
| 1 | Modelo de datos, DDL y carga | `sql/pregunta_01.sql` |
| 2 | Auditoría de calidad | `sql/pregunta_02.sql` |
| 3 | Evolución por región (CTE + ventanas) | `sql/pregunta_03.sql` |
| 4 | Segmentación RFM | `sql/pregunta_04.sql` |
| 5 | Ranking de productos | `sql/pregunta_05.sql` |
| 6 | Impacto de los descuentos | `sql/pregunta_06.sql` |

Cada archivo contiene el número de pregunta, la consulta HiveQL y el resultado obtenido.

## Uso de IA
Se utilizó inteligencia artificial (Claude) como apoyo para redactar las consultas y la documentación.
