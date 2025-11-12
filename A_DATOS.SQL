--TASA DE OCUPACION DE CELDAS
SELECT id_sede, 
       COUNT(CASE WHEN estado_celda='Ocupada' THEN 1 END)*100.0/COUNT(*) AS porcentaje_ocupacion
FROM CELDA
GROUP BY id_sede;

--INGRESOS TOTALES POR SEDE Y TIPO DE SERVICIO
SELECT s.nombre_sede, dft.tipo_servicio, SUM(df.sub_total) AS total_ingresos
FROM factura f
INNER JOIN detalle_factura df ON f.id_factura=df.id_factura
INNER JOIN detalle_factura_tipo dft ON df.id_detalle_factura=dft.id_detalle_factura
INNER JOIN sede s ON f.id_sede=s.id_sede
GROUP BY s.nombre_sede, dft.tipo_servicio;

--CLIENTES MAS FRECUENTES
SELECT c.nombre, COUNT(p.id_parqueo) AS visitas
FROM cliente c
INNER JOIN vehiculo v ON c.documento=v.documento_cliente
INNER JOIN parqueo p ON v.placa=p.placa_vehiculo
GROUP BY c.nombre
ORDER BY visitas DESC;
