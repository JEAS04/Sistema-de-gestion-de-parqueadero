-- =======================================================================================================================
-- ANALISIS DE DATOS APLICADO AL PROYECTO
-- Autor: Julian Alvarez
-- =======================================================================================================================

-- TASA DE OCUPACION DE CELDAS
SELECT id_sede, 
       COUNT(CASE WHEN estado = 'ocupada' THEN 1 END) * 100.0 / COUNT(*) AS porcentaje_ocupacion
FROM CELDA
GROUP BY id_sede;

--INGRESOS TOTALES POR SEDE Y TIPO DE SERVICIO
SELECT s.nombre AS nombre_sede, 
       df.servicio_pagado AS tipo_servicio, 
       SUM(df.subtotal) AS total_ingresos
FROM FACTURA f
INNER JOIN DETALLE_FACTURA df ON f.id_factura = df.id_factura
INNER JOIN PARQUEO p ON f.id_parqueo = p.id_parqueo
INNER JOIN SEDE s ON p.id_celda = (SELECT id_celda FROM CELDA WHERE id_celda = p.id_celda)
GROUP BY s.nombre, df.servicio_pagado
ORDER BY total_ingresos DESC;

-- CLIENTES MAS FRECUENTES
SELECT c.nombre AS NOMBRE, 
       c.apellido AS APELLIDO, 
       COUNT(p.id_parqueo) AS VISITAS
FROM CLIENTE c
INNER JOIN VEHICULO v ON c.id_cliente = v.id_cliente
INNER JOIN PARQUEO p ON v.id_vehiculo = p.id_vehiculo
GROUP BY c.nombre, c.apellido
ORDER BY visitas DESC;

