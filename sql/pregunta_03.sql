-- =====================================================================
-- PREGUNTA 3. Análisis de evolución comercial por región
-- =====================================================================
USE db_antho;

-- Ventas, ganancia, margen y variación % vs año anterior por región
WITH base AS (
  SELECT region,
         YEAR(order_date) AS anio,
         SUM(sales)       AS ventas,
         SUM(profit)      AS ganancia
  FROM superstore
  GROUP BY region, YEAR(order_date)
),
calc AS (
  SELECT region, anio, ventas, ganancia,
         ganancia / ventas * 100 AS margen_pct,
         LAG(ventas)   OVER (PARTITION BY region ORDER BY anio) AS ventas_anio_ant,
         LAG(ganancia) OVER (PARTITION BY region ORDER BY anio) AS ganancia_anio_ant
  FROM base
)
SELECT region, anio,
       ROUND(ventas, 2)     AS ventas,
       ROUND(ganancia, 2)   AS ganancia,
       ROUND(margen_pct, 2) AS margen_pct,
       ROUND((ventas - ventas_anio_ant) / ventas_anio_ant * 100, 2)       AS var_ventas_pct,
       ROUND((ganancia - ganancia_anio_ant) / ganancia_anio_ant * 100, 2) AS var_ganancia_pct,
       RANK() OVER (PARTITION BY anio ORDER BY ganancia DESC)             AS rank_anio
FROM calc
ORDER BY region, anio;

-- Región con mejor y peor desempeño (acumulado de todos los años)
WITH tot AS (
  SELECT region, SUM(sales) AS ventas, SUM(profit) AS ganancia
  FROM superstore
  GROUP BY region
),
rk AS (
  SELECT region, ventas, ganancia,
         ganancia / ventas * 100 AS margen_pct,
         RANK() OVER (ORDER BY ganancia DESC) AS posicion,
         COUNT(*) OVER ()                     AS total_regiones
  FROM tot
)
SELECT region,
       ROUND(ventas, 2)     AS ventas,
       ROUND(ganancia, 2)   AS ganancia,
       ROUND(margen_pct, 2) AS margen_pct,
       posicion,
       CASE WHEN posicion = 1 THEN 'MEJOR'
            WHEN posicion = total_regiones THEN 'PEOR'
            ELSE '-' END AS desempeno
FROM rk
ORDER BY posicion;

-- =====================================================================
-- RESULTADO
-- =====================================================================
-- region  | anio | ventas    | ganancia | margen_pct | var_ventas_pct | var_ganancia_pct | rank_anio
-- Central | 2014 | 103838.16 |   539.55 |  0.52 | NULL   | NULL    | 4
-- Central | 2015 | 102874.22 | 11716.80 | 11.39 | -0.93  | 2071.57 | 3
-- Central | 2016 | 147429.38 | 19899.16 | 13.50 | 43.31  | 69.83   | 3
-- Central | 2017 | 147098.13 |  7550.84 |  5.13 | -0.22  | -62.05  | 4
-- East    | 2014 | 128680.46 | 17059.61 | 13.26 | NULL   | NULL    | 2
-- East    | 2015 | 156332.06 | 21091.01 | 13.49 | 21.49  | 23.63   | 1
-- East    | 2016 | 180685.82 | 20141.60 | 11.15 | 15.58  | -4.50   | 2
-- East    | 2017 | 213082.90 | 33230.56 | 15.60 | 17.93  | 64.98   | 2
-- South   | 2014 | 103845.84 | 11879.12 | 11.44 | NULL   | NULL    | 3
-- South   | 2015 |  71359.98 |  8318.59 | 11.66 | -31.28 | -29.97  | 4
-- South   | 2016 |  93610.22 | 17702.81 | 18.91 | 31.18  | 112.81  | 4
-- South   | 2017 | 122905.86 |  8848.91 |  7.20 | 31.30  | -50.01  | 3
-- West    | 2014 | 147883.03 | 20065.69 | 13.57 | NULL   | NULL    | 1
-- West    | 2015 | 139966.25 | 20492.19 | 14.64 | -5.35  | 2.13    | 2
-- West    | 2016 | 187480.18 | 24051.61 | 12.83 | 33.95  | 17.37   | 1
-- West    | 2017 | 250128.37 | 43808.96 | 17.51 | 33.42  | 82.15   | 1
--
-- Acumulado:
-- region  | ventas    | ganancia  | margen_pct | posicion | desempeno
-- West    | 725457.82 | 108418.45 | 14.94 | 1 | MEJOR
-- East    | 678781.24 |  91522.78 | 13.48 | 2 | -
-- South   | 391721.91 |  46749.43 | 11.93 | 3 | -
-- Central | 501239.89 |  39706.36 |  7.92 | 4 | PEOR
