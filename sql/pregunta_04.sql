-- =====================================================================
-- PREGUNTA 4. Segmentación de clientes mediante RFM
-- =====================================================================
-- Criterios de puntuación (1 = peor, 5 = mejor):
--   R (días desde la última compra): <=30:5 | <=90:4 | <=180:3 | <=365:2 | >365:1
--   F (órdenes únicas):              >=10:5 | >=8:4  | >=6:3   | >=4:2   | <4:1
--   M (ventas acumuladas, USD):      >=5000:5 | >=3000:4 | >=1500:3 | >=500:2 | <500:1
-- Segmentos:
--   Alto valor  : R>=4 y F>=4 y M>=4
--   Recurrente  : F>=4 (y no es alto valor)
--   En riesgo   : R<=2 y (F>=3 o M>=3)
--   Ocasional   : resto
-- =====================================================================
USE db_antho;

DROP TABLE IF EXISTS rfm_clientes;
CREATE TABLE rfm_clientes STORED AS ORC AS
WITH ref AS (
  SELECT MAX(order_date) AS fecha_ref FROM superstore
),
base AS (
  SELECT s.customer_id,
         MAX(s.customer_name)                   AS customer_name,
         DATEDIFF(MAX(r.fecha_ref), MAX(s.order_date)) AS recency,
         COUNT(DISTINCT s.order_id)             AS frequency,
         SUM(s.sales)                           AS monetary
  FROM superstore s CROSS JOIN ref r
  GROUP BY s.customer_id
),
score AS (
  SELECT *,
         CASE WHEN recency <= 30 THEN 5 WHEN recency <= 90 THEN 4
              WHEN recency <= 180 THEN 3 WHEN recency <= 365 THEN 2 ELSE 1 END AS r_score,
         CASE WHEN frequency >= 10 THEN 5 WHEN frequency >= 8 THEN 4
              WHEN frequency >= 6 THEN 3 WHEN frequency >= 4 THEN 2 ELSE 1 END AS f_score,
         CASE WHEN monetary >= 5000 THEN 5 WHEN monetary >= 3000 THEN 4
              WHEN monetary >= 1500 THEN 3 WHEN monetary >= 500 THEN 2 ELSE 1 END AS m_score
  FROM base
)
SELECT customer_id, customer_name, recency, frequency,
       ROUND(monetary, 2) AS monetary,
       r_score, f_score, m_score,
       CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm,
       CASE WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Alto valor'
            WHEN f_score >= 4 THEN 'Recurrente'
            WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) THEN 'En riesgo'
            ELSE 'Ocasional' END AS segmento
FROM score;

-- Resumen por segmento
SELECT segmento,
       COUNT(*)                     AS clientes,
       ROUND(AVG(recency), 1)       AS recency_prom,
       ROUND(AVG(frequency), 1)     AS frequency_prom,
       ROUND(AVG(monetary), 2)      AS monetary_prom,
       ROUND(SUM(monetary), 2)      AS ventas_total
FROM rfm_clientes
GROUP BY segmento
ORDER BY ventas_total DESC;

-- Top 10 clientes de alto valor
SELECT customer_id, customer_name, recency, frequency, monetary, rfm
FROM rfm_clientes
WHERE segmento = 'Alto valor'
ORDER BY monetary DESC
LIMIT 10;

-- Top 10 clientes en riesgo de abandono (mayor valor perdido)
SELECT customer_id, customer_name, recency, frequency, monetary, rfm
FROM rfm_clientes
WHERE segmento = 'En riesgo'
ORDER BY monetary DESC
LIMIT 10;

-- =====================================================================
-- RESULTADO  (fecha de referencia: 2017-12-30)
-- =====================================================================
-- segmento   | clientes | recency_prom | frequency_prom | monetary_prom | ventas_total
-- Ocasional  | 464 | 135.7 | 4.9 | 2211.80 | 1026274.23
-- Alto valor |  97 |  33.7 | 9.8 | 5423.74 |  526102.36
-- Recurrente | 144 | 108.1 | 9.1 | 3191.50 |  459576.54
-- En riesgo  |  88 | 393.1 | 5.2 | 3241.45 |  285247.81
--
-- Top 10 Alto valor:
-- AB-10105 | Adrian Barton    | 41 | 10 | 14473.57 | 455
-- KL-16645 | Ken Lonsdale     | 47 | 12 | 14175.23 | 455
-- SE-20110 | Sanjit Engle     |  9 | 11 | 12209.44 | 555
-- GT-14710 | Greg Tran        | 36 | 11 | 11820.12 | 455
-- ME-17320 | Maria Etezadi    | 42 | 10 | 10663.73 | 455
-- JL-15835 | John Lee         | 21 | 11 |  9799.92 | 555
-- JD-16150 | Justin Deggeller | 41 |  8 |  8828.03 | 445
-- JE-15715 | Joe Elijah       | 46 | 10 |  8697.84 | 455
-- PK-19075 | Pete Kriz        |  9 | 12 |  8646.93 | 555
-- DR-12940 | Daniel Raglin    | 50 |  8 |  8350.87 | 445
--
-- Top 10 En riesgo:
-- TC-20980 | Tamara Chand      | 399 | 5 | 19052.22 | 125
-- BM-11140 | Becky Martin      | 307 | 4 | 11789.63 | 225
-- BS-11365 | Bill Shonely      | 558 | 5 | 10501.65 | 125
-- TB-21400 | Tom Boeckenhauer  | 202 | 7 |  9133.99 | 235
-- PF-19120 | Peter Fuller      | 835 | 4 |  9062.86 | 125
-- KD-16270 | Karen Daniels     | 484 | 5 |  8282.36 | 125
-- RH-19510 | Rick Huthwaite    | 467 | 6 |  6979.18 | 135
-- PS-19045 | Penelope Sewall   | 236 | 7 |  6843.63 | 235
-- VD-21670 | Valerie Dominguez | 581 | 6 |  6442.25 | 135
-- SB-20185 | Sarah Brown       | 188 | 6 |  6411.00 | 235
