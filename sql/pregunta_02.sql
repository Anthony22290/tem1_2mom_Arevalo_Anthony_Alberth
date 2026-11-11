-- =====================================================================
-- PREGUNTA 2. Auditoría de calidad e integridad de datos
-- =====================================================================
USE db_antho;

-- Resumen de calidad de datos
WITH dup AS (
  SELECT COUNT(*) AS row_id_duplicados
  FROM (SELECT row_id FROM superstore GROUP BY row_id HAVING COUNT(*) > 1) d
)
SELECT
  COUNT(*)                                                   AS total_registros,
  MAX(dup.row_id_duplicados)                                 AS row_id_duplicados,
  COUNT(DISTINCT s.order_id)                                 AS ordenes_unicas,
  COUNT(DISTINCT s.customer_id)                              AS clientes_unicos,
  SUM(CASE WHEN s.order_date IS NULL OR s.ship_date IS NULL
             OR YEAR(s.order_date) NOT BETWEEN 2014 AND 2017
           THEN 1 ELSE 0 END)                                AS fechas_invalidas,
  SUM(CASE WHEN s.sales <= 0 THEN 1 ELSE 0 END)              AS ventas_cero_o_negativas,
  SUM(CASE WHEN s.discount < 0 OR s.discount >= 1 THEN 1 ELSE 0 END) AS descuento_fuera_rango,
  SUM(CASE WHEN s.ship_date < s.order_date THEN 1 ELSE 0 END) AS envio_antes_de_pedido
FROM superstore s CROSS JOIN dup;

-- Campos con valores NULL
SELECT
  SUM(CASE WHEN row_id        IS NULL THEN 1 ELSE 0 END) AS null_row_id,
  SUM(CASE WHEN order_id      IS NULL OR order_id = ''      THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN order_date    IS NULL THEN 1 ELSE 0 END) AS null_order_date,
  SUM(CASE WHEN ship_date     IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
  SUM(CASE WHEN ship_mode     IS NULL OR ship_mode = ''     THEN 1 ELSE 0 END) AS null_ship_mode,
  SUM(CASE WHEN customer_id   IS NULL OR customer_id = ''   THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN customer_name IS NULL OR customer_name = '' THEN 1 ELSE 0 END) AS null_customer_name,
  SUM(CASE WHEN segment       IS NULL OR segment = ''       THEN 1 ELSE 0 END) AS null_segment,
  SUM(CASE WHEN country       IS NULL OR country = ''       THEN 1 ELSE 0 END) AS null_country,
  SUM(CASE WHEN city          IS NULL OR city = ''          THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN state         IS NULL OR state = ''         THEN 1 ELSE 0 END) AS null_state,
  SUM(CASE WHEN postal_code   IS NULL OR postal_code = ''   THEN 1 ELSE 0 END) AS null_postal_code,
  SUM(CASE WHEN region        IS NULL OR region = ''        THEN 1 ELSE 0 END) AS null_region,
  SUM(CASE WHEN product_id    IS NULL OR product_id = ''    THEN 1 ELSE 0 END) AS null_product_id,
  SUM(CASE WHEN category      IS NULL OR category = ''      THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN sub_category  IS NULL OR sub_category = ''  THEN 1 ELSE 0 END) AS null_sub_category,
  SUM(CASE WHEN product_name  IS NULL OR product_name = ''  THEN 1 ELSE 0 END) AS null_product_name,
  SUM(CASE WHEN sales         IS NULL THEN 1 ELSE 0 END) AS null_sales,
  SUM(CASE WHEN quantity      IS NULL THEN 1 ELSE 0 END) AS null_quantity,
  SUM(CASE WHEN discount      IS NULL THEN 1 ELSE 0 END) AS null_discount,
  SUM(CASE WHEN profit        IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM superstore;

-- =====================================================================
-- RESULTADO
-- =====================================================================
-- total_registros         : 9994
-- row_id_duplicados       : 0
-- ordenes_unicas          : 5009
-- clientes_unicos         : 793
-- fechas_invalidas        : 0
-- ventas_cero_o_negativas : 0
-- descuento_fuera_rango   : 0   (descuento min 0, max 0.8)
-- envio_antes_de_pedido   : 0
--
-- Campos con NULL / vacíos: 0 en las 21 columnas.
--
-- Criterios de tratamiento propuestos:
--   * row_id duplicado        -> conservar un solo registro (ROW_NUMBER() = 1).
--   * Fechas nulas/invalidas  -> excluir del análisis temporal.
--   * Ventas <= 0             -> excluir (no representan una venta real).
--   * Descuento fuera de 0-1  -> marcar y excluir de análisis de descuentos.
--   * Envío antes del pedido  -> excluir / reportar como error de captura.
--   * postal_code se guarda como STRING para no perder ceros a la izquierda.
