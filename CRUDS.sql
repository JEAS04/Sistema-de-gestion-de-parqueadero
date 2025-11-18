-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS CRUD
-- Autor: Julian Alvarez
-- Sistema de Gestión de Parqueadero y Lavado
-- ============================================================================
-- Descripción: Procedimientos para realizar operaciones CRUD (Crear, Leer,
--              Actualizar, Eliminar) sobre las tablas principales del sistema
-- ============================================================================
-- TABLA 1: CLIENTE
-- ============================================================================
-- PROCEDIMIENTO: P_CREAR_CLIENTE
-- Descripción: Inserta un nuevo cliente en el sistema
-- ============================================================================
GO
CREATE OR ALTER PROCEDURE P_CREAR_CLIENTE
    @documento NVARCHAR(20),
    @nombre NVARCHAR(100),
    @apellido NVARCHAR(100),
    @telefono NVARCHAR(20) = NULL,
    @correo NVARCHAR(100) = NULL,
    @direccion NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Valida que el documento del cliente no existe en la base de datos
        IF EXISTS (SELECT 1 FROM CLIENTE WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' ya existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Inserta el cliente
        INSERT INTO CLIENTE (documento, nombre, apellido, telefono, correo, direccion)
        VALUES (@documento, @nombre, @apellido, @telefono, @correo, @direccion);
        
        PRINT 'Cliente creado exitosamente: ' + @nombre + ' ' + @apellido;
        PRINT 'Documento: ' + @documento;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al crear cliente: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_CREAR_CLIENTE
    @documento = '1234567890',
    @nombre = 'Roberto',
    @apellido = 'Gomez',
    @telefono = '987654321',
    @correo = 'robertogomez@example.com',
    @direccion = 'Calle 000, Ciudad X';
*/

-- ====================================================================
-- PROCEDIMIENTO: P_CONSULTA_CLIENTE
-- Descripción: Consulta la información de uno o todos los clientes
-- ====================================================================
GO
CREATE OR ALTER PROCEDURE P_CONSULTA_CLIENTE
    @documento NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @documento IS NULL
        BEGIN
            -- Listar todos los clientes con información de vehículos
            SELECT 
                c.id_cliente,
                c.documento,
                c.nombre,
                c.apellido,
                c.telefono,
                c.correo,
                c.direccion,
                c.fecha_registro,
                COUNT(v.id_vehiculo) AS cantidad_vehiculos
            FROM CLIENTE c
            LEFT JOIN VEHICULO v ON c.id_cliente = v.id_cliente
            GROUP BY c.id_cliente, c.documento, c.nombre, c.apellido, 
                     c.telefono, c.correo, c.direccion, c.fecha_registro
            ORDER BY c.nombre, c.apellido;
        END
        ELSE
        BEGIN
            -- Buscar cliente específico
            IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE documento = @documento)
            BEGIN
                PRINT 'No se encontró el cliente con documento: ' + @documento;
                RETURN;
            END
            
            SELECT 
                c.id_cliente,
                c.documento,
                c.nombre,
                c.apellido,
                c.telefono,
                c.correo,
                c.direccion,
                c.fecha_registro,
                COUNT(v.id_vehiculo) AS cantidad_vehiculos
            FROM CLIENTE c
            LEFT JOIN VEHICULO v ON c.id_cliente = v.id_cliente
            WHERE c.documento = @documento
            GROUP BY c.id_cliente, c.documento, c.nombre, c.apellido, 
                     c.telefono, c.correo, c.direccion, c.fecha_registro;
        END
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al consultar cliente: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_CONSULTA_CLIENTE;
EXEC P_CONSULTA_CLIENTE @documento = '1010101010';
*/

-- =======================================================================
-- PROCEDIMIENTO: P_ACTUALIZAR_CLIENTE
-- Descripción: Actualiza la información de un cliente existente
-- =======================================================================
GO
CREATE OR ALTER PROCEDURE P_ACTUALIZAR_CLIENTE
    @documento NVARCHAR(20),
    @nombre NVARCHAR(100) = NULL,
    @apellido NVARCHAR(100) = NULL,
    @telefono NVARCHAR(20) = NULL,
    @correo NVARCHAR(100) = NULL,
    @direccion NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Valida que el cliente existe 
        IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
         
        -- Actualizar solo los campos que no son NULL
        UPDATE CLIENTE
        SET nombre = ISNULL(@nombre, nombre),
            apellido = ISNULL(@apellido, apellido),
            telefono = ISNULL(@telefono, telefono),
            correo = ISNULL(@correo, correo),
            direccion = ISNULL(@direccion, direccion)
        WHERE documento = @documento;
        
        PRINT 'Cliente actualizado exitosamente: ' + @documento;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al actualizar cliente: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/* 
EJEMPLO DE USO

EXEC P_ACTUALIZAR_CLIENTE 
    @documento = '1234567890', 
    @telefono = '987654321', 
    @correo = 'nuevo.correo@ejemplo.com';

EXEC P_ACTUALIZAR_CLIENTE 
    @documento = '1234567890', 
    @nombre = 'Juanito', 
    @apellido = 'Pérez',
    @telefono = '912345678', 
    @correo = 'juanito.perez@ejemplo.com', 
    @direccion = 'Calle Nueva 456, Ciudad Y';
*/

-- =======================================================================
-- PROCEDIMIENTO: P_ELIMINAR_CLIENTE
-- Descripción: Elimina un cliente del sistema (solo si no tiene vehículos)
-- =======================================================================
GO
CREATE OR ALTER PROCEDURE P_ELIMINAR_CLIENTE
    @documento NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    DECLARE @nombre NVARCHAR(100);
    DECLARE @apellido NVARCHAR(100);
    DECLARE @id_cliente INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Valida que el cliente existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Obtener id y nombre para validaciones y mensaje
        SELECT @id_cliente = id_cliente, @nombre = nombre, @apellido = apellido 
        FROM CLIENTE 
        WHERE documento = @documento;

        -- Validar que no tenga vehículos asociados
        IF EXISTS (SELECT 1 FROM VEHICULO WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'No se puede eliminar el cliente porque tiene vehículos registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga servicios de lavado
        IF EXISTS (SELECT 1 FROM SERVICIO_LAVADO WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'No se puede eliminar el cliente porque tiene servicios de lavado registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga facturas
        IF EXISTS (SELECT 1 FROM FACTURA WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'No se puede eliminar el cliente porque tiene facturas registradas.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga pagos
        IF EXISTS (SELECT 1 FROM PAGO WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'No se puede eliminar el cliente porque tiene pagos registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Eliminar cliente
        DELETE FROM CLIENTE WHERE documento = @documento;
        
        COMMIT TRANSACTION;
        
        PRINT 'Cliente eliminado exitosamente: ' + @nombre + ' ' + @apellido;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al eliminar cliente: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_ELIMINAR_CLIENTE @documento = '1234567890';
*/

-- ============================================================================
-- TABLA 2: VEHICULO
-- ============================================================================
-- PROCEDIMIENTO: P_CREAR_VEHICULO
-- Descripción: Inserta un nuevo vehículo en el sistema
-- ============================================================================
GO
CREATE OR ALTER PROCEDURE P_CREAR_VEHICULO
    @placa NVARCHAR(20),
    @año INT,
    @color NVARCHAR(50) = NULL,
    @modelo NVARCHAR(100) = NULL,
    @marca NVARCHAR(100) = NULL,
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Valida que la placa del vehículo no existe en la base de datos
        IF EXISTS (SELECT 1 FROM VEHICULO WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehículo con placa ' + @placa + ' ya existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Valida que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'El cliente especificado no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Inserta el vehículo
        INSERT INTO VEHICULO (placa, año, color, modelo, marca, id_cliente)
        VALUES (@placa, @año, @color, @modelo, @marca, @id_cliente);
        
        PRINT 'Vehículo creado exitosamente: ' + @placa;
        PRINT 'Marca: ' + ISNULL(@marca, 'N/A') + ' - Modelo: ' + ISNULL(@modelo, 'N/A');
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al crear vehículo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_CREAR_VEHICULO
    @placa = 'XYZ999',
    @año = 2023,
    @color = 'Azul',
    @modelo = 'Civic',
    @marca = 'Honda',
    @id_cliente = 1;
*/

-- ====================================================================
-- PROCEDIMIENTO: P_CONSULTA_VEHICULO
-- Descripción: Consulta la información de uno o todos los vehículos
-- ====================================================================
GO
CREATE OR ALTER PROCEDURE P_CONSULTA_VEHICULO
    @placa NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @placa IS NULL
        BEGIN
            -- Listar todos los vehículos con información del cliente
            SELECT 
                v.id_vehiculo,
                v.placa,
                v.año,
                v.color,
                v.modelo,
                v.marca,
                c.nombre + ' ' + c.apellido AS nombre_cliente,
                c.documento AS documento_cliente,
                c.telefono AS telefono_cliente
            FROM VEHICULO v
            INNER JOIN CLIENTE c ON v.id_cliente = c.id_cliente
            ORDER BY v.placa;
        END
        ELSE
        BEGIN
            -- Buscar vehículo específico
            IF NOT EXISTS (SELECT 1 FROM VEHICULO WHERE placa = @placa)
            BEGIN
                PRINT 'No se encontró el vehículo con placa: ' + @placa;
                RETURN;
            END
            
            SELECT 
                v.id_vehiculo,
                v.placa,
                v.año,
                v.color,
                v.modelo,
                v.marca,
                c.nombre + ' ' + c.apellido AS nombre_cliente,
                c.documento AS documento_cliente,
                c.telefono AS telefono_cliente
            FROM VEHICULO v
            INNER JOIN CLIENTE c ON v.id_cliente = c.id_cliente
            WHERE v.placa = @placa;
        END
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al consultar vehículo: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_CONSULTA_VEHICULO;
EXEC P_CONSULTA_VEHICULO @placa = 'ABC123';
*/

-- =======================================================================
-- PROCEDIMIENTO: P_ACTUALIZAR_VEHICULO
-- Descripción: Actualiza la información de un vehículo existente
-- =======================================================================
GO
CREATE OR ALTER PROCEDURE P_ACTUALIZAR_VEHICULO
    @placa NVARCHAR(20),
    @año INT = NULL,
    @color NVARCHAR(50) = NULL,
    @modelo NVARCHAR(100) = NULL,
    @marca NVARCHAR(100) = NULL,
    @id_cliente INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Valida que el vehículo existe 
        IF NOT EXISTS (SELECT 1 FROM VEHICULO WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehículo con placa ' + @placa + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Si se especifica un nuevo cliente, validar que existe
        IF @id_cliente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CLIENTE WHERE id_cliente = @id_cliente)
        BEGIN
            SET @error_msg = 'El cliente especificado no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
         
        -- Actualizar solo los campos que no son NULL
        UPDATE VEHICULO
        SET año = ISNULL(@año, año),
            color = ISNULL(@color, color),
            modelo = ISNULL(@modelo, modelo),
            marca = ISNULL(@marca, marca),
            id_cliente = ISNULL(@id_cliente, id_cliente)
        WHERE placa = @placa;
        
        PRINT 'Vehículo actualizado exitosamente: ' + @placa;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al actualizar vehículo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/* 
EJEMPLO DE USO

EXEC P_ACTUALIZAR_VEHICULO 
    @placa = 'ABC123', 
    @color = 'Rojo', 
    @año = 2024;

EXEC P_ACTUALIZAR_VEHICULO 
    @placa = 'ABC123', 
    @marca = 'Toyota', 
    @modelo = 'Corolla 2024';
*/

-- =======================================================================
-- PROCEDIMIENTO: P_ELIMINAR_VEHICULO
-- Descripción: Elimina un vehículo del sistema (solo si no tiene dependencias)
-- =======================================================================
GO
CREATE OR ALTER PROCEDURE P_ELIMINAR_VEHICULO
    @placa NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    DECLARE @marca NVARCHAR(100);
    DECLARE @modelo NVARCHAR(100);
    DECLARE @id_vehiculo INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Valida que el vehículo existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM VEHICULO WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehículo con placa ' + @placa + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Obtener id y datos para validaciones y mensaje
        SELECT @id_vehiculo = id_vehiculo, @marca = marca, @modelo = modelo 
        FROM VEHICULO 
        WHERE placa = @placa;

        -- Validar que no tenga asignaciones de convenio
        IF EXISTS (SELECT 1 FROM ASIGNACION_CONVENIO WHERE id_vehiculo = @id_vehiculo)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehículo porque tiene asignaciones de convenio.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga servicios de lavado
        IF EXISTS (SELECT 1 FROM SERVICIO_LAVADO WHERE id_vehiculo = @id_vehiculo)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehículo porque tiene servicios de lavado registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga turnos de lavado
        IF EXISTS (SELECT 1 FROM TURNO_LAVADO WHERE id_vehiculo = @id_vehiculo)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehículo porque tiene turnos de lavado registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no esté en relación con convenios de día y placa
        IF EXISTS (SELECT 1 FROM CONVENIO_DIA_PLACA WHERE id_vehiculo = @id_vehiculo)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehículo porque está asociado a convenios de día y placa.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Eliminar relaciones M:N si existen
        DELETE FROM Vehiculo_TipoVehiculo WHERE id_vehiculo = @id_vehiculo;
        
        -- Eliminar vehículo
        DELETE FROM VEHICULO WHERE placa = @placa;
        
        COMMIT TRANSACTION;
        
        PRINT 'Vehículo eliminado exitosamente: ' + @placa;
        PRINT 'Marca: ' + ISNULL(@marca, 'N/A') + ' - Modelo: ' + ISNULL(@modelo, 'N/A');
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al eliminar vehículo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO

EXEC P_ELIMINAR_VEHICULO @placa = 'XYZ999';
*/
