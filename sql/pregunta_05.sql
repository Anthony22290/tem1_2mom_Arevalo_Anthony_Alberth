-- =====================================================================
-- PREGUNTA 5. Ranking de productos según rentabilidad
-- =====================================================================
USE db_antho;

DROP TABLE IF EXISTS ranking_productos;
CREATE TABLE ranking_productos STORED AS ORC AS
WITH prod AS (
  SELECT category, product_name,
         SUM(sales)    AS ventas,
         SUM(profit)   AS ganancia,
         SUM(quantity) AS unidades
  FROM superstore
  GROUP BY category, product_name
)
SELECT category, product_name,
       ROUND(ventas, 2)                  AS ventas,
       ROUND(ganancia, 2)                AS ganancia,
       unidades,
       ROUND(ganancia / ventas * 100, 2) AS margen_pct,
       RANK()       OVER (PARTITION BY category ORDER BY ganancia DESC) AS rank_categoria,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY ganancia DESC) AS dense_rank_categoria,
       ROUND(SUM(ganancia) OVER (PARTITION BY category ORDER BY ganancia DESC
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)       AS ganancia_acumulada_cat,
       RANK() OVER (ORDER BY ventas DESC)  AS rank_ventas,
       RANK() OVER (ORDER BY ganancia ASC) AS rank_menor_ganancia
FROM prod;

-- a) Top 5 productos con mayor ganancia por categoría
SELECT category, rank_categoria, dense_rank_categoria, product_name,
       ganancia, margen_pct, ganancia_acumulada_cat
FROM ranking_productos
WHERE rank_categoria <= 5
ORDER BY category, rank_categoria;

-- b) Top 5 productos con mayor volumen de ventas
SELECT rank_ventas, product_name, category, ventas, ganancia, margen_pct
FROM ranking_productos
WHERE rank_ventas <= 5
ORDER BY rank_ventas;

-- c) Top 5 productos con menor rentabilidad (mayores pérdidas)
SELECT rank_menor_ganancia, product_name, category, ventas, ganancia, margen_pct,
       rank_categoria AS posicion_en_categoria
FROM ranking_productos
WHERE rank_menor_ganancia <= 5
ORDER BY rank_menor_ganancia;

-- d) Margen individual y posición de cada producto en su categoría
SELECT category, rank_categoria, product_name, ventas, ganancia, margen_pct
FROM ranking_productos
ORDER BY category, rank_categoria;

-- =====================================================================
-- RESULTADO  (1850 productos: Furniture 380, Office Supplies 1058, Technology 412)
-- =====================================================================
-- a) Top 5 ganancia por categoría
-- category        | rank | dense | product_name | ganancia | margen_pct | ganancia_acumulada_cat
-- Furniture       | 1 | 1 | Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back | 1927.44 | 18.12 | 1927.44
-- Furniture       | 2 | 2 | Global Deluxe High-Back Manager's Chair | 1558.59 | 17.99 | 3486.03
-- Furniture       | 3 | 3 | Hon Pagoda Stacking Chairs | 1540.70 | 23.76 | 5026.74
-- Furniture       | 4 | 4 | Hon 4070 Series Pagoda Armless Upholstered Stacking Chairs | 1388.63 | 16.47 | 6415.37
-- Furniture       | 5 | 5 | Office Star - Professional Matrix Back Chair with 2-to-1 Synchro Tilt and Mesh Fabric Seat | 1305.65 | 14.88 | 7721.02
-- Office Supplies | 1 | 1 | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | 7753.04 | 28.24 | 7753.04
-- Office Supplies | 2 | 2 | Ibico EPK-21 Electric Binding System | 3345.28 | 21.07 | 11098.32
-- Office Supplies | 3 | 3 | Honeywell Enviracaire Portable HEPA Air Cleaner for 17' x 22' Room | 3247.02 | 28.72 | 14345.34
-- Office Supplies | 4 | 4 | Fellowes PB300 Plastic Comb Binding Machine | 2518.06 | 31.20 | 16863.40
-- Office Supplies | 5 | 5 | Ibico Ibimaster 300 Manual Binding System | 2318.34 | 29.03 | 19181.73
-- Technology      | 1 | 1 | Canon imageCLASS 2200 Advanced Copier | 25199.93 | 40.91 | 25199.93
-- Technology      | 2 | 2 | Hewlett Packard LaserJet 3310 Copier | 6983.88 | 37.07 | 32183.81
-- Technology      | 3 | 3 | Canon PC1060 Personal Laser Copier | 4570.93 | 39.34 | 36754.75
-- Technology      | 4 | 4 | HP Designjet T520 Inkjet Large Format Printer - 24" Color | 4094.98 | 22.29 | 40849.72
-- Technology      | 5 | 5 | Ativa V4110MDD Micro-Cut Shredder | 3772.95 | 49.00 | 44622.67
--
-- b) Top 5 por volumen de ventas
-- 1 | Canon imageCLASS 2200 Advanced Copier | Technology | 61599.82 | 25199.93 | 40.91
-- 2 | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | Office Supplies | 27453.38 | 7753.04 | 28.24
-- 3 | Cisco TelePresence System EX90 Videoconferencing Unit | Technology | 22638.48 | -1811.08 | -8.00
-- 4 | HON 5400 Series Task Chairs for Big and Tall | Furniture | 21870.58 | 0.00 | 0.00
-- 5 | GBC DocuBind TL300 Electric Binding System | Office Supplies | 19823.48 | 2233.51 | 11.27
--
-- c) Top 5 menor rentabilidad
-- rank | product_name | category | ventas | ganancia | margen_pct | posicion_en_categoria
-- 1 | Cubify CubeX 3D Printer Double Head Print | Technology | 11099.96 | -8879.97 | -80.00 | 412 de 412
-- 2 | Lexmark MX611dhe Monochrome Laser Printer | Technology | 16829.90 | -4589.97 | -27.27 | 411 de 412
-- 3 | Cubify CubeX 3D Printer Triple Head Print | Technology |  7999.98 | -3839.99 | -48.00 | 410 de 412
-- 4 | Chromcraft Bull-Nose Wood Oval Conference Tables & Bases | Furniture | 9917.64 | -2876.12 | -29.00 | 380 de 380
-- 5 | Bush Advantage Collection Racetrack Conference Table | Furniture | 9544.73 | -1934.40 | -20.27 | 379 de 380
--
-- d) La consulta d) lista los 1850 productos con su margen y posición (ver tabla ranking_productos).
