-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS CRUD
-- Sistema de Gestión de Parqueadero
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
CREATE PROCEDURE P_CREAR_CLIENTE
    @documento VARCHAR(50),
    @nombre VARCHAR(100),
    @telefono VARCHAR(20),
    @correo VARCHAR(100),
    @direccion VARCHAR(200),
    @id_convenio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
			-- Valida que el documento del cliente no existe en la base de datos
        IF EXISTS (SELECT 1 FROM cliente WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' ya existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        IF @id_convenio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM convenio WHERE id_convenio = @id_convenio)
        BEGIN
            SET @error_msg = 'El convenio especificado no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Inserta el cliente
        INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio)
        VALUES (@documento, @nombre, @telefono, @correo, @direccion, @id_convenio);
        
        PRINT 'Cliente creado exitosamente: ' + @nombre;
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
    @nombre = 'Roberto Gomez',
    @telefono = '987654321',
    @correo = 'robertogomez@example.com',
    @direccion = 'Calle 000, Ciudad X',
	*/

-- ====================================================================
-- PROCEDIMIENTO: P_CONSULTA_CLIENTE
-- Descripción: Consulta la información de uno o todos los clientes
-- ====================================================================
GO
CREATE PROCEDURE P_CONSULTA_CLIENTE
    @documento VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @documento IS NULL
        BEGIN
            -- Listar todos los clientes con información del convenio
            SELECT 
                c.documento,
                c.nombre,
                c.telefono,
                c.correo,
                c.direccion,
                c.id_convenio,
                ISNULL(conv.nombre_convenio, 'Sin convenio') AS nombre_convenio
            FROM cliente c
            LEFT JOIN convenio conv ON c.id_convenio = conv.id_convenio
            ORDER BY c.nombre;
        END
        ELSE
        BEGIN
            -- Buscar cliente específico
            IF NOT EXISTS (SELECT 1 FROM cliente WHERE documento = @documento)
            BEGIN
                PRINT 'No se encontró el cliente con documento: ' + @documento;
                RETURN;
            END
            
            SELECT 
                c.documento,
                c.nombre,
                c.telefono,
                c.correo,
                c.direccion,
                c.id_convenio,
                ISNULL(conv.nombre_convenio, 'Sin convenio') AS nombre_convenio
            FROM cliente c
            LEFT JOIN convenio conv ON c.id_convenio = conv.id_convenio
            WHERE c.documento = @documento;
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
EXEC P_CONSULTA_CLIENTE @documento = 'C001';
*/

-- =======================================================================
-- PROCEDIMIENTO: P_ACTUALIZAR_CLIENTE
-- Descripción: Actualiza la información de un cliente existente
-- =======================================================================
GO
CREATE PROCEDURE P_ACTUALIZAR_CLIENTE
    @documento VARCHAR(50),
    @nombre VARCHAR(100) = NULL,
    @telefono VARCHAR(20) = NULL,
    @correo VARCHAR(100) = NULL,
    @direccion VARCHAR(200) = NULL,
    @id_convenio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
			-- Valida que el cliente existe 
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
         
			-- Actualizar solo los campos que no son NULL

        UPDATE cliente
        SET nombre = ISNULL(@nombre, nombre),
            telefono = ISNULL(@telefono, telefono),
            correo = ISNULL(@correo, correo),
            direccion = ISNULL(@direccion, direccion),
            id_convenio = ISNULL(@id_convenio, id_convenio)
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
    @nombre = 'Juanito Pérez', 
    @telefono = '912345678', 
    @correo = 'juanito.perez@ejemplo.com', 
    @direccion = 'Calle Nueva 456, Ciudad Y', 
    @id_convenio = 2;

*/


-- =======================================================================
-- PROCEDIMIENTO: P_ELIMINAR_CLIENTE
-- Descripción: Elimina un cliente del sistema (solo si no tiene vehículos)
-- =======================================================================
GO
CREATE PROCEDURE P_ELIMINAR_CLIENTE
    @documento VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    DECLARE @nombre VARCHAR(100);
    
    BEGIN TRY
        BEGIN TRANSACTION;
			-- Valida que el cliente existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE documento = @documento)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
			-- Obtener nombre para mensaje

        SELECT @nombre = nombre FROM cliente WHERE documento = @documento;

			-- Validar que no tenga vehículos asociados

        IF EXISTS (SELECT 1 FROM vehiculo WHERE documento_cliente = @documento)
        BEGIN
            SET @error_msg = 'No se puede eliminar el cliente porque tiene vehiculos registrados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Eliminar cliente

        DELETE FROM cliente WHERE documento = @documento;
        
        COMMIT TRANSACTION;
        
        PRINT 'Cliente eliminado exitosamente: ' + @nombre;
        
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
-- Descripción: Registra un nuevo vehículo en el sistema
-- ============================================================================
GO
CREATE PROCEDURE P_CREAR_VEHICULO
    @placa VARCHAR(20),
    @marca VARCHAR(50),
    @modelo VARCHAR(50),
    @color VARCHAR(30),
    @id_tipo_vehiculo INT,
    @documento_cliente VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
			-- Validar que la placa no exista en la base de datos

        IF EXISTS (SELECT 1 FROM vehiculo WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehiculo con placa ' + @placa + ' ya existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
			-- Validar que el cliente existe en la base de datos

        IF NOT EXISTS (SELECT 1 FROM cliente WHERE documento = @documento_cliente)
        BEGIN
            SET @error_msg = 'El cliente con documento ' + @documento_cliente + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
			-- Validar que el tipo de vehículo existe en la base de datos

        IF NOT EXISTS (SELECT 1 FROM TIPO_VEHICULO WHERE id_tipo_vehiculo = @id_tipo_vehiculo)
        BEGIN
            SET @error_msg = 'El tipo de vehiculo especificado no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
			-- Insertar vehículo en la base de datos
        INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente)
        VALUES (@placa, @marca, @modelo, @color, @id_tipo_vehiculo, @documento_cliente);
        
        PRINT 'Vehiculo registrado exitosamente: ' + @placa;
        PRINT 'Marca: ' + @marca + ' | Modelo: ' + @modelo;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al crear vehiculo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO
/* 
EJEMPLO DE USO

EXEC P_CREAR_VEHICULO
    @placa = 'ABC123',
    @marca = 'Toyota',
    @modelo = 'Corolla',
    @color = 'Rojo',
    @id_tipo_vehiculo = 1,  -- Suponiendo que 1 es el id de un tipo de vehículo válido
    @documento_cliente = '1234567890';  -- Documento del cliente
*/

-- ============================================================================
-- PROCEDIMIENTO: P_CONSULTA_VEHICULO
-- Descripción: Consulta información de uno o todos los vehículos
-- ============================================================================
GO
CREATE PROCEDURE P_CONSULTA_VEHICULO
    @placa VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @placa IS NULL
        BEGIN
            -- Listar todos los vehículos
            SELECT 
                v.placa,
                v.marca,
                v.modelo,
                v.color,
                tv.nombre_tipo AS tipo_vehiculo,
                v.documento_cliente,
                c.nombre AS nombre_propietario
            FROM vehiculo v
            INNER JOIN TIPO_VEHICULO tv ON v.id_tipo_vehiculo = tv.id_tipo_vehiculo
            INNER JOIN cliente c ON v.documento_cliente = c.documento
            ORDER BY v.placa;
        END
        ELSE
        BEGIN
            -- Buscar vehículo específico
            IF NOT EXISTS (SELECT 1 FROM vehiculo WHERE placa = @placa)
            BEGIN
                PRINT 'No se encontro el vehiculo con placa: ' + @placa;
                RETURN;
            END
            
            SELECT 
                v.placa,
                v.marca,
                v.modelo,
                v.color,
                tv.nombre_tipo AS tipo_vehiculo,
                v.documento_cliente,
                c.nombre AS nombre_propietario,
                c.telefono AS telefono_propietario
            FROM vehiculo v
            INNER JOIN TIPO_VEHICULO tv ON v.id_tipo_vehiculo = tv.id_tipo_vehiculo
            INNER JOIN cliente c ON v.documento_cliente = c.documento
            WHERE v.placa = @placa;
        END
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al consultar vehiculo: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/* 
EJEMPLO DE USO
EXEC P_CONSULTA_VEHICULO;
EXEC P_CONSULTA_VEHICULO @placa = 'ABC001';
*/

-- ============================================================================
-- PROCEDIMIENTO: P_ACTUALIZAR_VEHICULO
-- Descripción: Actualiza información de un vehículo
-- ============================================================================
GO
CREATE PROCEDURE P_ACTUALIZAR_VEHICULO
    @placa VARCHAR(20),
    @marca VARCHAR(50) = NULL,
    @modelo VARCHAR(50) = NULL,
    @color VARCHAR(30) = NULL,
    @id_tipo_vehiculo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Validar que el vehículo existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM vehiculo WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehiculo con placa ' + @placa + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Actualizar solo los campos proporcionados
        UPDATE vehiculo
        SET marca = ISNULL(@marca, marca),
            modelo = ISNULL(@modelo, modelo),
            color = ISNULL(@color, color),
            id_tipo_vehiculo = ISNULL(@id_tipo_vehiculo, id_tipo_vehiculo)
        WHERE placa = @placa;
        
        PRINT 'Vehiculo actualizado exitosamente: ' + @placa;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al actualizar vehiculo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/* 
EJEMPLO DE USO
EXEC P_ACTUALIZAR_VEHICULO
    @placa = 'ABC123',
    @marca = 'Honda',  -- Cambiar marca
    @modelo = 'Civic';  -- Cambiar modelo

EXEC P_ACTUALIZAR_VEHICULO
    @placa = 'ABC123',
    @marca = 'Toyota',  -- Nueva marca
    @modelo = 'Camry',  -- Nuevo modelo
    @color = 'Negro',   -- Nuevo color
    @id_tipo_vehiculo = 2;  -- Nuevo tipo de vehículo

*/

-- ============================================================================
-- PROCEDIMIENTO: P_ELIMINAR_VEHICULO
-- Descripción: Elimina un vehículo del sistema (solo si no tiene historial)
-- ============================================================================
GO
CREATE PROCEDURE P_ELIMINAR_VEHICULO
    @placa VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el vehículo existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM vehiculo WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'El vehiculo con placa ' + @placa + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga historial de parqueo
        IF EXISTS (SELECT 1 FROM parqueo WHERE placa_vehiculo = @placa)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehiculo porque tiene historial de parqueo.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar que no tenga historial de lavado
        IF EXISTS (SELECT 1 FROM lavado WHERE placa = @placa)
        BEGIN
            SET @error_msg = 'No se puede eliminar el vehiculo porque tiene historial de lavado.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Eliminar vehículo
        DELETE FROM vehiculo WHERE placa = @placa;
        
        COMMIT TRANSACTION;
        
        PRINT 'Vehiculo eliminado exitosamente: ' + @placa;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al eliminar vehiculo: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO
/* 
EJEMPLO DE USO
EXEC P_ELIMINAR_VEHICULO
    @placa = 'ABC001';
*/

-- ============================================================================
-- TABLA 3: CONVENIO
-- ============================================================================
-- PROCEDIMIENTO: P_CREAR_CONVENIO
-- Descripción: Crea un nuevo convenio/plan de parqueadero
-- ============================================================================
GO
CREATE PROCEDURE P_CREAR_CONVENIO
    @nombre_convenio VARCHAR(100),
    @descripcion VARCHAR(200),
    @precio_base DECIMAL(10,2),
    @unidad_tarifaria VARCHAR(50),
    @vigencia_inicio DATE,
    @vigencia_fin DATE,
    @id_sede INT,
    @id_convenio_nuevo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Validar que la sede existe
        IF NOT EXISTS (SELECT 1 FROM sede WHERE id_sede = @id_sede)
        BEGIN
            SET @error_msg = 'La sede especificada no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar fechas
        IF @vigencia_fin < @vigencia_inicio
        BEGIN
            SET @error_msg = 'La fecha de fin debe ser mayor a la fecha de inicio.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Validar unidad tarifaria
        IF @unidad_tarifaria NOT IN ('HORA', 'DIA', 'MES', 'FIJO')
        BEGIN
            SET @error_msg = 'Unidad tarifaria invalida. Use: HORA, DIA, MES o FIJO.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Insertar convenio
        INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, 
                            vigencia_inicio, vigencia_fin, id_sede)
        VALUES (@nombre_convenio, @descripcion, @precio_base, @unidad_tarifaria,
               @vigencia_inicio, @vigencia_fin, @id_sede);
        
        SET @id_convenio_nuevo = SCOPE_IDENTITY();
        
        PRINT 'Convenio creado exitosamente: ' + @nombre_convenio;
        PRINT 'ID Convenio: ' + CAST(@id_convenio_nuevo AS VARCHAR(10));
        PRINT 'Precio: $' + CAST(@precio_base AS VARCHAR(20)) + ' por ' + @unidad_tarifaria;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al crear convenio: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

DECLARE @id_convenio_nuevo INT;
/*
EJEMPLO DE USO
EXEC P_CREAR_CONVENIO
    @nombre_convenio = 'Convenio Corporativo',
    @descripcion = 'Convenio especial para empresas con tarifas preferenciales.',
    @precio_base = 500.00,
    @unidad_tarifaria = 'MES',
    @vigencia_inicio = '2025-01-01',
    @vigencia_fin = '2025-12-31',
    @id_sede = 1,
    @id_convenio_nuevo = @id_convenio_nuevo OUTPUT;

-- Mostrar el ID del nuevo convenio creado
SELECT @id_convenio_nuevo AS 'Nuevo ID Convenio';
*/

-- ============================================================================
-- PROCEDIMIENTO: P_CONSULTAR_CONVENIO
-- Descripción: Consulta convenios activos o específicos
-- ============================================================================
GO
CREATE PROCEDURE P_CONSULTAR_CONVENIO
    @id_convenio INT = NULL,
    @solo_vigentes BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @fecha_actual DATE = CAST(GETDATE() AS DATE);
    
    BEGIN TRY
        IF @id_convenio IS NULL
        BEGIN
            -- Listar convenios según filtro
            SELECT 
                c.id_convenio,
                c.nombre_convenio,
                c.descripcion,
                c.precio_base,
                c.unidad_tarifaria,
                c.vigencia_inicio,
                c.vigencia_fin,
                s.nombre_sede,
                CASE 
                    WHEN @fecha_actual BETWEEN c.vigencia_inicio AND c.vigencia_fin 
                    THEN 'VIGENTE'
                    WHEN @fecha_actual < c.vigencia_inicio 
                    THEN 'PENDIENTE'
                    ELSE 'VENCIDO'
                END AS estado_convenio
            FROM convenio c
            INNER JOIN sede s ON c.id_sede = s.id_sede
            WHERE (@solo_vigentes = 0 OR @fecha_actual BETWEEN c.vigencia_inicio AND c.vigencia_fin)
            ORDER BY c.vigencia_inicio DESC;
        END
        ELSE
        BEGIN
            -- Buscar convenio específico
            IF NOT EXISTS (SELECT 1 FROM convenio WHERE id_convenio = @id_convenio)
            BEGIN
                PRINT 'No se encontro el convenio con ID: ' + CAST(@id_convenio AS VARCHAR(10));
                RETURN;
            END
            
            SELECT 
                c.id_convenio,
                c.nombre_convenio,
                c.descripcion,
                c.precio_base,
                c.unidad_tarifaria,
                c.vigencia_inicio,
                c.vigencia_fin,
                s.nombre_sede,
                CASE 
                    WHEN @fecha_actual BETWEEN c.vigencia_inicio AND c.vigencia_fin 
                    THEN 'VIGENTE'
                    WHEN @fecha_actual < c.vigencia_inicio 
                    THEN 'PENDIENTE'
                    ELSE 'VENCIDO'
                END AS estado_convenio
            FROM convenio c
            INNER JOIN sede s ON c.id_sede = s.id_sede
            WHERE c.id_convenio = @id_convenio;
        END
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR al consultar convenio: ' + ERROR_MESSAGE();
    END CATCH
END
GO
/*
EJEMPLO DE USO
EXEC P_CONSULTAR_CONVENIO;
EXEC P_CONSULTAR_CONVENIO @id_convenio = 5; -- POR ID:
*/
-- ============================================================================
-- PROCEDIMIENTO: P_ACTUALIZAR_CONVENIO
-- Descripción: Actualiza información de un convenio existente
-- ============================================================================
GO
CREATE PROCEDURE  P_ACTUALIZAR_CONVENIO
    @id_convenio INT,
    @nombre_convenio VARCHAR(100) = NULL,
    @descripcion VARCHAR(200) = NULL,
    @precio_base DECIMAL(10,2) = NULL,
    @vigencia_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Validar que el convenio existe
        IF NOT EXISTS (SELECT 1 FROM convenio WHERE id_convenio = @id_convenio)
        BEGIN
            SET @error_msg = 'El convenio con ID ' + CAST(@id_convenio AS VARCHAR(10)) + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Actualizar convenio
        UPDATE convenio
        SET nombre_convenio = ISNULL(@nombre_convenio, nombre_convenio),
            descripcion = ISNULL(@descripcion, descripcion),
            precio_base = ISNULL(@precio_base, precio_base),
            vigencia_fin = ISNULL(@vigencia_fin, vigencia_fin)
        WHERE id_convenio = @id_convenio;
        
        PRINT 'Convenio actualizado exitosamente. ID: ' + CAST(@id_convenio AS VARCHAR(10));
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al actualizar convenio: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO
EXEC P_ACTUALIZAR_CONVENIO
    @id_convenio = 10,
    @nombre_convenio = 'Nuevo Nombre Convenio',
    @precio_base = 2000.00,
    @vigencia_fin = '2025-12-31';
*/

-- ============================================================================
-- PROCEDIMIENTO: P_ELIMINAR_CONVENIO
-- Descripción: Elimina un convenio (solo si no tiene clientes asociados)
-- ============================================================================
GO
CREATE PROCEDURE P_ELIMINAR_CONVENIO
    @id_convenio INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    DECLARE @nombre VARCHAR(100);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el convenio existe en la base de datos
        IF NOT EXISTS (SELECT 1 FROM convenio WHERE id_convenio = @id_convenio)
        BEGIN
            SET @error_msg = 'El convenio con ID ' + CAST(@id_convenio AS VARCHAR(10)) + ' no existe.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Obtener nombre
        SELECT @nombre = nombre_convenio FROM convenio WHERE id_convenio = @id_convenio;
        
        -- Validar que no tenga clientes asociados
        IF EXISTS (SELECT 1 FROM cliente WHERE id_convenio = @id_convenio)
        BEGIN
            SET @error_msg = 'No se puede eliminar el convenio porque tiene clientes asociados.';
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END
        
        -- Eliminar convenio
        DELETE FROM convenio WHERE id_convenio = @id_convenio;
        
        COMMIT TRANSACTION;
        
        PRINT 'Convenio eliminado exitosamente: ' + @nombre;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @error_msg = ERROR_MESSAGE();
        PRINT 'ERROR al eliminar convenio: ' + @error_msg;
        RAISERROR(@error_msg, 16, 1);
    END CATCH
END
GO

/*
EJEMPLO DE USO:
EXEC P_ELIMINAR_CONVENIO @id_convenio = 7;
*/