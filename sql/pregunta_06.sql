-- =====================================================================
-- PREGUNTA 6. Análisis del impacto de los descuentos
-- =====================================================================
USE db_antho;

-- Indicadores por rango de descuento
WITH rangos AS (
  SELECT *,
         CASE WHEN discount = 0    THEN '1. Sin descuento (0)'
              WHEN discount <= 0.2 THEN '2. Bajo (0-20%]'
              WHEN discount <= 0.5 THEN '3. Medio (20-50%]'
              ELSE                      '4. Alto (>50%)' END AS rango_descuento
  FROM superstore
)
SELECT rango_descuento,
       COUNT(*)                                          AS registros,
       ROUND(SUM(sales), 2)                              AS ventas,
       ROUND(SUM(profit), 2)                             AS ganancia,
       ROUND(SUM(profit) / SUM(sales) * 100, 2)          AS margen_pct,
       SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)       AS registros_con_perdida,
       ROUND(SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS pct_no_rentables,
       ROUND(AVG(discount) * 100, 2)                     AS descuento_prom_pct
FROM rangos
GROUP BY rango_descuento
ORDER BY rango_descuento;

-- Categorías y subcategorías más afectadas (operaciones con descuento)
SELECT category, sub_category,
       COUNT(*)                                              AS registros_con_desc,
       ROUND(AVG(discount) * 100, 2)                         AS descuento_prom_pct,
       SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)           AS registros_con_perdida,
       ROUND(SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS pct_no_rentables,
       ROUND(SUM(profit), 2)                                 AS ganancia
FROM superstore
WHERE discount > 0
GROUP BY category, sub_category
ORDER BY ganancia ASC
LIMIT 10;

-- =====================================================================
-- RESULTADO
-- =====================================================================
-- rango_descuento      | registros | ventas     | ganancia  | margen_pct | con_perdida | pct_no_rentables | desc_prom_pct
-- 1. Sin descuento (0) | 4798 | 1087908.47 | 320987.60 |   29.51 |   0 |   0.00 |  0.00
-- 2. Bajo (0-20%]      | 3803 |  846522.24 | 100785.47 |   11.91 | 523 |  13.75 | 19.68
-- 3. Medio (20-50%]    |  537 |  298541.41 | -58817.00 |  -19.70 | 492 |  91.62 | 36.70
-- 4. Alto (>50%)       |  856 |   64228.74 | -76559.05 | -119.20 | 856 | 100.00 | 71.89
--
-- Subcategorías más afectadas (registros con descuento)
-- category        | sub_category | registros | desc_prom_pct | con_perdida | pct_no_rentables | ganancia
-- Furniture       | Tables       |  247 | 33.74 | 203 | 82.19 | -31001.78
-- Technology      | Machines     |   86 | 40.93 |  44 | 51.16 | -23753.07
-- Furniture       | Bookcases    |  168 | 28.65 | 109 | 64.88 |  -9548.27
-- Office Supplies | Binders      | 1186 | 47.81 | 613 | 51.69 |  -9092.69
-- Office Supplies | Appliances   |  195 | 39.79 |  67 | 34.36 |  -5045.73
-- Office Supplies | Storage      |  316 | 20.00 | 161 | 50.95 |  -4249.35
-- Furniture       | Furnishings  |  386 | 34.30 | 167 | 43.26 |  -3788.83
-- Office Supplies | Supplies     |   73 | 20.00 |  33 | 45.21 |  -2907.49
-- Office Supplies | Fasteners    |   89 | 20.00 |  12 | 13.48 |    297.31
-- Office Supplies | Labels       |  125 | 20.00 |   0 |  0.00 |   1124.16
--
-- Sí: a mayor descuento, mayor proporción de operaciones no rentables
-- (0% -> 13.75% -> 91.62% -> 100%).
