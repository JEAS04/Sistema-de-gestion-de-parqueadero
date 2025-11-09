-- ============================================================================
-- NECESIDAD 1: GESTIÓN AUTOMÁTICA DE FACTURACIÓN Y LIQUIDACIÓN DE SERVICIOS
-- ============================================================================
-- Descripción: Al finalizar un servicio (parqueo o lavado), el sistema debe
-- calcular automáticamente los montos, generar la factura y actualizar
-- inventarios de celdas, manteniendo la integridad de todas las transacciones.
-- ============================================================================

-- FUNCIÓN 1.1: Calcular tarifa de parqueo según tiempo y convenio
GO
CREATE OR ALTER FUNCTION dbo.fn_CalcularTarifaParqueo(
    @fecha_ingreso DATETIME,
    @fecha_salida DATETIME,
    @id_convenio INT,
    @id_tipo_vehiculo INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @monto DECIMAL(10,2) = 0;
    DECLARE @minutos INT;
    DECLARE @horas DECIMAL(10,2);
    DECLARE @precio_base DECIMAL(10,2);
    DECLARE @unidad_tarifaria VARCHAR(50);
    
    -- Calcular tiempo transcurrido
    SET @minutos = DATEDIFF(MINUTE, @fecha_ingreso, @fecha_salida);
    SET @horas = CAST(@minutos AS DECIMAL(10,2)) / 60.0;
    
    -- Si tiene convenio, obtener precio del convenio
    IF @id_convenio IS NOT NULL
    BEGIN
        SELECT @precio_base = precio_base, @unidad_tarifaria = unidad_tarifaria
        FROM convenio
        WHERE id_convenio = @id_convenio
              AND GETDATE() BETWEEN vigencia_inicio AND vigencia_fin;
        
        IF @precio_base IS NOT NULL
        BEGIN
            -- Aplicar precio según unidad tarifaria
            IF @unidad_tarifaria = 'DIA'
                SET @monto = @precio_base * CEILING(@horas / 24.0);
            ELSE IF @unidad_tarifaria = 'HORA'
                SET @monto = @precio_base * CEILING(@horas);
            ELSE
                SET @monto = @precio_base; -- Tarifa fija
        END
    END
    ELSE
    BEGIN
        -- Tarifas ocasionales según tipo de vehículo
        IF @id_tipo_vehiculo = 1 -- Automóvil
            SET @monto = 3000 * CEILING(@horas);
        ELSE IF @id_tipo_vehiculo = 2 -- Moto
            SET @monto = 1500 * CEILING(@horas);
        ELSE IF @id_tipo_vehiculo = 3 -- Camión
            SET @monto = 5000 * CEILING(@horas);
        ELSE
            SET @monto = 2000 * CEILING(@horas);
    END
    
    -- Mínimo 1 hora
    IF @monto < 2000
        SET @monto = 2000;
    
    RETURN @monto;
END
GO

-- FUNCIÓN 1.2: Validar disponibilidad de celda por tipo
GO
CREATE OR ALTER FUNCTION dbo.fn_ValidarDisponibilidadCelda(
    @id_sede INT,
    @id_tipo_celda INT
)
RETURNS INT
AS
BEGIN
    DECLARE @celda_disponible INT = NULL;
    
    SELECT TOP 1 @celda_disponible = id_celda
    FROM CELDA
    WHERE id_sede = @id_sede
          AND id_tipo_celda = @id_tipo_celda
          AND estado_celda = 'Libre'
    ORDER BY id_celda;
    
    RETURN @celda_disponible;
END
GO

-- TRIGGER 1.1: Actualizar estado de celda al registrar parqueo
GO
CREATE OR ALTER TRIGGER trg_ParqueoIngreso
ON parqueo
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Actualizar celda a ocupada
        UPDATE CELDA
        SET estado_celda = 'Ocupada'
        FROM CELDA c
        INNER JOIN inserted i ON c.id_celda = i.id_celda
        WHERE i.id_celda IS NOT NULL;
        
        -- Actualizar estado de tarjeta
        UPDATE Tarjeta
        SET estado_tarjeta = 'EN_USO'
        FROM Tarjeta t
        INNER JOIN inserted i ON t.id_tarjeta = i.id_tarjeta;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        RAISERROR(@error_msg, 16, 1);
        ROLLBACK TRANSACTION;
    END CATCH
END
GO

-- TRIGGER 1.2: Liberar celda y generar factura al registrar salida
GO
CREATE OR ALTER TRIGGER trg_ParqueoSalida
ON parqueo
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Solo procesar cuando se registra fecha de salida
        IF UPDATE(fecha_hora_salida)
        BEGIN
            DECLARE @id_parqueo INT, @id_celda INT, @id_tarjeta INT;
            DECLARE @placa VARCHAR(20), @documento_cliente VARCHAR(50);
            DECLARE @fecha_ingreso DATETIME, @fecha_salida DATETIME;
            DECLARE @id_convenio INT, @id_tipo_vehiculo INT, @id_sede INT;
            DECLARE @monto DECIMAL(10,2);
            
            -- Cursor para procesar cada salida
            DECLARE cur_salidas CURSOR FOR
            SELECT i.id_parqueo, i.id_celda, i.id_tarjeta, i.placa_vehiculo,
                   i.fecha_hora_ingreso, i.fecha_hora_salida, i.id_sede
            FROM inserted i
            INNER JOIN deleted d ON i.id_parqueo = d.id_parqueo
            WHERE i.fecha_hora_salida IS NOT NULL 
                  AND d.fecha_hora_salida IS NULL;
            
            OPEN cur_salidas;
            FETCH NEXT FROM cur_salidas INTO @id_parqueo, @id_celda, @id_tarjeta,
                @placa, @fecha_ingreso, @fecha_salida, @id_sede;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Obtener datos del vehículo y cliente
                SELECT @documento_cliente = v.documento_cliente,
                       @id_tipo_vehiculo = v.id_tipo_vehiculo
                FROM vehiculo v
                WHERE v.placa = @placa;
                
                -- Obtener convenio del cliente si existe
                SELECT @id_convenio = c.id_convenio
                FROM cliente c
                WHERE c.documento = @documento_cliente;
                
                -- Calcular monto usando la función
                SET @monto = dbo.fn_CalcularTarifaParqueo(
                    @fecha_ingreso, @fecha_salida, @id_convenio, @id_tipo_vehiculo
                );
                
                -- Liberar celda
                IF @id_celda IS NOT NULL
                BEGIN
                    UPDATE CELDA
                    SET estado_celda = 'Libre'
                    WHERE id_celda = @id_celda;
                END
                
                -- Liberar tarjeta
                UPDATE Tarjeta
                SET estado_tarjeta = 'DISPONIBLE'
                WHERE id_tarjeta = @id_tarjeta;
                
                -- Crear factura (se genera en el procedimiento principal)
                -- Este trigger solo prepara los datos
                
                FETCH NEXT FROM cur_salidas INTO @id_parqueo, @id_celda, @id_tarjeta,
                    @placa, @fecha_ingreso, @fecha_salida, @id_sede;
            END
            
            CLOSE cur_salidas;
            DEALLOCATE cur_salidas;
        END
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        
        IF CURSOR_STATUS('local', 'cur_salidas') >= 0
        BEGIN
            CLOSE cur_salidas;
            DEALLOCATE cur_salidas;
        END
        
        RAISERROR(@error_msg, 16, 1);
        ROLLBACK TRANSACTION;
    END CATCH
END
GO

-- PROCEDIMIENTO 1: Procesar salida de vehículo y generar factura completa
GO
CREATE OR ALTER PROCEDURE sp_ProcesarSalidaVehiculo
    @id_parqueo INT,
    @id_factura INT OUTPUT,
    @total_factura DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_message NVARCHAR(4000);
    DECLARE @placa VARCHAR(20), @documento_cliente VARCHAR(50);
    DECLARE @fecha_ingreso DATETIME, @fecha_salida DATETIME;
    DECLARE @id_convenio INT, @id_tipo_vehiculo INT, @id_sede INT;
    DECLARE @monto_parqueo DECIMAL(10,2);
    DECLARE @id_lavado INT, @monto_lavado DECIMAL(10,2);
    DECLARE @id_liquidacion_lavado INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el parqueo existe y no tiene salida registrada
        IF NOT EXISTS (SELECT 1 FROM parqueo 
                      WHERE id_parqueo = @id_parqueo 
                      AND fecha_hora_salida IS NULL)
        BEGIN
            SET @error_message = 'El parqueo no existe o ya tiene salida registrada.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener datos del parqueo
        SELECT @placa = placa_vehiculo,
               @fecha_ingreso = fecha_hora_ingreso,
               @id_sede = id_sede
        FROM parqueo
        WHERE id_parqueo = @id_parqueo;
        
        -- Registrar fecha de salida
        SET @fecha_salida = GETDATE();
        UPDATE parqueo
        SET fecha_hora_salida = @fecha_salida,
            estado_parqueo = 'FINALIZADO'
        WHERE id_parqueo = @id_parqueo;
        
        -- Obtener datos del vehículo y cliente
        SELECT @documento_cliente = v.documento_cliente,
               @id_tipo_vehiculo = v.id_tipo_vehiculo
        FROM vehiculo v
        WHERE v.placa = @placa;
        
        IF @documento_cliente IS NULL
        BEGIN
            SET @error_message = 'No se encontró el cliente asociado al vehículo.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener convenio del cliente
        SELECT @id_convenio = id_convenio
        FROM cliente
        WHERE documento = @documento_cliente;
        
        -- Calcular monto de parqueo
        SET @monto_parqueo = dbo.fn_CalcularTarifaParqueo(
            @fecha_ingreso, @fecha_salida, @id_convenio, @id_tipo_vehiculo
        );
        
        -- Verificar si hay servicios de lavado pendientes
        SELECT @id_lavado = id_lavado,
               @monto_lavado = precio_lavado
        FROM lavado
        WHERE placa = @placa
              AND estado_lavado = 'FINALIZADO'
              AND id_lavado NOT IN (SELECT id_lavado FROM liquidacion_lavado);
        
        -- Crear liquidación de lavado si existe
        IF @id_lavado IS NOT NULL
        BEGIN
            INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion)
            VALUES (@id_lavado, @monto_lavado, CAST(GETDATE() AS DATE));
            
            SET @id_liquidacion_lavado = SCOPE_IDENTITY();
        END
        
        -- Calcular total
        SET @total_factura = @monto_parqueo + ISNULL(@monto_lavado, 0);
        
        -- Crear factura
        INSERT INTO factura (fecha_emision, documento_cliente, id_sede, 
                           total_pagar, id_liquidacion_lavado)
        VALUES (CAST(GETDATE() AS DATE), @documento_cliente, @id_sede,
               @total_factura, @id_liquidacion_lavado);
        
        SET @id_factura = SCOPE_IDENTITY();
        
        -- Crear detalle de factura para parqueo
        INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total)
        VALUES (@id_factura, @id_parqueo, @monto_parqueo);
        
        -- Crear detalle de factura para lavado si existe
        IF @id_lavado IS NOT NULL
        BEGIN
            INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total)
            VALUES (@id_factura, @id_lavado, @monto_lavado);
        END
        
        COMMIT TRANSACTION;
        
        -- Mensaje de éxito
        PRINT 'Salida procesada exitosamente. Factura #' + CAST(@id_factura AS VARCHAR(10));
        PRINT 'Total a pagar: $' + CAST(@total_factura AS VARCHAR(20));
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_message = ERROR_MESSAGE();
        PRINT 'ERROR: ' + @error_message;
        RAISERROR(@error_message, 16, 1);
    END CATCH
END
GO

-- ============================================================================
-- NECESIDAD 2: GESTIÓN AUTOMÁTICA DE RESERVAS Y CONTROL DE OCUPACIÓN
-- ============================================================================
-- Descripción: Administrar automáticamente las reservas de celdas según
-- convenios, validar disponibilidad, controlar tiempos de gracia y liberar
-- celdas no utilizadas, manteniendo estadísticas actualizadas.
-- ============================================================================

-- Tabla auxiliar para estadísticas (crear primero)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'estadistica_ocupacion')
BEGIN
    CREATE TABLE estadistica_ocupacion (
        id_estadistica INT PRIMARY KEY IDENTITY(1,1),
        id_sede INT NOT NULL,
        fecha DATE NOT NULL,
        total_celdas INT,
        celdas_ocupadas INT,
        porcentaje_ocupacion DECIMAL(5,2),
        ingresos_dia DECIMAL(10,2),
        CONSTRAINT FK_estadistica_sede FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
    );
END
GO

-- FUNCIÓN 2.1: Calcular porcentaje de ocupación por sede
GO
CREATE OR ALTER FUNCTION dbo.fn_CalcularOcupacionSede(
    @id_sede INT,
    @id_tipo_celda INT = NULL
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total INT, @ocupadas INT, @porcentaje DECIMAL(5,2);
    
    IF @id_tipo_celda IS NULL
    BEGIN
        -- Calcular para todas las celdas
        SELECT @total = COUNT(*),
               @ocupadas = SUM(CASE WHEN estado_celda = 'Ocupada' THEN 1 ELSE 0 END)
        FROM CELDA
        WHERE id_sede = @id_sede;
    END
    ELSE
    BEGIN
        -- Calcular para tipo específico
        SELECT @total = COUNT(*),
               @ocupadas = SUM(CASE WHEN estado_celda = 'Ocupada' THEN 1 ELSE 0 END)
        FROM CELDA
        WHERE id_sede = @id_sede AND id_tipo_celda = @id_tipo_celda;
    END
    
    IF @total > 0
        SET @porcentaje = (@ocupadas * 100.0) / @total;
    ELSE
        SET @porcentaje = 0;
    
    RETURN @porcentaje;
END
GO

-- FUNCIÓN 2.2: Obtener tiempo promedio de permanencia
GO
CREATE OR ALTER FUNCTION dbo.fn_TiempoPromedioParqueo(
    @id_sede INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @promedio_horas DECIMAL(10,2);
    
    SELECT @promedio_horas = AVG(DATEDIFF(MINUTE, fecha_hora_ingreso, fecha_hora_salida) / 60.0)
    FROM parqueo
    WHERE id_sede = @id_sede
          AND fecha_hora_salida IS NOT NULL
          AND CAST(fecha_hora_ingreso AS DATE) BETWEEN @fecha_inicio AND @fecha_fin;
    
    RETURN ISNULL(@promedio_horas, 0);
END
GO

-- TRIGGER 2.1: Actualizar estadísticas al cambiar ocupación
GO
CREATE OR ALTER TRIGGER trg_ActualizarEstadisticas
ON CELDA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        IF UPDATE(estado_celda)
        BEGIN
            DECLARE @id_sede INT, @fecha DATE;
            DECLARE @total_celdas INT, @celdas_ocupadas INT;
            DECLARE @porcentaje DECIMAL(5,2), @ingresos DECIMAL(10,2);
            
            SET @fecha = CAST(GETDATE() AS DATE);
            
            -- Cursor para procesar cada sede afectada
            DECLARE cur_sedes CURSOR FOR
            SELECT DISTINCT id_sede
            FROM inserted;
            
            OPEN cur_sedes;
            FETCH NEXT FROM cur_sedes INTO @id_sede;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Calcular ocupación
                SELECT @total_celdas = COUNT(*),
                       @celdas_ocupadas = SUM(CASE WHEN estado_celda = 'Ocupada' THEN 1 ELSE 0 END)
                FROM CELDA
                WHERE id_sede = @id_sede;
                
                SET @porcentaje = dbo.fn_CalcularOcupacionSede(@id_sede, NULL);
                
                -- Calcular ingresos del día
                SELECT @ingresos = ISNULL(SUM(total_pagar), 0)
                FROM factura
                WHERE id_sede = @id_sede AND fecha_emision = @fecha;
                
                -- Actualizar o insertar estadísticas
                IF EXISTS (SELECT 1 FROM estadistica_ocupacion 
                          WHERE id_sede = @id_sede AND fecha = @fecha)
                BEGIN
                    UPDATE estadistica_ocupacion
                    SET total_celdas = @total_celdas,
                        celdas_ocupadas = @celdas_ocupadas,
                        porcentaje_ocupacion = @porcentaje,
                        ingresos_dia = @ingresos
                    WHERE id_sede = @id_sede AND fecha = @fecha;
                END
                ELSE
                BEGIN
                    INSERT INTO estadistica_ocupacion 
                        (id_sede, fecha, total_celdas, celdas_ocupadas, 
                         porcentaje_ocupacion, ingresos_dia)
                    VALUES (@id_sede, @fecha, @total_celdas, @celdas_ocupadas,
                           @porcentaje, @ingresos);
                END
                
                FETCH NEXT FROM cur_sedes INTO @id_sede;
            END
            
            CLOSE cur_sedes;
            DEALLOCATE cur_sedes;
        END
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        
        IF CURSOR_STATUS('local', 'cur_sedes') >= 0
        BEGIN
            CLOSE cur_sedes;
            DEALLOCATE cur_sedes;
        END
        -- No lanzar error para no bloquear la operación principal
        PRINT 'Error al actualizar estadisticas: ';
        PRINT @error_msg;
    END CATCH
END
GO

-- PROCEDIMIENTO 2: Asignar celda automáticamente según disponibilidad y convenio
GO
CREATE OR ALTER PROCEDURE sp_AsignarCeldaAutomatica
    @placa VARCHAR(20),
    @id_sede INT,
    @id_personal INT,
    @id_parqueo INT OUTPUT,
    @id_celda_asignada INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_message NVARCHAR(4000);
    DECLARE @id_tipo_vehiculo INT, @id_tipo_celda INT;
    DECLARE @documento_cliente VARCHAR(50), @id_convenio INT;
    DECLARE @id_tarjeta INT;
    DECLARE @ocupacion DECIMAL(5,2);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el vehículo existe
        IF NOT EXISTS (SELECT 1 FROM vehiculo WHERE placa = @placa)
        BEGIN
            SET @error_message = 'El vehiculo con placa ' + @placa + ' no esta registrado.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener tipo de vehículo y cliente
        SELECT @id_tipo_vehiculo = v.id_tipo_vehiculo,
               @documento_cliente = v.documento_cliente
        FROM vehiculo v
        WHERE v.placa = @placa;
        
        -- Determinar tipo de celda según tipo de vehículo
        SET @id_tipo_celda = @id_tipo_vehiculo;
        
        -- Verificar disponibilidad
        SET @id_celda_asignada = dbo.fn_ValidarDisponibilidadCelda(@id_sede, @id_tipo_celda);
        
        IF @id_celda_asignada IS NULL
        BEGIN
            -- Verificar ocupación actual
            SET @ocupacion = dbo.fn_CalcularOcupacionSede(@id_sede, @id_tipo_celda);
            SET @error_message = 'No hay celdas disponibles para este tipo de vehiculo. Ocupacion actual: ' + CAST(@ocupacion AS VARCHAR(10)) + '%';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener convenio del cliente si existe
        SELECT @id_convenio = id_convenio
        FROM cliente
        WHERE documento = @documento_cliente;
        
        -- Generar tarjeta
        INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal)
        VALUES ('ACTIVA', GETDATE(), @id_personal);
        
        SET @id_tarjeta = SCOPE_IDENTITY();
        
        -- Crear registro de parqueo
        INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, id_sede, 
                           placa_vehiculo, estado_parqueo, id_celda)
        VALUES (@id_tarjeta, GETDATE(), @id_sede, @placa, 'ACTIVO', @id_celda_asignada);
        
        SET @id_parqueo = SCOPE_IDENTITY();
        
        -- El trigger se encarga de actualizar el estado de la celda y tarjeta
        
        COMMIT TRANSACTION;
        
        -- Mensaje de éxito
        PRINT 'Celda asignada exitosamente.';
        PRINT 'Parqueo #' + CAST(@id_parqueo AS VARCHAR(10));
        PRINT 'Celda #' + CAST(@id_celda_asignada AS VARCHAR(10));
        PRINT 'Tarjeta #' + CAST(@id_tarjeta AS VARCHAR(10));
        
        IF @id_convenio IS NOT NULL
            PRINT 'Cliente con convenio activo.';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_message = ERROR_MESSAGE();
        PRINT 'ERROR: ' + @error_message;
        RAISERROR(@error_message, 16, 1);
    END CATCH
END
GO

-- EJEMPLO DE USO

/*
-- Procedimiento 1: Procesar salida
DECLARE @id_factura INT, @total DECIMAL(10,2);
EXEC sp_ProcesarSalidaVehiculo 
    @id_parqueo = 1,
    @id_factura = @id_factura OUTPUT,
    @total_factura = @total OUTPUT;
    
SELECT @id_factura AS FacturaGenerada, @total AS TotalAPagar;

-- Procedimiento 2: Asignar celda
DECLARE @id_parqueo INT, @id_celda INT;
EXEC sp_AsignarCeldaAutomatica
    @placa = 'ABC001',
    @id_sede = 1,
    @id_personal = 1,
    @id_parqueo = @id_parqueo OUTPUT,
    @id_celda_asignada = @id_celda OUTPUT;
    
SELECT @id_parqueo AS ParqueoCreado, @id_celda AS CeldaAsignada;

-- Consultar estadísticas
SELECT * FROM estadistica_ocupacion 
WHERE fecha = CAST(GETDATE() AS DATE);

-- Ver ocupación actual
SELECT id_sede, 
       dbo.fn_CalcularOcupacionSede(id_sede, NULL) AS PorcentajeOcupacion
FROM sede;
*/
