# Diccionario de datos – tabla `db_antho.superstore`

| Nro | Campo CSV | Columna Hive | Tipo Hive | Descripción | Restricciones |
|----|-----------|--------------|-----------|-------------|---------------|
| 1 | Row ID | row_id | INT | Identificador de fila | Único, no nulo |
| 2 | Order ID | order_id | STRING | Identificador de la orden | No nulo |
| 3 | Order Date | order_date | DATE | Fecha del pedido (origen M/d/yyyy) | No nulo |
| 4 | Ship Date | ship_date | DATE | Fecha de envío (origen M/d/yyyy) | ≥ order_date |
| 5 | Ship Mode | ship_mode | STRING | Modalidad de envío | Valores de catálogo |
| 6 | Customer ID | customer_id | STRING | Identificador del cliente | No nulo |
| 7 | Customer Name | customer_name | STRING | Nombre del cliente | – |
| 8 | Segment | segment | STRING | Consumer / Corporate / Home Office | Valores de catálogo |
| 9 | Country | country | STRING | País | – |
| 10 | City | city | STRING | Ciudad | – |
| 11 | State | state | STRING | Estado | – |
| 12 | Postal Code | postal_code | STRING | Código postal (texto para no perder ceros) | – |
| 13 | Region | region | STRING | Central / East / South / West | Valores de catálogo |
| 14 | Product ID | product_id | STRING | Identificador del producto | No nulo |
| 15 | Category | category | STRING | Categoría del producto | Valores de catálogo |
| 16 | Sub-Category | sub_category | STRING | Subcategoría | Valores de catálogo |
| 17 | Product Name | product_name | STRING | Nombre del producto | – |
| 18 | Sales | sales | DOUBLE | Importe de venta (USD) | > 0 |
| 19 | Quantity | quantity | INT | Unidades vendidas | > 0 |
| 20 | Discount | discount | DOUBLE | Descuento aplicado (0 a 1) | 0 ≤ x < 1 |
| 21 | Profit | profit | DOUBLE | Ganancia (puede ser negativa) | – |
