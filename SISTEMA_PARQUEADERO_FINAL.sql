-- =====================================================
-- CREACION Y USO DE LA BASE DE DATOS.
-- =====================================================
CREATE DATABASE SISTEMA_PARQUEADERO
GO
USE SISTEMA_PARQUEADERO
GO
-- =====================================================
-- CREACION DE LAS TABLAS.
-- =====================================================

CREATE TABLE TIPO_LAVADO (
    id_tipo_lavado INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(255),
    Precio_base DECIMAL(10,2) NOT NULL,
    Duracion_estimada TIME NOT NULL,
    Activo BIT NOT NULL DEFAULT 1
);

CREATE TABLE USUARIO (
    id_usuario INT PRIMARY KEY IDENTITY(1,1),
    nombre_usuario NVARCHAR(50) NOT NULL,
    documento NVARCHAR(20) NOT NULL,
    contraseña NVARCHAR(255) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    apellidos NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(20),
    fecha_creacion DATE DEFAULT GETDATE(),
    estado NVARCHAR(20) NOT NULL DEFAULT 'activo'
);

CREATE TABLE SEDE (
    id_sede INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    capacidad_total INT NOT NULL,
    horario_apertura TIME NOT NULL,
    horario_cierre TIME NOT NULL,
    telefono NVARCHAR(20),
    ciudad NVARCHAR(100) NOT NULL,
    direccion NVARCHAR(255) NOT NULL,
    id_gerente INT NOT NULL,
    CONSTRAINT FK_Sede_Gerente FOREIGN KEY (id_gerente)
        REFERENCES USUARIO(id_usuario)
);

CREATE TABLE CLIENTE (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    documento NVARCHAR(20) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT GETDATE(),
    telefono NVARCHAR(20),
    direccion NVARCHAR(255),
    correo NVARCHAR(100)
);

CREATE TABLE VEHICULO (
    id_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    año INT NOT NULL,
    placa NVARCHAR(20) NOT NULL,
    color NVARCHAR(50), 
    modelo NVARCHAR(100),
    marca NVARCHAR(100),
    id_cliente INT NOT NULL,
    CONSTRAINT FK_Vehiculo_Cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE TIPO_VEHICULO (
    id_tipo_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    tamaño_estimado NVARCHAR(50) NOT NULL,
    cilindraje INT NOT NULL,
    descripcion NVARCHAR(255)
);

CREATE TABLE CELDA (
    id_celda INT PRIMARY KEY IDENTITY(1,1),
    ubicacion NVARCHAR(100) NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'disponible',
    id_sede INT NOT NULL,
    CONSTRAINT FK_Celda_Sede FOREIGN KEY (id_sede)
        REFERENCES SEDE(id_sede)
);

CREATE TABLE CONVENIO (
    id_convenio INT PRIMARY KEY IDENTITY(1,1),
    descripcion NVARCHAR(255) NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    vigencia_inicio DATE NOT NULL,
    vigencia_fin DATE NOT NULL,
    plazo INT NOT NULL,
    reglas_especiales NVARCHAR(500)
);

CREATE TABLE TARJETA (
    id_tarjeta INT PRIMARY KEY IDENTITY(1,1),
    fecha_hora_emision DATETIME NOT NULL,
    codigo_tarjeta NVARCHAR(50) NOT NULL UNIQUE,
    estado_tarjeta NVARCHAR(20) NOT NULL DEFAULT 'Inactiva',
    fecha_vencimiento DATE
);

CREATE TABLE PARQUEO (
    id_parqueo INT PRIMARY KEY IDENTITY(1,1),
    fecha_hora_ingreso DATETIME NOT NULL,
    fecha_hora_salida DATETIME,
    estado_parqueo NVARCHAR(20) NOT NULL DEFAULT 'activo',
    modo_ingreso NVARCHAR(20) NOT NULL,
    valor_cobrado DECIMAL(10,2) DEFAULT 0.00,
    id_tarjeta INT NOT NULL,
    id_celda INT NOT NULL,
    CONSTRAINT FK_Parqueo_Tarjeta FOREIGN KEY (id_tarjeta)
        REFERENCES TARJETA(id_tarjeta),
    CONSTRAINT FK_Parqueo_Celda FOREIGN KEY (id_celda)
        REFERENCES CELDA(id_celda)
);

CREATE TABLE TURNO_LABORAL (
    id_turno_laboral INT PRIMARY KEY IDENTITY(1,1),
    observaciones NVARCHAR(255),
    estado NVARCHAR(20) NOT NULL DEFAULT 'activo',
    horas_trabajadas DECIMAL(5,2) NOT NULL DEFAULT 0.0,
    fecha_hora_entrada DATETIME NOT NULL,
    fecha_hora_salida DATETIME,
    id_usuario INT NOT NULL,
    CONSTRAINT FK_TurnoLaboral_Usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario)
);

CREATE TABLE FACTURA (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    total_bruto DECIMAL(10,2) NOT NULL,
    numero_factura NVARCHAR(50) NOT NULL UNIQUE,
    metodo_pago NVARCHAR(50) NOT NULL,
    total_neto DECIMAL(10,2) NOT NULL,
    fecha_hora_emision DATETIME NOT NULL DEFAULT GETDATE(),
    id_usuario INT NOT NULL,
    id_parqueo INT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT FK_Factura_Usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_Factura_Parqueo FOREIGN KEY (id_parqueo)
        REFERENCES PARQUEO(id_parqueo),
    CONSTRAINT FK_Factura_Cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE PAGO (
    id_pago INT PRIMARY KEY IDENTITY(1,1),
    metodo_pago NVARCHAR(50) NOT NULL,
    monto_pago DECIMAL(10,2) NOT NULL,
    fecha_hora_pago DATETIME NOT NULL DEFAULT GETDATE(),
    referencia_transaccion NVARCHAR(100) UNIQUE,
    id_factura INT NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT FK_Pago_Factura FOREIGN KEY (id_factura)
        REFERENCES FACTURA(id_factura),
    CONSTRAINT FK_Pago_Cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE DETALLE_FACTURA (
    id_factura INT NOT NULL,
    id_detalle_factura INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    servicio_pagado NVARCHAR(50) NOT NULL,
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    descripcion NVARCHAR(255),
    id_parqueo INT NULL,
    PRIMARY KEY (id_factura, id_detalle_factura),
    CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (id_factura)
        REFERENCES FACTURA(id_factura),
    CONSTRAINT FK_DetalleFactura_Parqueo FOREIGN KEY (id_parqueo)
        REFERENCES PARQUEO(id_parqueo)
);

CREATE TABLE SERVICIO_LAVADO (
    id_servicio_lavado INT PRIMARY KEY IDENTITY(1,1),
    fecha_hora_inicio DATETIME NOT NULL,
    fecha_hora_fin DATETIME,
    valor DECIMAL(10,2) NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',
    id_tipo_lavado INT NOT NULL,
    id_usuario INT NOT NULL,
    id_celda INT NOT NULL,
    id_factura INT NULL,
    id_cliente INT NOT NULL,
    id_vehiculo INT NOT NULL,
    CONSTRAINT FK_ServicioLavado_TipoLavado FOREIGN KEY (id_tipo_lavado)
        REFERENCES TIPO_LAVADO(id_tipo_lavado),
    CONSTRAINT FK_ServicioLavado_Usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_ServicioLavado_Celda FOREIGN KEY (id_celda)
        REFERENCES CELDA(id_celda),
    CONSTRAINT FK_ServicioLavado_Factura FOREIGN KEY (id_factura)
        REFERENCES FACTURA(id_factura),
    CONSTRAINT FK_ServicioLavado_Cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),
    CONSTRAINT FK_ServicioLavado_Vehiculo FOREIGN KEY (id_vehiculo)
        REFERENCES VEHICULO(id_vehiculo)
);

CREATE TABLE TARIFA_LAVADO (
    id_tarifa_lavado INT PRIMARY KEY IDENTITY(1,1),
    precio DECIMAL(10,2) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    tiempo_estimado INT NOT NULL,
    id_tipo_lavado INT NOT NULL,
    id_tipo_vehiculo INT NOT NULL,
    id_servicio_lavado INT NOT NULL,
    CONSTRAINT FK_TarifaLavado_TipoLavado FOREIGN KEY (id_tipo_lavado)
        REFERENCES TIPO_LAVADO(id_tipo_lavado),
    CONSTRAINT FK_TarifaLavado_TipoVehiculo FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES TIPO_VEHICULO(id_tipo_vehiculo),
    CONSTRAINT FK_TarifaLavado_ServicioLavado FOREIGN KEY (id_servicio_lavado)
        REFERENCES SERVICIO_LAVADO(id_servicio_lavado)
);

CREATE TABLE ASIGNACION_CONVENIO (
    id_asignacion_convenio INT PRIMARY KEY IDENTITY(1,1),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    id_celda INT NULL,
    id_vehiculo INT NULL,
    limite_vehiculos INT NOT NULL DEFAULT 1,
    precio_negociado DECIMAL(10,2) NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Inactivo',
    id_tarjeta INT NOT NULL,
    id_convenio INT NOT NULL,
    CONSTRAINT FK_AsignacionConvenio_Celda FOREIGN KEY (id_celda)
        REFERENCES CELDA(id_celda),
    CONSTRAINT FK_AsignacionConvenio_Vehiculo FOREIGN KEY (id_vehiculo)
        REFERENCES VEHICULO(id_vehiculo),
    CONSTRAINT FK_AsignacionConvenio_Tarjeta FOREIGN KEY (id_tarjeta)
        REFERENCES TARJETA(id_tarjeta),
    CONSTRAINT FK_AsignacionConvenio_Convenio FOREIGN KEY (id_convenio)
        REFERENCES CONVENIO(id_convenio)
);

ALTER TABLE FACTURA
ADD id_asignacion_convenio INT NULL,
    CONSTRAINT FK_Factura_AsignacionConvenio FOREIGN KEY (id_asignacion_convenio)
        REFERENCES ASIGNACION_CONVENIO(id_asignacion_convenio);

ALTER TABLE SERVICIO_LAVADO
ADD id_convenio INT NULL,
    CONSTRAINT FK_ServicioLavado_Convenio FOREIGN KEY (id_convenio)
        REFERENCES CONVENIO(id_convenio);

-- =====================================================
-- ESPECIALIZACIONES DE USUARIO
-- =====================================================

CREATE TABLE GERENTE (
    id_usuario INT PRIMARY KEY,
	fecha_inicio_gestion DATE NOT NULL,
    CONSTRAINT FK_Gerente_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIO(id_usuario)
);

CREATE TABLE ADMINISTRADOR (
    id_usuario INT PRIMARY KEY,
    nivel_acceso INT NOT NULL,
    CONSTRAINT FK_Administrador_Usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario)
);

CREATE TABLE SUPERVISOR (
    id_usuario INT PRIMARY KEY,
    fecha_inicio_gestion DATE NOT NULL,
    nivel_acceso INT NOT NULL,
	area_responsable VARCHAR(50),
    CONSTRAINT FK_Supervisor_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIO(id_usuario)
);

CREATE TABLE OPERARIO (
    id_usuario INT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    id_supervisor INT NULL,
    id_parqueo INT NULL,
    CONSTRAINT FK_Operario_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_Operario_Supervisor FOREIGN KEY (id_supervisor)
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_Operario_Parqueo FOREIGN KEY (id_parqueo)
        REFERENCES PARQUEO(id_parqueo)
);

CREATE TABLE LAVADOR (
    id_usuario INT PRIMARY KEY,
    fecha_inicio_gestion DATE NOT NULL,
	cantidad_servicios INT DEFAULT 0,
    especialidad_lavado VARCHAR(50),
    id_sede INT NOT NULL,
    CONSTRAINT FK_Lavador_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_Lavador_Sede FOREIGN KEY (id_sede)
        REFERENCES SEDE(id_sede)
);
-- =====================================================
-- ESPECIALIZACIONES DE TARJETA
-- =====================================================

CREATE TABLE TARJETA_CONVENIO (
    id_tarjeta INT PRIMARY KEY,
    fecha_expiracion DATE NOT NULL,
    CONSTRAINT FK_TarjetaConvenio_Tarjeta FOREIGN KEY (id_tarjeta) 
        REFERENCES TARJETA(id_tarjeta)
);

CREATE TABLE TARJETA_OCASIONAL (
    id_tarjeta INT PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    pagada BIT NOT NULL DEFAULT 0,
    hora_entrada DATETIME NOT NULL,
    id_pago INT NULL,
    CONSTRAINT FK_TarjetaOcasional_Tarjeta FOREIGN KEY (id_tarjeta) 
        REFERENCES TARJETA(id_tarjeta),
    CONSTRAINT FK_TarjetaOcasional_Pago FOREIGN KEY (id_pago)
        REFERENCES PAGO(id_pago)
);

-- =====================================================
-- ESPECIALIZACIONES DE CONVENIO
-- =====================================================

CREATE TABLE CONVENIO_PARQUEADERO (
    id_convenio INT PRIMARY KEY,
    requiere_tarjeta BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ConvenioParqueadero_Convenio FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO(id_convenio)
);

CREATE TABLE CONVENIO_LAVADO (
    id_convenio INT PRIMARY KEY,
    cantidad_lavado_mes INT NOT NULL,
    CONSTRAINT FK_ConvenioLavado_Convenio FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO(id_convenio)
);

CREATE TABLE CONVENIO_IRRESTRICTIVO (
    id_convenio INT PRIMARY KEY,
    cantidad_vehiculos INT NOT NULL,
    CONSTRAINT FK_ConvenioIrrestrictivo_ConvenioParqueadero FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_PARQUEADERO(id_convenio)
);

CREATE TABLE CONVENIO_CELDA_FIJA (
    id_convenio INT PRIMARY KEY,
    id_celda INT NOT NULL,
    CONSTRAINT FK_ConvenioCeldaFija_ConvenioParqueadero FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_PARQUEADERO(id_convenio),
    CONSTRAINT FK_ConvenioCeldaFija_Celda FOREIGN KEY (id_celda) 
        REFERENCES CELDA(id_celda)
);

CREATE TABLE CONVENIO_DIAS_MES (
    id_convenio INT PRIMARY KEY,
    cantidad_dias INT NOT NULL,
    CONSTRAINT FK_ConvenioDiasMes_ConvenioParqueadero FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_PARQUEADERO(id_convenio)
);

CREATE TABLE CONVENIO_HORAS_MES (
    id_convenio INT PRIMARY KEY,
    horas_permitidas INT NOT NULL,
    cantidad_horas_mes INT NOT NULL,
    CONSTRAINT FK_ConvenioHorasMes_ConvenioParqueadero FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_PARQUEADERO(id_convenio)
);

CREATE TABLE CONVENIO_DIA_PLACA (
    id_convenio INT PRIMARY KEY,
    id_vehiculo INT NOT NULL,
    CONSTRAINT FK_ConvenioDiaPlaca_ConvenioParqueadero FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_PARQUEADERO(id_convenio),
    CONSTRAINT FK_ConvenioDiaPlaca_Vehiculo FOREIGN KEY (id_vehiculo) 
        REFERENCES VEHICULO(id_vehiculo)
);

-- =====================================================
-- ESPECIALIZACIONES DE CELDA
-- =====================================================

CREATE TABLE CELDA_PARQUEO (
    id_celda INT PRIMARY KEY,
    id_convenio INT NULL,
    CONSTRAINT FK_CeldaParqueo_Celda FOREIGN KEY (id_celda) 
        REFERENCES CELDA(id_celda),
    CONSTRAINT FK_CeldaParqueo_ConvenioCeldaFija FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO_CELDA_FIJA(id_convenio)
);

CREATE TABLE CELDA_LAVADO (
    id_celda INT PRIMARY KEY,
    condicion_luz NVARCHAR(50) NOT NULL,
    espacio NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_CeldaLavado_Celda FOREIGN KEY (id_celda) 
        REFERENCES CELDA(id_celda)
);

CREATE TABLE CELDA_RECARGA_ELECTRICA (
    id_celda INT PRIMARY KEY,
    potencia DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_CeldaRecargaElectrica_Celda FOREIGN KEY (id_celda) 
        REFERENCES CELDA(id_celda)
);

CREATE TABLE CELDA_MOVILIDAD_REDUCIDA (
    id_celda INT PRIMARY KEY,
    ancho DECIMAL(5,2) NOT NULL,
    CONSTRAINT FK_CeldaMovilidadReducida_Celda FOREIGN KEY (id_celda) 
        REFERENCES CELDA(id_celda)
);
ALTER TABLE PARQUEO
ADD id_vehiculo INT NULL
    FOREIGN KEY REFERENCES VEHICULO(id_vehiculo);

CREATE TABLE TURNO_LAVADO (
    id_turno_lavado INT PRIMARY KEY IDENTITY(1,1),
    fecha DATE NOT NULL,
    fecha_hora_inicio TIME NOT NULL,
    fecha_hora_salida TIME NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Inactivo',
    id_tipo_lavado INT NOT NULL,
    id_vehiculo INT NOT NULL,
    id_usuario INT NOT NULL,
    id_celda_lavado INT NOT NULL,
    id_servicio_lavado INT NOT NULL,
    CONSTRAINT FK_TurnoLavado_TipoLavado FOREIGN KEY (id_tipo_lavado)
        REFERENCES TIPO_LAVADO(id_tipo_lavado),
    CONSTRAINT FK_TurnoLavado_Vehiculo FOREIGN KEY (id_vehiculo)
        REFERENCES VEHICULO(id_vehiculo),
    CONSTRAINT FK_TurnoLavado_Usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_TurnoLavado_CeldaLavado FOREIGN KEY (id_celda_lavado)
        REFERENCES CELDA_LAVADO(id_celda),
    CONSTRAINT FK_TurnoLavado_ServicioLavado FOREIGN KEY (id_servicio_lavado)
        REFERENCES SERVICIO_LAVADO(id_servicio_lavado)
);

-- =====================================================
-- TABLAS DE RELACIONES MUCHOS A MUCHOS
-- =====================================================

CREATE TABLE Vehiculo_TipoVehiculo (
    id_vehiculo INT NOT NULL,
    id_tipo_vehiculo INT NOT NULL,
    PRIMARY KEY (id_vehiculo, id_tipo_vehiculo),
    CONSTRAINT FK_VehiculoTipoVehiculo_Vehiculo FOREIGN KEY (id_vehiculo)
        REFERENCES VEHICULO(id_vehiculo),
    CONSTRAINT FK_VehiculoTipoVehiculo_Tipo FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES TIPO_VEHICULO(id_tipo_vehiculo)
);

CREATE TABLE Convenio_TipoLavado (
    id_convenio_lavado INT NOT NULL,
    id_tipo_lavado INT NOT NULL,
    PRIMARY KEY (id_convenio_lavado, id_tipo_lavado),
    CONSTRAINT FK_ConvenioTipoLavado_ConvenioLavado FOREIGN KEY (id_convenio_lavado) 
        REFERENCES CONVENIO_LAVADO(id_convenio),
    CONSTRAINT FK_ConvenioTipoLavado_TipoLavado FOREIGN KEY (id_tipo_lavado) 
        REFERENCES TIPO_LAVADO(id_tipo_lavado)
);

CREATE TABLE Convenio_Celda (
    id_convenio INT NOT NULL,
    id_celda INT NOT NULL,
    PRIMARY KEY (id_convenio, id_celda),
    CONSTRAINT FK_ConvenioCelda_Convenio FOREIGN KEY (id_convenio)
        REFERENCES CONVENIO(id_convenio),
    CONSTRAINT FK_ConvenioCelda_CeldaLavado FOREIGN KEY (id_celda)
        REFERENCES CELDA_LAVADO(id_celda)
);

CREATE TABLE Convenio_TipoVehiculo (
    id_convenio_parqueadero INT NOT NULL,
    id_tipo_vehiculo INT NOT NULL,
    PRIMARY KEY (id_convenio_parqueadero, id_tipo_vehiculo),
    CONSTRAINT FK_ConvenioTipoVehiculo_ConvenioParqueadero FOREIGN KEY (id_convenio_parqueadero)
        REFERENCES CONVENIO_PARQUEADERO(id_convenio),
    CONSTRAINT FK_ConvenioTipoVehiculo_TipoVehiculo FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES TIPO_VEHICULO(id_tipo_vehiculo)
);

CREATE TABLE Celda_TipoVehiculo (
    id_celda INT NOT NULL,
    id_tipo_vehiculo INT NOT NULL,
    PRIMARY KEY (id_celda, id_tipo_vehiculo),
    CONSTRAINT FK_CeldaTipoVehiculo_Celda FOREIGN KEY (id_celda)
        REFERENCES CELDA(id_celda),
    CONSTRAINT FK_CeldaTipoVehiculo_TipoVehiculo FOREIGN KEY (id_tipo_vehiculo)
        REFERENCES TIPO_VEHICULO(id_tipo_vehiculo)
);

CREATE TABLE Convenio_Sede (
    id_convenio INT NOT NULL,
    id_sede INT NOT NULL,
    PRIMARY KEY (id_convenio, id_sede),
    CONSTRAINT FK_ConvenioSede_Convenio FOREIGN KEY (id_convenio)
        REFERENCES CONVENIO(id_convenio),
    CONSTRAINT FK_ConvenioSede_Sede FOREIGN KEY (id_sede)
        REFERENCES SEDE(id_sede)
);

GO
-- =====================================================
-- CHECK CONSTRAINTS
-- =====================================================
ALTER TABLE TIPO_LAVADO
ADD CONSTRAINT CHK_TipoLavado_Precio CHECK (Precio_base > 0), -- El precio no puede ser negativo
    CONSTRAINT CHK_TipoLavado_Duracion CHECK (Duracion_estimada > '00:00:00'); -- La hora no puede ser negativa

ALTER TABLE USUARIO
ADD CONSTRAINT CHK_Usuario_Documento CHECK (LEN(documento) >= 5), -- Valida que la longitud del documento sea mayor que 5
    CONSTRAINT CHK_Usuario_Telefono CHECK (telefono LIKE '[0-9]%'); -- Verifica si el valor de telefono comienza con un dígito del 0 al 9

ALTER TABLE SEDE
ADD CONSTRAINT CHK_Sede_Capacidad CHECK (capacidad_total > 0), -- La capacidad total no puede ser negativa
    CONSTRAINT CHK_Sede_Horario CHECK (horario_cierre > horario_apertura); -- El horario de cierre debe ser mayor al horario de apertura

ALTER TABLE CONVENIO
ADD CONSTRAINT CHK_Convenio_Precio CHECK (precio_base >= 0), -- El precio debe ser positivo
    CONSTRAINT CHK_Convenio_Vigencia CHECK (vigencia_fin > vigencia_inicio); -- La fecha de finalizacion debe ser mayor a la de inicio

ALTER TABLE PARQUEO
ADD CONSTRAINT CHK_Parqueo_ValorCobrado CHECK (valor_cobrado >= 0), -- El valor debe ser positivo
    CONSTRAINT CHK_Parqueo_FechaSalida CHECK (fecha_hora_salida IS NULL OR fecha_hora_salida >= fecha_hora_ingreso); -- La fecha de salida debe ser mayor a la de entrada

ALTER TABLE TURNO_LABORAL
ADD CONSTRAINT CHK_TurnoLaboral_Horas CHECK (horas_trabajadas >= 0), -- Las horas deben ser positivas
    CONSTRAINT CHK_TurnoLaboral_FechaSalida CHECK (fecha_hora_salida IS NULL OR fecha_hora_salida >= fecha_hora_entrada); -- La fecha de salida debe ser mayor a la de entrada

ALTER TABLE FACTURA
ADD CONSTRAINT CHK_Factura_TotalBruto CHECK (total_bruto >= 0),
    CONSTRAINT CHK_Factura_TotalNeto CHECK (total_neto >= 0); -- Los totales deben ser positivos

ALTER TABLE PAGO
ADD CONSTRAINT CHK_Pago_Monto CHECK (monto_pago > 0); -- El monto debe ser positivo

ALTER TABLE DETALLE_FACTURA
ADD CONSTRAINT CHK_DetalleFactura_Cantidad CHECK (cantidad > 0), -- La cantidad debe ser positiva
    CONSTRAINT CHK_DetalleFactura_PrecioUnitario CHECK (precio_unitario >= 0);  -- Permite precios gratuitos o mayores

ALTER TABLE SERVICIO_LAVADO
ADD CONSTRAINT CHK_ServicioLavado_Valor CHECK (valor >= 0), -- El valor debe ser positivo
    CONSTRAINT CHK_ServicioLavado_FechaFin CHECK (fecha_hora_fin IS NULL OR fecha_hora_fin >= fecha_hora_inicio); -- La fecha de finalizacion debe ser mayor a la de inicio

ALTER TABLE TARIFA_LAVADO
ADD CONSTRAINT CHK_TarifaLavado_Precio CHECK (precio > 0),-- El precio debe ser positivo
    CONSTRAINT CHK_TarifaLavado_TiempoEstimado CHECK (tiempo_estimado > 0);  -- El tiempo debe ser positivo

ALTER TABLE ASIGNACION_CONVENIO
ADD CONSTRAINT CHK_AsignacionConvenio_Fechas CHECK (fecha_fin >= fecha_inicio); -- La fecha de finalizacion debe ser mayor a la de inicio

ALTER TABLE CONVENIO_LAVADO
ADD CONSTRAINT CHK_ConvenioLavado_CantidadLavado CHECK (cantidad_lavado_mes > 0);  -- Garantiza al menos 1 lavado incluido por mes

ALTER TABLE CONVENIO_IRRESTRICTIVO
ADD CONSTRAINT CHK_ConvenioIrrestrictivo_CantidadVehiculos CHECK (cantidad_vehiculos > 0);  -- Garantiza al menos 1 vehículo en convenio

ALTER TABLE CELDA_RECARGA_ELECTRICA
ADD CONSTRAINT CHK_CeldaRecargaElectrica_Potencia CHECK (potencia > 0);  -- La potencia debe ser positiva

ALTER TABLE TURNO_LAVADO
ADD CONSTRAINT CHK_TurnoLavado_Horario CHECK (fecha_hora_salida > fecha_hora_inicio); -- La fecha de salida debe ser mayor a la de entrada

/*
USE master;
GO   
ALTER DATABASE SISTEMA_PARQUEADERO 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO   
DROP DATABASE SISTEMA_PARQUEADERO;
GO   */ -- PARA ELIMINAR LA BASE DE DATOS Y HACER PRUEBAS.

-- =====================================================
-- INSERTS PARA TIPO_LAVADO
-- =====================================================
INSERT INTO TIPO_LAVADO (Nombre, Descripcion, Precio_base, Duracion_estimada, Activo) VALUES
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado de motor', 'Lavado de motor completo', 55000.00, '01:45:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 10000.00, '00:15:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 25000.00, '00:45:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 80000.00, '02:30:00', 1),
('Lavado de motor', 'Lavado de motor completo', 40000.00, '01:15:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 20000.00, '00:40:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 30000.00, '00:50:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 120000.00, '03:00:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 20000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 40000.00, '01:05:00', 1),
('Lavado de motor', 'Lavado de motor completo', 58000.00, '01:40:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 15000.00, '00:25:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 26000.00, '00:42:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 82000.00, '02:20:00', 1),
('Lavado de motor', 'Lavado de motor completo', 45000.00, '01:25:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 24000.00, '00:50:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 31000.00, '00:48:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 118000.00, '02:55:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado de motor', 'Lavado de motor completo', 55000.00, '01:45:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 10000.00, '00:15:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 25000.00, '00:45:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 80000.00, '02:30:00', 1),
('Lavado de motor', 'Lavado de motor completo', 40000.00, '01:15:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 20000.00, '00:40:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 30000.00, '00:50:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 120000.00, '03:00:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 20000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 40000.00, '01:05:00', 1),
('Lavado de motor', 'Lavado de motor completo', 58000.00, '01:40:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 15000.00, '00:25:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 26000.00, '00:42:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 82000.00, '02:20:00', 1),
('Lavado de motor', 'Lavado de motor completo', 45000.00, '01:25:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 24000.00, '00:50:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 31000.00, '00:48:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 118000.00, '02:55:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado de motor', 'Lavado de motor completo', 55000.00, '01:45:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 10000.00, '00:15:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 25000.00, '00:45:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 80000.00, '02:30:00', 1),
('Lavado de motor', 'Lavado de motor completo', 40000.00, '01:15:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 20000.00, '00:40:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 30000.00, '00:50:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 120000.00, '03:00:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 20000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 40000.00, '01:05:00', 1),
('Lavado de motor', 'Lavado de motor completo', 58000.00, '01:40:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 15000.00, '00:25:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 26000.00, '00:42:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 82000.00, '02:20:00', 1),
('Lavado de motor', 'Lavado de motor completo', 45000.00, '01:25:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 24000.00, '00:50:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 31000.00, '00:48:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 118000.00, '02:55:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado de motor', 'Lavado de motor completo', 55000.00, '01:45:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 10000.00, '00:15:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 25000.00, '00:45:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 80000.00, '02:30:00', 1),
('Lavado de motor', 'Lavado de motor completo', 40000.00, '01:15:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 20000.00, '00:40:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 30000.00, '00:50:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 120000.00, '03:00:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 20000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 40000.00, '01:05:00', 1),
('Lavado de motor', 'Lavado de motor completo', 58000.00, '01:40:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 15000.00, '00:25:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 26000.00, '00:42:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 82000.00, '02:20:00', 1),
('Lavado de motor', 'Lavado de motor completo', 45000.00, '01:25:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 24000.00, '00:50:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 31000.00, '00:48:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 118000.00, '02:55:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado de motor', 'Lavado de motor completo', 55000.00, '01:45:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 10000.00, '00:15:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 25000.00, '00:45:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 80000.00, '02:30:00', 1),
('Lavado de motor', 'Lavado de motor completo', 40000.00, '01:15:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 20000.00, '00:40:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 30000.00, '00:50:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 120000.00, '03:00:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 20000.00, '00:30:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 40000.00, '01:05:00', 1),
('Lavado de motor', 'Lavado de motor completo', 58000.00, '01:40:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 15000.00, '00:25:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 26000.00, '00:42:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 82000.00, '02:20:00', 1),
('Lavado de motor', 'Lavado de motor completo', 45000.00, '01:25:00', 1),
('Lavado, desmanchada y brillada.', 'Lavado todo incluido', 24000.00, '00:50:00', 1),
('Lavado de cabina exterior', 'Lavado de cabina exterior básica del vehículo', 31000.00, '00:48:00', 1),
('Lavado de cabina exterior e interior', 'Limpieza exterior e interior completa', 118000.00, '02:55:00', 1);

-- =====================================================
-- INSERTS PARA USUARIO
-- =====================================================
INSERT INTO USUARIO (nombre_usuario, documento, contraseña, nombre, apellidos, telefono, estado) VALUES
('jperez', '1234567890', 'hash123', 'Juan', 'Pérez García', '3001234567', 'activo'),
('mrodriguez', '0987654321', 'hash456', 'María', 'Rodríguez López', '3109876543', 'activo'),
('cgarcia', '1122334455', 'hash789', 'Carlos', 'García Martínez', '3201122334', 'activo'),
('amartinez', '5544332211', 'hash321', 'Ana', 'Martínez Sánchez', '3115544332', 'activo'),
('lhernandez', '6677889900', 'hash654', 'Luis', 'Hernández Díaz', '3206677889', 'activo'),
('slopez', '9988776655', 'hash987', 'Sandra', 'López Ramírez', '3109988776', 'activo'),
('dgomez', '1231231234', 'hash111', 'Diego', 'Gómez Torres', '3001231231', 'activo'),
('pcastro', '4564564567', 'hash222', 'Patricia', 'Castro Vargas', '3154564564', 'activo'),
('rmoreno', '7897897890', 'hash333', 'Roberto', 'Moreno Ruiz', '3207897897', 'activo'),
('msuarez', '3213213210', 'hash444', 'Mónica', 'Suárez Ortiz', '3113213213', 'activo'),
('jramirez', '1357913579', 'hash555', 'Jorge', 'Ramírez Castillo', '3001357913', 'activo'),
('acortes', '2468024680', 'hash666', 'Andrea', 'Cortés Mejía', '3102468024', 'activo'),
('farias', '1123581321', 'hash777', 'Fernando', 'Arias Pardo', '3201123581', 'activo'),
('nfernandez', '3141592653', 'hash888', 'Natalia', 'Fernández Ríos', '3113141592', 'activo'),
('hrojas', '2718281828', 'hash999', 'Hernán', 'Rojas Peña', '3152718281', 'activo'),
('vtorres', '1618033988', 'hash101', 'Valeria', 'Torres Guzmán', '3001618033', 'activo'),
('jcastillo', '1414213562', 'hash202', 'Julio', 'Castillo Herrera', '3101414213', 'activo'),
('mjimenez', '1732050807', 'hash303', 'Marcela', 'Jiménez Soto', '3201732050', 'activo'),
('rnavarro', '2236067977', 'hash404', 'Ricardo', 'Navarro León', '3112236067', 'activo'),
('pgutierrez', '2449489742', 'hash505', 'Paola', 'Gutiérrez Silva', '3152449489', 'activo'),
('druiz', '3162277660', 'hash606', 'Daniel', 'Ruiz Romero', '3003162277', 'activo'),
('lvalencia', '3542484510', 'hash707', 'Laura', 'Valencia Cárdenas', '3103542484', 'activo'),
('osanchez', '3741657386', 'hash808', 'Oscar', 'Sánchez Molina', '3203741657', 'activo'),
('kmedina', '4242640687', 'hash909', 'Karen', 'Medina Duarte', '3114242640', 'activo'),
('jortega', '4472135954', 'hash121', 'Julián', 'Ortega Salas', '3154472135', 'activo'),
('mfuentes', '4582575694', 'hash131', 'Mauricio', 'Fuentes Cabrera', '3004582575', 'activo'),
('cdominguez', '4690415759', 'hash141', 'Claudia', 'Domínguez Lara', '3104690415', 'activo'),
('agonzalez', '4795831523', 'hash151', 'Andrés', 'González Vega', '3204795831', 'activo'),
('ycastro', '4898979485', 'hash161', 'Yolanda', 'Castro Pineda', '3114898979', 'activo'),
('jarias', '5000000000', 'hash171', 'José', 'Arias Correa', '3155000000', 'activo'),
('mcastro', '5105105105', 'hash181', 'Marcela', 'Castro Jiménez', '3005105105', 'activo'),
('jcorrea', '5205205205', 'hash191', 'Julián', 'Correa Vargas', '3105205205', 'activo'),
('rvera', '5305305305', 'hash201', 'Raúl', 'Vera Montoya', '3205305305', 'activo'),
('lospina', '5405405405', 'hash211', 'Lorena', 'Ospina Roldán', '3115405405', 'activo'),
('dmejia', '5505505505', 'hash221', 'David', 'Mejía Cano', '3155505505', 'activo'),
('jarias', '5605605605', 'hash231', 'Jimena', 'Arias Salgado', '3005605605', 'activo'),
('fmontoya', '5705705705', 'hash241', 'Felipe', 'Montoya Pérez', '3105705705', 'activo'),
('cvalencia', '5805805805', 'hash251', 'Camila', 'Valencia Torres', '3205805805', 'activo'),
('hgutierrez', '5905905905', 'hash261', 'Hugo', 'Gutiérrez Ramírez', '3115905905', 'activo'),
('pfernandez', '6006006006', 'hash271', 'Paula', 'Fernández Díaz', '3156006006', 'activo'),
('jlozano', '6106106106', 'hash281', 'Jorge', 'Lozano Herrera', '3006106106', 'activo'),
('mramirez', '6206206206', 'hash291', 'Marta', 'Ramírez Salas', '3106206206', 'activo'),
('gcardenas', '6306306306', 'hash301', 'Gabriel', 'Cárdenas Ríos', '3206306306', 'activo'),
('nrodriguez', '6406406406', 'hash311', 'Nicolás', 'Rodríguez Peña', '3116406406', 'activo'),
('lmartinez', '6506506506', 'hash321', 'Lucía', 'Martínez Guzmán', '3156506506', 'activo'),
('dtorres', '6606606606', 'hash331', 'Diego', 'Torres Molina', '3006606606', 'activo'),
('jmoreno', '6706706706', 'hash341', 'Juliana', 'Moreno Duarte', '3106706706', 'activo'),
('rgarcia', '6806806806', 'hash351', 'Rodrigo', 'García Silva', '3206806806', 'activo'),
('marias', '6906906906', 'hash361', 'Marisol', 'Arias Cabrera', '3116906906', 'activo'),
('fhernandez', '7007007007', 'hash371', 'Francisco', 'Hernández Vega', '3157007007', 'activo'),
('jmunoz', '7107107107', 'hash381', 'Javier', 'Muñoz Herrera', '3007107107', 'activo'),
('marias', '7207207207', 'hash391', 'María', 'Arias López', '3107207207', 'activo'),
('fcastillo', '7307307307', 'hash401', 'Felipe', 'Castillo Gómez', '3207307307', 'activo'),
('nrojas', '7407407407', 'hash411', 'Nora', 'Rojas Díaz', '3117407407', 'activo'),
('hvalencia', '7507507507', 'hash421', 'Héctor', 'Valencia Ruiz', '3157507507', 'activo'),
('pcano', '7607607607', 'hash431', 'Paola', 'Cano Torres', '3007607607', 'activo'),
('jramirez', '7707707707', 'hash441', 'José', 'Ramírez Salas', '3107707707', 'activo'),
('mfernandez', '7807807807', 'hash451', 'Mónica', 'Fernández Vega', '3207807807', 'activo'),
('rcardenas', '7907907907', 'hash461', 'Ricardo', 'Cárdenas Peña', '3117907907', 'activo'),
('lortega', '8008008008', 'hash471', 'Laura', 'Ortega Guzmán', '3158008008', 'activo'),
('dlopez', '8108108108', 'hash481', 'Daniel', 'López Herrera', '3008108108', 'activo'),
('jtorres', '8208208208', 'hash491', 'Juliana', 'Torres Molina', '3108208208', 'activo'),
('mrodriguez', '8308308308', 'hash501', 'Mauricio', 'Rodríguez Duarte', '3208308308', 'activo'),
('cjimenez', '8408408408', 'hash511', 'Claudia', 'Jiménez Silva', '3118408408', 'activo'),
('agonzalez', '8508508508', 'hash521', 'Andrés', 'González Cabrera', '3158508508', 'activo'),
('ycastillo', '8608608608', 'hash531', 'Yolanda', 'Castillo Vega', '3008608608', 'activo'),
('jarias', '8708708708', 'hash541', 'Jorge', 'Arias Correa', '3108708708', 'activo'),
('mvalencia', '8808808808', 'hash551', 'Marcela', 'Valencia Pardo', '3208808808', 'activo'),
('rnavarro', '8908908908', 'hash561', 'Roberto', 'Navarro León', '3118908908', 'activo'),
('pgutierrez', '9009009009', 'hash571', 'Patricia', 'Gutiérrez Silva', '3159009009', 'activo'),
('druiz', '9109109109', 'hash581', 'Diego', 'Ruiz Romero', '3009109109', 'activo'),
('lvalencia', '9209209209', 'hash591', 'Lucía', 'Valencia Cárdenas', '3109209209', 'activo'),
('osanchez', '9309309309', 'hash601', 'Oscar', 'Sánchez Molina', '3209309309', 'activo'),
('kmedina', '9409409409', 'hash611', 'Karen', 'Medina Duarte', '3119409409', 'activo'),
('jortega', '9509509509', 'hash621', 'Julián', 'Ortega Salas', '3159509509', 'activo'),
('mfuentes', '9609609609', 'hash631', 'Mauricio', 'Fuentes Cabrera', '3009609609', 'activo'),
('cdominguez', '9709709709', 'hash641', 'Claudia', 'Domínguez Lara', '3109709709', 'activo'),
('agonzalez2', '9809809809', 'hash651', 'Alejandro', 'González Vega', '3209809809', 'activo'),
('ycastro', '9909909909', 'hash661', 'Yolanda', 'Castro Pineda', '3119909909', 'activo'),
('jarias2', '1000100010', 'hash671', 'José', 'Arias Correa', '3151000100', 'activo'),
('mcastro', '1010101010', 'hash681', 'Marcela', 'Castro Jiménez', '3001010101', 'activo'),
('jcorrea', '1020102010', 'hash691', 'Julián', 'Correa Vargas', '3101020102', 'activo'),
('rvera', '1030103010', 'hash701', 'Raúl', 'Vera Montoya', '3201030103', 'activo'),
('lospina', '1040104010', 'hash711', 'Lorena', 'Ospina Roldán', '3111040104', 'activo'),
('dmejia', '1050105010', 'hash721', 'David', 'Mejía Cano', '3151050105', 'activo'),
('jarias3', '1060106010', 'hash731', 'Jimena', 'Arias Salgado', '3001060106', 'activo'),
('fmontoya', '1070107010', 'hash741', 'Felipe', 'Montoya Pérez', '3101070107', 'activo'),
('cvalencia', '1080108010', 'hash751', 'Camila', 'Valencia Torres', '3201080108', 'activo'),
('hgutierrez', '1090109010', 'hash761', 'Hugo', 'Gutiérrez Ramírez', '3111090109', 'activo'),
('pfernandez', '1100110011', 'hash771', 'Paula', 'Fernández Díaz', '3151100110', 'activo'),
('jlozano', '1110111011', 'hash781', 'Jorge', 'Lozano Herrera', '3001110111', 'activo'),
('mramirez', '1120112011', 'hash791', 'Marta', 'Ramírez Salas', '3101120112', 'activo'),
('gcardenas', '1130113011', 'hash801', 'Gabriel', 'Cárdenas Ríos', '3201130113', 'activo'),
('nrodriguez', '1140114011', 'hash811', 'Nicolás', 'Rodríguez Peña', '3111140114', 'activo'),
('lmartinez', '1150115011', 'hash821', 'Lucía', 'Martínez Guzmán', '3151150115', 'activo'),
('dtorres', '1160116011', 'hash831', 'Diego', 'Torres Molina', '3001160116', 'activo'),
('jmoreno', '1170117011', 'hash841', 'Juliana', 'Moreno Duarte', '3101170117', 'activo'),
('rgarcia', '1180118011', 'hash851', 'Rodrigo', 'García Silva', '3201180118', 'activo'),
('marias2', '1190119011', 'hash861', 'Marisol', 'Arias Cabrera', '3111190119', 'activo'),
('fhernandez', '1200120012', 'hash871', 'Francisco', 'Hernández Vega', '3151200120', 'activo');

-- =====================================================
-- INSERTS PARA GERENTE (20 GERENTES)
-- =====================================================
INSERT INTO GERENTE (id_usuario, fecha_inicio_gestion) VALUES
(17, '2023-02-10'),
(45, '2023-04-05'),
(63, '2023-05-12'),
(8, '2023-06-01'),
(29, '2023-07-18'),
(92, '2023-08-25'),
(34, '2023-09-03'),
(76, '2023-10-14'),
(55, '2023-11-20'),
(11, '2023-12-30'),
(88, '2024-01-09'),
(23, '2024-02-15'),
(39, '2024-03-22'),
(70, '2024-04-28'),
(5, '2024-05-06'),
(97, '2024-06-19'),
(41, '2024-07-25'),
(14, '2024-08-31'),
(62, '2024-09-07'),
(81, '2024-10-15');

-- =====================================================
-- INSERTS PARA ADMINISTRADOR (20 ADMINISTRADORES)
-- =====================================================
INSERT INTO ADMINISTRADOR (id_usuario, nivel_acceso) VALUES
(3, 5),
(4, 4),
(6, 2),
(9, 3),
(12, 5),
(15, 4),
(19, 1),
(21, 2),
(24, 3),
(27, 5),
(30, 4),
(32, 2),
(36, 1),
(40, 3),
(43, 5),
(46, 4),
(50, 2),
(53, 1),
(57, 3),
(61, 5);

-- =====================================================
-- INSERTS PARA SUPERVISOR (20 SUPERVISORES)
-- =====================================================
INSERT INTO SUPERVISOR (id_usuario, fecha_inicio_gestion, nivel_acceso, area_responsable) VALUES
(5, '2023-06-01', 3, 'Parqueadero'),
(6, '2023-07-15', 3, 'Lavado'),
(1, '2023-01-20', 4, 'Parqueadero'),
(2, '2023-02-10', 2, 'Lavado'),
(7, '2023-03-05', 3, 'Caja'),
(9, '2023-04-12', 5, 'Recepción'),
(13, '2023-05-18', 2, 'Parqueadero'),
(16, '2023-06-25', 4, 'Lavado'),
(20, '2023-07-30', 3, 'Caja'),
(26, '2023-08-14', 1, 'Recepción'),
(28, '2023-09-02', 2, 'Parqueadero'),
(33, '2023-10-10', 5, 'Lavado'),
(37, '2023-11-21', 3, 'Caja'),
(42, '2023-12-05', 4, 'Recepción'),
(44, '2024-01-15', 2, 'Parqueadero'),
(47, '2024-02-20', 1, 'Lavado'),
(49, '2024-03-12', 3, 'Caja'),
(51, '2024-04-25', 5, 'Recepción'),
(54, '2024-05-30', 2, 'Parqueadero'),
(58, '2024-06-18', 4, 'Lavado');

-- =====================================================
-- SEDE
-- =====================================================
SET IDENTITY_INSERT SEDE ON;
GO

INSERT INTO SEDE (id_sede, nombre, capacidad_total, horario_apertura, horario_cierre, telefono, ciudad, direccion, id_gerente) VALUES
(1, 'Sede El Poblado', 250, '06:00:00', '22:00:00', '6043001000', 'Medellín', 'Calle 10 # 43A-30, El Poblado', 1),
(2, 'Sede Laureles', 230, '06:00:00', '22:00:00', '6043001001', 'Medellín', 'Carrera 70 # 45-20, Laureles', 2),
(3, 'Sede El Poblado - Torre Norte', 120, '06:00:00', '22:00:00', '6043001002', 'Medellín', 'Calle 10 # 43A-30 Torre Norte', 1),
(4, 'Sede El Poblado - Torre Sur', 130, '06:00:00', '22:00:00', '6043001003', 'Medellín', 'Calle 10 # 43A-30 Torre Sur', 1),
(5, 'Sede Laureles - Edificio A', 115, '06:00:00', '22:00:00', '6043001004', 'Medellín', 'Carrera 70 # 45-20 Edificio A', 2),
(6, 'Sede Laureles - Edificio B', 115, '06:00:00', '22:00:00', '6043001005', 'Medellín', 'Carrera 70 # 45-20 Edificio B', 2),
(7, 'Sede El Poblado - Nivel 1', 60, '06:00:00', '22:00:00', '6043001006', 'Medellín', 'Calle 10 # 43A-30 Nivel 1', 1),
(8, 'Sede El Poblado - Nivel 2', 60, '06:00:00', '22:00:00', '6043001007', 'Medellín', 'Calle 10 # 43A-30 Nivel 2', 1),
(9, 'Sede Laureles - Piso 1', 58, '06:00:00', '22:00:00', '6043001008', 'Medellín', 'Carrera 70 # 45-20 Piso 1', 2),
(10, 'Sede Laureles - Piso 2', 57, '06:00:00', '22:00:00', '6043001009', 'Medellín', 'Carrera 70 # 45-20 Piso 2', 2),
(11, 'Sede El Poblado - Sección VIP', 45, '06:00:00', '22:00:00', '6043001010', 'Medellín', 'Calle 10 # 43A-30 VIP', 1),
(12, 'Sede Laureles - Zona Premium', 42, '06:00:00', '22:00:00', '6043001011', 'Medellín', 'Carrera 70 # 45-20 Premium', 2),
(13, 'Sede El Poblado - Motos', 35, '06:00:00', '22:00:00', '6043001012', 'Medellín', 'Calle 10 # 43A-30 Motos', 1),
(14, 'Sede Laureles - Motos', 33, '06:00:00', '22:00:00', '6043001013', 'Medellín', 'Carrera 70 # 45-20 Motos', 2),
(15, 'Sede El Poblado - Bicicletas', 25, '06:00:00', '22:00:00', '6043001014', 'Medellín', 'Calle 10 # 43A-30 Bicicletas', 1),
(16, 'Sede Laureles - Bicicletas', 23, '06:00:00', '22:00:00', '6043001015', 'Medellín', 'Carrera 70 # 45-20 Bicicletas', 2),
(17, 'Sede El Poblado - Lavado', 40, '07:00:00', '20:00:00', '6043001016', 'Medellín', 'Calle 10 # 43A-30 Lavado', 1),
(18, 'Sede Laureles - Lavado', 38, '07:00:00', '20:00:00', '6043001017', 'Medellín', 'Carrera 70 # 45-20 Lavado', 2),
(19, 'Sede El Poblado - Express', 50, '06:00:00', '22:00:00', '6043001018', 'Medellín', 'Calle 10 # 43A-30 Express', 1),
(20, 'Sede Laureles - Express', 48, '06:00:00', '22:00:00', '6043001019', 'Medellín', 'Carrera 70 # 45-20 Express', 2),
(21, 'Sede El Poblado - Zona A1', 30, '06:00:00', '22:00:00', '6043001020', 'Medellín', 'Calle 10 # 43A-30 Zona A1', 1),
(22, 'Sede El Poblado - Zona A2', 30, '06:00:00', '22:00:00', '6043001021', 'Medellín', 'Calle 10 # 43A-30 Zona A2', 1),
(23, 'Sede Laureles - Zona B1', 28, '06:00:00', '22:00:00', '6043001022', 'Medellín', 'Carrera 70 # 45-20 Zona B1', 2),
(24, 'Sede Laureles - Zona B2', 28, '06:00:00', '22:00:00', '6043001023', 'Medellín', 'Carrera 70 # 45-20 Zona B2', 2),
(25, 'Sede El Poblado - Corporativo', 55, '06:00:00', '22:00:00', '6043001024', 'Medellín', 'Calle 10 # 43A-30 Corporativo', 1),
(26, 'Sede Laureles - Empresarial', 52, '06:00:00', '22:00:00', '6043001025', 'Medellín', 'Carrera 70 # 45-20 Empresarial', 2),
(27, 'Sede El Poblado - Residencial', 48, '06:00:00', '22:00:00', '6043001026', 'Medellín', 'Calle 10 # 43A-30 Residencial', 1),
(28, 'Sede Laureles - Residencial', 46, '06:00:00', '22:00:00', '6043001027', 'Medellín', 'Carrera 70 # 45-20 Residencial', 2),
(29, 'Sede El Poblado - Eléctricos', 20, '06:00:00', '22:00:00', '6043001028', 'Medellín', 'Calle 10 # 43A-30 Eléctricos', 1),
(30, 'Sede Laureles - Eléctricos', 18, '06:00:00', '22:00:00', '6043001029', 'Medellín', 'Carrera 70 # 45-20 Eléctricos', 2),
(31, 'Sede El Poblado - 24 Horas', 65, '00:00:00', '23:59:00', '6043001030', 'Medellín', 'Calle 10 # 43A-30 24H', 1),
(32, 'Sede Laureles - 24 Horas', 62, '00:00:00', '23:59:00', '6043001031', 'Medellín', 'Carrera 70 # 45-20 24H', 2),
(33, 'Sede El Poblado - Cubierto', 75, '06:00:00', '22:00:00', '6043001032', 'Medellín', 'Calle 10 # 43A-30 Cubierto', 1),
(34, 'Sede Laureles - Cubierto', 72, '06:00:00', '22:00:00', '6043001033', 'Medellín', 'Carrera 70 # 45-20 Cubierto', 2),
(35, 'Sede El Poblado - Descubierto', 70, '06:00:00', '22:00:00', '6043001034', 'Medellín', 'Calle 10 # 43A-30 Descubierto', 1),
(36, 'Sede Laureles - Descubierto', 68, '06:00:00', '22:00:00', '6043001035', 'Medellín', 'Carrera 70 # 45-20 Descubierto', 2),
(37, 'Sede El Poblado - Camiones', 15, '06:00:00', '22:00:00', '6043001036', 'Medellín', 'Calle 10 # 43A-30 Camiones', 1),
(38, 'Sede Laureles - Camiones', 14, '06:00:00', '22:00:00', '6043001037', 'Medellín', 'Carrera 70 # 45-20 Camiones', 2),
(39, 'Sede El Poblado - SUV', 40, '06:00:00', '22:00:00', '6043001038', 'Medellín', 'Calle 10 # 43A-30 SUV', 1),
(40, 'Sede Laureles - SUV', 38, '06:00:00', '22:00:00', '6043001039', 'Medellín', 'Carrera 70 # 45-20 SUV', 2),
(41, 'Sede El Poblado - Compactos', 45, '06:00:00', '22:00:00', '6043001040', 'Medellín', 'Calle 10 # 43A-30 Compactos', 1),
(42, 'Sede Laureles - Compactos', 43, '06:00:00', '22:00:00', '6043001041', 'Medellín', 'Carrera 70 # 45-20 Compactos', 2),
(43, 'Sede El Poblado - Sedanes', 42, '06:00:00', '22:00:00', '6043001042', 'Medellín', 'Calle 10 # 43A-30 Sedanes', 1),
(44, 'Sede Laureles - Sedanes', 40, '06:00:00', '22:00:00', '6043001043', 'Medellín', 'Carrera 70 # 45-20 Sedanes', 2),
(45, 'Sede El Poblado - Vans', 22, '06:00:00', '22:00:00', '6043001044', 'Medellín', 'Calle 10 # 43A-30 Vans', 1),
(46, 'Sede Laureles - Vans', 20, '06:00:00', '22:00:00', '6043001045', 'Medellín', 'Carrera 70 # 45-20 Vans', 2),
(47, 'Sede El Poblado - Pickups', 28, '06:00:00', '22:00:00', '6043001046', 'Medellín', 'Calle 10 # 43A-30 Pickups', 1),
(48, 'Sede Laureles - Pickups', 26, '06:00:00', '22:00:00', '6043001047', 'Medellín', 'Carrera 70 # 45-20 Pickups', 2),
(49, 'Sede El Poblado - Premium Plus', 35, '06:00:00', '22:00:00', '6043001048', 'Medellín', 'Calle 10 # 43A-30 Premium Plus', 1),
(50, 'Sede Laureles - Premium Plus', 33, '06:00:00', '22:00:00', '6043001049', 'Medellín', 'Carrera 70 # 45-20 Premium Plus', 2),
(51, 'Sede El Poblado - Standard', 55, '06:00:00', '22:00:00', '6043001050', 'Medellín', 'Calle 10 # 43A-30 Standard', 1),
(52, 'Sede Laureles - Standard', 53, '06:00:00', '22:00:00', '6043001051', 'Medellín', 'Carrera 70 # 45-20 Standard', 2),
(53, 'Sede El Poblado - Economy', 50, '06:00:00', '22:00:00', '6043001052', 'Medellín', 'Calle 10 # 43A-30 Economy', 1),
(54, 'Sede Laureles - Economy', 48, '06:00:00', '22:00:00', '6043001053', 'Medellín', 'Carrera 70 # 45-20 Economy', 2),
(55, 'Sede El Poblado - Visitantes', 44, '06:00:00', '22:00:00', '6043001054', 'Medellín', 'Calle 10 # 43A-30 Visitantes', 1),
(56, 'Sede Laureles - Visitantes', 42, '06:00:00', '22:00:00', '6043001055', 'Medellín', 'Carrera 70 # 45-20 Visitantes', 2),
(57, 'Sede El Poblado - Mensualidades', 80, '06:00:00', '22:00:00', '6043001056', 'Medellín', 'Calle 10 # 43A-30 Mensualidades', 1),
(58, 'Sede Laureles - Mensualidades', 78, '06:00:00', '22:00:00', '6043001057', 'Medellín', 'Carrera 70 # 45-20 Mensualidades', 2),
(59, 'Sede El Poblado - Ocasional', 85, '06:00:00', '22:00:00', '6043001058', 'Medellín', 'Calle 10 # 43A-30 Ocasional', 1),
(60, 'Sede Laureles - Ocasional', 82, '06:00:00', '22:00:00', '6043001059', 'Medellín', 'Carrera 70 # 45-20 Ocasional', 2),
(61, 'Sede El Poblado - Sótano 1', 65, '06:00:00', '22:00:00', '6043001060', 'Medellín', 'Calle 10 # 43A-30 Sótano 1', 1),
(62, 'Sede Laureles - Sótano 1', 62, '06:00:00', '22:00:00', '6043001061', 'Medellín', 'Carrera 70 # 45-20 Sótano 1', 2),
(63, 'Sede El Poblado - Sótano 2', 60, '06:00:00', '22:00:00', '6043001062', 'Medellín', 'Calle 10 # 43A-30 Sótano 2', 1),
(64, 'Sede Laureles - Sótano 2', 58, '06:00:00', '22:00:00', '6043001063', 'Medellín', 'Carrera 70 # 45-20 Sótano 2', 2),
(65, 'Sede El Poblado - Primer Piso', 70, '06:00:00', '22:00:00', '6043001064', 'Medellín', 'Calle 10 # 43A-30 Primer Piso', 1),
(66, 'Sede Laureles - Primer Piso', 68, '06:00:00', '22:00:00', '6043001065', 'Medellín', 'Carrera 70 # 45-20 Primer Piso', 2),
(67, 'Sede El Poblado - Segundo Piso', 65, '06:00:00', '22:00:00', '6043001066', 'Medellín', 'Calle 10 # 43A-30 Segundo Piso', 1),
(68, 'Sede Laureles - Segundo Piso', 63, '06:00:00', '22:00:00', '6043001067', 'Medellín', 'Carrera 70 # 45-20 Segundo Piso', 2),
(69, 'Sede El Poblado - Tercer Piso', 55, '06:00:00', '22:00:00', '6043001068', 'Medellín', 'Calle 10 # 43A-30 Tercer Piso', 1),
(70, 'Sede Laureles - Tercer Piso', 53, '06:00:00', '22:00:00', '6043001069', 'Medellín', 'Carrera 70 # 45-20 Tercer Piso', 2),
(71, 'Sede El Poblado - Ala Este', 38, '06:00:00', '22:00:00', '6043001070', 'Medellín', 'Calle 10 # 43A-30 Ala Este', 1),
(72, 'Sede Laureles - Ala Este', 36, '06:00:00', '22:00:00', '6043001071', 'Medellín', 'Carrera 70 # 45-20 Ala Este', 2),
(73, 'Sede El Poblado - Ala Oeste', 38, '06:00:00', '22:00:00', '6043001072', 'Medellín', 'Calle 10 # 43A-30 Ala Oeste', 1),
(74, 'Sede Laureles - Ala Oeste', 36, '06:00:00', '22:00:00', '6043001073', 'Medellín', 'Carrera 70 # 45-20 Ala Oeste', 2),
(75, 'Sede El Poblado - Ala Norte', 40, '06:00:00', '22:00:00', '6043001074', 'Medellín', 'Calle 10 # 43A-30 Ala Norte', 1),
(76, 'Sede Laureles - Ala Norte', 38, '06:00:00', '22:00:00', '6043001075', 'Medellín', 'Carrera 70 # 45-20 Ala Norte', 2),
(77, 'Sede El Poblado - Ala Sur', 40, '06:00:00', '22:00:00', '6043001076', 'Medellín', 'Calle 10 # 43A-30 Ala Sur', 1),
(78, 'Sede Laureles - Ala Sur', 38, '06:00:00', '22:00:00', '6043001077', 'Medellín', 'Carrera 70 # 45-20 Ala Sur', 2),
(79, 'Sede El Poblado - Sector A', 32, '06:00:00', '22:00:00', '6043001078', 'Medellín', 'Calle 10 # 43A-30 Sector A', 1),
(80, 'Sede Laureles - Sector A', 30, '06:00:00', '22:00:00', '6043001079', 'Medellín', 'Carrera 70 # 45-20 Sector A', 2),
(81, 'Sede El Poblado - Sector B', 32, '06:00:00', '22:00:00', '6043001080', 'Medellín', 'Calle 10 # 43A-30 Sector B', 1),
(82, 'Sede Laureles - Sector B', 30, '06:00:00', '22:00:00', '6043001081', 'Medellín', 'Carrera 70 # 45-20 Sector B', 2),
(83, 'Sede El Poblado - Sector C', 32, '06:00:00', '22:00:00', '6043001082', 'Medellín', 'Calle 10 # 43A-30 Sector C', 1),
(84, 'Sede Laureles - Sector C', 30, '06:00:00', '22:00:00', '6043001083', 'Medellín', 'Carrera 70 # 45-20 Sector C', 2),
(85, 'Sede El Poblado - Preferencial', 28, '06:00:00', '22:00:00', '6043001084', 'Medellín', 'Calle 10 # 43A-30 Preferencial', 1),
(86, 'Sede Laureles - Preferencial', 26, '06:00:00', '22:00:00', '6043001085', 'Medellín', 'Carrera 70 # 45-20 Preferencial', 2),
(87, 'Sede El Poblado - Reservado', 24, '06:00:00', '22:00:00', '6043001086', 'Medellín', 'Calle 10 # 43A-30 Reservado', 1),
(88, 'Sede Laureles - Reservado', 22, '06:00:00', '22:00:00', '6043001087', 'Medellín', 'Carrera 70 # 45-20 Reservado', 2),
(89, 'Sede El Poblado - Rotativo', 52, '06:00:00', '22:00:00', '6043001088', 'Medellín', 'Calle 10 # 43A-30 Rotativo', 1),
(90, 'Sede Laureles - Rotativo', 50, '06:00:00', '22:00:00', '6043001089', 'Medellín', 'Carrera 70 # 45-20 Rotativo', 2),
(91, 'Sede El Poblado - Rápido', 46, '06:00:00', '22:00:00', '6043001090', 'Medellín', 'Calle 10 # 43A-30 Rápido', 1),
(92, 'Sede Laureles - Rápido', 44, '06:00:00', '22:00:00', '6043001091', 'Medellín', 'Carrera 70 # 45-20 Rápido', 2),
(93, 'Sede El Poblado - Corta Estancia', 48, '06:00:00', '22:00:00', '6043001092', 'Medellín', 'Calle 10 # 43A-30 Corta Estancia', 1),
(94, 'Sede Laureles - Corta Estancia', 46, '06:00:00', '22:00:00', '6043001093', 'Medellín', 'Carrera 70 # 45-20 Corta Estancia', 2),
(95, 'Sede El Poblado - Larga Estancia', 36, '06:00:00', '22:00:00', '6043001094', 'Medellín', 'Calle 10 # 43A-30 Larga Estancia', 1),
(96, 'Sede Laureles - Larga Estancia', 34, '06:00:00', '22:00:00', '6043001095', 'Medellín', 'Carrera 70 # 45-20 Larga Estancia', 2),
(97, 'Sede El Poblado - Vigilancia Plus', 42, '06:00:00', '22:00:00', '6043001096', 'Medellín', 'Calle 10 # 43A-30 Vigilancia Plus', 1),
(98, 'Sede Laureles - Vigilancia Plus', 40, '06:00:00', '22:00:00', '6043001097', 'Medellín', 'Carrera 70 # 45-20 Vigilancia Plus', 2),
(99, 'Sede El Poblado - Seguridad Max', 38, '06:00:00', '22:00:00', '6043001098', 'Medellín', 'Calle 10 # 43A-30 Seguridad Max', 1),
(100, 'Sede Laureles - Seguridad Max', 36, '06:00:00', '22:00:00', '6043001099', 'Medellín', 'Carrera 70 # 45-20 Seguridad Max', 2);
SET IDENTITY_INSERT SEDE OFF;
GO
-- =====================================================
-- INSERTS PARA OPERARIO (20 OPERARIOS)
-- =====================================================
INSERT INTO OPERARIO (id_usuario, fecha_inicio, id_supervisor, id_parqueo) VALUES
(65, '2024-01-10', 5, NULL),
(66, '2024-02-15', 5, NULL),
(71, '2024-03-01', 6, NULL),
(72, '2024-03-20', 6, NULL),
(73, '2024-04-05', 7, NULL),
(75, '2024-04-22', 7, NULL),
(77, '2024-05-10', 9, NULL),
(78, '2024-05-25', 9, NULL),
(79, '2024-06-12', 13, NULL),
(80, '2024-06-28', 13, NULL),
(82, '2024-07-15', 16, NULL),
(83, '2024-07-30', 16, NULL),
(84, '2024-08-18', 20, NULL),
(85, '2024-09-02', 20, NULL),
(86, '2024-09-20', 26, NULL),
(87, '2024-10-05', 26, NULL),
(89, '2024-10-22', 28, NULL),
(90, '2024-11-08', 28, NULL),
(91, '2024-11-25', 33, NULL),
(93, '2024-12-10', 33, NULL);

-- =====================================================
-- INSERTS PARA LAVADOR (20 LAVADORES)
-- =====================================================
INSERT INTO LAVADOR (id_usuario, fecha_inicio_gestion, cantidad_servicios, especialidad_lavado, id_sede) VALUES
(9, '2024-03-01', 45, 'Pulido', 1),
(10, '2024-04-01', 38, 'Tapicería', 2),
(67, '2024-05-10', 52, 'Encerado', 15),
(68, '2024-05-25', 40, 'Lavado Exterior', 23),
(69, '2024-06-12', 33, 'Lavado Interior', 37),
(94, '2024-06-28', 29, 'Pulido', 42),
(96, '2024-07-15', 61, 'Tapicería', 56),
(98, '2024-07-30', 47, 'Lavado Completo', 64),
(99, '2024-08-18', 36, 'Encerado', 72),
(100, '2024-09-02', 55, 'Lavado Motor', 81),
(73, '2024-09-20', 44, 'Pulido', 88),
(74, '2024-10-05', 39, 'Lavado Interior', 95),
(75, '2024-10-22', 28, 'Tapicería', 12),
(82, '2024-11-08', 31, 'Lavado Exterior', 25),
(83, '2024-11-25', 50, 'Lavado Completo', 33),
(84, '2024-12-10', 46, 'Encerado', 47),
(85, '2024-12-28', 42, 'Pulido', 59),
(86, '2025-01-15', 37, 'Lavado Motor', 68),
(87, '2025-02-01', 53, 'Tapicería', 77),
(90, '2025-02-20', 41, 'Lavado Completo', 99);

-- =====================================================
-- INSERTS PARA CLIENTE
-- =====================================================
INSERT INTO CLIENTE (nombre, apellido, documento, telefono, direccion, correo) VALUES
('Andrés', 'Ramírez', '1010101010', '3121010101', 'Calle 45 #23-10', 'andres.ramirez@email.com'),
('Laura', 'Morales', '2020202020', '3132020202', 'Carrera 70 #45-30', 'laura.morales@email.com'),
('Felipe', 'Gutiérrez', '3030303030', '3143030303', 'Avenida 80 #12-50', 'felipe.gutierrez@email.com'),
('Valentina', 'Castro', '4040404040', '3154040404', 'Calle 127 #54-20', 'valentina.castro@email.com'),
('Santiago', 'Rojas', '5050505050', '3165050505', 'Carrera 15 #88-40', 'santiago.rojas@email.com'),
('Camila', 'Ospina', '6060606060', '3176060606', 'Calle 53 #30-15', 'camila.ospina@email.com'),
('Mateo', 'Vargas', '7070707070', '3187070707', 'Avenida 68 #25-80', 'mateo.vargas@email.com'),
('Isabella', 'Mendoza', '8080808080', '3198080808', 'Carrera 7 #100-30', 'isabella.mendoza@email.com'),
('Sebastián', 'Parra', '9090909090', '3209090909', 'Calle 85 #15-25', 'sebastian.parra@email.com'),
('Sofía', 'Reyes', '1212121212', '3111212121', 'Avenida 19 #120-45', 'sofia.reyes@email.com'),
('Daniel', 'Suárez', '1313131313', '3121313131', 'Calle 10 #20-30', 'daniel.suarez@email.com'),
('Mariana', 'Gómez', '1414141414', '3131414141', 'Carrera 25 #15-40', 'mariana.gomez@email.com'),
('Juan', 'Pardo', '1515151515', '3141515151', 'Avenida 33 #45-22', 'juan.pardo@email.com'),
('Lucía', 'Salazar', '1616161616', '3151616161', 'Calle 50 #12-18', 'lucia.salazar@email.com'),
('Pedro', 'Mejía', '1717171717', '3161717171', 'Carrera 12 #34-56', 'pedro.mejia@email.com'),
('Carolina', 'Torres', '1818181818', '3171818181', 'Avenida 80 #20-10', 'carolina.torres@email.com'),
('Andrés', 'Cárdenas', '1919191919', '3181919191', 'Calle 60 #18-22', 'andres.cardenas@email.com'),
('Valeria', 'López', '2121212121', '3192121212', 'Carrera 45 #22-33', 'valeria.lopez@email.com'),
('Esteban', 'Martínez', '2222222222', '3202222222', 'Avenida 15 #10-25', 'esteban.martinez@email.com'),
('Paula', 'Ramírez', '2323232323', '3112323232', 'Calle 70 #30-40', 'paula.ramirez@email.com'),
('Julián', 'Moreno', '2424242424', '3122424242', 'Carrera 18 #12-50', 'julian.moreno@email.com'),
('Natalia', 'Fernández', '2525252525', '3132525252', 'Avenida 45 #22-60', 'natalia.fernandez@email.com'),
('Diego', 'Castillo', '2626262626', '3142626262', 'Calle 33 #15-20', 'diego.castillo@email.com'),
('Sara', 'García', '2727272727', '3152727272', 'Carrera 70 #40-18', 'sara.garcia@email.com'),
('Hernán', 'Vega', '2828282828', '3162828282', 'Avenida 12 #50-30', 'hernan.vega@email.com'),
('Valentina', 'Pérez', '2929292929', '3172929292', 'Calle 80 #22-15', 'valentina.perez@email.com'),
('Mauricio', 'Navarro', '3131313131', '3183131313', 'Carrera 33 #18-40', 'mauricio.navarro@email.com'),
('Claudia', 'Ortega', '3232323232', '3193232323', 'Avenida 25 #12-22', 'claudia.ortega@email.com'),
('Ricardo', 'Silva', '3333333333', '3203333333', 'Calle 15 #10-18', 'ricardo.silva@email.com'),
('Juliana', 'Cano', '3434343434', '3113434343', 'Carrera 80 #22-40', 'juliana.cano@email.com'),
('Gabriela', 'Núñez', '3535353535', '3123535353', 'Calle 12 #45-22', 'gabriela.nunez@email.com'),
('Tomás', 'Peña', '3636363636', '3133636363', 'Carrera 20 #33-18', 'tomas.pena@email.com'),
('Daniela', 'Ríos', '3737373737', '3143737373', 'Avenida 50 #12-40', 'daniela.rios@email.com'),
('Martín', 'Salcedo', '3838383838', '3153838383', 'Calle 80 #22-15', 'martin.salcedo@email.com'),
('Alejandra', 'Castaño', '3939393939', '3163939393', 'Carrera 15 #18-25', 'alejandra.castano@email.com'),
('Cristian', 'Mejía', '4141414141', '3174141414', 'Avenida 68 #30-20', 'cristian.mejia@email.com'),
('Natalia', 'Vargas', '4242424242', '3184242424', 'Calle 33 #22-40', 'natalia.vargas@email.com'),
('Mauricio', 'Patiño', '4343434343', '3194343434', 'Carrera 70 #15-12', 'mauricio.patino@email.com'),
('Camilo', 'Serrano', '4444444444', '3204444444', 'Avenida 19 #80-30', 'camilo.serrano@email.com'),
('Julieta', 'Ramírez', '4545454545', '3114545454', 'Calle 25 #12-18', 'julieta.ramirez@email.com'),
('Felipe', 'Morales', '4646464646', '3124646464', 'Carrera 33 #45-22', 'felipe.morales@email.com'),
('Isabel', 'Torres', '4747474747', '3134747474', 'Avenida 12 #20-40', 'isabel.torres@email.com'),
('Samuel', 'Gómez', '4848484848', '3144848484', 'Calle 70 #30-15', 'samuel.gomez@email.com'),
('María', 'Londoño', '4949494949', '3154949494', 'Carrera 18 #22-33', 'maria.londono@email.com'),
('Jorge', 'Cárdenas', '5151515151', '3165151515', 'Avenida 45 #10-25', 'jorge.cardenas@email.com'),
('Luisa', 'Salazar', '5252525252', '3175252525', 'Calle 33 #18-40', 'luisa.salazar@email.com'),
('Andrés', 'Ortega', '5353535353', '3185353535', 'Carrera 80 #22-40', 'andres.ortega@email.com'),
('Valeria', 'Silva', '5454545454', '3195454545', 'Avenida 25 #12-22', 'valeria.silva@email.com'),
('Esteban', 'Cano', '5555555555', '3205555555', 'Calle 15 #10-18', 'esteban.cano@email.com'),
('Paola', 'Navarro', '5656565656', '3115656565', 'Carrera 70 #22-40', 'paola.navarro@email.com'),
('Ricardo', 'Reyes', '5757575757', '3125757575', 'Avenida 33 #15-20', 'ricardo.reyes@email.com'),
('Juliana', 'Mendoza', '5858585858', '3135858585', 'Calle 80 #22-15', 'juliana.mendoza@email.com'),
('Natalia', 'Parra', '5959595959', '3145959595', 'Carrera 12 #34-56', 'natalia.parra@email.com'),
('Diego', 'Rojas', '6061616161', '3156061616', 'Avenida 50 #12-40', 'diego.rojas@email.com'),
('Sara', 'Castro', '6161616161', '3166161616', 'Calle 33 #22-40', 'sara.castro@email.com'),
('Hernán', 'García', '6262626262', '3176262626', 'Carrera 70 #15-12', 'hernan.garcia@email.com'),
('Valentina', 'Pardo', '6363636363', '3186363636', 'Avenida 19 #80-30', 'valentina.pardo@email.com'),
('Mauricio', 'Suárez', '6464646464', '3196464646', 'Calle 25 #12-18', 'mauricio.suarez@email.com'),
('Claudia', 'Peña', '6565656565', '3206565656', 'Carrera 33 #45-22', 'claudia.pena@email.com'),
('Ricardo', 'Moreno', '6666666666', '3116666666', 'Avenida 12 #20-40', 'ricardo.moreno@email.com'),
('Alejandro', 'Guzmán', '6767676767', '3126767676', 'Calle 12 #45-22', 'alejandro.guzman@email.com'),
('María', 'Patiño', '6868686868', '3136868686', 'Carrera 20 #33-18', 'maria.patino@email.com'),
('José', 'Serrano', '6969696969', '3146969696', 'Avenida 50 #12-40', 'jose.serrano@email.com'),
('Camila', 'Ramírez', '7071717171', '3157071717', 'Calle 80 #22-15', 'camila.ramirez@email.com'),
('Felipe', 'Morales', '7171717171', '3167171717', 'Carrera 15 #18-25', 'felipe.morales@email.com'),
('Isabel', 'Torres', '7272727272', '3177272727', 'Avenida 68 #30-20', 'isabel.torres@email.com'),
('Samuel', 'Gómez', '7373737373', '3187373737', 'Calle 33 #22-40', 'samuel.gomez@email.com'),
('María', 'Londoño', '7474747474', '3197474747', 'Carrera 70 #15-12', 'maria.londono@email.com'),
('Jorge', 'Cárdenas', '7575757575', '3207575757', 'Avenida 19 #80-30', 'jorge.cardenas@email.com'),
('Luisa', 'Salazar', '7676767676', '3117676767', 'Calle 25 #12-18', 'luisa.salazar@email.com'),
('Andrés', 'Ortega', '7777777777', '3127777777', 'Carrera 33 #45-22', 'andres.ortega@email.com'),
('Valeria', 'Silva', '7878787878', '3137878787', 'Avenida 12 #20-40', 'valeria.silva@email.com'),
('Esteban', 'Cano', '7979797979', '3147979797', 'Calle 70 #30-15', 'esteban.cano@email.com'),
('Paola', 'Navarro', '8081818181', '3158081818', 'Carrera 18 #22-33', 'paola.navarro@email.com'),
('Ricardo', 'Reyes', '8181818181', '3168181818', 'Avenida 45 #10-25', 'ricardo.reyes@email.com'),
('Juliana', 'Mendoza', '8282828282', '3178282828', 'Calle 33 #18-40', 'juliana.mendoza@email.com'),
('Natalia', 'Parra', '8383838383', '3188383838', 'Carrera 80 #22-40', 'natalia.parra@email.com'),
('Diego', 'Rojas', '8484848484', '3198484848', 'Avenida 25 #12-22', 'diego.rojas@email.com'),
('Sara', 'Castro', '8585858585', '3208585858', 'Calle 15 #10-18', 'sara.castro@email.com'),
('Hernán', 'García', '8686868686', '3118686868', 'Carrera 70 #22-40', 'hernan.garcia@email.com'),
('Valentina', 'Suárez', '8787878787', '3128787878', 'Calle 12 #45-22', 'valentina.suarez@email.com'),
('Mauricio', 'Gómez', '8888888888', '3138888888', 'Carrera 20 #33-18', 'mauricio.gomez@email.com'),
('Claudia', 'Martínez', '8989898989', '3148989898', 'Avenida 50 #12-40', 'claudia.martinez@email.com'),
('Ricardo', 'Ramírez', '9091919191', '3159091919', 'Calle 80 #22-15', 'ricardo.ramirez@email.com'),
('Juliana', 'Morales', '9191919191', '3169191919', 'Carrera 15 #18-25', 'juliana.morales@email.com'),
('Natalia', 'Cano', '9292929292', '3179292929', 'Avenida 68 #30-20', 'natalia.cano@email.com'),
('Diego', 'Reyes', '9393939393', '3189393939', 'Calle 33 #22-40', 'diego.reyes@email.com'),
('Sara', 'Mendoza', '9494949494', '3199494949', 'Carrera 70 #15-12', 'sara.mendoza@email.com'),
('Hernán', 'Parra', '9595959595', '3209595959', 'Avenida 19 #80-30', 'hernan.parra@email.com'),
('Valeria', 'Rojas', '9696969696', '3119696969', 'Calle 25 #12-18', 'valeria.rojas@email.com'),
('Esteban', 'Castro', '9797979797', '3129797979', 'Carrera 33 #45-22', 'esteban.castro@email.com'),
('Paola', 'García', '9898989898', '3139898989', 'Avenida 12 #20-40', 'paola.garcia@email.com'),
('Ricardo', 'Vega', '9999999999', '3149999999', 'Calle 70 #30-15', 'ricardo.vega@email.com'),
('Juliana', 'Salazar', '1011111111', '3151011111', 'Carrera 18 #22-33', 'juliana.salazar@email.com'),
('Natalia', 'Ortega', '1021212121', '3161021212', 'Avenida 45 #10-25', 'natalia.ortega@email.com'),
('Diego', 'Silva', '1031313131', '3171031313', 'Calle 33 #18-40', 'diego.silva@email.com'),
('Sara', 'Navarro', '1041414141', '3181041414', 'Carrera 80 #22-40', 'sara.navarro@email.com'),
('Hernán', 'Peña', '1051515151', '3191051515', 'Avenida 25 #12-22', 'hernan.pena@email.com'),
('Valeria', 'Moreno', '1061616161', '3201061616', 'Calle 15 #10-18', 'valeria.moreno@email.com'),
('Esteban', 'Suárez', '1071717171', '3111071717', 'Carrera 70 #22-40', 'esteban.suarez@email.com');

-- =====================================================
-- INSERTS PARA VEHICULO
-- =====================================================
INSERT INTO VEHICULO (año, placa, color, modelo, marca, id_cliente) VALUES
(2020, 'ABC123', 'Blanco', 'Logan', 'Renault', 1),
(2019, 'DEF456', 'Negro', 'Civic', 'Honda', 2),
(2021, 'GHI789', 'Gris', 'Corolla', 'Toyota', 3),
(2022, 'JKL012', 'Rojo', 'Mazda 3', 'Mazda', 4),
(2018, 'MNO345', 'Azul', 'Spark', 'Chevrolet', 5),
(2023, 'PQR678', 'Plateado', 'CR-V', 'Honda', 6),
(2020, 'STU901', 'Blanco', 'Tucson', 'Hyundai', 7),
(2021, 'VWX234', 'Negro', 'RAV4', 'Toyota', 8),
(2019, 'YZA567', 'Verde', 'Sportage', 'Kia', 9),
(2022, 'BCD890', 'Gris', 'Grand Vitara', 'Suzuki', 10),
(2021, 'EFG111', 'Blanco', 'Sentra', 'Nissan', 11),
(2020, 'HIJ222', 'Negro', 'Accord', 'Honda', 12),
(2019, 'KLM333', 'Gris', 'Camry', 'Toyota', 13),
(2022, 'NOP444', 'Rojo', 'CX-5', 'Mazda', 14),
(2018, 'QRS555', 'Azul', 'Aveo', 'Chevrolet', 15),
(2023, 'TUV666', 'Plateado', 'Santa Fe', 'Hyundai', 16),
(2020, 'WXY777', 'Blanco', 'Elantra', 'Hyundai', 17),
(2021, 'ZAB888', 'Negro', 'Hilux', 'Toyota', 18),
(2019, 'CDE999', 'Verde', 'Rio', 'Kia', 19),
(2022, 'FGH000', 'Gris', 'Swift', 'Suzuki', 20),
(2021, 'IJK123', 'Blanco', 'Versa', 'Nissan', 21),
(2020, 'LMN456', 'Negro', 'Pilot', 'Honda', 22),
(2019, 'OPQ789', 'Gris', 'Yaris', 'Toyota', 23),
(2022, 'RST012', 'Rojo', 'CX-30', 'Mazda', 24),
(2018, 'UVW345', 'Azul', 'Onix', 'Chevrolet', 25),
(2023, 'XYZ678', 'Plateado', 'Kona', 'Hyundai', 26),
(2020, 'ABC901', 'Blanco', 'Sonata', 'Hyundai', 27),
(2021, 'DEF234', 'Negro', 'Fortuner', 'Toyota', 28),
(2019, 'GHI567', 'Verde', 'Cerato', 'Kia', 29),
(2022, 'JKL890', 'Gris', 'Baleno', 'Suzuki', 30),
(2021, 'MNO111', 'Blanco', 'Altima', 'Nissan', 31),
(2020, 'PQR222', 'Negro', 'CR-V', 'Honda', 32),
(2019, 'STU333', 'Gris', 'Corolla', 'Toyota', 33),
(2022, 'VWX444', 'Rojo', 'Mazda 6', 'Mazda', 34),
(2018, 'YZA555', 'Azul', 'Cruze', 'Chevrolet', 35),
(2023, 'BCD666', 'Plateado', 'Palisade', 'Hyundai', 36),
(2020, 'EFG777', 'Blanco', 'Accent', 'Hyundai', 37),
(2021, 'HIJ888', 'Negro', 'Land Cruiser', 'Toyota', 38),
(2019, 'KLM999', 'Verde', 'Picanto', 'Kia', 39),
(2022, 'NOP000', 'Gris', 'Vitara', 'Suzuki', 40),
(2021, 'QRS123', 'Blanco', 'Versa', 'Nissan', 41),
(2020, 'TUV456', 'Negro', 'Odyssey', 'Honda', 42),
(2019, 'WXY789', 'Gris', 'Yaris', 'Toyota', 43),
(2022, 'ZAB012', 'Rojo', 'CX-9', 'Mazda', 44),
(2018, 'CDE345', 'Azul', 'Sail', 'Chevrolet', 45),
(2023, 'FGH678', 'Plateado', 'Venue', 'Hyundai', 46),
(2020, 'IJK901', 'Blanco', 'Sonata', 'Hyundai', 47),
(2021, 'LMN234', 'Negro', 'Prado', 'Toyota', 48),
(2019, 'OPQ567', 'Verde', 'Stonic', 'Kia', 49),
(2022, 'RST890', 'Gris', 'Ignis', 'Suzuki', 50),
(2021, 'UVW111', 'Blanco', 'Tiida', 'Nissan', 51),
(2020, 'XYZ222', 'Negro', 'HR-V', 'Honda', 52),
(2019, 'ABC333', 'Gris', 'Avalon', 'Toyota', 53),
(2022, 'DEF444', 'Rojo', 'Mazda 2', 'Mazda', 54),
(2018, 'GHI555', 'Azul', 'Tracker', 'Chevrolet', 55),
(2023, 'JKL666', 'Plateado', 'Creta', 'Hyundai', 56),
(2020, 'MNO777', 'Blanco', 'i20', 'Hyundai', 57),
(2021, 'PQR888', 'Negro', 'Highlander', 'Toyota', 58),
(2019, 'STU999', 'Verde', 'Soul', 'Kia', 59),
(2022, 'VWX000', 'Gris', 'Dzire', 'Suzuki', 60),
(2021, 'YZA123', 'Blanco', 'Micra', 'Nissan', 61),
(2020, 'BCD456', 'Negro', 'Ridgeline', 'Honda', 62),
(2019, 'EFG789', 'Gris', 'Supra', 'Toyota', 63),
(2022, 'HIJ012', 'Rojo', 'MX-5', 'Mazda', 64),
(2018, 'KLM345', 'Azul', 'Captiva', 'Chevrolet', 65),
(2023, 'NOP678', 'Plateado', 'Bayon', 'Hyundai', 66),
(2020, 'QRS901', 'Blanco', 'Venue', 'Hyundai', 67),
(2021, 'TUV234', 'Negro', 'Sequoia', 'Toyota', 68),
(2019, 'WXY567', 'Verde', 'Sorento', 'Kia', 69),
(2022, 'ZAB890', 'Gris', 'Celerio', 'Suzuki', 70),
(2021, 'CDE111', 'Blanco', 'March', 'Nissan', 71),
(2020, 'FGH222', 'Negro', 'City', 'Honda', 72),
(2019, 'IJK333', 'Gris', 'Prius', 'Toyota', 73),
(2022, 'LMN444', 'Rojo', 'Mazda CX-3', 'Mazda', 74),
(2018, 'OPQ555', 'Azul', 'Spark GT', 'Chevrolet', 75),
(2023, 'RST666', 'Plateado', 'Tucson', 'Hyundai', 76),
(2020, 'UVW777', 'Blanco', 'Creta', 'Hyundai', 77),
(2021, 'XYZ888', 'Negro', 'Corolla Cross', 'Toyota', 78),
(2019, 'ABC999', 'Verde', 'Sportage', 'Kia', 79),
(2022, 'DEF000', 'Gris', 'Jimny', 'Suzuki', 80),
(2021, 'GHI123', 'Blanco', 'Sentra', 'Nissan', 81),
(2020, 'JKL456', 'Negro', 'Civic', 'Honda', 82),
(2019, 'MNO789', 'Gris', 'Camry', 'Toyota', 83),
(2022, 'PQR012', 'Rojo', 'Mazda 2', 'Mazda', 84),
(2018, 'STU345', 'Azul', 'Aveo', 'Chevrolet', 85),
(2023, 'VWX678', 'Plateado', 'Santa Fe', 'Hyundai', 86),
(2020, 'YZA901', 'Blanco', 'Elantra', 'Hyundai', 87),
(2021, 'BCD234', 'Negro', 'Hilux', 'Toyota', 88),
(2019, 'EFG567', 'Verde', 'Rio', 'Kia', 89),
(2022, 'HIJ890', 'Gris', 'Swift', 'Suzuki', 90),
(2021, 'KLM111', 'Blanco', 'Versa', 'Nissan', 91),
(2020, 'NOP222', 'Negro', 'Pilot', 'Honda', 92),
(2019, 'QRS333', 'Gris', 'Yaris', 'Toyota', 93),
(2022, 'TUV444', 'Rojo', 'CX-30', 'Mazda', 94),
(2018, 'WXY555', 'Azul', 'Onix', 'Chevrolet', 95),
(2023, 'ZAB666', 'Plateado', 'Kona', 'Hyundai', 96),
(2020, 'CDE777', 'Blanco', 'Sonata', 'Hyundai', 97),
(2021, 'FGH888', 'Negro', 'Fortuner', 'Toyota', 98),
(2019, 'IJK999', 'Verde', 'Cerato', 'Kia', 99),
(2022, 'LMN000', 'Gris', 'Baleno', 'Suzuki', 100);
-- =====================================================
-- INSERTS PARA TIPO_VEHICULO
-- =====================================================
INSERT INTO TIPO_VEHICULO (tamaño_estimado, cilindraje, descripcion) VALUES
('Pequeño', 1400, 'Sedán compacto o hatchback'),
('Mediano', 1800, 'Sedán mediano'),
('Grande', 2500, 'Camioneta o SUV grande'),
('Compacto', 1000, 'Vehículo ciudad pequeño'),
('SUV Mediano', 2000, 'SUV tamaño medio'),
('Deportivo', 2200, 'Vehículo deportivo'),
('Van', 3000, 'Vehículo tipo van o minivan'),
('Pickup', 2800, 'Camioneta pickup'),
('Lujo', 3500, 'Vehículo de lujo grande'),
('Eléctrico', 0, 'Vehículo eléctrico'),
('Micro', 800, 'Vehículo urbano muy pequeño'),
('Compacto Premium', 1200, 'Compacto con acabados de lujo'),
('Sedán Familiar', 1600, 'Sedán diseñado para familias'),
('SUV Compacto', 1800, 'SUV de tamaño reducido'),
('SUV Grande', 3000, 'SUV de gran tamaño y potencia'),
('Crossover', 2000, 'Vehículo crossover entre sedán y SUV'),
('Híbrido Compacto', 1500, 'Vehículo híbrido pequeño'),
('Híbrido SUV', 2200, 'SUV con motor híbrido'),
('Eléctrico Compacto', 0, 'Vehículo eléctrico urbano'),
('Eléctrico SUV', 0, 'SUV eléctrico'),
('Deportivo Compacto', 1800, 'Deportivo de menor tamaño'),
('Deportivo Premium', 3200, 'Deportivo de alta gama'),
('Pickup Compacta', 2400, 'Camioneta pickup pequeña'),
('Pickup Grande', 3500, 'Pickup de gran tamaño'),
('Van Compacta', 2000, 'Van pequeña para ciudad'),
('Van Grande', 3200, 'Van de transporte familiar'),
('Lujo Compacto', 2000, 'Vehículo compacto de lujo'),
('Lujo SUV', 4000, 'SUV de lujo'),
('Convertible', 2200, 'Vehículo convertible'),
('Roadster', 2500, 'Vehículo deportivo biplaza'),
('Offroad Compacto', 2000, 'Vehículo todoterreno pequeño'),
('Offroad SUV', 3200, 'SUV todoterreno'),
('Camión Ligero', 4000, 'Camión de carga ligera'),
('Camión Mediano', 6000, 'Camión de carga mediana'),
('Camión Grande', 8000, 'Camión de carga pesada'),
('Moto Compacta', 250, 'Motocicleta pequeña'),
('Moto Mediana', 600, 'Motocicleta mediana'),
('Moto Grande', 1000, 'Motocicleta de gran cilindraje'),
('Motocicleta Eléctrica', 0, 'Moto eléctrica'),
('Cuatrimoto', 500, 'Vehículo recreativo todoterreno'),
('Compacto Urbano', 1100, 'Vehículo pequeño para ciudad'),
('Sedán Ejecutivo', 2000, 'Sedán de gama ejecutiva'),
('SUV Premium', 2800, 'SUV con acabados premium'),
('Crossover Compacto', 1600, 'Crossover de tamaño reducido'),
('Crossover Grande', 2400, 'Crossover de gran tamaño'),
('Híbrido Sedán', 1800, 'Sedán híbrido'),
('Híbrido Deportivo', 2500, 'Deportivo híbrido'),
('Eléctrico Premium', 0, 'Vehículo eléctrico de lujo'),
('Eléctrico Deportivo', 0, 'Deportivo eléctrico'),
('Convertible Compacto', 1600, 'Convertible pequeño'),
('Convertible Premium', 2800, 'Convertible de gama alta'),
('Roadster Compacto', 2000, 'Roadster pequeño'),
('Roadster Premium', 3200, 'Roadster de lujo'),
('Pickup Urbana', 2000, 'Pickup para ciudad'),
('Pickup Offroad', 3200, 'Pickup todoterreno'),
('Van Escolar', 2800, 'Van para transporte escolar'),
('Van Ejecutiva', 3500, 'Van de lujo ejecutiva'),
('Lujo Deportivo', 4000, 'Deportivo de lujo'),
('Lujo Convertible', 3800, 'Convertible de lujo'),
('Offroad Compacto', 2200, 'Todoterreno pequeño'),
('Offroad Premium', 3500, 'Todoterreno de lujo'),
('Camión Urbano', 4500, 'Camión pequeño para ciudad'),
('Camión Distribución', 5500, 'Camión de reparto'),
('Camión Pesado', 9000, 'Camión de carga pesada'),
('Moto Scooter', 125, 'Motocicleta scooter'),
('Moto Touring', 750, 'Motocicleta touring'),
('Moto Deportiva', 1000, 'Motocicleta deportiva'),
('Moto Custom', 1200, 'Motocicleta estilo custom'),
('Moto Adventure', 850, 'Motocicleta de aventura'),
('Cuatrimoto Premium', 700, 'Cuatrimoto de gama alta'),
('Compacto Eléctrico', 0, 'Compacto totalmente eléctrico'),
('Sedán Deportivo', 2400, 'Sedán con enfoque deportivo'),
('SUV Eléctrico', 0, 'SUV impulsado por energía eléctrica'),
('Crossover Eléctrico', 0, 'Crossover eléctrico urbano'),
('Pickup Eléctrica', 0, 'Camioneta pickup eléctrica'),
('Van Eléctrica', 0, 'Van eléctrica para transporte urbano'),
('Lujo Eléctrico', 0, 'Vehículo de lujo eléctrico'),
('Convertible Eléctrico', 0, 'Convertible eléctrico'),
('Roadster Eléctrico', 0, 'Roadster eléctrico biplaza'),
('Offroad Eléctrico', 0, 'Todoterreno eléctrico'),
('Compacto Híbrido', 1400, 'Compacto con motor híbrido'),
('Sedán Híbrido', 2000, 'Sedán híbrido mediano'),
('SUV Híbrido', 2500, 'SUV híbrido grande'),
('Crossover Híbrido', 1800, 'Crossover híbrido'),
('Pickup Híbrida', 2800, 'Pickup híbrida'),
('Van Híbrida', 3000, 'Van híbrida'),
('Lujo Híbrido', 3500, 'Vehículo de lujo híbrido'),
('Convertible Híbrido', 2200, 'Convertible híbrido'),
('Roadster Híbrido', 2500, 'Roadster híbrido'),
('Offroad Híbrido', 3200, 'Todoterreno híbrido'),
('Compacto Premium Eléctrico', 0, 'Compacto eléctrico de gama alta'),
('Sedán Ejecutivo Eléctrico', 0, 'Sedán eléctrico ejecutivo'),
('SUV Premium Eléctrico', 0, 'SUV eléctrico premium'),
('Crossover Premium Eléctrico', 0, 'Crossover eléctrico de lujo'),
('Pickup Premium Eléctrica', 0, 'Pickup eléctrica premium'),
('Van Premium Eléctrica', 0, 'Van eléctrica premium'),
('Lujo Premium Eléctrico', 0, 'Vehículo eléctrico de lujo'),
('Convertible Premium Eléctrico', 0, 'Convertible eléctrico premium'),
('Roadster Premium Eléctrico', 0, 'Roadster eléctrico premium'),
('Offroad Premium Eléctrico', 0, 'Todoterreno eléctrico premium');

-- =====================================================
-- INSERTS PARA Vehiculo_TipoVehiculo
-- =====================================================
INSERT INTO Vehiculo_TipoVehiculo (id_vehiculo, id_tipo_vehiculo) VALUES
(1, 1), (2, 2), (3, 2), (4, 2), (5, 4),
(6, 5), (7, 5), (8, 5), (9, 5), (10, 5),
(11, 6), (12, 7), (13, 8), (14, 9), (15, 10),
(16, 11), (17, 12), (18, 13), (19, 14), (20, 15),
(21, 16), (22, 17), (23, 18), (24, 19), (25, 20),
(26, 21), (27, 22), (28, 23), (29, 24), (30, 25),
(31, 26), (32, 27), (33, 28), (34, 29), (35, 30),
(36, 31), (37, 32), (38, 33), (39, 34), (40, 35),
(41, 36), (42, 37), (43, 38), (44, 39), (45, 40),
(46, 41), (47, 42), (48, 43), (49, 44), (50, 45),
(51, 46), (52, 47), (53, 48), (54, 49), (55, 50),
(56, 51), (57, 52), (58, 53), (59, 54), (60, 55),
(61, 56), (62, 57), (63, 58), (64, 59), (65, 60),
(66, 61), (67, 62), (68, 63), (69, 64), (70, 65),
(71, 66), (72, 67), (73, 68), (74, 69), (75, 70),
(76, 71), (77, 72), (78, 73), (79, 74), (80, 75),
(81, 76), (82, 77), (83, 78), (84, 79), (85, 80),
(86, 81), (87, 82), (88, 83), (89, 84), (90, 85),
(91, 86), (92, 87), (93, 88), (94, 89), (95, 90),
(96, 91), (97, 92), (98, 93), (99, 94), (100, 95);
-- =====================================================
-- INSERTS PARA CELDA
-- =====================================================
INSERT INTO CELDA (ubicacion, estado, id_sede) VALUES
('A-101', 'disponible', 1),
('A-102', 'ocupada', 1),
('A-103', 'disponible', 1),
('B-201', 'disponible', 2),
('B-202', 'mantenimiento', 2),
('C-301', 'disponible', 3),
('C-302', 'ocupada', 3),
('D-401', 'disponible', 4),
('E-501', 'disponible', 5),
('F-601', 'disponible', 6),
('A-104', 'disponible', 7),
('A-105', 'ocupada', 8),
('A-106', 'mantenimiento', 9),
('A-107', 'disponible', 10),
('A-108', 'ocupada', 11),
('A-109', 'disponible', 12),
('A-110', 'mantenimiento', 13),
('B-203', 'disponible', 14),
('B-204', 'ocupada', 15),
('B-205', 'mantenimiento', 16),
('B-206', 'disponible', 17),
('B-207', 'ocupada', 18),
('B-208', 'disponible', 19),
('B-209', 'mantenimiento', 20),
('B-210', 'disponible', 21),
('C-303', 'ocupada', 22),
('C-304', 'disponible', 23),
('C-305', 'mantenimiento', 24),
('C-306', 'disponible', 25),
('C-307', 'ocupada', 26),
('C-308', 'disponible', 27),
('C-309', 'mantenimiento', 28),
('C-310', 'disponible', 29),
('D-402', 'ocupada', 30),
('D-403', 'disponible', 31),
('D-404', 'mantenimiento', 32),
('D-405', 'disponible', 33),
('D-406', 'ocupada', 34),
('D-407', 'disponible', 35),
('D-408', 'mantenimiento', 36),
('D-409', 'disponible', 37),
('D-410', 'ocupada', 38),
('E-502', 'disponible', 39),
('E-503', 'mantenimiento', 40),
('E-504', 'ocupada', 41),
('E-505', 'disponible', 42),
('E-506', 'mantenimiento', 43),
('E-507', 'disponible', 44),
('E-508', 'ocupada', 45),
('E-509', 'disponible', 46),
('E-510', 'mantenimiento', 47),
('F-602', 'disponible', 48),
('F-603', 'ocupada', 49),
('F-604', 'disponible', 50),
('F-605', 'mantenimiento', 51),
('F-606', 'disponible', 52),
('F-607', 'ocupada', 53),
('F-608', 'disponible', 54),
('F-609', 'mantenimiento', 55),
('F-610', 'disponible', 56),
('G-701', 'ocupada', 57),
('G-702', 'disponible', 58),
('G-703', 'mantenimiento', 59),
('G-704', 'disponible', 60),
('G-705', 'ocupada', 61),
('G-706', 'disponible', 62),
('G-707', 'mantenimiento', 63),
('G-708', 'disponible', 64),
('G-709', 'ocupada', 65),
('G-710', 'disponible', 66),
('H-801', 'mantenimiento', 67),
('H-802', 'disponible', 68),
('H-803', 'ocupada', 69),
('H-804', 'disponible', 70),
('H-805', 'mantenimiento', 71),
('H-806', 'disponible', 72),
('H-807', 'ocupada', 73),
('H-808', 'disponible', 74),
('H-809', 'mantenimiento', 75),
('H-810', 'disponible', 76),
('I-901', 'ocupada', 77),
('I-902', 'disponible', 78),
('I-903', 'mantenimiento', 79),
('I-904', 'disponible', 80),
('I-905', 'ocupada', 81),
('I-906', 'disponible', 82),
('I-907', 'mantenimiento', 83),
('I-908', 'disponible', 84),
('I-909', 'ocupada', 85),
('I-910', 'disponible', 86),
('J-1001', 'mantenimiento', 87),
('J-1002', 'disponible', 88),
('J-1003', 'ocupada', 89),
('J-1004', 'disponible', 90),
('J-1005', 'mantenimiento', 91),
('J-1006', 'disponible', 92),
('J-1007', 'ocupada', 93),
('J-1008', 'disponible', 94),
('J-1009', 'mantenimiento', 95),
('J-1010', 'disponible', 96);

-- =====================================================
-- INSERTS PARA CELDA_PARQUEO
-- =====================================================

INSERT INTO CELDA_PARQUEO (id_celda, id_convenio) VALUES
(1, NULL), (2, NULL), (3, NULL), (4, NULL), (5, NULL),
(6, NULL), (7, NULL), (8, NULL), (9, NULL), (10, NULL),
(11, NULL), (12, NULL), (13, NULL), (14, NULL), (15, NULL),
(16, NULL), (17, NULL), (18, NULL), (19, NULL),(20, NULL),
(21, NULL), (22, NULL), (23, NULL), (24, NULL), (25, NULL);

-- =====================================================
-- INSERTS PARA CELDA_LAVADO
-- =====================================================

INSERT INTO CELDA_LAVADO (id_celda, condicion_luz, espacio) VALUES
(26, 'Natural', 'Amplio'),
(27, 'Artificial', 'Mediano'),
(28, 'Natural', 'Grande'),
(29, 'Mixta', 'Amplio'),
(30, 'Artificial', 'Grande'),
(31, 'Natural', 'Mediano'),
(32, 'Mixta', 'Amplio'),
(33, 'Artificial', 'Mediano'),
(34, 'Natural', 'Grande'),
(35, 'Mixta', 'Mediano'),
(36, 'Artificial', 'Amplio'),
(37, 'Natural', 'Mediano'),
(38, 'Mixta', 'Grande'),
(39, 'Artificial', 'Mediano'),
(40, 'Natural', 'Amplio'),
(41, 'Mixta', 'Mediano'),
(42, 'Artificial', 'Grande'),
(43, 'Natural', 'Amplio'),
(44, 'Mixta', 'Grande'),
(45, 'Artificial', 'Mediano'),
(46, 'Natural', 'Amplio'),
(47, 'Mixta', 'Mediano'),
(48, 'Artificial', 'Grande'),
(49, 'Natural', 'Mediano'),
(50, 'Mixta', 'Amplio');

-- =====================================================
-- INSERTS PARA CELDA_RECARGA_ELECTRICA
-- =====================================================

INSERT INTO CELDA_RECARGA_ELECTRICA (id_celda, potencia) VALUES
(51, 7.50), (52, 11.00), (53, 22.00), (54, 50.00),(55, 7.50),
(56, 11.00), (57, 22.00), (58, 50.00), (59, 7.50), (60, 11.00),
(61, 22.00), (62, 50.00), (63, 7.50), (64, 11.00), (65, 22.00),
(66, 50.00), (67, 7.50), (68, 11.00), (69, 22.00), (70, 50.00),
(71, 7.50), (72, 11.00), (73, 22.00), (74, 50.00), (75, 7.50);

-- =====================================================
-- INSERTS PARA CELDA_MOVILIDAD_REDUCIDA
-- =====================================================

INSERT INTO CELDA_MOVILIDAD_REDUCIDA (id_celda, ancho) VALUES
(76, 3.50), (77, 3.80), (78, 3.60), (79, 3.70), (80, 4.00),
(81, 3.90), (82, 3.50), (83, 3.80), (84, 3.60), (85, 3.70),
(86, 4.00), (87, 3.50), (88, 3.90), (89, 3.80), (90, 3.60),
(91, 3.70), (92, 4.00), (93, 3.50), (94, 3.80), (95, 3.60),
(96, 3.70), (97, 3.90), (98, 4.00), (99, 3.50), (100, 3.80);

-- =====================================================
-- INSERTS PARA Celda_TipoVehiculo
-- =====================================================

INSERT INTO Celda_TipoVehiculo (id_celda, id_tipo_vehiculo) VALUES
(1, 1), (1, 2), (2, 2), (3, 3), (4, 1),
(5, 4), (6, 5), (7, 3), (8, 2), (9, 1), (10, 5),
(11, 6), (12, 7), (13, 8), (14, 9), (15, 10),
(16, 11), (17, 12), (18, 13), (19, 14), (20, 15),
(21, 16), (22, 17), (23, 18), (24, 19), (25, 20),
(26, 21), (27, 22), (28, 23), (29, 24), (30, 25),
(31, 26), (32, 27), (33, 28), (34, 29), (35, 30),
(36, 31), (37, 32), (38, 33), (39, 34), (40, 35),
(41, 36), (42, 37), (43, 38), (44, 39), (45, 40),
(46, 41), (47, 42), (48, 43), (49, 44), (50, 45),
(51, 46), (52, 47), (53, 48), (54, 49), (55, 50),
(56, 51), (57, 52), (58, 53), (59, 54), (60, 55),
(61, 56), (62, 57), (63, 58), (64, 59), (65, 60),
(66, 61), (67, 62), (68, 63), (69, 64), (70, 65),
(71, 66), (72, 67), (73, 68), (74, 69), (75, 70),
(76, 71), (77, 72), (78, 73), (79, 74), (80, 75),
(81, 76), (82, 77), (83, 78), (84, 79), (85, 80),
(86, 81), (87, 82), (88, 83), (89, 84), (90, 85),
(91, 86), (92, 87), (93, 88), (94, 89), (95, 90),
(96, 91), (97, 92), (98, 93), (99, 94), (100, 95);

-- =====================================================
-- INSERTS PARA CONVENIO
-- =====================================================

INSERT INTO CONVENIO (descripcion, precio_base, vigencia_inicio, vigencia_fin, plazo, reglas_especiales) VALUES
('Ingreso irrestrictivo para una cantidad dada de vehículos', 180000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado de lunes a viernes'),
('Arriendo permanente de una celda.', 250000.00, '2024-01-01', '2024-12-31', 30, 'Celda asignada exclusivamente'),
('Contratación fija para ciertos días durante el mes.', 120000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 15 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 100 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 95000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo en días de restricción vehicular'),
('Contratación por día para una placa específica.', 200000.00, '2024-01-01', '2024-12-31', 30, '10 lavados completos al mes'),
('Contratación fija para ciertas horas durante el mes.', 300000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 3 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 140000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 6pm a 6am ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 80000.00, '2024-01-01', '2024-12-31', 30, 'Sábados y domingos ilimitado'),
('Arriendo permanente de una celda.', 450000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 4 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 185000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado fines de semana'),
('Arriendo permanente de una celda.', 260000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con acceso 24/7'),
('Contratación fija para ciertos días durante el mes.', 125000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 20 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 155000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 120 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 100000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días festivos'),
('Contratación por día para una placa específica.', 210000.00, '2024-01-01', '2024-12-31', 30, '8 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 310000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 5 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 145000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo nocturno ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 85000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado domingos'),
('Arriendo permanente de una celda.', 460000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 2 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 190000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado lunes a sábado'),
('Arriendo permanente de una celda.', 270000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con vigilancia'),
('Contratación fija para ciertos días durante el mes.', 130000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 10 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 160000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 80 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 105000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días hábiles'),
('Contratación por día para una placa específica.', 220000.00, '2024-01-01', '2024-12-31', 30, '12 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 320000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 2 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 7am a 7pm ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 90000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado sábados'),
('Arriendo permanente de una celda.', 470000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 6 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 180000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado de lunes a viernes'),
('Arriendo permanente de una celda.', 250000.00, '2024-01-01', '2024-12-31', 30, 'Celda asignada exclusivamente'),
('Contratación fija para ciertos días durante el mes.', 120000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 15 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 100 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 95000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo en días de restricción vehicular'),
('Contratación por día para una placa específica.', 200000.00, '2024-01-01', '2024-12-31', 30, '10 lavados completos al mes'),
('Contratación fija para ciertas horas durante el mes.', 300000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 3 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 140000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 6pm a 6am ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 80000.00, '2024-01-01', '2024-12-31', 30, 'Sábados y domingos ilimitado'),
('Arriendo permanente de una celda.', 450000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 4 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 185000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado fines de semana'),
('Arriendo permanente de una celda.', 260000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con acceso 24/7'),
('Contratación fija para ciertos días durante el mes.', 125000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 20 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 155000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 120 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 100000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días festivos'),
('Contratación por día para una placa específica.', 210000.00, '2024-01-01', '2024-12-31', 30, '8 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 310000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 5 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 145000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo nocturno ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 85000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado domingos'),
('Arriendo permanente de una celda.', 460000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 2 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 190000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado lunes a sábado'),
('Arriendo permanente de una celda.', 270000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con vigilancia'),
('Contratación fija para ciertos días durante el mes.', 130000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 10 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 160000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 80 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 105000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días hábiles'),
('Contratación por día para una placa específica.', 220000.00, '2024-01-01', '2024-12-31', 30, '12 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 320000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 2 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 7am a 7pm ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 90000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado sábados'),
('Arriendo permanente de una celda.', 470000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 6 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 180000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado de lunes a viernes'),
('Arriendo permanente de una celda.', 250000.00, '2024-01-01', '2024-12-31', 30, 'Celda asignada exclusivamente'),
('Contratación fija para ciertos días durante el mes.', 120000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 15 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 100 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 95000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo en días de restricción vehicular'),
('Contratación por día para una placa específica.', 200000.00, '2024-01-01', '2024-12-31', 30, '10 lavados completos al mes'),
('Contratación fija para ciertas horas durante el mes.', 300000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 3 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 140000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 6pm a 6am ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 80000.00, '2024-01-01', '2024-12-31', 30, 'Sábados y domingos ilimitado'),
('Arriendo permanente de una celda.', 450000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 4 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 185000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado fines de semana'),
('Arriendo permanente de una celda.', 260000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con acceso 24/7'),
('Contratación fija para ciertos días durante el mes.', 125000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 20 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 155000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 120 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 100000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días festivos'),
('Contratación por día para una placa específica.', 210000.00, '2024-01-01', '2024-12-31', 30, '8 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 310000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 5 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 145000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo nocturno ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 85000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado domingos'),
('Arriendo permanente de una celda.', 460000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 2 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 190000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado lunes a sábado'),
('Arriendo permanente de una celda.', 270000.00, '2024-01-01', '2024-12-31', 30, 'Celda exclusiva con vigilancia'),
('Contratación fija para ciertos días durante el mes.', 130000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 10 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 160000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 80 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 105000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado en días hábiles'),
('Contratación por día para una placa específica.', 220000.00, '2024-01-01', '2024-12-31', 30, '12 lavados básicos al mes'),
('Contratación fija para ciertas horas durante el mes.', 320000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 2 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 7am a 7pm ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 90000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado sábados'),
('Arriendo permanente de una celda.', 470000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 6 lavados premium mensuales'),
('Contratación fija para ciertas horas durante el mes.', 320000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 2 vehículos por empresa'),
('Contratación fija para ciertos días durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 7am a 7pm ilimitado'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 90000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado sábados'),
('Arriendo permanente de una celda.', 470000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 6 lavados premium mensuales'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 180000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado de lunes a viernes'),
('Arriendo permanente de una celda.', 250000.00, '2024-01-01', '2024-12-31', 30, 'Celda asignada exclusivamente'),
('Contratación fija para ciertos días durante el mes.', 120000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 15 días calendario'),
('Contratación fija para ciertas horas durante el mes.', 150000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 100 horas de parqueo al mes'),
('Ingreso irrestrictivo para una cantidad dada de vehículos', 95000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo en días de restricción vehicular'),
('Contratación por día para una placa específica.', 200000.00, '2024-01-01', '2024-12-31', 30, '10 lavados completos al mes');

-- =====================================================
-- INSERTS PARA CONVENIO_PARQUEADERO
-- =====================================================

INSERT INTO CONVENIO_PARQUEADERO (id_convenio, requiere_tarjeta) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
(6,1), (7, 1), (8, 1), (9, 1), (10, 1),
(11, 1), (12, 1), (13, 1), (14, 1), (15, 1),
(16, 1), (17, 1), (18, 1), (19, 1), (20, 1),
(21, 1), (22, 1), (23, 1), (24, 1), (25, 1),
(26, 1), (27, 1), (28, 1), (29, 1), (30, 1),
(31, 1), (32, 1), (33, 1), (34, 1), (35, 1),
(36, 1), (37, 1), (38, 1), (39, 1), (40, 1),
(41, 1), (42, 1), (43, 1), (44, 1), (45, 1),
(46, 1), (47, 1), (48, 1), (49, 1), (50, 1);

-- =====================================================
-- INSERTS PARA CONVENIO_LAVADO
-- =====================================================

INSERT INTO CONVENIO_LAVADO (id_convenio, cantidad_lavado_mes) VALUES
(51, 10), (52, 4), (53, 6), (54, 8), (55, 12), (56, 4), (57, 10),
(58, 6), (59, 8), (60, 2), (61, 12), (62, 4),
(63, 6), (64, 10), (65, 8), (66, 12), (67, 4),
(68, 6), (69, 2), (70, 8), (71, 10), (72, 12),
(73, 4), (74, 6), (75, 8), (76, 10), (77, 12),
(78, 2), (79, 4), (80, 6), (81, 8), (82, 10),
(83, 12), (84, 4), (85, 6), (86, 8), (87, 10),
(88, 12), (89, 2), (90, 4), (91, 6), (92, 8),
(93, 10), (94, 12), (95, 4), (96, 6), (97, 8),
(98, 10), (99, 12), (100, 2);

-- =====================================================
-- INSERTS PARA CONVENIO_IRRESTRICTIVO
-- =====================================================

INSERT INTO CONVENIO_IRRESTRICTIVO (id_convenio, cantidad_vehiculos) VALUES
(1, 1),(7, 3),(8, 1),(12, 2),(15, 5),(20, 3),(25, 10),(30, 2),(35, 4),(40, 6);

-- =====================================================
-- INSERTS PARA CONVENIO_CELDA_FIJA
-- =====================================================

INSERT INTO CONVENIO_CELDA_FIJA (id_convenio, id_celda) VALUES
(2, 1),(10, 3),(11, 5),(13, 7),(14, 9),(16, 11),(18, 13),(22, 15),(28, 17),(32, 19);

-- =====================================================
-- INSERTS PARA CONVENIO_DIAS_MES
-- =====================================================

INSERT INTO CONVENIO_DIAS_MES (id_convenio, cantidad_dias) VALUES
(3, 15),(9, 8),(4, 12),(5, 20),(6, 10),(17, 18),(19, 25),(21, 12),(23, 15),(24, 30);

-- =====================================================
-- INSERTS PARA CONVENIO_HORAS_MES
-- =====================================================

INSERT INTO CONVENIO_HORAS_MES (id_convenio, horas_permitidas, cantidad_horas_mes) VALUES
(27, 5, 100), (29, 12, 360),(31, 8, 200),(33, 10, 250),(34, 6, 180),(36, 15, 400),(37, 20, 500),(38, 7, 150),(39, 9, 220),(41, 12, 300);
-- =====================================================
-- INSERTS PARA CONVENIO_DIA_PLACA
-- =====================================================

INSERT INTO CONVENIO_DIA_PLACA (id_convenio, id_vehiculo) VALUES
(26, 1),(42, 2),(43, 3),(44, 4),(45, 5),(46, 6),(47, 7),(48, 8),(49, 9),(50, 10);
-- =====================================================
-- INSERTS PARA Convenio_TipoVehiculo
-- =====================================================

INSERT INTO Convenio_TipoVehiculo (id_convenio_parqueadero, id_tipo_vehiculo) VALUES
(1, 1), (1, 2), (2, 2), (3, 1), (4, 2),
(7, 3), (8, 1), (9, 2), (10, 5),
(11, 1), (11, 3), (12, 2), (12, 4), (13, 5),
(14, 1), (14, 2), (15, 3), (15, 4), (16, 5),
(17, 1), (17, 2), (18, 3), (18, 4), (19, 5),
(20, 1), (20, 2), (21, 3), (21, 4), (22, 5),
(23, 1), (23, 2), (24, 3), (24, 4), (25, 5),
(26, 1), (26, 2), (27, 3), (27, 4), (28, 5),
(29, 1), (29, 2), (30, 3), (30, 4), (31, 5),
(32, 1), (32, 2), (33, 3), (33, 4), (34, 5),
(35, 1), (35, 2), (36, 3), (36, 4), (37, 5),
(38, 1), (38, 2), (39, 3), (39, 4), (40, 5),
(41, 1), (41, 2), (42, 3), (42, 4), (43, 5),
(44, 1), (44, 2), (45, 3), (45, 4), (46, 5),
(47, 1), (47, 2), (48, 3), (48, 4), (49, 5),
(50, 1), (50, 2), (50, 3), (50, 4), (50, 5);
-- =====================================================
-- INSERTS PARA Convenio_Sede
-- =====================================================

INSERT INTO Convenio_Sede (id_convenio, id_sede) VALUES
(1, 1), (1, 2),
(2, 1), (2, 3),
(3, 2), (3, 4),
(4, 2), (4, 5),
(5, 3), (5, 6),
(6, 1), (6, 7),
(7, 4), (7, 8),
(8, 5), (8, 9),
(9, 6), (9, 10),
(10, 1), (10, 2),
(11, 3), (11, 4),
(12, 5), (12, 6),
(13, 7), (13, 8),
(14, 9), (14, 10),
(15, 1), (15, 3),
(16, 2), (16, 4),
(17, 5), (17, 7),
(18, 6), (18, 8),
(19, 9), (19, 10),
(20, 1), (20, 4),
(21, 2), (21, 5),
(22, 3), (22, 6),
(23, 7), (23, 9),
(24, 8), (24, 10),
(25, 1), (25, 6),
(26, 2), (26, 7),
(27, 3), (27, 8),
(28, 4), (28, 9),
(29, 5), (29, 10),
(30, 1), (30, 7),
(31, 2), (31, 8),
(32, 3), (32, 9),
(33, 4), (33, 10),
(34, 5), (34, 1),
(35, 6), (35, 2),
(36, 7), (36, 3),
(37, 8), (37, 4),
(38, 9), (38, 5),
(39, 10), (39, 6),
(40, 1), (40, 7),
(41, 2), (41, 8),
(42, 3), (42, 9),
(43, 4), (43, 10),
(44, 5), (44, 1),
(45, 6), (45, 2),
(46, 7), (46, 3),
(47, 8), (47, 4),
(48, 9), (48, 5),
(49, 10), (49, 6),
(50, 1), (50, 7);

-- =====================================================
-- INSERTS PARA Convenio_TipoLavado
-- =====================================================

INSERT INTO Convenio_TipoLavado (id_convenio_lavado, id_tipo_lavado) VALUES
(51, 2), (51, 3),
(55, 3), (55, 6), (55, 10),
(56, 1), (56, 4),
(57, 2), (57, 5),
(58, 3), (58, 7),
(59, 4), (59, 8),
(60, 5), (60, 9),
(61, 6), (61, 10),
(62, 1), (62, 2),
(63, 3), (63, 4),
(64, 5), (64, 6),
(65, 7), (65, 8),
(66, 9), (66, 10),
(67, 1), (67, 3),
(68, 2), (68, 4),
(69, 5), (69, 7),
(70, 6), (70, 8),
(71, 9), (71, 10),
(72, 1), (72, 5),
(73, 2), (73, 6),
(74, 3), (74, 7),
(75, 4), (75, 8),
(76, 5), (76, 9),
(77, 6), (77, 10),
(78, 1), (78, 2),
(79, 3), (79, 4),
(80, 5), (80, 6),
(81, 7), (81, 8),
(82, 9), (82, 10),
(83, 1), (83, 3),
(84, 2), (84, 4),
(85, 5), (85, 7),
(86, 6), (86, 8),
(87, 9), (87, 10),
(88, 1), (88, 4),
(89, 2), (89, 5),
(90, 3), (90, 6),
(91, 4), (91, 7),
(92, 5), (92, 8),
(93, 6), (93, 9),
(94, 7), (94, 10),
(95, 1), (95, 2);

-- =====================================================
-- INSERTS PARA Convenio_Celda
-- =====================================================

INSERT INTO Convenio_Celda (id_convenio, id_celda) VALUES
(6, 26), (6, 27),
(10, 28), (10, 32), (10, 33),
(11, 29), (11, 30),
(12, 31), (12, 34),
(13, 35), (13, 36),
(14, 37), (14, 38),
(15, 39), (15, 40),
(16, 41), (16, 42),
(17, 43), (17, 44),
(18, 45), (18, 26),
(19, 27), (19, 28),
(20, 29), (20, 30),
(21, 31), (21, 32),
(22, 33), (22, 34),
(23, 35), (23, 36),
(24, 37), (24, 38),
(25, 39), (25, 40),
(26, 41), (26, 42),
(27, 43), (27, 44),
(28, 45), (28, 26),
(29, 27), (29, 28),
(30, 29), (30, 30),
(31, 31), (31, 32),
(32, 33), (32, 34),
(33, 35), (33, 36),
(34, 37), (34, 38),
(35, 39), (35, 40),
(36, 41), (36, 42),
(37, 43), (37, 44),
(38, 45), (38, 26),
(39, 27), (39, 28),
(40, 29), (40, 30),
(41, 31), (41, 32),
(42, 33), (42, 34),
(43, 35), (43, 36),
(44, 37), (44, 38),
(45, 39), (45, 40),
(46, 41), (46, 42),
(47, 43), (47, 44),
(48, 45), (48, 26),
(49, 27), (49, 28),
(50, 29), (50, 30);

-- =====================================================
-- INSERTS PARA TARJETA
-- =====================================================

INSERT INTO TARJETA (fecha_hora_emision, codigo_tarjeta, estado_tarjeta, fecha_vencimiento) VALUES
('2024-01-15 08:30:00', 'TJ-2024-0001', 'Activa', '2024-12-31'),
('2024-01-20 09:15:00', 'TJ-2024-0002', 'Activa', '2024-12-31'),
('2024-02-10 10:00:00', 'TJ-2024-0003', 'Activa', '2024-12-31'),
('2024-03-05 11:20:00', 'TJ-2024-0004', 'Activa', '2024-12-31'),
('2024-04-12 08:45:00', 'TJ-2024-0005', 'Activa', '2024-12-31'),
('2024-05-20 13:30:00', 'TJ-2024-0006', 'Activa', '2024-12-31'),
('2024-06-01 09:00:00', 'TJ-2024-0007', 'Activa', '2024-12-31'),
('2024-06-02 09:15:00', 'TJ-2024-0008', 'Inactiva', '2024-12-31'),
('2024-06-03 09:30:00', 'TJ-2024-0009', 'Activa', '2024-12-31'),
('2024-06-04 09:45:00', 'TJ-2024-0010', 'Activa', '2024-12-31'),
('2024-06-05 10:00:00', 'TJ-2024-0011', 'Activa', '2024-12-31'),
('2024-06-06 10:15:00', 'TJ-2024-0012', 'Inactiva', '2024-12-31'),
('2024-06-07 10:30:00', 'TJ-2024-0013', 'Activa', '2024-12-31'),
('2024-06-08 10:45:00', 'TJ-2024-0014', 'Activa', '2024-12-31'),
('2024-06-09 11:00:00', 'TJ-2024-0015', 'Activa', '2024-12-31'),
('2024-06-10 11:15:00', 'TJ-2024-0016', 'Inactiva', '2024-12-31'),
('2024-06-11 11:30:00', 'TJ-2024-0017', 'Activa', '2024-12-31'),
('2024-06-12 11:45:00', 'TJ-2024-0018', 'Activa', '2024-12-31'),
('2024-06-13 12:00:00', 'TJ-2024-0019', 'Activa', '2024-12-31'),
('2024-06-14 12:15:00', 'TJ-2024-0020', 'Inactiva', '2024-12-31'),
('2024-07-01 09:00:00', 'TJ-2024-0021', 'Activa', '2024-12-31'),
('2024-07-02 09:15:00', 'TJ-2024-0022', 'Activa', '2024-12-31'),
('2024-07-03 09:30:00', 'TJ-2024-0023', 'Inactiva', '2024-12-31'),
('2024-07-04 09:45:00', 'TJ-2024-0024', 'Activa', '2024-12-31'),
('2024-07-05 10:00:00', 'TJ-2024-0025', 'Activa', '2024-12-31'),
('2024-07-06 10:15:00', 'TJ-2024-0026', 'Activa', '2024-12-31'),
('2024-07-07 10:30:00', 'TJ-2024-0027', 'Inactiva', '2024-12-31'),
('2024-07-08 10:45:00', 'TJ-2024-0028', 'Activa', '2024-12-31'),
('2024-07-09 11:00:00', 'TJ-2024-0029', 'Activa', '2024-12-31'),
('2024-07-10 11:15:00', 'TJ-2024-0030', 'Activa', '2024-12-31'),
('2024-08-01 09:00:00', 'TJ-2024-0031', 'Activa', '2024-12-31'),
('2024-08-02 09:15:00', 'TJ-2024-0032', 'Inactiva', '2024-12-31'),
('2024-08-03 09:30:00', 'TJ-2024-0033', 'Activa', '2024-12-31'),
('2024-08-04 09:45:00', 'TJ-2024-0034', 'Activa', '2024-12-31'),
('2024-08-05 10:00:00', 'TJ-2024-0035', 'Activa', '2024-12-31'),
('2024-08-06 10:15:00', 'TJ-2024-0036', 'Activa', '2024-12-31'),
('2024-08-07 10:30:00', 'TJ-2024-0037', 'Inactiva', '2024-12-31'),
('2024-08-08 10:45:00', 'TJ-2024-0038', 'Activa', '2024-12-31'),
('2024-08-09 11:00:00', 'TJ-2024-0039', 'Activa', '2024-12-31'),
('2024-08-10 11:15:00', 'TJ-2024-0040', 'Activa', '2024-12-31'),
('2024-09-01 09:00:00', 'TJ-2024-0041', 'Activa', '2024-12-31'),
('2024-09-02 09:15:00', 'TJ-2024-0042', 'Activa', '2024-12-31'),
('2024-09-03 09:30:00', 'TJ-2024-0043', 'Inactiva', '2024-12-31'),
('2024-09-04 09:45:00', 'TJ-2024-0044', 'Activa', '2024-12-31'),
('2024-09-05 10:00:00', 'TJ-2024-0045', 'Activa', '2024-12-31'),
('2024-09-06 10:15:00', 'TJ-2024-0046', 'Activa', '2024-12-31'),
('2024-09-07 10:30:00', 'TJ-2024-0047', 'Inactiva', '2024-12-31'),
('2024-09-08 10:45:00', 'TJ-2024-0048', 'Activa', '2024-12-31'),
('2024-09-09 11:00:00', 'TJ-2024-0049', 'Activa', '2024-12-31'),
('2024-09-10 11:15:00', 'TJ-2024-0050', 'Activa', '2024-12-31'),
('2024-10-01 09:00:00', 'TO-2024-0001', 'Activa', NULL),
('2024-10-02 09:15:00', 'TO-2024-0002', 'Inactiva', NULL),
('2024-10-03 09:30:00', 'TO-2024-0003', 'Activa', NULL),
('2024-10-04 09:45:00', 'TO-2024-0004', 'Activa', NULL),
('2024-10-05 10:00:00', 'TO-2024-0005', 'Activa', NULL),
('2024-10-06 10:15:00', 'TO-2024-0006', 'Inactiva', NULL),
('2024-10-07 10:30:00', 'TO-2024-0007', 'Activa', NULL),
('2024-10-08 10:45:00', 'TO-2024-0008', 'Activa', NULL),
('2024-10-09 11:00:00', 'TO-2024-0009', 'Activa', NULL),
('2024-10-10 11:15:00', 'TO-2024-0010', 'Inactiva', NULL),
('2024-10-11 09:00:00', 'TO-2024-0011', 'Activa', NULL),
('2024-10-12 09:15:00', 'TO-2024-0012', 'Activa', NULL),
('2024-10-13 09:30:00', 'TO-2024-0013', 'Inactiva', NULL),
('2024-10-14 09:45:00', 'TO-2024-0014', 'Activa', NULL),
('2024-10-15 10:00:00', 'TO-2024-0015', 'Activa', NULL),
('2024-10-16 10:15:00', 'TO-2024-0016', 'Activa', NULL),
('2024-10-17 10:30:00', 'TO-2024-0017', 'Inactiva', NULL),
('2024-10-18 10:45:00', 'TO-2024-0018', 'Activa', NULL),
('2024-10-19 11:00:00', 'TO-2024-0019', 'Activa', NULL),
('2024-10-20 11:15:00', 'TO-2024-0020', 'Activa', NULL),
('2024-10-21 09:00:00', 'TO-2024-0021', 'Activa', NULL),
('2024-10-22 09:15:00', 'TO-2024-0022', 'Activa', NULL),
('2024-10-23 09:30:00', 'TO-2024-0023', 'Inactiva', NULL),
('2024-10-24 09:45:00', 'TO-2024-0024', 'Activa', NULL),
('2024-10-25 10:00:00', 'TO-2024-0025', 'Activa', NULL),
('2024-10-26 10:15:00', 'TO-2024-0026', 'Activa', NULL),
('2024-10-27 10:30:00', 'TO-2024-0027', 'Inactiva', NULL),
('2024-10-28 10:45:00', 'TO-2024-0028', 'Activa', NULL),
('2024-10-29 11:00:00', 'TO-2024-0029', 'Activa', NULL),
('2024-10-30 11:15:00', 'TO-2024-0030', 'Activa', NULL),
('2024-11-01 09:00:00', 'TO-2024-0031', 'Activa', NULL),
('2024-11-02 09:15:00', 'TO-2024-0032', 'Inactiva', NULL),
('2024-11-03 09:30:00', 'TO-2024-0033', 'Activa', NULL),
('2024-11-04 09:45:00', 'TO-2024-0034', 'Activa', NULL),
('2024-11-05 10:00:00', 'TO-2024-0035', 'Activa', NULL),
('2024-11-06 10:15:00', 'TO-2024-0036', 'Activa', NULL),
('2024-11-07 10:30:00', 'TO-2024-0037', 'Inactiva', NULL),
('2024-11-08 10:45:00', 'TO-2024-0038', 'Activa', NULL),
('2024-11-09 11:00:00', 'TO-2024-0039', 'Activa', NULL),
('2024-11-10 11:15:00', 'TO-2024-0040', 'Activa', NULL),
('2024-11-11 09:00:00', 'TO-2024-0041', 'Activa', NULL),
('2024-11-12 09:15:00', 'TO-2024-0042', 'Activa', NULL),
('2024-11-13 09:30:00', 'TO-2024-0043', 'Inactiva', NULL),
('2024-11-14 09:45:00', 'TO-2024-0044', 'Activa', NULL),
('2024-11-15 10:00:00', 'TO-2024-0045', 'Activa', NULL),
('2024-11-16 10:15:00', 'TO-2024-0046', 'Activa', NULL),
('2024-11-17 10:30:00', 'TO-2024-0047', 'Inactiva', NULL),
('2024-11-18 10:45:00', 'TO-2024-0048', 'Activa', NULL),
('2024-11-19 11:00:00', 'TO-2024-0049', 'Activa', NULL),
('2024-11-20 11:15:00', 'TO-2024-0050', 'Activa', NULL);

-- =====================================================
-- INSERTS PARA TARJETA_CONVENIO
-- =====================================================

INSERT INTO TARJETA_CONVENIO (id_tarjeta, fecha_expiracion) VALUES
(1, '2024-12-31'),
(2, '2024-12-31'),
(3, '2024-12-31'),
(4, '2024-12-31'),
(5, '2024-12-31'),
(6, '2024-12-31'),
(7, '2024-12-31'),
(8, '2024-12-31'),
(9, '2024-12-31'),
(10, '2024-12-31'),
(11, '2024-12-31'),
(12, '2024-12-31'),
(13, '2024-12-31'),
(14, '2024-12-31'),
(15, '2024-12-31'),
(16, '2024-12-31'),
(17, '2024-12-31'),
(18, '2024-12-31'),
(19, '2024-12-31'),
(20, '2024-12-31'),
(21, '2024-12-31'),
(22, '2024-12-31'),
(23, '2024-12-31'),
(24, '2024-12-31'),
(25, '2024-12-31'),
(26, '2024-12-31'),
(27, '2024-12-31'),
(28, '2024-12-31'),
(29, '2024-12-31'),
(30, '2024-12-31'),
(31, '2024-12-31'),
(32, '2024-12-31'),
(33, '2024-12-31'),
(34, '2024-12-31'),
(35, '2024-12-31'),
(36, '2024-12-31'),
(37, '2024-12-31'),
(38, '2024-12-31'),
(39, '2024-12-31'),
(40, '2024-12-31'),
(41, '2024-12-31'),
(42, '2024-12-31'),
(43, '2024-12-31'),
(44, '2024-12-31'),
(45, '2024-12-31'),
(46, '2024-12-31'),
(47, '2024-12-31'),
(48, '2024-12-31'),
(49, '2024-12-31'),
(50, '2024-12-31');

-- =====================================================
-- INSERTS PARA TARJETA_OCASIONAL
-- =====================================================

INSERT INTO TARJETA_OCASIONAL (id_tarjeta, valor, pagada, hora_entrada, id_pago) VALUES
(51, 7000.00, 0, '2024-11-18 08:00:00', NULL),
(52, 9000.00, 1, '2024-11-18 09:15:00', NULL),
(53, 6500.00, 0, '2024-11-18 10:30:00', NULL),
(54, 12000.00, 1, '2024-11-18 11:45:00', NULL),
(55, 8000.00, 0, '2024-11-18 12:00:00', NULL),
(56, 10000.00, 1, '2024-11-18 13:15:00', NULL),
(57, 7500.00, 0, '2024-11-18 14:30:00', NULL),
(58, 9500.00, 1, '2024-11-18 15:45:00', NULL),
(59, 11000.00, 0, '2024-11-18 16:00:00', NULL),
(60, 8500.00, 1, '2024-11-18 17:15:00', NULL),
(61, 7000.00, 0, '2024-11-19 08:00:00', NULL),
(62, 9000.00, 1, '2024-11-19 09:15:00', NULL),
(63, 6500.00, 0, '2024-11-19 10:30:00', NULL),
(64, 12000.00, 1, '2024-11-19 11:45:00', NULL),
(65, 8000.00, 0, '2024-11-19 12:00:00', NULL),
(66, 10000.00, 1, '2024-11-19 13:15:00', NULL),
(67, 7500.00, 0, '2024-11-19 14:30:00', NULL),
(68, 9500.00, 1, '2024-11-19 15:45:00', NULL),
(69, 11000.00, 0, '2024-11-19 16:00:00', NULL),
(70, 8500.00, 1, '2024-11-19 17:15:00', NULL),
(71, 7000.00, 0, '2024-11-20 08:00:00', NULL),
(72, 9000.00, 1, '2024-11-20 09:15:00', NULL),
(73, 6500.00, 0, '2024-11-20 10:30:00', NULL),
(74, 12000.00, 1, '2024-11-20 11:45:00', NULL),
(75, 8000.00, 0, '2024-11-20 12:00:00', NULL),
(76, 7000.00, 0, '2024-11-21 08:00:00', NULL),
(77, 9000.00, 1, '2024-11-21 09:15:00', NULL),
(78, 6500.00, 0, '2024-11-21 10:30:00', NULL),
(79, 12000.00, 1, '2024-11-21 11:45:00', NULL),
(80, 8000.00, 0, '2024-11-21 12:00:00', NULL),
(81, 10000.00, 1, '2024-11-21 13:15:00', NULL),
(82, 7500.00, 0, '2024-11-21 14:30:00', NULL),
(83, 9500.00, 1, '2024-11-21 15:45:00', NULL),
(84, 11000.00, 0, '2024-11-21 16:00:00', NULL),
(85, 8500.00, 1, '2024-11-21 17:15:00', NULL),
(86, 7000.00, 0, '2024-11-22 08:00:00', NULL),
(87, 9000.00, 1, '2024-11-22 09:15:00', NULL),
(88, 6500.00, 0, '2024-11-22 10:30:00', NULL),
(89, 12000.00, 1, '2024-11-22 11:45:00', NULL),
(90, 8000.00, 0, '2024-11-22 12:00:00', NULL),
(91, 10000.00, 1, '2024-11-22 13:15:00', NULL),
(92, 7500.00, 0, '2024-11-22 14:30:00', NULL),
(93, 9500.00, 1, '2024-11-22 15:45:00', NULL),
(94, 11000.00, 0, '2024-11-22 16:00:00', NULL),
(95, 8500.00, 1, '2024-11-22 17:15:00', NULL),
(96, 7000.00, 0, '2024-11-23 08:00:00', NULL),
(97, 9000.00, 1, '2024-11-23 09:15:00', NULL),
(98, 6500.00, 0, '2024-11-23 10:30:00', NULL),
(99, 12000.00, 1, '2024-11-23 11:45:00', NULL),
(100, 8000.00, 0, '2024-11-23 12:00:00', NULL);

-- =====================================================
-- INSERTS PARA ASIGNACION_CONVENIO
-- =====================================================

INSERT INTO ASIGNACION_CONVENIO 
(fecha_inicio, fecha_fin, id_celda, id_vehiculo, limite_vehiculos, precio_negociado, estado, id_tarjeta, id_convenio) VALUES
('2024-01-01', '2024-12-31', NULL, 1, 1, 180000.00, 'Activo', 1, 1),
('2024-01-01', '2024-12-31', 1, NULL, 1, 250000.00, 'Activo', 2, 2),
('2024-01-01', '2024-12-31', NULL, 2, 1, 120000.00, 'Activo', 3, 3),
('2024-01-01', '2024-12-31', NULL, 3, 1, 150000.00, 'Activo', 4, 4),
('2024-01-01', '2024-12-31', NULL, 4, 1, 95000.00, 'Activo', 5, 5),
('2024-01-01', '2024-12-31', NULL, 5, 1, 200000.00, 'Activo', 6, 6),
('2024-01-01', '2024-12-31', NULL, 6, 3, 300000.00, 'Activo', 7, 7),
('2024-01-01', '2024-12-31', NULL, 7, 1, 140000.00, 'Activo', 8, 8),
('2024-01-01', '2024-12-31', NULL, 8, 1, 80000.00, 'Activo', 9, 9),
('2024-01-01', '2024-12-31', 3, 9, 1, 450000.00, 'Activo', 10, 10),
('2024-01-01', '2024-12-31', 4, 10, 1, 220000.00, 'Activo', 11, 11),
('2024-01-01', '2024-12-31', NULL, 11, 1, 175000.00, 'Activo', 12, 12),
('2024-01-01', '2024-12-31', 5, 12, 1, 195000.00, 'Activo', 13, 13),
('2024-01-01', '2024-12-31', NULL, 13, 1, 205000.00, 'Activo', 14, 14),
('2024-01-01', '2024-12-31', 6, 14, 1, 215000.00, 'Activo', 15, 15),
('2024-01-01', '2024-12-31', NULL, 15, 1, 225000.00, 'Activo', 16, 16),
('2024-01-01', '2024-12-31', 7, 16, 1, 235000.00, 'Activo', 17, 17),
('2024-01-01', '2024-12-31', NULL, 17, 1, 245000.00, 'Activo', 18, 18),
('2024-01-01', '2024-12-31', 8, 18, 1, 255000.00, 'Activo', 19, 19),
('2024-01-01', '2024-12-31', NULL, 19, 1, 265000.00, 'Activo', 20, 20),
('2024-01-01', '2024-12-31', 9, 20, 1, 275000.00, 'Activo', 21, 21),
('2024-01-01', '2024-12-31', NULL, 21, 1, 285000.00, 'Activo', 22, 22),
('2024-01-01', '2024-12-31', 10, 22, 1, 295000.00, 'Activo', 23, 23),
('2024-01-01', '2024-12-31', NULL, 23, 1, 305000.00, 'Activo', 24, 24),
('2024-01-01', '2024-12-31', 11, 24, 1, 315000.00, 'Activo', 25, 25),
('2024-01-01', '2024-12-31', NULL, 25, 1, 325000.00, 'Activo', 26, 26),
('2024-01-01', '2024-12-31', 12, 26, 1, 335000.00, 'Activo', 27, 27),
('2024-01-01', '2024-12-31', NULL, 27, 1, 345000.00, 'Activo', 28, 28),
('2024-01-01', '2024-12-31', 13, 28, 1, 355000.00, 'Activo', 29, 29),
('2024-01-01', '2024-12-31', NULL, 29, 1, 365000.00, 'Activo', 30, 30),
('2024-01-01', '2024-12-31', 14, 30, 1, 375000.00, 'Activo', 31, 31),
('2024-01-01', '2024-12-31', NULL, 31, 1, 385000.00, 'Activo', 32, 32),
('2024-01-01', '2024-12-31', 15, 32, 1, 395000.00, 'Activo', 33, 33),
('2024-01-01', '2024-12-31', NULL, 33, 1, 405000.00, 'Activo', 34, 34),
('2024-01-01', '2024-12-31', 16, 34, 1, 415000.00, 'Activo', 35, 35),
('2024-01-01', '2024-12-31', NULL, 35, 1, 425000.00, 'Activo', 36, 36),
('2024-01-01', '2024-12-31', 17, 36, 1, 435000.00, 'Activo', 36, 37),
('2024-01-01', '2024-12-31', NULL, 37, 1, 445000.00, 'Activo', 38, 38),
('2024-01-01', '2024-12-31', 18, 38, 1, 455000.00, 'Activo', 39, 39),
('2024-01-01', '2024-12-31', NULL, 39, 1, 465000.00, 'Activo', 40, 40),
('2024-01-01', '2024-12-31', 19, 40, 1, 475000.00, 'Activo', 41, 41),
('2024-01-01', '2024-12-31', NULL, 41, 1, 485000.00, 'Activo', 42, 42),
('2024-01-01', '2024-12-31', 20, 42, 1, 495000.00, 'Activo', 43, 43),
('2024-01-01', '2024-12-31', NULL, 43, 1, 505000.00, 'Activo', 44, 44),
('2024-01-01', '2024-12-31', 21, 44, 1, 515000.00, 'Activo', 45, 45),
('2024-01-01', '2024-12-31', NULL, 45, 1, 525000.00, 'Activo', 46, 46),
('2024-01-01', '2024-12-31', 22, 46, 1, 535000.00, 'Activo', 47, 47),
('2024-01-01', '2024-12-31', NULL, 47, 1, 545000.00, 'Activo', 48, 48),
('2024-01-01', '2024-12-31', 23, 48, 1, 555000.00, 'Activo', 49, 49),
('2024-01-01', '2024-12-31', NULL, 49, 1, 565000.00, 'Activo', 50, 50),
('2024-01-01', '2024-12-31', 24, 50, 1, 575000.00, 'Activo', 51, 51),
('2024-01-01', '2024-12-31', NULL, 51, 1, 585000.00, 'Activo', 52, 52),
('2024-01-01', '2024-12-31', 25, 52, 1, 595000.00, 'Activo', 53, 53),
('2024-01-01', '2024-12-31', NULL, 53, 1, 605000.00, 'Activo', 54, 54),
('2024-01-01', '2024-12-31', 26, 54, 1, 615000.00, 'Activo', 55, 55),
('2024-01-01', '2024-12-31', NULL, 55, 1, 625000.00, 'Activo', 56, 56),
('2024-01-01', '2024-12-31', 27, 56, 1, 635000.00, 'Activo', 57, 57),
('2024-01-01', '2024-12-31', NULL, 57, 1, 645000.00, 'Activo', 58, 58),
('2024-01-01', '2024-12-31', 28, 58, 1, 655000.00, 'Activo', 59, 59),
('2024-01-01', '2024-12-31', NULL, 59, 1, 665000.00, 'Activo', 60, 60),
('2024-01-01', '2024-12-31', 29, 60, 1, 675000.00, 'Activo', 61, 61),
('2024-01-01', '2024-12-31', NULL, 61, 1, 685000.00, 'Activo', 62, 62),
('2024-01-01', '2024-12-31', 30, 62, 1, 695000.00, 'Activo', 63, 63),
('2024-01-01', '2024-12-31', NULL, 63, 1, 705000.00, 'Activo', 64, 64),
('2024-01-01', '2024-12-31', 31, 64, 1, 715000.00, 'Activo', 65, 65),
('2024-01-01', '2024-12-31', NULL, 65, 1, 725000.00, 'Activo', 66, 66),
('2024-01-01', '2024-12-31', 32, 66, 1, 735000.00, 'Activo', 67, 67),
('2024-01-01', '2024-12-31', NULL, 67, 1, 745000.00, 'Activo', 68, 68),
('2024-01-01', '2024-12-31', 33, 68, 1, 755000.00, 'Activo', 69, 69),
('2024-01-01', '2024-12-31', NULL, 69, 1, 765000.00, 'Activo', 70, 70),
('2024-01-01', '2024-12-31', 34, 70, 1, 775000.00, 'Activo', 71, 71),
('2024-01-01', '2024-12-31', NULL, 71, 1, 785000.00, 'Activo', 72, 72),
('2024-01-01', '2024-12-31', 35, 72, 1, 795000.00, 'Activo', 73, 73),
('2024-01-01', '2024-12-31', NULL, 73, 1, 805000.00, 'Activo', 74, 74),
('2024-01-01', '2024-12-31', 36, 74, 1, 815000.00, 'Activo', 75, 75),
('2024-01-01', '2024-12-31', NULL, 75, 1, 825000.00, 'Activo', 76, 76),
('2024-01-01', '2024-12-31', 37, 76, 1, 835000.00, 'Activo', 77, 77),
('2024-01-01', '2024-12-31', NULL, 77, 1, 845000.00, 'Activo', 78, 78),
('2024-01-01', '2024-12-31', 38, 78, 1, 855000.00, 'Activo', 79, 79),
('2024-01-01', '2024-12-31', NULL, 79, 1, 865000.00, 'Activo', 80, 80),
('2024-01-01', '2024-12-31', 39, 80, 1, 875000.00, 'Activo', 81, 81),
('2024-01-01', '2024-12-31', NULL, 81, 1, 885000.00, 'Activo', 82, 82),
('2024-01-01', '2024-12-31', 40, 82, 1, 895000.00, 'Activo', 83, 83),
('2024-01-01', '2024-12-31', NULL, 83, 1, 905000.00, 'Activo', 84, 84),
('2024-01-01', '2024-12-31', 41, 84, 1, 915000.00, 'Activo', 85, 85),
('2024-01-01', '2024-12-31', NULL, 85, 1, 925000.00, 'Activo', 86, 86),
('2024-01-01', '2024-12-31', 42, 86, 1, 935000.00, 'Activo', 87, 87),
('2024-01-01', '2024-12-31', NULL, 87, 1, 945000.00, 'Activo', 88, 88),
('2024-01-01', '2024-12-31', 43, 88, 1, 955000.00, 'Activo', 89, 89),
('2024-01-01', '2024-12-31', NULL, 89, 1, 965000.00, 'Activo', 90, 90),
('2024-01-01', '2024-12-31', 44, 90, 1, 975000.00, 'Activo', 91, 91),
('2024-01-01', '2024-12-31', NULL, 91, 1, 985000.00, 'Activo', 92, 92),
('2024-01-01', '2024-12-31', 45, 92, 1, 995000.00, 'Activo', 93, 93),
('2024-01-01', '2024-12-31', NULL, 93, 1, 1005000.00, 'Activo', 94, 94),
('2024-01-01', '2024-12-31', 46, 94, 1, 1015000.00, 'Activo', 95, 95),
('2024-01-01', '2024-12-31', NULL, 95, 1, 1025000.00, 'Activo', 96, 96),
('2024-01-01', '2024-12-31', 47, 96, 1, 1035000.00, 'Activo', 97, 97),
('2024-01-01', '2024-12-31', NULL, 97, 1, 1045000.00, 'Activo', 98, 98),
('2024-01-01', '2024-12-31', 48, 98, 1, 1055000.00, 'Activo', 99, 99),
('2024-01-01', '2024-12-31', NULL, 99, 1, 1065000.00, 'Activo', 100, 100);

-- =====================================================
-- INSERTS PARA PARQUEO
-- =====================================================

INSERT INTO PARQUEO (
    fecha_hora_ingreso, fecha_hora_salida, estado_parqueo, modo_ingreso, valor_cobrado, id_tarjeta, id_celda, id_vehiculo
) VALUES
('2024-11-17 08:00:00','2024-11-17 18:00:00','finalizado','Convenio',0.00,1,1,1),
('2024-11-17 09:30:00',NULL,'activo','Convenio',0.00,2,2,2),
('2024-11-17 14:30:00',NULL,'activo','Ocasional',8000.00,3,3,3),
('2024-11-17 10:00:00','2024-11-17 15:00:00','finalizado','Ocasional',12000.00,4,4,4),
('2024-11-17 07:45:00',NULL,'activo','Convenio',0.00,5,5,5),
('2024-11-17 11:20:00','2024-11-17 17:30:00','finalizado','Convenio',0.00,6,6,6),
('2024-11-17 16:15:00',NULL,'activo','Ocasional',6000.00,7,7,7),
('2024-11-17 13:00:00',NULL,'activo','Convenio',0.00,8,8,8),
('2024-11-17 17:00:00',NULL,'activo','Ocasional',15000.00,9,9,9),
('2024-11-17 06:30:00','2024-11-17 19:00:00','finalizado','Convenio',0.00,10,10,10),
('2024-11-18 08:00:00','2024-11-18 18:00:00','finalizado','Convenio',0.00,11,11,11),
('2024-11-18 09:30:00',NULL,'activo','Convenio',0.00,12,12,12),
('2024-11-18 14:30:00',NULL,'activo','Ocasional',7000.00,13,13,13),
('2024-11-18 10:00:00','2024-11-18 15:00:00','finalizado','Ocasional',9500.00,14,14,14),
('2024-11-18 07:45:00',NULL,'activo','Convenio',0.00,15,15,15),
('2024-11-18 11:20:00','2024-11-18 17:30:00','finalizado','Convenio',0.00,16,16,16),
('2024-11-18 16:15:00',NULL,'activo','Ocasional',8500.00,17,17,17),
('2024-11-18 13:00:00',NULL,'activo','Convenio',0.00,18,18,18),
('2024-11-18 17:00:00',NULL,'activo','Ocasional',11000.00,19,19,19),
('2024-11-18 06:30:00','2024-11-18 19:00:00','finalizado','Convenio',0.00,20,20,20),
('2024-11-19 08:00:00','2024-11-19 18:00:00','finalizado','Convenio',0.00,21,21,21),
('2024-11-19 09:30:00',NULL,'activo','Convenio',0.00,22,22,22),
('2024-11-19 14:30:00',NULL,'activo','Ocasional',6000.00,23,23,23),
('2024-11-19 10:00:00','2024-11-19 15:00:00','finalizado','Ocasional',12500.00,24,24,24),
('2024-11-19 07:45:00',NULL,'activo','Convenio',0.00,25,25,25),
('2024-11-20 08:00:00','2024-11-20 18:00:00','finalizado','Convenio',0.00,26,26,26),
('2024-11-20 09:30:00',NULL,'activo','Convenio',0.00,27,27,27),
('2024-11-20 14:30:00',NULL,'activo','Ocasional',7000.00,28,28,28),
('2024-11-20 10:00:00','2024-11-20 15:00:00','finalizado','Ocasional',9500.00,29,29,29),
('2024-11-20 07:45:00',NULL,'activo','Convenio',0.00,30,30,30),
('2024-11-21 11:20:00','2024-11-21 17:30:00','finalizado','Convenio',0.00,31,31,31),
('2024-11-21 16:15:00',NULL,'activo','Ocasional',8500.00,32,32,32),
('2024-11-21 13:00:00',NULL,'activo','Convenio',0.00,33,33,33),
('2024-11-21 17:00:00',NULL,'activo','Ocasional',11000.00,34,34,34),
('2024-11-21 06:30:00','2024-11-21 19:00:00','finalizado','Convenio',0.00,35,35,35),
('2024-11-22 08:00:00','2024-11-22 18:00:00','finalizado','Convenio',0.00,36,36,36),
('2024-11-22 09:30:00',NULL,'activo','Convenio',0.00,37,37,37),
('2024-11-22 14:30:00',NULL,'activo','Ocasional',6000.00,38,38,38),
('2024-11-22 10:00:00','2024-11-22 15:00:00','finalizado','Ocasional',12500.00,39,39,39),
('2024-11-22 07:45:00',NULL,'activo','Convenio',0.00,40,40,40),
('2024-11-23 11:20:00','2024-11-23 17:30:00','finalizado','Convenio',0.00,41,41,41),
('2024-11-23 16:15:00',NULL,'activo','Ocasional',8500.00,42,42,42),
('2024-11-23 13:00:00',NULL,'activo','Convenio',0.00,43,43,43),
('2024-11-23 17:00:00',NULL,'activo','Ocasional',11000.00,44,44,44),
('2024-11-23 06:30:00','2024-11-23 19:00:00','finalizado','Convenio',0.00,45,45,45),
('2024-11-24 08:00:00','2024-11-24 18:00:00','finalizado','Convenio',0.00,46,46,46),
('2024-11-24 09:30:00',NULL,'activo','Convenio',0.00,47,47,47),
('2024-11-24 14:30:00',NULL,'activo','Ocasional',7000.00,48,48,48),
('2024-11-24 10:00:00','2024-11-24 15:00:00','finalizado','Ocasional',9500.00,49,49,49),
('2024-11-24 07:45:00',NULL,'activo','Convenio',0.00,50,50,50),
('2024-11-25 08:00:00','2024-11-25 18:00:00','finalizado','Convenio',0.00,51,51,51),
('2024-11-25 09:30:00',NULL,'activo','Convenio',0.00,52,52,52),
('2024-11-25 14:30:00',NULL,'activo','Ocasional',7000.00,53,53,53),
('2024-11-25 10:00:00','2024-11-25 15:00:00','finalizado','Ocasional',9500.00,54,54,54),
('2024-11-25 07:45:00',NULL,'activo','Convenio',0.00,55,55,55),
('2024-11-26 11:20:00','2024-11-26 17:30:00','finalizado','Convenio',0.00,56,56,56),
('2024-11-26 16:15:00',NULL,'activo','Ocasional',8500.00,57,57,57),
('2024-11-26 13:00:00',NULL,'activo','Convenio',0.00,58,58,58),
('2024-11-26 17:00:00',NULL,'activo','Ocasional',11000.00,59,59,59),
('2024-11-26 06:30:00','2024-11-26 19:00:00','finalizado','Convenio',0.00,60,60,60),
('2024-11-27 08:00:00','2024-11-27 18:00:00','finalizado','Convenio',0.00,61,61,61),
('2024-11-27 09:30:00',NULL,'activo','Convenio',0.00,62,62,62),
('2024-11-27 14:30:00',NULL,'activo','Ocasional',6000.00,63,63,63),
('2024-11-27 10:00:00','2024-11-27 15:00:00','finalizado','Ocasional',12500.00,64,64,64),
('2024-11-27 07:45:00',NULL,'activo','Convenio',0.00,65,65,65),
('2024-11-28 11:20:00','2024-11-28 17:30:00','finalizado','Convenio',0.00,66,66,66),
('2024-11-28 16:15:00',NULL,'activo','Ocasional',8500.00,67,67,67),
('2024-11-28 13:00:00',NULL,'activo','Convenio',0.00,68,68,68),
('2024-11-28 17:00:00',NULL,'activo','Ocasional',11000.00,69,69,69),
('2024-11-28 06:30:00','2024-11-28 19:00:00','finalizado','Convenio',0.00,70,70,70),
('2024-11-29 08:00:00','2024-11-29 18:00:00','finalizado','Convenio',0.00,71,71,71),
('2024-11-29 09:30:00',NULL,'activo','Convenio',0.00,72,72,72),
('2024-11-29 14:30:00',NULL,'activo','Ocasional',7000.00,73,73,73),
('2024-11-29 10:00:00','2024-11-29 15:00:00','finalizado','Ocasional',9500.00,74,74,74),
('2024-11-29 07:45:00',NULL,'activo','Convenio',0.00,75,75,75),
('2024-11-30 08:00:00','2024-11-30 18:00:00','finalizado','Convenio',0.00,76,76,76),
('2024-11-30 09:30:00',NULL,'activo','Convenio',0.00,77,77,77),
('2024-11-30 14:30:00',NULL,'activo','Ocasional',7000.00,78,78,78),
('2024-11-30 10:00:00','2024-11-30 15:00:00','finalizado','Ocasional',9500.00,79,79,79),
('2024-11-30 07:45:00',NULL,'activo','Convenio',0.00,80,80,80),
('2024-12-01 11:20:00','2024-12-01 17:30:00','finalizado','Convenio',0.00,81,81,81),
('2024-12-01 16:15:00',NULL,'activo','Ocasional',8500.00,82,82,82),
('2024-12-01 13:00:00',NULL,'activo','Convenio',0.00,83,83,83),
('2024-12-01 17:00:00',NULL,'activo','Ocasional',11000.00,84,84,84),
('2024-12-01 06:30:00','2024-12-01 19:00:00','finalizado','Convenio',0.00,85,85,85),
('2024-12-02 08:00:00','2024-12-02 18:00:00','finalizado','Convenio',0.00,86,86,86),
('2024-12-02 09:30:00',NULL,'activo','Convenio',0.00,87,87,87),
('2024-12-02 14:30:00',NULL,'activo','Ocasional',6000.00,88,88,88),
('2024-12-02 10:00:00','2024-12-02 15:00:00','finalizado','Ocasional',12500.00,89,89,89),
('2024-12-02 07:45:00',NULL,'activo','Convenio',0.00,90,90,90),
('2024-12-03 11:20:00','2024-12-03 17:30:00','finalizado','Convenio',0.00,91,91,91),
('2024-12-03 16:15:00',NULL,'activo','Ocasional',8500.00,92,92,92),
('2024-12-03 13:00:00',NULL,'activo','Convenio',0.00,93,93,93),
('2024-12-03 17:00:00',NULL,'activo','Ocasional',11000.00,94,94,94),
('2024-12-03 06:30:00','2024-12-03 19:00:00','finalizado','Convenio',0.00,95,95,95),
('2024-12-04 08:00:00','2024-12-04 18:00:00','finalizado','Convenio',0.00,96,96,96),
('2024-12-04 09:30:00',NULL,'activo','Convenio',0.00,97,97,97),
('2024-12-04 14:30:00',NULL,'activo','Ocasional',7000.00,98,98,98),
('2024-12-04 10:00:00','2024-12-04 15:00:00','finalizado','Ocasional',9500.00,99,99,99),
('2024-12-04 07:45:00',NULL,'activo','Convenio',0.00,100,100,100);

-- =====================================================
-- INSERTS PARA TURNO_LABORAL
-- =====================================================

INSERT INTO TURNO_LABORAL 
(observaciones, estado, horas_trabajadas, fecha_hora_entrada, fecha_hora_salida, id_usuario) VALUES
('Turno normal', 'finalizado', 8.00, '2024-11-17 06:00:00','2024-11-17 14:00:00',1),
('Turno tarde', 'activo', 0.00, '2024-11-17 14:00:00',NULL,2),
('Turno mañana', 'finalizado', 8.00, '2024-11-17 06:00:00','2024-11-17 14:00:00',3),
('Turno completo', 'activo', 0.00, '2024-11-17 08:00:00',NULL,4),
('Turno nocturno', 'finalizado', 8.00, '2024-11-16 22:00:00','2024-11-17 06:00:00',5),
('Turno partido', 'finalizado', 6.00, '2024-11-17 10:00:00','2024-11-17 16:00:00',6),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-16 08:00:00','2024-11-16 18:00:00',7),
('Turno supervisión', 'activo', 0.00, '2024-11-17 07:00:00',NULL,8),
('Turno gerencia', 'activo', 0.00, '2024-11-17 08:00:00',NULL,9),
('Turno administración', 'activo', 0.00, '2024-11-17 09:00:00',NULL,10),
('Turno normal', 'finalizado', 8.00, '2024-11-18 06:00:00','2024-11-18 14:00:00',11),
('Turno tarde', 'activo', 0.00, '2024-11-18 14:00:00',NULL,12),
('Turno mañana', 'finalizado', 8.00, '2024-11-18 06:00:00','2024-11-18 14:00:00',13),
('Turno completo', 'activo', 0.00, '2024-11-18 08:00:00',NULL,14),
('Turno nocturno', 'finalizado', 8.00, '2024-11-17 22:00:00','2024-11-18 06:00:00',15),
('Turno partido', 'finalizado', 6.00, '2024-11-18 10:00:00','2024-11-18 16:00:00',16),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-17 08:00:00','2024-11-17 18:00:00',17),
('Turno supervisión', 'activo', 0.00, '2024-11-18 07:00:00',NULL,18),
('Turno gerencia', 'activo', 0.00, '2024-11-18 08:00:00',NULL,19),
('Turno administración', 'activo', 0.00, '2024-11-18 09:00:00',NULL,20),
('Turno normal', 'finalizado', 8.00, '2024-11-19 06:00:00','2024-11-19 14:00:00',21),
('Turno tarde', 'activo', 0.00, '2024-11-19 14:00:00',NULL,22),
('Turno mañana', 'finalizado', 8.00, '2024-11-19 06:00:00','2024-11-19 14:00:00',23),
('Turno completo', 'activo', 0.00, '2024-11-19 08:00:00',NULL,24),
('Turno nocturno', 'finalizado', 8.00, '2024-11-18 22:00:00','2024-11-19 06:00:00',25),
('Turno normal', 'finalizado', 8.00, '2024-11-20 06:00:00','2024-11-20 14:00:00',26),
('Turno tarde', 'activo', 0.00, '2024-11-20 14:00:00',NULL,27),
('Turno mañana', 'finalizado', 8.00, '2024-11-20 06:00:00','2024-11-20 14:00:00',28),
('Turno completo', 'activo', 0.00, '2024-11-20 08:00:00',NULL,29),
('Turno nocturno', 'finalizado', 8.00, '2024-11-19 22:00:00','2024-11-20 06:00:00',30),
('Turno partido', 'finalizado', 6.00, '2024-11-20 10:00:00','2024-11-20 16:00:00',31),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-19 08:00:00','2024-11-19 18:00:00',32),
('Turno supervisión', 'activo', 0.00, '2024-11-20 07:00:00',NULL,33),
('Turno gerencia', 'activo', 0.00, '2024-11-20 08:00:00',NULL,34),
('Turno administración', 'activo', 0.00, '2024-11-20 09:00:00',NULL,35),
('Turno normal', 'finalizado', 8.00, '2024-11-21 06:00:00','2024-11-21 14:00:00',36),
('Turno tarde', 'activo', 0.00, '2024-11-21 14:00:00',NULL,37),
('Turno mañana', 'finalizado', 8.00, '2024-11-21 06:00:00','2024-11-21 14:00:00',38),
('Turno completo', 'activo', 0.00, '2024-11-21 08:00:00',NULL,39),
('Turno nocturno', 'finalizado', 8.00, '2024-11-20 22:00:00','2024-11-21 06:00:00',40),
('Turno partido', 'finalizado', 6.00, '2024-11-21 10:00:00','2024-11-21 16:00:00',41),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-20 08:00:00','2024-11-20 18:00:00',42),
('Turno supervisión', 'activo', 0.00, '2024-11-21 07:00:00',NULL,43),
('Turno gerencia', 'activo', 0.00, '2024-11-21 08:00:00',NULL,44),
('Turno administración', 'activo', 0.00, '2024-11-21 09:00:00',NULL,45),
('Turno normal', 'finalizado', 8.00, '2024-11-22 06:00:00','2024-11-22 14:00:00',46),
('Turno tarde', 'activo', 0.00, '2024-11-22 14:00:00',NULL,47),
('Turno mañana', 'finalizado', 8.00, '2024-11-22 06:00:00','2024-11-22 14:00:00',48),
('Turno completo', 'activo', 0.00, '2024-11-22 08:00:00',NULL,49),
('Turno nocturno', 'finalizado', 8.00, '2024-11-21 22:00:00','2024-11-22 06:00:00',50),
('Turno normal', 'finalizado', 8.00, '2024-11-23 06:00:00','2024-11-23 14:00:00',51),
('Turno tarde', 'activo', 0.00, '2024-11-23 14:00:00',NULL,52),
('Turno mañana', 'finalizado', 8.00, '2024-11-23 06:00:00','2024-11-23 14:00:00',53),
('Turno completo', 'activo', 0.00, '2024-11-23 08:00:00',NULL,54),
('Turno nocturno', 'finalizado', 8.00, '2024-11-22 22:00:00','2024-11-23 06:00:00',55),
('Turno partido', 'finalizado', 6.00, '2024-11-23 10:00:00','2024-11-23 16:00:00',56),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-22 08:00:00','2024-11-22 18:00:00',57),
('Turno supervisión', 'activo', 0.00, '2024-11-23 07:00:00',NULL,58),
('Turno gerencia', 'activo', 0.00, '2024-11-23 08:00:00',NULL,59),
('Turno administración', 'activo', 0.00, '2024-11-23 09:00:00',NULL,60),
('Turno normal', 'finalizado', 8.00, '2024-11-24 06:00:00','2024-11-24 14:00:00',61),
('Turno tarde', 'activo', 0.00, '2024-11-24 14:00:00',NULL,62),
('Turno mañana', 'finalizado', 8.00, '2024-11-24 06:00:00','2024-11-24 14:00:00',63),
('Turno completo', 'activo', 0.00, '2024-11-24 08:00:00',NULL,64),
('Turno nocturno', 'finalizado', 8.00, '2024-11-23 22:00:00','2024-11-24 06:00:00',65),
('Turno partido', 'finalizado', 6.00, '2024-11-24 10:00:00','2024-11-24 16:00:00',66),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-23 08:00:00','2024-11-23 18:00:00',67),
('Turno supervisión', 'activo', 0.00, '2024-11-24 07:00:00',NULL,68),
('Turno gerencia', 'activo', 0.00, '2024-11-24 08:00:00',NULL,69),
('Turno administración', 'activo', 0.00, '2024-11-24 09:00:00',NULL,70),
('Turno normal', 'finalizado', 8.00, '2024-11-25 06:00:00','2024-11-25 14:00:00',71),
('Turno tarde', 'activo', 0.00, '2024-11-25 14:00:00',NULL,72),
('Turno mañana', 'finalizado', 8.00, '2024-11-25 06:00:00','2024-11-25 14:00:00',73),
('Turno completo', 'activo', 0.00, '2024-11-25 08:00:00',NULL,74),
('Turno nocturno', 'finalizado', 8.00, '2024-11-24 22:00:00','2024-11-25 06:00:00',75),
('Turno normal', 'finalizado', 8.00, '2024-11-26 06:00:00','2024-11-26 14:00:00',76),
('Turno tarde', 'activo', 0.00, '2024-11-26 14:00:00',NULL,77),
('Turno mañana', 'finalizado', 8.00, '2024-11-26 06:00:00','2024-11-26 14:00:00',78),
('Turno completo', 'activo', 0.00, '2024-11-26 08:00:00',NULL,79),
('Turno nocturno', 'finalizado', 8.00, '2024-11-25 22:00:00','2024-11-26 06:00:00',80),
('Turno partido', 'finalizado', 6.00, '2024-11-26 10:00:00','2024-11-26 16:00:00',81),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-25 08:00:00','2024-11-25 18:00:00',82),
('Turno supervisión', 'activo', 0.00, '2024-11-26 07:00:00',NULL,83),
('Turno gerencia', 'activo', 0.00, '2024-11-26 08:00:00',NULL,84),
('Turno administración', 'activo', 0.00, '2024-11-26 09:00:00',NULL,85),
('Turno normal', 'finalizado', 8.00, '2024-11-27 06:00:00','2024-11-27 14:00:00',86),
('Turno tarde', 'activo', 0.00, '2024-11-27 14:00:00',NULL,87),
('Turno mañana', 'finalizado', 8.00, '2024-11-27 06:00:00','2024-11-27 14:00:00',88),
('Turno completo', 'activo', 0.00, '2024-11-27 08:00:00',NULL,89),
('Turno nocturno', 'finalizado', 8.00, '2024-11-26 22:00:00','2024-11-27 06:00:00',90),
('Turno partido', 'finalizado', 6.00, '2024-11-27 10:00:00','2024-11-27 16:00:00',91),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-26 08:00:00','2024-11-26 18:00:00',92),
('Turno supervisión', 'activo', 0.00, '2024-11-27 07:00:00',NULL,93),
('Turno gerencia', 'activo', 0.00, '2024-11-27 08:00:00',NULL,94),
('Turno administración', 'activo', 0.00, '2024-11-27 09:00:00',NULL,95),
('Turno normal', 'finalizado', 8.00, '2024-11-28 06:00:00','2024-11-28 14:00:00',96),
('Turno tarde', 'activo', 0.00, '2024-11-28 14:00:00',NULL,97),
('Turno mañana', 'finalizado', 8.00, '2024-11-28 06:00:00','2024-11-28 14:00:00',98),
('Turno completo', 'activo', 0.00, '2024-11-28 08:00:00',NULL,99),
('Turno nocturno', 'finalizado', 8.00, '2024-11-27 22:00:00','2024-11-28 06:00:00',100);

-- =====================================================
-- INSERTS PARA FACTURA
-- =====================================================

INSERT INTO FACTURA 
(total_bruto, numero_factura, metodo_pago, total_neto, fecha_hora_emision, id_usuario, id_parqueo, id_cliente, id_asignacion_convenio) VALUES
(35000.00, 'FAC-2024-0001', 'Efectivo', 35000.00, '2024-11-17 12:00:00', 1, NULL, 1, NULL),
(12000.00, 'FAC-2024-0002', 'Tarjeta', 12000.00, '2024-11-17 15:00:00', 2, 2, 2, NULL),
(55000.00, 'FAC-2024-0003', 'Transferencia', 55000.00, '2024-11-17 16:30:00', 3, NULL, 3, NULL),
(180000.00, 'FAC-2024-0004', 'Transferencia', 180000.00, '2024-01-15 10:00:00', 4, NULL, 4, 1),
(8000.00, 'FAC-2024-0005', 'Efectivo', 8000.00, '2024-11-17 18:00:00', 5, 5, 5, NULL),
(40000.00, 'FAC-2024-0006', 'Tarjeta', 40000.00, '2024-11-17 14:45:00', 6, NULL, 6, NULL),
(120000.00, 'FAC-2024-0007', 'Transferencia', 120000.00, '2024-02-10 11:00:00', 7, NULL, 7, 3),
(25000.00, 'FAC-2024-0008', 'Efectivo', 25000.00, '2024-11-17 17:15:00', 8, NULL, 8, NULL),
(80000.00, 'FAC-2024-0009', 'Tarjeta', 80000.00, '2024-11-17 19:00:00', 9, NULL, 9, NULL),
(250000.00, 'FAC-2024-0010', 'Transferencia', 250000.00, '2024-01-20 09:30:00', 10, NULL, 10, 2),
(15000.00, 'FAC-2024-0011', 'Efectivo', 15000.00, '2024-11-18 10:00:00', 11, 11, 11, NULL),
(22000.00, 'FAC-2024-0012', 'Tarjeta', 22000.00, '2024-11-18 11:30:00', 12, NULL, 12, NULL),
(60000.00, 'FAC-2024-0013', 'Transferencia', 60000.00, '2024-11-18 12:45:00', 13, NULL, 13, 4),
(9000.00, 'FAC-2024-0014', 'Efectivo', 9000.00, '2024-11-18 13:15:00', 14, 14, 14, NULL),
(45000.00, 'FAC-2024-0015', 'Tarjeta', 45000.00, '2024-11-18 14:30:00', 15, NULL, 15, NULL),
(130000.00, 'FAC-2024-0016', 'Transferencia', 130000.00, '2024-02-15 09:00:00', 16, NULL, 16, 5),
(20000.00, 'FAC-2024-0017', 'Efectivo', 20000.00, '2024-11-18 15:45:00', 17, 17, 17, NULL),
(70000.00, 'FAC-2024-0018', 'Tarjeta', 70000.00, '2024-11-18 16:30:00', 18, NULL, 18, NULL),
(300000.00, 'FAC-2024-0019', 'Transferencia', 300000.00, '2024-03-01 10:30:00', 19, NULL, 19, 6),
(10000.00, 'FAC-2024-0020', 'Efectivo', 10000.00, '2024-11-18 17:00:00', 20, 20, 20, NULL),
(25000.00, 'FAC-2024-0021', 'Tarjeta', 25000.00, '2024-11-18 18:15:00', 21, NULL, 21, NULL),
(95000.00, 'FAC-2024-0022', 'Transferencia', 95000.00, '2024-03-05 09:45:00', 22, NULL, 22, 7),
(18000.00, 'FAC-2024-0023', 'Efectivo', 18000.00, '2024-11-18 19:00:00', 23, 23, 23, NULL),
(50000.00, 'FAC-2024-0024', 'Tarjeta', 50000.00, '2024-11-18 20:00:00', 24, NULL, 24, NULL),
(160000.00, 'FAC-2024-0025', 'Transferencia', 160000.00, '2024-03-10 11:00:00', 25, NULL, 25, 8),
(20000.00, 'FAC-2024-0026', 'Efectivo', 20000.00, '2024-11-19 10:00:00', 26, 26, 1, NULL),
(45000.00, 'FAC-2024-0027', 'Tarjeta', 45000.00, '2024-11-19 11:30:00', 27, NULL, 2, NULL),
(100000.00, 'FAC-2024-0028', 'Transferencia', 100000.00, '2024-03-15 09:00:00', 28, NULL, 3, 9),
(15000.00, 'FAC-2024-0029', 'Efectivo', 15000.00, '2024-11-19 12:15:00', 29, 29, 4, NULL),
(60000.00, 'FAC-2024-0030', 'Tarjeta', 60000.00, '2024-11-19 13:45:00', 30, NULL, 5, NULL),
(175000.00, 'FAC-2024-0031', 'Transferencia', 175000.00, '2024-03-20 10:30:00', 31, NULL, 6, 10),
(22000.00, 'FAC-2024-0032', 'Efectivo', 22000.00, '2024-11-19 14:30:00', 32, 32, 7, NULL),
(50000.00, 'FAC-2024-0033', 'Tarjeta', 50000.00, '2024-11-19 15:15:00', 33, NULL, 8, NULL),
(140000.00, 'FAC-2024-0034', 'Transferencia', 140000.00, '2024-03-25 09:45:00', 34, NULL, 9, 11),
(18000.00, 'FAC-2024-0035', 'Efectivo', 18000.00, '2024-11-19 16:00:00', 35, 35, 10, NULL),
(65000.00, 'FAC-2024-0036', 'Tarjeta', 65000.00, '2024-11-19 17:30:00', 36, NULL, 11, NULL),
(200000.00, 'FAC-2024-0037', 'Transferencia', 200000.00, '2024-04-01 10:00:00', 37, NULL, 12, 12),
(12000.00, 'FAC-2024-0038', 'Efectivo', 12000.00, '2024-11-19 18:15:00', 38, 38, 13, NULL),
(48000.00, 'FAC-2024-0039', 'Tarjeta', 48000.00, '2024-11-19 19:00:00', 39, NULL, 14, NULL),
(155000.00, 'FAC-2024-0040', 'Transferencia', 155000.00, '2024-04-05 11:00:00', 40, NULL, 15, 13),
(25000.00, 'FAC-2024-0041', 'Efectivo', 25000.00, '2024-11-20 10:00:00', 41, 41, 16, NULL),
(70000.00, 'FAC-2024-0042', 'Tarjeta', 70000.00, '2024-11-20 11:30:00', 42, NULL, 17, NULL),
(300000.00, 'FAC-2024-0043', 'Transferencia', 300000.00, '2024-04-10 09:30:00', 43, NULL, 18, 14),
(9000.00, 'FAC-2024-0044', 'Efectivo', 9000.00, '2024-11-20 12:15:00', 44, 44, 19, NULL),
(52000.00, 'FAC-2024-0045', 'Tarjeta', 52000.00, '2024-11-20 13:45:00', 45, NULL, 20, NULL),
(165000.00, 'FAC-2024-0046', 'Transferencia', 165000.00, '2024-04-15 10:30:00', 46, NULL, 21, 15),
(20000.00, 'FAC-2024-0047', 'Efectivo', 20000.00, '2024-11-20 14:30:00', 47, 47, 22, NULL),
(60000.00, 'FAC-2024-0048', 'Tarjeta', 60000.00, '2024-11-20 15:15:00', 48, NULL, 23, NULL),
(145000.00, 'FAC-2024-0049', 'Transferencia', 145000.00, '2024-04-20 09:45:00', 49, NULL, 24, 16),
(18000.00, 'FAC-2024-0050', 'Efectivo', 18000.00, '2024-11-20 16:00:00', 50, 50, 25, NULL),
(22000.00, 'FAC-2024-0051', 'Efectivo', 22000.00, '2024-11-21 10:00:00', 51, 51, 26, NULL),
(48000.00, 'FAC-2024-0052', 'Tarjeta', 48000.00, '2024-11-21 11:30:00', 52, NULL, 27, NULL),
(150000.00, 'FAC-2024-0053', 'Transferencia', 150000.00, '2024-04-25 09:00:00', 53, NULL, 28, 17),
(18000.00, 'FAC-2024-0054', 'Efectivo', 18000.00, '2024-11-21 12:15:00', 54, 54, 29, NULL),
(55000.00, 'FAC-2024-0055', 'Tarjeta', 55000.00, '2024-11-21 13:45:00', 55, NULL, 30, NULL),
(170000.00, 'FAC-2024-0056', 'Transferencia', 170000.00, '2024-04-30 10:30:00', 56, NULL, 31, 18),
(25000.00, 'FAC-2024-0057', 'Efectivo', 25000.00, '2024-11-21 14:30:00', 57, 57, 32, NULL),
(60000.00, 'FAC-2024-0058', 'Tarjeta', 60000.00, '2024-11-21 15:15:00', 58, NULL, 33, NULL),
(135000.00, 'FAC-2024-0059', 'Transferencia', 135000.00, '2024-05-05 09:45:00', 59, NULL, 34, 19),
(20000.00, 'FAC-2024-0060', 'Efectivo', 20000.00, '2024-11-21 16:00:00', 60, 60, 35, NULL),
(70000.00, 'FAC-2024-0061', 'Tarjeta', 70000.00, '2024-11-21 17:30:00', 61, NULL, 36, NULL),
(210000.00, 'FAC-2024-0062', 'Transferencia', 210000.00, '2024-05-10 10:00:00', 62, NULL, 37, 20),
(15000.00, 'FAC-2024-0063', 'Efectivo', 15000.00, '2024-11-21 18:15:00', 63, 63, 38, NULL),
(50000.00, 'FAC-2024-0064', 'Tarjeta', 50000.00, '2024-11-21 19:00:00', 64, NULL, 39, NULL),
(160000.00, 'FAC-2024-0065', 'Transferencia', 160000.00, '2024-05-15 11:00:00', 65, NULL, 40, 21),
(23000.00, 'FAC-2024-0066', 'Efectivo', 23000.00, '2024-11-22 10:00:00', 66, 66, 41, NULL),
(65000.00, 'FAC-2024-0067', 'Tarjeta', 65000.00, '2024-11-22 11:30:00', 67, NULL, 42, NULL),
(145000.00, 'FAC-2024-0068', 'Transferencia', 145000.00, '2024-05-20 09:30:00', 68, NULL, 43, 22),
(17000.00, 'FAC-2024-0069', 'Efectivo', 17000.00, '2024-11-22 12:15:00', 69, 69, 44, NULL),
(52000.00, 'FAC-2024-0070', 'Tarjeta', 52000.00, '2024-11-22 13:45:00', 70, NULL, 45, NULL),
(175000.00, 'FAC-2024-0071', 'Transferencia', 175000.00, '2024-05-25 10:30:00', 71, NULL, 46, 23),
(19000.00, 'FAC-2024-0072', 'Efectivo', 19000.00, '2024-11-22 14:30:00', 72, 72, 47, NULL),
(60000.00, 'FAC-2024-0073', 'Tarjeta', 60000.00, '2024-11-22 15:15:00', 73, NULL, 48, NULL),
(150000.00, 'FAC-2024-0074', 'Transferencia', 150000.00, '2024-05-30 09:45:00', 74, NULL, 49, 24),
(21000.00, 'FAC-2024-0075', 'Efectivo', 21000.00, '2024-11-22 16:00:00', 75, 75, 50, NULL),
(24000.00, 'FAC-2024-0076', 'Efectivo', 24000.00, '2024-11-23 10:00:00', 76, 76, 51, NULL),
(50000.00, 'FAC-2024-0077', 'Tarjeta', 50000.00, '2024-11-23 11:30:00', 77, NULL, 52, NULL),
(155000.00, 'FAC-2024-0078', 'Transferencia', 155000.00, '2024-06-01 09:00:00', 78, NULL, 53, 25),
(19000.00, 'FAC-2024-0079', 'Efectivo', 19000.00, '2024-11-23 12:15:00', 79, 79, 54, NULL),
(58000.00, 'FAC-2024-0080', 'Tarjeta', 58000.00, '2024-11-23 13:45:00', 80, NULL, 55, NULL),
(180000.00, 'FAC-2024-0081', 'Transferencia', 180000.00, '2024-06-05 10:30:00', 81, NULL, 56, 26),
(26000.00, 'FAC-2024-0082', 'Efectivo', 26000.00, '2024-11-23 14:30:00', 82, 82, 57, NULL),
(62000.00, 'FAC-2024-0083', 'Tarjeta', 62000.00, '2024-11-23 15:15:00', 83, NULL, 58, NULL),
(140000.00, 'FAC-2024-0084', 'Transferencia', 140000.00, '2024-06-10 09:45:00', 84, NULL, 59, 27),
(21000.00, 'FAC-2024-0085', 'Efectivo', 21000.00, '2024-11-23 16:00:00', 85, 85, 60, NULL),
(72000.00, 'FAC-2024-0086', 'Tarjeta', 72000.00, '2024-11-23 17:30:00', 86, NULL, 61, NULL),
(220000.00, 'FAC-2024-0087', 'Transferencia', 220000.00, '2024-06-15 10:00:00', 87, NULL, 62, 28),
(16000.00, 'FAC-2024-0088', 'Efectivo', 16000.00, '2024-11-23 18:15:00', 88, 88, 63, NULL),
(52000.00, 'FAC-2024-0089', 'Tarjeta', 52000.00, '2024-11-23 19:00:00', 89, NULL, 64, NULL),
(165000.00, 'FAC-2024-0090', 'Transferencia', 165000.00, '2024-06-20 11:00:00', 90, NULL, 65, 29),
(27000.00, 'FAC-2024-0091', 'Efectivo', 27000.00, '2024-11-24 10:00:00', 91, 91, 66, NULL),
(68000.00, 'FAC-2024-0092', 'Tarjeta', 68000.00, '2024-11-24 11:30:00', 92, NULL, 67, NULL),
(150000.00, 'FAC-2024-0093', 'Transferencia', 150000.00, '2024-06-25 09:30:00', 93, NULL, 68, 30),
(20000.00, 'FAC-2024-0094', 'Efectivo', 20000.00, '2024-11-24 12:15:00', 94, 94, 69, NULL),
(54000.00, 'FAC-2024-0095', 'Tarjeta', 54000.00, '2024-11-24 13:45:00', 95, NULL, 70, NULL),
(170000.00, 'FAC-2024-0096', 'Transferencia', 170000.00, '2024-06-30 10:30:00', 96, NULL, 71, 31),
(21000.00, 'FAC-2024-0097', 'Efectivo', 21000.00, '2024-11-24 14:30:00', 97, 97, 72, NULL),
(60000.00, 'FAC-2024-0098', 'Tarjeta', 60000.00, '2024-11-24 15:15:00', 98, NULL, 73, NULL),
(145000.00, 'FAC-2024-0099', 'Transferencia', 145000.00, '2024-07-05 09:45:00', 99, NULL, 74, 32),
(22000.00, 'FAC-2024-0100', 'Efectivo', 22000.00, '2024-11-24 16:00:00', 100, 100, 75, NULL);

-- =====================================================
-- INSERTS PARA PAGO
-- =====================================================

INSERT INTO PAGO 
(metodo_pago, monto_pago, fecha_hora_pago, referencia_transaccion, id_factura, id_cliente) VALUES
('Efectivo', 35000.00, '2024-11-17 12:00:00', 'EFE-20241117-001', 1, 1),
('Tarjeta', 12000.00, '2024-11-17 15:00:00', 'TRX-20241117-001', 2, 2),
('Transferencia', 55000.00, '2024-11-17 16:30:00', 'TRF-20241117-002', 3, 3),
('Transferencia', 180000.00, '2024-01-15 10:00:00', 'TRF-20240115-001', 4, 4),
('Efectivo', 8000.00, '2024-11-17 18:00:00', 'EFE-20241117-002', 5, 5),
('Tarjeta', 40000.00, '2024-11-17 14:45:00', 'TRX-20241117-003', 6, 6),
('Transferencia', 120000.00, '2024-02-10 11:00:00', 'TRF-20240210-001', 7, 7),
('Efectivo', 25000.00, '2024-11-17 17:15:00', 'EFE-20241117-003', 8, 8),
('Tarjeta', 80000.00, '2024-11-17 19:00:00', 'TRX-20241117-004', 9, 9),
('Transferencia', 250000.00, '2024-01-20 09:30:00', 'TRF-20240120-001', 10, 10),
('Efectivo', 15000.00, '2024-11-18 10:00:00', 'EFE-20241118-001', 11, 11),
('Tarjeta', 22000.00, '2024-11-18 11:30:00', 'TRX-20241118-001', 12, 12),
('Transferencia', 60000.00, '2024-11-18 12:45:00', 'TRF-20241118-001', 13, 13),
('Efectivo', 9000.00, '2024-11-18 13:15:00', 'EFE-20241118-002', 14, 14),
('Tarjeta', 45000.00, '2024-11-18 14:30:00', 'TRX-20241118-002', 15, 15),
('Transferencia', 130000.00, '2024-02-15 09:00:00', 'TRF-20240215-001', 16, 16),
('Efectivo', 20000.00, '2024-11-18 15:45:00', 'EFE-20241118-003', 17, 17),
('Tarjeta', 70000.00, '2024-11-18 16:30:00', 'TRX-20241118-003', 18, 18),
('Transferencia', 300000.00, '2024-03-01 10:30:00', 'TRF-20240301-001', 19, 19),
('Efectivo', 10000.00, '2024-11-18 17:00:00', 'EFE-20241118-004', 20, 20),
('Tarjeta', 25000.00, '2024-11-18 18:15:00', 'TRX-20241118-004', 21, 21),
('Transferencia', 95000.00, '2024-03-05 09:45:00', 'TRF-20240305-001', 22, 22),
('Efectivo', 18000.00, '2024-11-18 19:00:00', 'EFE-20241118-005', 23, 23),
('Tarjeta', 50000.00, '2024-11-18 20:00:00', 'TRX-20241118-005', 24, 24),
('Transferencia', 160000.00, '2024-03-10 11:00:00', 'TRF-20240310-001', 25, 25),
('Efectivo', 20000.00, '2024-11-19 10:00:00', 'EFE-20241119-001', 26, 26),
('Tarjeta', 45000.00, '2024-11-19 11:30:00', 'TRX-20241119-001', 27, 27),
('Transferencia', 100000.00, '2024-03-15 09:00:00', 'TRF-20240315-001', 28, 28),
('Efectivo', 15000.00, '2024-11-19 12:15:00', 'EFE-20241119-002', 29, 29),
('Tarjeta', 60000.00, '2024-11-19 13:45:00', 'TRX-20241119-002', 30, 30),
('Transferencia', 175000.00, '2024-03-20 10:30:00', 'TRF-20240320-001', 31, 31),
('Efectivo', 22000.00, '2024-11-19 14:30:00', 'EFE-20241119-003', 32, 32),
('Tarjeta', 50000.00, '2024-11-19 15:15:00', 'TRX-20241119-003', 33, 33),
('Transferencia', 140000.00, '2024-03-25 09:45:00', 'TRF-20240325-001', 34, 34),
('Efectivo', 18000.00, '2024-11-19 16:00:00', 'EFE-20241119-004', 35, 35),
('Tarjeta', 65000.00, '2024-11-19 17:30:00', 'TRX-20241119-004', 36, 36),
('Transferencia', 200000.00, '2024-04-01 10:00:00', 'TRF-20240401-001', 37, 37),
('Efectivo', 12000.00, '2024-11-19 18:15:00', 'EFE-20241119-005', 38, 38),
('Tarjeta', 48000.00, '2024-11-19 19:00:00', 'TRX-20241119-005', 39, 39),
('Transferencia', 155000.00, '2024-04-05 11:00:00', 'TRF-20240405-001', 40, 40),
('Efectivo', 25000.00, '2024-11-20 10:00:00', 'EFE-20241120-001', 41, 41),
('Tarjeta', 70000.00, '2024-11-20 11:30:00', 'TRX-20241120-001', 42, 42),
('Transferencia', 300000.00, '2024-04-10 09:30:00', 'TRF-20240410-001', 43, 43),
('Efectivo', 9000.00, '2024-11-20 12:15:00', 'EFE-20241120-002', 44, 44),
('Tarjeta', 52000.00, '2024-11-20 13:45:00', 'TRX-20241120-002', 45, 45),
('Transferencia', 165000.00, '2024-04-15 10:30:00', 'TRF-20240415-001', 46, 46),
('Efectivo', 20000.00, '2024-11-20 14:30:00', 'EFE-20241120-003', 47, 47),
('Tarjeta', 60000.00, '2024-11-20 15:15:00', 'TRX-20241120-003', 48, 48),
('Transferencia', 145000.00, '2024-04-20 09:45:00', 'TRF-20240420-001', 49, 49),
('Efectivo', 18000.00, '2024-11-20 16:00:00', 'EFE-20241120-004', 50, 50),
('Efectivo', 22000.00, '2024-11-21 10:00:00', 'EFE-20241121-001', 51, 51),
('Tarjeta', 48000.00, '2024-11-21 11:30:00', 'TRX-20241121-001', 52, 52),
('Transferencia', 150000.00, '2024-04-25 09:00:00', 'TRF-20240425-001', 53, 53),
('Efectivo', 18000.00, '2024-11-21 12:15:00', 'EFE-20241121-002', 54, 54),
('Tarjeta', 55000.00, '2024-11-21 13:45:00', 'TRX-20241121-002', 55, 55),
('Transferencia', 170000.00, '2024-04-30 10:30:00', 'TRF-20240430-001', 56, 56),
('Efectivo', 25000.00, '2024-11-21 14:30:00', 'EFE-20241121-003', 57, 57),
('Tarjeta', 60000.00, '2024-11-21 15:15:00', 'TRX-20241121-003', 58, 58),
('Transferencia', 135000.00, '2024-05-05 09:45:00', 'TRF-20240505-001', 59, 59),
('Efectivo', 20000.00, '2024-11-21 16:00:00', 'EFE-20241121-004', 60, 60),
('Tarjeta', 70000.00, '2024-11-21 17:30:00', 'TRX-20241121-004', 61, 61),
('Transferencia', 210000.00, '2024-05-10 10:00:00', 'TRF-20240510-001', 62, 62),
('Efectivo', 15000.00, '2024-11-21 18:15:00', 'EFE-20241121-005', 63, 63),
('Tarjeta', 50000.00, '2024-11-21 19:00:00', 'TRX-20241121-005', 64, 64),
('Transferencia', 160000.00, '2024-05-15 11:00:00', 'TRF-20240515-001', 65, 65),
('Efectivo', 23000.00, '2024-11-22 10:00:00', 'EFE-20241122-001', 66, 66),
('Tarjeta', 65000.00, '2024-11-22 11:30:00', 'TRX-20241122-001', 67, 67),
('Transferencia', 145000.00, '2024-05-20 09:30:00', 'TRF-20240520-001', 68, 68),
('Efectivo', 17000.00, '2024-11-22 12:15:00', 'EFE-20241122-002', 69, 69),
('Tarjeta', 52000.00, '2024-11-22 13:45:00', 'TRX-20241122-002', 70, 70),
('Transferencia', 175000.00, '2024-05-25 10:30:00', 'TRF-20240525-001', 71, 71),
('Efectivo', 19000.00, '2024-11-22 14:30:00', 'EFE-20241122-003', 72, 72),
('Tarjeta', 60000.00, '2024-11-22 15:15:00', 'TRX-20241122-003', 73, 73),
('Transferencia', 150000.00, '2024-05-30 09:45:00', 'TRF-20240530-001', 74, 74),
('Efectivo', 21000.00, '2024-11-22 16:00:00', 'EFE-20241122-004', 75, 75),
('Efectivo', 24000.00, '2024-11-23 10:00:00', 'EFE-20241123-001', 76, 76),
('Tarjeta', 50000.00, '2024-11-23 11:30:00', 'TRX-20241123-001', 77, 77),
('Transferencia', 155000.00, '2024-06-01 09:00:00', 'TRF-20240601-001', 78, 78),
('Efectivo', 19000.00, '2024-11-23 12:15:00', 'EFE-20241123-002', 79, 79),
('Tarjeta', 58000.00, '2024-11-23 13:45:00', 'TRX-20241123-002', 80, 80),
('Transferencia', 180000.00, '2024-06-05 10:30:00', 'TRF-20240605-001', 81, 81),
('Efectivo', 26000.00, '2024-11-23 14:30:00', 'EFE-20241123-003', 82, 82),
('Tarjeta', 62000.00, '2024-11-23 15:15:00', 'TRX-20241123-003', 83, 83),
('Transferencia', 140000.00, '2024-06-10 09:45:00', 'TRF-20240610-001', 84, 84),
('Efectivo', 21000.00, '2024-11-23 16:00:00', 'EFE-20241123-004', 85, 85),
('Tarjeta', 72000.00, '2024-11-23 17:30:00', 'TRX-20241123-004', 86, 86),
('Transferencia', 220000.00, '2024-06-15 10:00:00', 'TRF-20240615-001', 87, 87),
('Efectivo', 16000.00, '2024-11-23 18:15:00', 'EFE-20241123-005', 88, 88),
('Tarjeta', 52000.00, '2024-11-23 19:00:00', 'TRX-20241123-005', 89, 89),
('Transferencia', 165000.00, '2024-06-20 11:00:00', 'TRF-20240620-001', 90, 90),
('Efectivo', 27000.00, '2024-11-24 10:00:00', 'EFE-20241124-001', 91, 91),
('Tarjeta', 68000.00, '2024-11-24 11:30:00', 'TRX-20241124-001', 92, 92),
('Transferencia', 150000.00, '2024-06-25 09:30:00', 'TRF-20240625-001', 93, 93),
('Efectivo', 20000.00, '2024-11-24 12:15:00', 'EFE-20241124-002', 94, 94),
('Tarjeta', 54000.00, '2024-11-24 13:45:00', 'TRX-20241124-002', 95, 95),
('Transferencia', 170000.00, '2024-06-30 10:30:00', 'TRF-20240630-001', 96, 96),
('Efectivo', 21000.00, '2024-11-24 14:30:00', 'EFE-20241124-003', 97, 97),
('Tarjeta', 60000.00, '2024-11-24 15:15:00', 'TRX-20241124-003', 98, 98),
('Transferencia', 145000.00, '2024-07-05 09:45:00', 'TRF-20240705-001', 99, 99),
('Efectivo', 22000.00, '2024-11-24 16:00:00', 'EFE-20241124-004', 100, 100);

-- =====================================================
-- INSERTS PARA DETALLE_FACTURA
-- =====================================================

INSERT INTO DETALLE_FACTURA (id_factura, id_detalle_factura, cantidad, precio_unitario, servicio_pagado, descripcion, id_parqueo) VALUES
(1, 1, 1, 35000.00, 'Lavado Completo', 'Servicio de lavado completo interior y exterior', NULL),
(2, 1, 1, 12000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 4),
(3, 1, 1, 55000.00, 'Lavado Premium', 'Lavado premium con encerado', NULL),
(4, 1, 1, 180000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de enero', NULL),
(5, 1, 1, 8000.00, 'Parqueo', 'Tarifa parqueo ocasional 10 horas', 1),
(6, 1, 1, 40000.00, 'Limpieza Tapicería', 'Limpieza profunda de tapicería', NULL),
(7, 1, 1, 120000.00, 'Convenio 15 Días', 'Pago convenio 15 días mes de febrero', NULL),
(8, 1, 1, 25000.00, 'Lavado Motor', 'Servicio especializado motor', NULL),
(9, 1, 1, 80000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(10, 1, 1, 250000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de enero', NULL),
(11, 1, 1, 15000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 11),
(12, 1, 1, 22000.00, 'Lavado Básico', 'Lavado exterior básico', NULL),
(13, 1, 1, 60000.00, 'Lavado Premium', 'Lavado premium con tratamiento cerámico', NULL),
(14, 1, 1, 9000.00, 'Parqueo', 'Tarifa parqueo ocasional 4 horas', 14),
(15, 1, 1, 45000.00, 'Limpieza Tapicería', 'Limpieza de asientos y alfombras', NULL),
(16, 1, 1, 130000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de febrero', NULL),
(17, 1, 1, 20000.00, 'Parqueo', 'Tarifa parqueo ocasional 8 horas', 17),
(18, 1, 1, 70000.00, 'Pulido y Encerado', 'Pulido profesional de carrocería', NULL),
(19, 1, 1, 300000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de febrero', NULL),
(20, 1, 1, 10000.00, 'Parqueo', 'Tarifa parqueo ocasional 3 horas', 20),
(21, 1, 1, 25000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(22, 1, 1, 95000.00, 'Lavado Premium', 'Lavado premium con pulido', NULL),
(23, 1, 1, 18000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 23),
(24, 1, 1, 50000.00, 'Limpieza Tapicería', 'Limpieza profunda tapicería cuero', NULL),
(25, 1, 1, 160000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de marzo', NULL),
(26, 1, 1, 20000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 26),
(27, 1, 1, 45000.00, 'Lavado Completo', 'Lavado completo interior y exterior', NULL),
(28, 1, 1, 100000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de marzo', NULL),
(29, 1, 1, 15000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 29),
(30, 1, 1, 60000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(31, 1, 1, 175000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de marzo', NULL),
(32, 1, 1, 22000.00, 'Lavado Básico', 'Lavado exterior básico', NULL),
(33, 1, 1, 50000.00, 'Limpieza Tapicería', 'Limpieza profunda de tapicería', NULL),
(34, 1, 1, 140000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de abril', NULL),
(35, 1, 1, 18000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 35),
(36, 1, 1, 65000.00, 'Lavado Premium', 'Lavado premium con encerado', NULL),
(37, 1, 1, 200000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de abril', NULL),
(38, 1, 1, 12000.00, 'Parqueo', 'Tarifa parqueo ocasional 4 horas', 38),
(39, 1, 1, 48000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(40, 1, 1, 155000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de mayo', NULL),
(41, 1, 1, 25000.00, 'Parqueo', 'Tarifa parqueo ocasional 8 horas', 41),
(42, 1, 1, 70000.00, 'Pulido y Encerado', 'Pulido profesional de carrocería', NULL),
(43, 1, 1, 300000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de mayo', NULL),
(44, 1, 1, 9000.00, 'Parqueo', 'Tarifa parqueo ocasional 3 horas', 44),
(45, 1, 1, 52000.00, 'Limpieza Tapicería', 'Limpieza profunda tapicería cuero', NULL),
(46, 1, 1, 165000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de junio', NULL),
(47, 1, 1, 20000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 47),
(48, 1, 1, 60000.00, 'Lavado Premium', 'Lavado premium con tratamiento cerámico', NULL),
(49, 1, 1, 145000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de junio', NULL),
(50, 1, 1, 18000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 50),
(51, 1, 1, 22000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 51),
(52, 1, 1, 48000.00, 'Lavado Completo', 'Lavado completo interior y exterior', NULL),
(53, 1, 1, 150000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de julio', NULL),
(54, 1, 1, 18000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 54),
(55, 1, 1, 55000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(56, 1, 1, 170000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de julio', NULL),
(57, 1, 1, 25000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(58, 1, 1, 60000.00, 'Lavado Premium', 'Lavado premium con encerado', NULL),
(59, 1, 1, 135000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de agosto', NULL),
(60, 1, 1, 20000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 60),
(61, 1, 1, 70000.00, 'Pulido y Encerado', 'Pulido profesional de carrocería', NULL),
(62, 1, 1, 210000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de agosto', NULL),
(63, 1, 1, 15000.00, 'Parqueo', 'Tarifa parqueo ocasional 4 horas', 63),
(64, 1, 1, 50000.00, 'Limpieza Tapicería', 'Limpieza profunda tapicería cuero', NULL),
(65, 1, 1, 160000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de septiembre', NULL),
(66, 1, 1, 23000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 66),
(67, 1, 1, 65000.00, 'Lavado Premium', 'Lavado premium con tratamiento cerámico', NULL),
(68, 1, 1, 145000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de septiembre', NULL),
(69, 1, 1, 17000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 69),
(70, 1, 1, 52000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(71, 1, 1, 175000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de octubre', NULL),
(72, 1, 1, 19000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 72),
(73, 1, 1, 60000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(74, 1, 1, 150000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de octubre', NULL),
(75, 1, 1, 21000.00, 'Parqueo', 'Tarifa parqueo ocasional 8 horas', 75),
(76, 1, 1, 24000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 76),
(77, 1, 1, 50000.00, 'Lavado Completo', 'Lavado completo interior y exterior', NULL),
(78, 1, 1, 155000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de noviembre', NULL),
(79, 1, 1, 19000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 79),
(80, 1, 1, 58000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(81, 1, 1, 180000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de noviembre', NULL),
(82, 1, 1, 26000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(83, 1, 1, 62000.00, 'Lavado Premium', 'Lavado premium con encerado', NULL),
(84, 1, 1, 140000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de diciembre', NULL),
(85, 1, 1, 21000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 85),
(86, 1, 1, 72000.00, 'Pulido y Encerado', 'Pulido profesional de carrocería', NULL),
(87, 1, 1, 220000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de diciembre', NULL),
(88, 1, 1, 16000.00, 'Parqueo', 'Tarifa parqueo ocasional 4 horas', 88),
(89, 1, 1, 52000.00, 'Limpieza Tapicería', 'Limpieza profunda tapicería cuero', NULL),
(90, 1, 1, 165000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de enero', NULL),
(91, 1, 1, 27000.00, 'Parqueo', 'Tarifa parqueo ocasional 6 horas', 91),
(92, 1, 1, 68000.00, 'Lavado Premium', 'Lavado premium con tratamiento cerámico', NULL),
(93, 1, 1, 150000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de enero', NULL),
(94, 1, 1, 20000.00, 'Parqueo', 'Tarifa parqueo ocasional 5 horas', 94),
(95, 1, 1, 54000.00, 'Lavado Motor', 'Lavado especializado motor', NULL),
(96, 1, 1, 170000.00, 'Convenio Mensual', 'Pago convenio empresarial mes de febrero', NULL),
(97, 1, 1, 21000.00, 'Parqueo', 'Tarifa parqueo ocasional 7 horas', 97),
(98, 1, 1, 60000.00, 'Pulido y Encerado', 'Tratamiento profesional de pintura', NULL),
(99, 1, 1, 145000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de febrero', NULL),
(100, 1, 1, 22000.00, 'Parqueo', 'Tarifa parqueo ocasional 8 horas', 100);

-- =====================================================
-- INSERTS PARA SERVICIO_LAVADO
-- =====================================================

INSERT INTO SERVICIO_LAVADO 
(fecha_hora_inicio, fecha_hora_fin, valor, estado, id_tipo_lavado, id_usuario, id_celda, id_factura, id_cliente, id_vehiculo, id_convenio) VALUES
('2024-11-17 10:00:00','2024-11-17 11:00:00',35000.00,'completado',2,9,1,1,1,1,NULL),
('2024-11-17 14:00:00','2024-11-17 15:45:00',55000.00,'completado',3,9,2,3,3,3,NULL),
('2024-11-17 11:30:00','2024-11-17 12:45:00',40000.00,'completado',7,10,3,6,4,4,NULL),
('2024-11-17 16:00:00','2024-11-17 16:45:00',25000.00,'completado',5,9,4,8,5,5,NULL),
('2024-11-17 17:30:00','2024-11-17 20:00:00',80000.00,'completado',6,10,5,9,6,6,NULL),
('2024-11-17 08:30:00','2024-11-17 09:00:00',15000.00,'completado',1,9,6,NULL,7,7,NULL),
('2024-11-17 12:00:00',NULL,35000.00,'en_proceso',2,10,7,NULL,8,8,NULL),
('2024-11-17 15:30:00','2024-11-17 15:45:00',10000.00,'completado',4,9,8,NULL,9,9,NULL),
('2024-11-17 09:00:00','2024-11-17 09:50:00',30000.00,'completado',9,10,9,NULL,10,10,NULL),
('2024-11-16 16:00:00','2024-11-16 18:30:00',80000.00,'completado',6,9,10,NULL,1,2,6),
('2024-11-18 10:00:00','2024-11-18 11:00:00',35000.00,'completado',2,11,11,11,11,11,NULL),
('2024-11-18 14:00:00','2024-11-18 15:45:00',55000.00,'completado',3,12,12,12,12,12,NULL),
('2024-11-18 11:30:00','2024-11-18 12:45:00',40000.00,'completado',7,13,13,13,13,13,NULL),
('2024-11-18 16:00:00','2024-11-18 16:45:00',25000.00,'completado',5,14,14,14,14,14,NULL),
('2024-11-18 17:30:00','2024-11-18 20:00:00',80000.00,'completado',6,15,15,15,15,15,NULL),
('2024-11-18 08:30:00','2024-11-18 09:00:00',15000.00,'completado',1,16,16,NULL,16,16,NULL),
('2024-11-18 12:00:00',NULL,35000.00,'en_proceso',2,17,17,NULL,17,17,NULL),
('2024-11-18 15:30:00','2024-11-18 15:45:00',10000.00,'completado',4,18,18,NULL,18,18,NULL),
('2024-11-18 09:00:00','2024-11-18 09:50:00',30000.00,'completado',9,19,19,NULL,19,19,NULL),
('2024-11-18 16:00:00','2024-11-18 18:30:00',80000.00,'completado',6,20,20,NULL,20,20,7),
('2024-11-19 10:00:00','2024-11-19 11:00:00',35000.00,'completado',2,21,21,21,21,21,NULL),
('2024-11-19 14:00:00','2024-11-19 15:45:00',55000.00,'completado',3,22,22,22,22,22,NULL),
('2024-11-19 11:30:00','2024-11-19 12:45:00',40000.00,'completado',7,23,23,23,23,23,NULL),
('2024-11-19 16:00:00','2024-11-19 16:45:00',25000.00,'completado',5,24,24,24,24,24,NULL),
('2024-11-19 17:30:00','2024-11-19 20:00:00',80000.00,'completado',6,25,25,25,25,25,NULL),
('2024-11-19 08:00:00','2024-11-19 09:00:00',20000.00,'completado',1,26,26,26,26,26,NULL),
('2024-11-19 09:30:00','2024-11-19 10:45:00',45000.00,'completado',2,27,27,27,27,27,NULL),
('2024-11-19 11:00:00','2024-11-19 12:15:00',100000.00,'completado',3,28,28,28,28,28,NULL),
('2024-11-19 13:00:00','2024-11-19 14:00:00',15000.00,'completado',4,29,29,29,29,29,NULL),
('2024-11-19 15:00:00','2024-11-19 16:30:00',60000.00,'completado',5,30,30,30,30,30,NULL),
('2024-11-19 17:00:00','2024-11-19 18:30:00',175000.00,'completado',6,31,31,31,31,31,NULL),
('2024-11-20 08:00:00','2024-11-20 09:00:00',22000.00,'completado',7,32,32,32,32,32,NULL),
('2024-11-20 09:30:00','2024-11-20 10:45:00',50000.00,'completado',8,33,33,33,33,33,NULL),
('2024-11-20 11:00:00','2024-11-20 12:15:00',140000.00,'completado',9,34,34,34,34,34,NULL),
('2024-11-20 13:00:00','2024-11-20 14:00:00',18000.00,'completado',1,35,35,35,35,35,NULL),
('2024-11-20 15:00:00','2024-11-20 16:30:00',65000.00,'completado',2,36,36,36,36,36,NULL),
('2024-11-20 17:00:00','2024-11-20 18:30:00',200000.00,'completado',3,37,37,37,37,37,NULL),
('2024-11-21 08:00:00','2024-11-21 09:00:00',12000.00,'completado',4,38,38,38,38,38,NULL),
('2024-11-21 09:30:00','2024-11-21 10:45:00',48000.00,'completado',5,39,39,39,39,39,NULL),
('2024-11-21 11:00:00','2024-11-21 12:15:00',155000.00,'completado',6,40,40,40,40,40,NULL),
('2024-11-21 13:00:00','2024-11-21 14:00:00',25000.00,'completado',7,41,41,41,41,41,NULL),
('2024-11-21 15:00:00','2024-11-21 16:30:00',70000.00,'completado',8,42,42,42,42,42,NULL),
('2024-11-21 17:00:00','2024-11-21 18:30:00',300000.00,'completado',9,43,43,43,43,43,NULL),
('2024-11-22 08:00:00','2024-11-22 09:00:00',9000.00,'completado',1,44,44,44,44,44,NULL),
('2024-11-22 09:30:00','2024-11-22 10:45:00',52000.00,'completado',2,45,45,45,45,45,NULL),
('2024-11-22 11:00:00','2024-11-22 12:15:00',165000.00,'completado',3,46,46,46,46,46,NULL),
('2024-11-22 13:00:00','2024-11-22 14:00:00',20000.00,'completado',4,47,47,47,47,47,NULL),
('2024-11-22 15:00:00','2024-11-22 16:30:00',60000.00,'completado',5,48,48,48,48,48,NULL),
('2024-11-22 17:00:00','2024-11-22 18:30:00',145000.00,'completado',6,49,49,49,49,49,NULL),
('2024-11-23 08:00:00','2024-11-23 09:00:00',18000.00,'completado',7,50,50,50,50,50,NULL),
('2024-11-23 10:00:00','2024-11-23 11:00:00',22000.00,'completado',1,51,51,51,51,51,NULL),
('2024-11-23 12:00:00','2024-11-23 13:15:00',48000.00,'completado',2,52,52,52,52,52,NULL),
('2024-11-23 14:00:00','2024-11-23 15:30:00',150000.00,'completado',3,53,53,53,53,53,NULL),
('2024-11-23 16:00:00','2024-11-23 17:00:00',18000.00,'completado',4,54,54,54,54,54,NULL),
('2024-11-23 18:00:00','2024-11-23 19:30:00',55000.00,'completado',5,55,55,55,55,55,NULL),
('2024-11-24 08:00:00','2024-11-24 09:30:00',170000.00,'completado',6,56,56,56,56,56,NULL),
('2024-11-24 10:00:00','2024-11-24 11:00:00',25000.00,'completado',7,57,57,57,57,57,NULL),
('2024-11-24 12:00:00','2024-11-24 13:15:00',60000.00,'completado',8,58,58,58,58,58,NULL),
('2024-11-24 14:00:00','2024-11-24 15:30:00',135000.00,'completado',9,59,59,59,59,59,NULL),
('2024-11-24 16:00:00','2024-11-24 17:00:00',20000.00,'completado',1,60,60,60,60,60,NULL),
('2024-11-24 18:00:00','2024-11-24 19:30:00',70000.00,'completado',2,61,61,61,61,61,NULL),
('2024-11-25 08:00:00','2024-11-25 09:30:00',210000.00,'completado',3,62,62,62,62,62,NULL),
('2024-11-25 10:00:00','2024-11-25 11:00:00',15000.00,'completado',4,63,63,63,63,63,NULL),
('2024-11-25 12:00:00','2024-11-25 13:15:00',50000.00,'completado',5,64,64,64,64,64,NULL),
('2024-11-25 14:00:00','2024-11-25 15:30:00',160000.00,'completado',6,65,65,65,65,65,NULL),
('2024-11-25 16:00:00','2024-11-25 17:00:00',23000.00,'completado',7,66,66,66,66,66,NULL),
('2024-11-25 18:00:00','2024-11-25 19:30:00',65000.00,'completado',8,67,67,67,67,67,NULL),
('2024-11-26 08:00:00','2024-11-26 09:30:00',145000.00,'completado',9,68,68,68,68,68,NULL),
('2024-11-26 10:00:00','2024-11-26 11:00:00',17000.00,'completado',1,69,69,69,69,69,NULL),
('2024-11-26 12:00:00','2024-11-26 13:15:00',52000.00,'completado',2,70,70,70,70,70,NULL),
('2024-11-26 14:00:00','2024-11-26 15:30:00',175000.00,'completado',3,71,71,71,71,71,NULL),
('2024-11-26 16:00:00','2024-11-26 17:00:00',19000.00,'completado',4,72,72,72,72,72,NULL),
('2024-11-26 18:00:00','2024-11-26 19:30:00',60000.00,'completado',5,73,73,73,73,73,NULL),
('2024-11-27 08:00:00','2024-11-27 09:30:00',150000.00,'completado',6,74,74,74,74,74,NULL),
('2024-11-27 10:00:00','2024-11-27 11:00:00',21000.00,'completado',7,75,75,75,75,75,NULL),
('2024-11-27 12:00:00','2024-11-27 13:00:00',24000.00,'completado',1,76,76,76,76,76,NULL),
('2024-11-27 14:00:00','2024-11-27 15:15:00',50000.00,'completado',2,77,77,77,77,77,NULL),
('2024-11-27 16:00:00','2024-11-27 17:30:00',155000.00,'completado',3,78,78,78,78,78,NULL),
('2024-11-27 18:00:00','2024-11-27 19:00:00',19000.00,'completado',4,79,79,79,79,79,NULL),
('2024-11-28 08:00:00','2024-11-28 09:30:00',58000.00,'completado',5,80,80,80,80,80,NULL),
('2024-11-28 10:00:00','2024-11-28 11:30:00',180000.00,'completado',6,81,81,81,81,81,NULL),
('2024-11-28 12:00:00','2024-11-28 13:00:00',26000.00,'completado',7,82,82,82,82,82,NULL),
('2024-11-28 14:00:00','2024-11-28 15:15:00',62000.00,'completado',8,83,83,83,83,83,NULL),
('2024-11-28 16:00:00','2024-11-28 17:30:00',140000.00,'completado',9,84,84,84,84,84,NULL),
('2024-11-28 18:00:00','2024-11-28 19:00:00',21000.00,'completado',1,85,85,85,85,85,NULL),
('2024-11-29 08:00:00','2024-11-29 09:30:00',72000.00,'completado',2,86,86,86,86,86,NULL),
('2024-11-29 10:00:00','2024-11-29 11:30:00',220000.00,'completado',3,87,87,87,87,87,NULL),
('2024-11-29 12:00:00','2024-11-29 13:00:00',16000.00,'completado',4,88,88,88,88,88,NULL),
('2024-11-29 14:00:00','2024-11-29 15:15:00',52000.00,'completado',5,89,89,89,89,89,NULL),
('2024-11-29 16:00:00','2024-11-29 17:30:00',165000.00,'completado',6,90,90,90,90,90,NULL),
('2024-11-29 18:00:00','2024-11-29 19:00:00',27000.00,'completado',7,91,91,91,91,91,NULL),
('2024-11-30 08:00:00','2024-11-30 09:30:00',68000.00,'completado',8,92,92,92,92,92,NULL),
('2024-11-30 10:00:00','2024-11-30 11:30:00',150000.00,'completado',9,93,93,93,93,93,NULL),
('2024-11-30 12:00:00','2024-11-30 13:00:00',20000.00,'completado',1,94,94,94,94,94,NULL),
('2024-11-30 14:00:00','2024-11-30 15:15:00',54000.00,'completado',2,95,95,95,95,95,NULL),
('2024-11-30 16:00:00','2024-11-30 17:30:00',170000.00,'completado',3,96,96,96,96,96,NULL),
('2024-11-30 18:00:00','2024-11-30 19:00:00',21000.00,'completado',4,97,97,97,97,97,NULL),
('2024-12-01 08:00:00','2024-12-01 09:30:00',60000.00,'completado',5,98,98,98,98,98,NULL),
('2024-12-01 10:00:00','2024-12-01 11:30:00',145000.00,'completado',6,99,99,99,99,99,NULL),
('2024-12-01 12:00:00','2024-12-01 13:00:00',22000.00,'completado',7,100,100,100,100,100,NULL);

-- =====================================================
-- INSERTS PARA TARIFA_LAVADO
-- =====================================================

INSERT INTO TARIFA_LAVADO (precio, activo, tiempo_estimado, id_tipo_lavado, id_tipo_vehiculo, id_servicio_lavado) VALUES
(15000,1,30,1,1,1),
(20000,1,40,2,2,2),
(25000,1,50,3,3,3),
(30000,1,60,4,4,4),
(35000,1,70,5,5,5),
(40000,1,80,6,6,6),
(45000,1,90,7,7,7),
(50000,1,100,8,8,8),
(55000,1,110,9,9,9),
(60000,1,120,10,10,10),
(15000,1,25,11,11,11),
(20000,1,35,12,12,12),
(25000,1,45,13,13,13),
(30000,1,55,14,14,14),
(35000,1,65,15,15,15),
(40000,1,75,16,16,16),
(45000,1,85,17,17,17),
(50000,1,95,18,18,18),
(55000,1,105,19,19,19),
(60000,1,115,20,20,20),
(15000,1,28,21,21,21),
(20000,1,38,22,22,22),
(25000,1,48,23,23,23),
(30000,1,58,24,24,24),
(35000,1,68,25,25,25),
(40000,1,78,26,26,26),
(45000,1,88,27,27,27),
(50000,1,98,28,28,28),
(55000,1,108,29,29,29),
(60000,1,118,30,30,30),
(15000,1,32,31,31,31),
(20000,1,42,32,32,32),
(25000,1,52,33,33,33),
(30000,1,62,34,34,34),
(35000,1,72,35,35,35),
(40000,1,82,36,36,36),
(45000,1,92,37,37,37),
(50000,1,102,38,38,38),
(55000,1,112,39,39,39),
(60000,1,122,40,40,40),
(15000,1,34,41,41,41),
(20000,1,44,42,42,42),
(25000,1,54,43,43,43),
(30000,1,64,44,44,44),
(35000,1,74,45,45,45),
(40000,1,84,46,46,46),
(45000,1,94,47,47,47),
(50000,1,104,48,48,48),
(55000,1,114,49,49,49),
(60000,1,124,50,50,50),
(15000,1,36,51,51,51),
(20000,1,46,52,52,52),
(25000,1,56,53,53,53),
(30000,1,66,54,54,54),
(35000,1,76,55,55,55),
(40000,1,86,56,56,56),
(45000,1,96,57,57,57),
(50000,1,106,58,58,58),
(55000,1,116,59,59,59),
(60000,1,126,60,60,60),
(15000,1,38,61,61,61),
(20000,1,48,62,62,62),
(25000,1,58,63,63,63),
(30000,1,68,64,64,64),
(35000,1,78,65,65,65),
(40000,1,88,66,66,66),
(45000,1,98,67,67,67),
(50000,1,108,68,68,68),
(55000,1,118,69,69,69),
(60000,1,128,70,70,70),
(15000,1,40,71,71,71),
(20000,1,50,72,72,72),
(25000,1,60,73,73,73),
(30000,1,70,74,74,74),
(35000,1,80,75,75,75),
(40000,1,90,76,76,76),
(45000,1,100,77,77,77),
(50000,1,110,78,78,78),
(55000,1,120,79,79,79),
(60000,1,130,80,80,80),
(15000,1,42,81,81,81),
(20000,1,52,82,82,82),
(25000,1,62,83,83,83),
(30000,1,72,84,84,84),
(35000,1,82,85,85,85),
(40000,1,92,86,86,86),
(45000,1,102,87,87,87),
(50000,1,112,88,88,88),
(55000,1,122,89,89,89),
(60000,1,132,90,90,90),
(15000,1,44,91,91,91),
(20000,1,54,92,92,92),
(25000,1,64,93,93,93),
(30000,1,74,94,94,94),
(35000,1,84,95,95,95),
(40000,1,94,96,96,96),
(45000,1,104,97,97,97),
(50000,1,114,98,98,98),
(55000,1,124,99,99,99),
(60000,1,134,100,100,100);

-- =====================================================
-- INSERTS PARA TURNO_LAVADO
-- =====================================================

INSERT INTO TURNO_LAVADO 
(fecha, fecha_hora_inicio, fecha_hora_salida, estado, id_tipo_lavado, id_vehiculo, id_usuario, id_celda_lavado, id_servicio_lavado) 
VALUES
('2024-11-01','08:00:00','09:00:00','Completado',1,1,1,26,1),
('2024-11-01','09:15:00','10:30:00','En Proceso',2,2,2,27,2),
('2024-11-01','10:45:00','12:00:00','Pendiente',3,3,3,28,3),
('2024-11-01','12:15:00','13:00:00','Completado',4,4,4,29,4),
('2024-11-01','13:30:00','14:45:00','Completado',5,5,5,30,5),
('2024-11-02','08:00:00','09:00:00','Completado',6,6,6,31,6),
('2024-11-02','09:15:00','10:15:00','En Proceso',7,7,7,32,7),
('2024-11-02','10:30:00','11:30:00','Completado',8,8,8,33,8),
('2024-11-02','12:00:00','13:15:00','Pendiente',9,9,9,34,9),
('2024-11-02','13:30:00','14:00:00','Completado',10,10,10,35,10),
('2024-11-03','08:15:00','09:00:00','Completado',11,11,11,36,11),
('2024-11-03','09:30:00','10:45:00','En Proceso',12,12,12,37,12),
('2024-11-03','11:00:00','12:00:00','Completado',13,13,13,38,13),
('2024-11-03','12:30:00','13:45:00','Pendiente',14,14,14,39,14),
('2024-11-03','14:00:00','15:00:00','Completado',15,15,15,40,15),
('2024-11-04','08:00:00','09:10:00','Completado',16,16,16,41,16),
('2024-11-04','09:30:00','10:00:00','Pendiente',17,17,17,42,17),
('2024-11-04','10:15:00','11:15:00','Completado',18,18,18,43,18),
('2024-11-04','11:45:00','13:00:00','En Proceso',19,19,19,44,19),
('2024-11-04','13:15:00','14:15:00','Completado',20,20,20,45,20),
('2024-11-05','08:00:00','09:30:00','Completado',21,21,21,46,21),
('2024-11-05','09:45:00','10:30:00','En Proceso',22,22,22,47,22),
('2024-11-05','11:00:00','12:00:00','Completado',23,23,23,48,23),
('2024-11-05','12:30:00','13:00:00','Pendiente',24,24,24,49,24),
('2024-11-05','13:15:00','14:45:00','Completado',25,25,25,50,25);

-- =====================================================
-- FIN DE LOS INSERTS
-- =====================================================
-- =====================================================
-- CONSULTA PARA VERIFICAR CANTIDAD DE REGISTROS POR TABLA
-- =====================================================
SELECT 'TIPO_LAVADO' as Tabla, COUNT(*) as Total FROM TIPO_LAVADO
UNION ALL SELECT 'USUARIO', COUNT(*) FROM USUARIO
UNION ALL SELECT 'GERENTE', COUNT(*) FROM GERENTE
UNION ALL SELECT 'ADMINISTRADOR', COUNT(*) FROM ADMINISTRADOR
UNION ALL SELECT 'SUPERVISOR', COUNT(*) FROM SUPERVISOR
UNION ALL SELECT 'OPERARIO', COUNT(*) FROM OPERARIO
UNION ALL SELECT 'LAVADOR', COUNT(*) FROM LAVADOR
UNION ALL SELECT 'SEDE', COUNT(*) FROM SEDE
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL SELECT 'VEHICULO', COUNT(*) FROM VEHICULO
UNION ALL SELECT 'TIPO_VEHICULO', COUNT(*) FROM TIPO_VEHICULO
UNION ALL SELECT 'CELDA', COUNT(*) FROM CELDA
UNION ALL SELECT 'CONVENIO', COUNT(*) FROM CONVENIO
UNION ALL SELECT 'TARJETA', COUNT(*) FROM TARJETA
UNION ALL SELECT 'ASIGNACION_CONVENIO', COUNT(*) FROM ASIGNACION_CONVENIO
UNION ALL SELECT 'PARQUEO', COUNT(*) FROM PARQUEO
UNION ALL SELECT 'TURNO_LABORAL', COUNT(*) FROM TURNO_LABORAL
UNION ALL SELECT 'FACTURA', COUNT(*) FROM FACTURA
UNION ALL SELECT 'PAGO', COUNT(*) FROM PAGO
UNION ALL SELECT 'DETALLE_FACTURA', COUNT(*) FROM DETALLE_FACTURA
UNION ALL SELECT 'SERVICIO_LAVADO', COUNT(*) FROM SERVICIO_LAVADO
UNION ALL SELECT 'TARIFA_LAVADO', COUNT(*) FROM TARIFA_LAVADO
UNION ALL SELECT 'TURNO_LAVADO', COUNT(*) FROM TURNO_LAVADO
UNION ALL SELECT 'CELDA_LAVADO', COUNT(*) FROM CELDA_LAVADO
UNION ALL SELECT 'TARJETA_OCASIONAL', COUNT(*) FROM TARJETA_OCASIONAL
UNION ALL SELECT 'CONVENIO_PARQUEADERO', COUNT(*) FROM CONVENIO_PARQUEADERO
UNION ALL SELECT 'CONVENIO_LAVADO', COUNT(*) FROM CONVENIO_LAVADO
UNION ALL SELECT 'CONVENIO_IRRESTRICTIVO', COUNT(*) FROM CONVENIO_IRRESTRICTIVO
UNION ALL SELECT 'CONVENIO_CELDA_FIJA', COUNT(*) FROM CONVENIO_CELDA_FIJA
UNION ALL SELECT 'CONVENIO_DIAS_MES', COUNT(*) FROM CONVENIO_DIAS_MES
UNION ALL SELECT 'CONVENIO_HORAS_MES', COUNT(*) FROM CONVENIO_HORAS_MES
UNION ALL SELECT 'CONVENIO_DIA_PLACA', COUNT(*) FROM CONVENIO_DIA_PLACA
UNION ALL SELECT 'CELDA_PARQUEO', COUNT(*) FROM CELDA_PARQUEO
UNION ALL SELECT 'TIPO_LAVADO', COUNT(*) FROM TIPO_LAVADO
UNION ALL SELECT 'CELDA_RECARGA_ELECTRICA', COUNT(*) FROM CELDA_RECARGA_ELECTRICA
UNION ALL SELECT 'CELDA_MOVILIDAD_REDUCIDA', COUNT(*) FROM CELDA_MOVILIDAD_REDUCIDA
UNION ALL SELECT 'TURNO_LAVADO', COUNT(*) FROM TURNO_LAVADO
UNION ALL SELECT 'Vehiculo_TipoVehiculo', COUNT(*) FROM Vehiculo_TipoVehiculo
UNION ALL SELECT 'Convenio_TipoLavado', COUNT(*) FROM Convenio_TipoLavado
UNION ALL SELECT 'Convenio_Celda', COUNT(*) FROM Convenio_Celda
UNION ALL SELECT 'Convenio_TipoVehiculo', COUNT(*) FROM Convenio_TipoVehiculo
UNION ALL SELECT 'Celda_TipoVehiculo', COUNT(*) FROM Celda_TipoVehiculo
UNION ALL SELECT 'Convenio_Sede', COUNT(*) FROM Convenio_Sede
ORDER BY Tabla;

-- =======================================================================================================================
/* Hacer 4 consultas útiles para el usuario, que implementen los 4 tipos de JOINS que hay.
Cada consulta debe ir con su respectivo Enunciado, y debe generar algún resultado.*/
-- =======================================================================================================================
/* 1 Creacion de consulta con INNER JOIN
Autor: David Martinez
Enunciado : Mostrar los parqueos realizados, junto con la información del vehículo y la sede donde se estacionó.
El objetivo es que el usuario pueda ver los movimientos de parqueo con su contexto completo.*/
-- =======================================================================================================================
SELECT 
    p.id_parqueo,
    p.fecha_hora_ingreso,
    p.fecha_hora_salida,
    v.placa,
    v.marca,
    v.modelo,
    s.nombre AS nombre_sede,
    p.estado_parqueo
FROM PARQUEO p
INNER JOIN VEHICULO v ON p.id_vehiculo = v.id_vehiculo
INNER JOIN CELDA c ON p.id_celda = c.id_celda
INNER JOIN SEDE s ON c.id_sede = s.id_sede;
-- =======================================================================================================================
/* 2 Creacion de consulta con LEFT JOIN
Autor: David Martinez
Enunciado : Mostrar todos los clientes registrados, junto con los vehículos que tienen.  */
-- =======================================================================================================================
SELECT 
    c.id_cliente,
    c.documento,
    c.nombre AS nombre_cliente,
    c.telefono,
    v.id_vehiculo,
    v.placa,
    v.marca,
    v.modelo,
    v.color
FROM CLIENTE AS c
LEFT JOIN VEHICULO AS v
    ON v.id_cliente = c.id_cliente;
-- =======================================================================================================================
 /* 3 Creacion de consulta con RIGHT JOIN 
Autor: David Martinez
Enunciado : Mostrar todos los lavados realizados, junto con su factura asociada (si existe).
Si hay algún lavado que todavía no ha sido facturado, debe aparecer igualmente. */
-- =======================================================================================================================
SELECT
    f.id_factura,
    sl.id_servicio_lavado,
    sl.fecha_hora_inicio,
    sl.fecha_hora_fin,
    sl.valor,
    sl.estado,
    sl.id_tipo_lavado,
    sl.id_cliente,
    sl.id_vehiculo,
    sl.id_celda
FROM factura AS f
RIGHT JOIN servicio_lavado AS sl
    ON f.id_factura = sl.id_factura;
-- =======================================================================================================================
/* 4 Creacion de consulta con FULL OUTER JOIN
Autor: David Martinez
Listar todos los convenios y todos los clientes, para ver:
   - clientes sin convenio,
   - convenios sin clientes,
   - y los que sí están asociados. */
-- =======================================================================================================================

SELECT
    c.documento           AS documento_cliente,
    c.nombre              AS nombre_cliente,
    c.apellido            AS apellido_cliente,
    con.id_convenio,
    con.descripcion       AS descripcion_convenio,
    con.precio_base,
    v.placa               AS placa_vehiculo,
    ac.estado             AS estado_asignacion
FROM CLIENTE AS c
LEFT JOIN VEHICULO AS v 
    ON c.id_cliente = v.id_cliente
LEFT JOIN ASIGNACION_CONVENIO AS ac 
    ON v.id_vehiculo = ac.id_vehiculo
FULL OUTER JOIN CONVENIO AS con
    ON ac.id_convenio = con.id_convenio
ORDER BY con.id_convenio, c.documento;
GO
-- =======================================================================================================================
/*Desarrollar 3 funciones de tablas y 3 funciones escalares dentro de las necesidades del proyecto a desarrollar.
Estos procedimientos deben estar debidamente documentados.*/
-- =======================================================================================================================
/* 1 Creacion de funciones de tabla : Disponibilidad de Celdas 
Autor: David Martinez Giraldo 
Fecha : 7/11/2025 
-- =======================================================================================================================
*/
-- Función 1: Celdas de PARQUEO disponibles
-- =======================================================================================================================
CREATE OR ALTER FUNCTION dbo.tvf_DisponibilidadCeldasParqueo(@id_sede INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id_celda,
        s.nombre AS nombre_sede,
        'Parqueo' AS tipo_celda,
        c.estado,
        c.ubicacion,
        cp.id_convenio
    FROM CELDA c
    INNER JOIN SEDE s ON s.id_sede = c.id_sede
    INNER JOIN CELDA_PARQUEO cp ON cp.id_celda = c.id_celda
    WHERE c.id_sede = @id_sede
);
GO
-- =======================================================================================================================
-- Función 2: Celdas de LAVADO disponibles
-- =======================================================================================================================

CREATE OR ALTER FUNCTION dbo.tvf_DisponibilidadCeldasLavado(@id_sede INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id_celda,
        s.nombre AS nombre_sede,
        'Lavado' AS tipo_celda,
        c.estado,
        c.ubicacion,
        cl.condicion_luz,
        cl.espacio
    FROM CELDA c
    INNER JOIN SEDE s ON s.id_sede = c.id_sede
    INNER JOIN CELDA_LAVADO cl ON cl.id_celda = c.id_celda
    WHERE c.id_sede = @id_sede
);
GO
-- =======================================================================================================================
-- Función 3: Celdas de RECARGA ELÉCTRICA disponibles
-- =======================================================================================================================

CREATE OR ALTER FUNCTION dbo.tvf_DisponibilidadCeldasRecarga(@id_sede INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id_celda,
        s.nombre AS nombre_sede,
        'Recarga Eléctrica' AS tipo_celda,
        c.estado,
        c.ubicacion,
        cre.potencia
    FROM CELDA c
    INNER JOIN SEDE s ON s.id_sede = c.id_sede
    INNER JOIN CELDA_RECARGA_ELECTRICA cre ON cre.id_celda = c.id_celda
    WHERE c.id_sede = @id_sede
);
GO
-- =======================================================================================================================
-- Función 4: Celdas de MOVILIDAD REDUCIDA disponibles
-- =======================================================================================================================

CREATE OR ALTER FUNCTION dbo.tvf_DisponibilidadCeldasMovilidad(@id_sede INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id_celda,
        s.nombre AS nombre_sede,
        'Movilidad Reducida' AS tipo_celda,
        c.estado,
        c.ubicacion,
        cmr.ancho
    FROM CELDA c
    INNER JOIN SEDE s ON s.id_sede = c.id_sede
    INNER JOIN CELDA_MOVILIDAD_REDUCIDA cmr ON cmr.id_celda = c.id_celda
    WHERE c.id_sede = @id_sede
);
GO
/*
-- Ejemplo:
-- Ver todas las celdas de PARQUEO en la sede 1
SELECT * FROM dbo.tvf_DisponibilidadCeldasParqueo(1);
-- Ver todas las celdas de LAVADO en la sede 2
SELECT * FROM dbo.tvf_DisponibilidadCeldasLavado(2);

-- Ver celdas de RECARGA en la sede 3
SELECT * FROM dbo.tvf_DisponibilidadCeldasRecarga(3);

-- Ver celdas de MOVILIDAD REDUCIDA en la sede 1
SELECT * FROM dbo.tvf_DisponibilidadCeldasMovilidad(1);

-- Filtrar solo las disponibles (se hace en la consulta)
SELECT * FROM dbo.tvf_DisponibilidadCeldasParqueo(1) WHERE estado = 'disponible';
*/
-- =======================================================================================================================
/*2 Creacion de funcion de tabla: dbo.tvf_ParqueosAbiertosPorSede
Autor: David Martinez Giraldo 
Fecha : 7/11/2025 
Descripcion: Devuelve los parqueos abiertos (sin cierre ) de una sede específica, mostrando placa, hora de ingreso y el tiempo transcurrido en horas hasta ahora
 (o hasta la hora de salida si ya está registrada).*/
-- =======================================================================================================================

CREATE OR ALTER FUNCTION dbo.tvf_ParqueosAbiertosPorSede
(
    @id_sede INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT  
        p.id_parqueo,
        v.placa AS placa_vehiculo,
        p.fecha_hora_ingreso,
        p.fecha_hora_salida,
        DATEDIFF(MINUTE, p.fecha_hora_ingreso, ISNULL(p.fecha_hora_salida, GETDATE()))/60.0 AS horas_transcurridas,
        p.estado_parqueo,
        c.ubicacion,
        t.codigo_tarjeta
    FROM PARQUEO p
    INNER JOIN CELDA c ON c.id_celda = p.id_celda
    INNER JOIN TARJETA t ON t.id_tarjeta = p.id_tarjeta
    LEFT JOIN ASIGNACION_CONVENIO ac ON ac.id_tarjeta = t.id_tarjeta
    LEFT JOIN VEHICULO v ON v.id_vehiculo = ac.id_vehiculo
    WHERE c.id_sede = @id_sede
);
GO
-- Ejemplo:
 --SELECT * FROM dbo.tvf_ParqueosAbiertosPorSede(1);
-- =======================================================================================================================
  /*3 Creacion de funcion de tabla: dbo.tvf_HistorialLavadosPorVehiculo
Autor: David Martinez Giraldo 
Fecha : 7/11/2025 
Descripcion :Mostrar el historial de lavados realizados a un vehículo específico, con las fechas, estado y precio.
Ideal para consultas rápidas del cliente o para generar reportes de uso del servicio.*/
-- =======================================================================================================================

CREATE OR ALTER FUNCTION dbo.tvf_HistorialLavadosPorVehiculo
(
    @placa NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sl.id_servicio_lavado,
        s.nombre AS nombre_sede,
        sl.fecha_hora_inicio,
        sl.fecha_hora_fin,
        sl.estado,
        tl.Nombre AS tipo_lavado,
        tl.Descripcion AS descripcion_lavado,
        tl.Precio_base,
        sl.valor AS precio_cobrado,
        v.placa,
        v.marca,
        v.modelo,
        c.ubicacion AS celda_lavado
    FROM SERVICIO_LAVADO sl
    INNER JOIN VEHICULO v ON v.id_vehiculo = sl.id_vehiculo
    INNER JOIN CELDA c ON c.id_celda = sl.id_celda
    INNER JOIN SEDE s ON s.id_sede = c.id_sede
    LEFT JOIN TIPO_LAVADO tl ON tl.id_tipo_lavado = sl.id_tipo_lavado
    WHERE v.placa = @placa
);
GO
/*
-- ejemplo 
-- Ver historial de lavados del vehículo ABC123
SELECT * FROM dbo.tvf_HistorialLavadosPorVehiculo('ABC123');

-- Filtrar solo lavados completados
SELECT * 
FROM dbo.tvf_HistorialLavadosPorVehiculo('ABC123')
WHERE estado = 'completado';

-- Ver lavados pendientes o en proceso
SELECT * 
FROM dbo.tvf_HistorialLavadosPorVehiculo('DEF456')
WHERE estado IN ('pendiente', 'en_proceso');
*/
-- =======================================================================================================================
-- FUNCIONES ESCALARES
-- =======================================================================================================================
/*  1 Creacion de funcion escalar: dbo.ufn_TotalLavadosVehiculo 
Autor: David Martinez Giraldo 
Descripcion: Funcion que devuelve las veces en que se ha lavado un vehiculo 
*/
CREATE OR ALTER FUNCTION dbo.ufn_TotalLavadosVehiculo
(
    @placa NVARCHAR(20)
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;
    
    SELECT @total = COUNT(*)
    FROM SERVICIO_LAVADO sl
    INNER JOIN VEHICULO v ON v.id_vehiculo = sl.id_vehiculo
    WHERE v.placa = @placa;
    
    RETURN ISNULL(@total, 0);
END;
GO

-- ejemplo :
-- SELECT dbo.ufn_TotalLavadosVehiculo('ABC123') AS total_lavados;
-- =======================================================================================================================

 /*  2  Creacion de funcion escalar: dbo.ufn_CeldasDisponiblesEnSede 
Autor: David Martinez Giraldo 
Descripcion:  funcion que devuelve cuantas celdas estan libres en una cede 
*/
CREATE OR ALTER FUNCTION dbo.ufn_CeldasDisponiblesEnSede
(
    @id_sede INT
)
RETURNS INT
AS
BEGIN
    DECLARE @disponibles INT;
    
    SELECT @disponibles = COUNT(*)
    FROM CELDA
    WHERE id_sede = @id_sede;
    
    RETURN ISNULL(@disponibles, 0);
END;
GO
-- ejemplo 
 --SELECT dbo.ufn_CeldasDisponiblesEnSede(1) AS celdas_disponibles;
 -- =======================================================================================================================

  /*  3  creacion de funcion escalar:  dbo.ufn_CeldasOcupadasEnSede 
Autor: David Martinez Giraldo  David Martinez Giraldo 
descripcion:  funcion que devuelve cuantas celdas estan ocupado  en una cede 
*/
-- =======================================================================================================================
CREATE OR ALTER FUNCTION dbo.ufn_CeldasOcupadasEnSede
(
    @id_sede INT
)
RETURNS INT
AS
BEGIN
    DECLARE @ocupadas INT;
    
    SELECT @ocupadas = COUNT(*)
    FROM CELDA
    WHERE id_sede = @id_sede
      AND estado = 'ocupada';
    
    RETURN ISNULL(@ocupadas, 0);
END;
GO
-- ejemplo 
-- SELECT dbo.ufn_CeldasOcupadasEnSede(1) AS CeldasOcupadas;
-- =======================================================================================================================

/*Hacer 4 consultas que utilice teoría de conjuntos. Deben ir con su enunciado y producir algún resultado.*/

/* 1  creacion de consulta con UNION (teoría de conjuntos)
Autor: David Martinez Giraldo
Enunciado : Listar todas las placas que han tenido actividad en el sistema (ya sea parqueo o lavado), sin duplicados. */
-- =======================================================================================================================

SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p)
UNION
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT sl.id_vehiculo FROM SERVICIO_LAVADO AS sl);
-- =======================================================================================================================

/* 2  creacion de consulta con UNION ALL (teoría de conjuntos)
Autor: David Martinez Giraldo
Enunciado : Contar el total de actividades por placa sumando parqueos y lavados (conservando duplicados para sumar frecuencia). */
-- =======================================================================================================================

SELECT placa, COUNT(*) AS total_actividades
FROM (
    SELECT v.placa AS placa
    FROM VEHICULO AS v
    WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p)
    UNION ALL
    SELECT v.placa AS placa
    FROM VEHICULO AS v
    WHERE v.id_vehiculo IN (SELECT sl.id_vehiculo FROM SERVICIO_LAVADO AS sl)
) AS x
GROUP BY placa
ORDER BY total_actividades DESC, placa;
-- =======================================================================================================================

/* 3  creacion de consulta con INTERSECT (teoría de conjuntos)
Autor: David Martinez Giraldo
Enunciado : Obtener las placas que aparecen tanto en parqueos como en lavados (intersección). */
-- =======================================================================================================================

SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p)
INTERSECT
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT sl.id_vehiculo FROM SERVICIO_LAVADO AS sl);
/* 4  creacion de consulta con EXCEPT (teoría de conjuntos)
Autor: David Martinez Giraldo
Enunciado : Listar los vehículos registrados que nunca se han parqueado (diferencia de conjuntos). */
SELECT v.placa
FROM VEHICULO AS v
EXCEPT
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p);

GO

/* ============================================================
   VISTA 1: v_ParqueoEditableSimple
   Autor: David Martínez
   propósito: Mostrar los parqueos junto con datos básicos
   de tarjeta, celda/sede y vehículo, y permitir insertar/actualizar
   parqueos directamente desde la vista.
   Tablas base: PARQUEO (editable), TARJETA, CELDA, SEDE, VEHICULO
   ============================================================ */

CREATE OR ALTER VIEW dbo.v_ParqueoEditableSimple
AS
SELECT
    p.id_parqueo,           
    p.id_tarjeta,           -- FK a la tarjeta usada para ingresar
    p.id_celda,             -- FK a la celda donde se parquea
    c.id_sede,              -- FK a la sede (desde CELDA)
    p.fecha_hora_ingreso,   -- hora de entrada
    p.fecha_hora_salida,    -- hora de salida
    p.estado_parqueo,       -- estado actual del parqueo (activo/finalizado)
    p.modo_ingreso,         -- modo de ingreso (Convenio/Ocasional)
    p.valor_cobrado,        -- valor cobrado por el parqueo
    
    -- Datos adicionales de otras tablas
    s.nombre AS nombre_sede,        -- nombre de la sede
    c.ubicacion AS ubicacion_celda, -- ubicación de la celda
    c.estado AS estado_celda,       -- estado de la celda
    t.codigo_tarjeta,               -- código de la tarjeta
    t.estado_tarjeta,               -- estado de la tarjeta usada
    v.placa,                        -- placa del vehículo
    v.marca,                        -- marca del vehículo
    v.modelo,                       -- modelo del vehículo
    v.color                         -- color del vehículo
FROM PARQUEO AS p
INNER JOIN TARJETA AS t ON t.id_tarjeta = p.id_tarjeta
INNER JOIN CELDA AS c ON c.id_celda = p.id_celda
INNER JOIN SEDE AS s ON s.id_sede = c.id_sede
LEFT JOIN ASIGNACION_CONVENIO AS ac ON ac.id_tarjeta = t.id_tarjeta
LEFT JOIN VEHICULO AS v ON v.id_vehiculo = ac.id_vehiculo;
GO

/* ============================================================
   TRIGGER: tr_v_ParqueoEditableSimple_INS
   propósito: Cuando el usuario hace un INSERT sobre la vista,
   este trigger redirige el insert a la tabla base PARQUEO.
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.tr_v_ParqueoEditableSimple_INS
ON dbo.v_ParqueoEditableSimple
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON; -- evita mensajes extra de "x filas afectadas"

    INSERT INTO PARQUEO
        (id_tarjeta, id_celda, fecha_hora_ingreso, fecha_hora_salida, 
         estado_parqueo, modo_ingreso, valor_cobrado)
    SELECT
        i.id_tarjeta, -- usa la tarjeta que viene en el insert
        i.id_celda,
        ISNULL(i.fecha_hora_ingreso, GETDATE()), -- si no se envía una fecha, usa la actual
        NULL, -- la salida se deja nula al abrir el parqueo
        'activo', -- nuevo parqueo siempre inicia en estado Activo
        ISNULL(i.modo_ingreso, 'Ocasional'),
        ISNULL(i.valor_cobrado, 0.00)
    FROM inserted AS i; -- 'inserted' es la tabla temporal con los datos nuevos
END;
GO

/* ============================================================
   TRIGGER: tr_v_ParqueoEditableSimple_UPD
   propósito: Cuando el usuario hace un UPDATE sobre la vista,
   este trigger redirige la modificación a la tabla base PARQUEO.
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.tr_v_ParqueoEditableSimple_UPD
ON dbo.v_ParqueoEditableSimple
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET
		-- Si el usuario mandó un nuevo id_tarjeta, se usa ese;
        -- si no, se mantiene el valor anterior.
        p.id_tarjeta =
            CASE 
                WHEN i.id_tarjeta IS NOT NULL THEN i.id_tarjeta
                ELSE p.id_tarjeta
            END,

        p.id_celda =
            CASE 
                WHEN i.id_celda IS NOT NULL THEN i.id_celda
                ELSE p.id_celda
            END,
		-- Si se envía una nueva fecha de ingreso, la actualiza;
        -- si no, conserva la anterior.
        p.fecha_hora_ingreso =
            CASE 
                WHEN i.fecha_hora_ingreso IS NOT NULL THEN i.fecha_hora_ingreso
                ELSE p.fecha_hora_ingreso
            END,
			-- Igual con la fecha de salida.
        p.fecha_hora_salida =
            CASE 
                WHEN i.fecha_hora_salida IS NOT NULL THEN i.fecha_hora_salida
                ELSE p.fecha_hora_salida
            END,

        p.modo_ingreso =
            CASE 
                WHEN i.modo_ingreso IS NOT NULL THEN i.modo_ingreso
                ELSE p.modo_ingreso
            END,

        p.valor_cobrado =
            CASE 
                WHEN i.valor_cobrado IS NOT NULL THEN i.valor_cobrado
                ELSE p.valor_cobrado
            END,
			-- Aquí se aplica la lógica del estado:
        -- Si hay una fecha de salida (no es NULL) → estado = 'Inactivo'
        -- Si NO hay fecha de salida → estado = 'Activo'
        p.estado_parqueo =
            CASE
                WHEN (CASE 
                        WHEN i.fecha_hora_salida IS NOT NULL THEN i.fecha_hora_salida
                        ELSE p.fecha_hora_salida
                      END) IS NOT NULL
                THEN 'finalizado'
                ELSE 'activo'
            END
    FROM PARQUEO p
    INNER JOIN inserted i ON i.id_parqueo = p.id_parqueo; -- se actualizan solo los registros que se están modificando
END;
GO

/* ============================================================
   VISTA 2: v_FacturaEditableSimple
   Autor: David Martínez
   propósito: Permitir crear o modificar facturas
   y mostrar datos de cliente, usuario y parqueo/servicio asociados.
   Tablas base: FACTURA (editable), CLIENTE, USUARIO, PARQUEO, SERVICIO_LAVADO
   ============================================================ */

CREATE OR ALTER VIEW dbo.v_FacturaEditableSimple
AS
SELECT
    -- Campos EDITABLES (de la tabla FACTURA)
    f.id_factura,                -- PK de la factura
    f.fecha_hora_emision,        -- fecha de emisión de la factura
    f.id_cliente,                -- cliente asociado
    f.id_usuario,                -- usuario que genera la factura
    f.total_bruto,               -- total bruto
    f.total_neto,                -- total a cobrar
    f.numero_factura,            -- número único de factura
    f.metodo_pago,               -- método de pago usado
    f.id_parqueo,                -- FK al parqueo (puede ser NULL)
    f.id_asignacion_convenio,    -- FK a asignación de convenio (puede ser NULL)

    -- Campos informativos (de otras tablas)
    c.nombre       AS nombre_cliente,
    c.apellido     AS apellido_cliente,
    c.documento    AS documento_cliente,
    u.nombre       AS nombre_usuario,
    u.apellidos    AS apellido_usuario,
    p.fecha_hora_ingreso,
    p.fecha_hora_salida,
    p.valor_cobrado AS valor_parqueo
FROM FACTURA f
INNER JOIN CLIENTE c ON c.id_cliente = f.id_cliente
INNER JOIN USUARIO u ON u.id_usuario = f.id_usuario
LEFT JOIN PARQUEO p ON p.id_parqueo = f.id_parqueo;
GO

/* ============================================================
   TRIGGER: tr_v_FacturaEditableSimple_INS
   propósito: Cuando se hace INSERT sobre la vista,
   inserta los datos en la tabla base FACTURA.
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.tr_v_FacturaEditableSimple_INS
ON dbo.v_FacturaEditableSimple
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;  -- evita mensajes extra de "x filas afectadas"

    INSERT INTO FACTURA
        (fecha_hora_emision, id_cliente, id_usuario, total_bruto, total_neto, 
         numero_factura, metodo_pago, id_parqueo, id_asignacion_convenio)
    SELECT
        -- Si el usuario manda una fecha, se usa;
        -- si no, se usa la fecha actual del sistema.
        CASE 
            WHEN i.fecha_hora_emision IS NOT NULL THEN i.fecha_hora_emision
            ELSE GETDATE()
        END,

        -- Cliente y usuario se insertan directamente desde lo que venga en la vista.
        i.id_cliente,
        i.id_usuario,

        -- Si el usuario no envía el total bruto, se guarda 0 para evitar NULL.
        CASE 
            WHEN i.total_bruto IS NOT NULL THEN i.total_bruto
            ELSE 0
        END,

        -- Si el usuario no envía el total neto, se guarda 0 para evitar NULL.
        CASE 
            WHEN i.total_neto IS NOT NULL THEN i.total_neto
            ELSE 0
        END,

        -- Número de factura (debe ser único)
        i.numero_factura,

        -- Método de pago
        CASE 
            WHEN i.metodo_pago IS NOT NULL THEN i.metodo_pago
            ELSE 'Efectivo'
        END,

        -- Parqueo (puede ser NULL si es solo lavado)
        i.id_parqueo,

        -- Asignación de convenio (puede ser NULL)
        i.id_asignacion_convenio
    FROM inserted AS i;
END;
GO

/* ============================================================
   TRIGGER: tr_v_FacturaEditableSimple_UPD
   propósito: Permite actualizar campos de factura desde la vista.
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.tr_v_FacturaEditableSimple_UPD
ON dbo.v_FacturaEditableSimple
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE f
    SET
        -- Si se envía una nueva fecha de emisión, la actualiza;
        -- si no, conserva la anterior.
        f.fecha_hora_emision =
            CASE 
                WHEN i.fecha_hora_emision IS NOT NULL THEN i.fecha_hora_emision
                ELSE f.fecha_hora_emision
            END,

        -- Si se envía un nuevo total bruto, se actualiza;
        -- de lo contrario, permanece igual.
        f.total_bruto =
            CASE 
                WHEN i.total_bruto IS NOT NULL THEN i.total_bruto
                ELSE f.total_bruto
            END,

        -- Si se envía un nuevo total neto, se actualiza;
        -- de lo contrario, permanece igual.
        f.total_neto =
            CASE 
                WHEN i.total_neto IS NOT NULL THEN i.total_neto
                ELSE f.total_neto
            END,

        -- Si se cambia el método de pago, se actualiza.
        f.metodo_pago =
            CASE 
                WHEN i.metodo_pago IS NOT NULL THEN i.metodo_pago
                ELSE f.metodo_pago
            END,

        -- Actualiza el cliente si se envía un nuevo id_cliente.
        f.id_cliente =
            CASE 
                WHEN i.id_cliente IS NOT NULL THEN i.id_cliente
                ELSE f.id_cliente
            END,

        -- Si se envía un nuevo id_usuario, se usa ese.
        f.id_usuario =
            CASE 
                WHEN i.id_usuario IS NOT NULL THEN i.id_usuario
                ELSE f.id_usuario
            END,

        -- Si se envía un nuevo id_parqueo, se usa ese.
        f.id_parqueo =
            CASE 
                WHEN i.id_parqueo IS NOT NULL THEN i.id_parqueo
                ELSE f.id_parqueo
            END,

        -- Si se envía un nuevo id_asignacion_convenio, se usa ese.
        f.id_asignacion_convenio =
            CASE 
                WHEN i.id_asignacion_convenio IS NOT NULL THEN i.id_asignacion_convenio
                ELSE f.id_asignacion_convenio
            END
    FROM FACTURA f
    INNER JOIN inserted i ON i.id_factura = f.id_factura;  -- se actualizan solo los registros que se están modificando
END;
GO

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

-- ============================================================================
-- NECESIDAD 1: GESTIÓN AUTOMÁTICA DE FACTURACIÓN Y LIQUIDACIÓN DE SERVICIOS
-- Autor: Julian Alvarez
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
    DECLARE @plazo INT;
    
    -- Calcular tiempo transcurrido
    SET @minutos = DATEDIFF(MINUTE, @fecha_ingreso, @fecha_salida);
	SET @horas = @minutos / 60.0;
    
    -- Si tiene convenio, obtener precio del convenio
    IF @id_convenio IS NOT NULL
    BEGIN
        SELECT @precio_base = precio_base, @plazo = plazo
        FROM CONVENIO
        WHERE id_convenio = @id_convenio
              AND GETDATE() BETWEEN vigencia_inicio AND vigencia_fin;
        
        IF @precio_base IS NOT NULL
        BEGIN
            -- Aplicar precio según plazo (días)
            IF @plazo >= 30
                SET @monto = @precio_base; -- Tarifa mensual fija
            ELSE IF @plazo >= 7
                SET @monto = @precio_base * (@horas / 24.0); -- Por día
			ELSE
				SET @monto = @precio_base * @horas; -- Por hora
        END
    END
    ELSE
    BEGIN
        -- Tarifas ocasionales según tipo de vehículo
        IF @id_tipo_vehiculo = 1 -- Pequeño
			SET @monto = 2000 * @horas;
		ELSE IF @id_tipo_vehiculo = 2 -- Mediano
			SET @monto = 3000 * @horas;
		ELSE IF @id_tipo_vehiculo = 3 -- Grande/SUV
			SET @monto = 5000 * @horas;
		ELSE IF @id_tipo_vehiculo = 4 -- Compacto
			SET @monto = 1500 * @horas;
		ELSE
			SET @monto = 2500 * @horas;
    END
    
    -- Mínimo 1 hora
    IF @monto < 2000
        SET @monto = 2000;
    
    RETURN @monto;
END
GO

-- FUNCIÓN 1.2: Validar disponibilidad de celda por sede
GO
CREATE OR ALTER FUNCTION dbo.fn_ValidarDisponibilidadCelda(
    @id_sede INT
)
RETURNS INT
AS
BEGIN
    DECLARE @celda_disponible INT = NULL;
    
    SELECT TOP 1 @celda_disponible = id_celda
    FROM CELDA
    WHERE id_sede = @id_sede
          AND estado = 'disponible'
    ORDER BY id_celda;
    
    RETURN @celda_disponible;
END
GO

-- TRIGGER 1.1: Actualizar estado de celda al registrar parqueo
GO
CREATE OR ALTER TRIGGER trg_ParqueoIngreso
ON PARQUEO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_msg NVARCHAR(4000);
    
    BEGIN TRY
        -- Actualizar celda a ocupada
        UPDATE CELDA
        SET estado = 'ocupada'
        FROM CELDA c
        INNER JOIN inserted i ON c.id_celda = i.id_celda
        WHERE i.id_celda IS NOT NULL;
        
        -- Actualizar estado de tarjeta
        UPDATE TARJETA
        SET estado_tarjeta = 'Activa'
        FROM TARJETA t
        INNER JOIN inserted i ON t.id_tarjeta = i.id_tarjeta;
        
    END TRY
    BEGIN CATCH
        SET @error_msg = ERROR_MESSAGE();
        RAISERROR(@error_msg, 16, 1);
        ROLLBACK TRANSACTION;
    END CATCH
END
GO

-- TRIGGER 1.2: Liberar celda y calcular valor al registrar salida
GO
CREATE OR ALTER TRIGGER trg_ParqueoSalida
ON PARQUEO
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
            DECLARE @id_vehiculo INT, @id_cliente INT;
            DECLARE @fecha_ingreso DATETIME, @fecha_salida DATETIME;
            DECLARE @id_convenio INT, @id_tipo_vehiculo INT;
            DECLARE @monto DECIMAL(10,2);
            
            -- Cursor para procesar cada salida
            DECLARE cur_salidas CURSOR FOR
            SELECT i.id_parqueo, i.id_celda, i.id_tarjeta,
                   i.fecha_hora_ingreso, i.fecha_hora_salida
            FROM inserted i
            INNER JOIN deleted d ON i.id_parqueo = d.id_parqueo
            WHERE i.fecha_hora_salida IS NOT NULL 
                  AND d.fecha_hora_salida IS NULL;
            
            OPEN cur_salidas;
            FETCH NEXT FROM cur_salidas INTO @id_parqueo, @id_celda, @id_tarjeta,
                @fecha_ingreso, @fecha_salida;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Obtener vehículo y cliente desde ASIGNACION_CONVENIO
                SELECT TOP 1 @id_vehiculo = ac.id_vehiculo,
                       @id_convenio = ac.id_convenio
                FROM ASIGNACION_CONVENIO ac
                WHERE ac.id_tarjeta = @id_tarjeta
                      AND ac.estado = 'Activo';
                
                IF @id_vehiculo IS NOT NULL
                BEGIN
                    -- Obtener cliente y tipo de vehículo
                    SELECT @id_cliente = v.id_cliente
                    FROM VEHICULO v
                    WHERE v.id_vehiculo = @id_vehiculo;
                    
                    -- Obtener tipo de vehículo desde la relación M:N
                    SELECT TOP 1 @id_tipo_vehiculo = vt.id_tipo_vehiculo
                    FROM Vehiculo_TipoVehiculo vt
                    WHERE vt.id_vehiculo = @id_vehiculo;
                END
                
                -- Calcular monto usando la función
                SET @monto = dbo.fn_CalcularTarifaParqueo(
                    @fecha_ingreso, @fecha_salida, @id_convenio, @id_tipo_vehiculo
                );
                
                -- Actualizar valor cobrado en el parqueo
                UPDATE PARQUEO
                SET valor_cobrado = @monto,
                    estado_parqueo = 'finalizado'
                WHERE id_parqueo = @id_parqueo;
                
                -- Liberar celda
                IF @id_celda IS NOT NULL
                BEGIN
                    UPDATE CELDA
                    SET estado = 'disponible'
                    WHERE id_celda = @id_celda;
                END
                
                -- Actualizar estado de tarjeta
                UPDATE TARJETA
                SET estado_tarjeta = 'Inactiva'
                WHERE id_tarjeta = @id_tarjeta;
                
                FETCH NEXT FROM cur_salidas INTO @id_parqueo, @id_celda, @id_tarjeta,
                    @fecha_ingreso, @fecha_salida;
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
-- =======================================================================================================================
-- PROCEDIMIENTO 1: Procesar salida de vehículo y generar factura completa
-- =======================================================================================================================

GO
CREATE OR ALTER PROCEDURE sp_ProcesarSalidaVehiculo
    @id_parqueo INT,
    @id_usuario INT,
    @metodo_pago NVARCHAR(50) = 'Efectivo',
    @id_factura INT OUTPUT,
    @total_factura DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_message NVARCHAR(4000);
    DECLARE @id_vehiculo INT, @id_cliente INT, @id_tarjeta INT;
    DECLARE @fecha_ingreso DATETIME, @fecha_salida DATETIME;
    DECLARE @id_convenio INT, @id_tipo_vehiculo INT, @id_sede INT;
    DECLARE @monto_parqueo DECIMAL(10,2);
    DECLARE @id_servicio_lavado INT, @monto_lavado DECIMAL(10,2);
    DECLARE @numero_factura NVARCHAR(50);
    DECLARE @total_bruto DECIMAL(10,2), @total_neto DECIMAL(10,2);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el parqueo existe y no tiene salida registrada
        IF NOT EXISTS (SELECT 1 FROM PARQUEO 
                      WHERE id_parqueo = @id_parqueo 
                      AND fecha_hora_salida IS NULL)
        BEGIN
            SET @error_message = 'El parqueo no existe o ya tiene salida registrada.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener datos del parqueo
        SELECT @fecha_ingreso = p.fecha_hora_ingreso,
               @id_tarjeta = p.id_tarjeta,
               @id_sede = c.id_sede
        FROM PARQUEO p
        INNER JOIN CELDA c ON c.id_celda = p.id_celda
        WHERE p.id_parqueo = @id_parqueo;
        
        -- Registrar fecha de salida (esto activará el trigger)
        SET @fecha_salida = GETDATE();
        UPDATE PARQUEO
        SET fecha_hora_salida = @fecha_salida
        WHERE id_parqueo = @id_parqueo;
        
        -- Obtener el valor calculado por el trigger
        SELECT @monto_parqueo = valor_cobrado
        FROM PARQUEO
        WHERE id_parqueo = @id_parqueo;
        
        -- Obtener vehículo y cliente
        SELECT TOP 1 @id_vehiculo = ac.id_vehiculo,
               @id_convenio = ac.id_convenio
        FROM ASIGNACION_CONVENIO ac
        WHERE ac.id_tarjeta = @id_tarjeta
              AND ac.estado = 'Activo';
        
        IF @id_vehiculo IS NOT NULL
        BEGIN
            SELECT @id_cliente = id_cliente
            FROM VEHICULO
            WHERE id_vehiculo = @id_vehiculo;
        END
        
        IF @id_cliente IS NULL
        BEGIN
            SET @error_message = 'No se encontró el cliente asociado al vehículo.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Verificar si hay servicios de lavado completados sin facturar
        SELECT TOP 1 @id_servicio_lavado = id_servicio_lavado,
               @monto_lavado = valor
        FROM SERVICIO_LAVADO
        WHERE id_vehiculo = @id_vehiculo
              AND estado = 'completado'
              AND id_factura IS NULL
        ORDER BY fecha_hora_fin DESC;
        
        -- Calcular totales
        SET @total_bruto = @monto_parqueo + ISNULL(@monto_lavado, 0);
        SET @total_neto = @total_bruto;
        
        -- Generar número de factura único
        SET @numero_factura = 'FAC-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                             RIGHT('0000' + CAST(@id_parqueo AS VARCHAR), 4);
        
        -- Crear factura
        INSERT INTO FACTURA (total_bruto, numero_factura, metodo_pago, total_neto, 
                           fecha_hora_emision, id_usuario, id_parqueo, id_cliente)
        VALUES (@total_bruto, @numero_factura, @metodo_pago, @total_neto,
               GETDATE(), @id_usuario, @id_parqueo, @id_cliente);
        
        SET @id_factura = SCOPE_IDENTITY();
        
        -- Crear detalle de factura para parqueo
        INSERT INTO DETALLE_FACTURA (id_factura, id_detalle_factura, cantidad, 
                                    precio_unitario, servicio_pagado, descripcion, id_parqueo)
        VALUES (@id_factura, 1, 1, @monto_parqueo, 'Parqueo', 
               'Servicio de parqueadero', @id_parqueo);
        
        -- Crear detalle de factura para lavado si existe
        IF @id_servicio_lavado IS NOT NULL
        BEGIN
            -- Actualizar servicio de lavado con la factura
            UPDATE SERVICIO_LAVADO
            SET id_factura = @id_factura
            WHERE id_servicio_lavado = @id_servicio_lavado;
            
            INSERT INTO DETALLE_FACTURA (id_factura, id_detalle_factura, cantidad,
                                        precio_unitario, servicio_pagado, descripcion)
            VALUES (@id_factura, 2, 1, @monto_lavado, 'Lavado',
                   'Servicio de lavado de vehículo');
        END
        
        -- Crear registro de pago
        INSERT INTO PAGO (metodo_pago, monto_pago, fecha_hora_pago, 
                         referencia_transaccion, id_factura, id_cliente)
        VALUES (@metodo_pago, @total_neto, GETDATE(),
               'PAG-' + @numero_factura, @id_factura, @id_cliente);
        
        SET @total_factura = @total_neto;
        
        COMMIT TRANSACTION;
        
        -- Mensaje de éxito
        PRINT 'Salida procesada exitosamente. Factura #' + @numero_factura;
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
-- Autor: Julian Alvarez
-- ============================================================================
-- Descripción: Administrar automáticamente las reservas de celdas según
-- convenios, validar disponibilidad, controlar tiempos de gracia y liberar
-- celdas no utilizadas, manteniendo estadísticas actualizadas.
-- ============================================================================

-- Tabla auxiliar
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'estadistica_ocupacion')
BEGIN
    CREATE TABLE estadistica_ocupacion (
        id_estadistica INT PRIMARY KEY IDENTITY(1,1),
        id_sede INT NOT NULL,
        fecha DATE NOT NULL,
        total_celdas INT,
        celdas_ocupadas INT,
        celdas_disponibles INT,
        celdas_mantenimiento INT,
        porcentaje_ocupacion DECIMAL(5,2),
        ingresos_dia DECIMAL(10,2),
        CONSTRAINT FK_estadistica_sede FOREIGN KEY (id_sede) REFERENCES SEDE(id_sede),
        CONSTRAINT UQ_estadistica_sede_fecha UNIQUE (id_sede, fecha)
    );
END
GO

-- FUNCIÓN 2.1: Calcular porcentaje de ocupación por sede
GO
CREATE OR ALTER FUNCTION dbo.fn_CalcularOcupacionSede(
    @id_sede INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total INT, @ocupadas INT, @porcentaje DECIMAL(5,2);
    
    -- Calcular para todas las celdas de la sede
    SELECT @total = COUNT(*),
           @ocupadas = SUM(CASE WHEN estado = 'ocupada' THEN 1 ELSE 0 END)
    FROM CELDA
    WHERE id_sede = @id_sede;
    
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
    
    SELECT @promedio_horas = AVG(DATEDIFF(MINUTE, p.fecha_hora_ingreso, p.fecha_hora_salida) / 60.0)
    FROM PARQUEO p
    INNER JOIN CELDA c ON c.id_celda = p.id_celda
    WHERE c.id_sede = @id_sede
          AND p.fecha_hora_salida IS NOT NULL
          AND CAST(p.fecha_hora_ingreso AS DATE) BETWEEN @fecha_inicio AND @fecha_fin;
    
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
        IF UPDATE(estado)
        BEGIN
            DECLARE @id_sede INT, @fecha DATE;
            DECLARE @total_celdas INT, @celdas_ocupadas INT;
            DECLARE @celdas_disponibles INT, @celdas_mantenimiento INT;
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
                       @celdas_ocupadas = SUM(CASE WHEN estado = 'ocupada' THEN 1 ELSE 0 END),
                       @celdas_disponibles = SUM(CASE WHEN estado = 'disponible' THEN 1 ELSE 0 END),
                       @celdas_mantenimiento = SUM(CASE WHEN estado = 'mantenimiento' THEN 1 ELSE 0 END)
                FROM CELDA
                WHERE id_sede = @id_sede;
                
                SET @porcentaje = dbo.fn_CalcularOcupacionSede(@id_sede);
                
                -- Calcular ingresos del día
                SELECT @ingresos = ISNULL(SUM(f.total_neto), 0)
                FROM FACTURA f
                INNER JOIN PARQUEO p ON p.id_parqueo = f.id_parqueo
                INNER JOIN CELDA c ON c.id_celda = p.id_celda
                WHERE c.id_sede = @id_sede 
                      AND CAST(f.fecha_hora_emision AS DATE) = @fecha;
                
                -- Actualizar o insertar estadísticas
                IF EXISTS (SELECT 1 FROM estadistica_ocupacion 
                          WHERE id_sede = @id_sede AND fecha = @fecha)
                BEGIN
                    UPDATE estadistica_ocupacion
                    SET total_celdas = @total_celdas,
                        celdas_ocupadas = @celdas_ocupadas,
                        celdas_disponibles = @celdas_disponibles,
                        celdas_mantenimiento = @celdas_mantenimiento,
                        porcentaje_ocupacion = @porcentaje,
                        ingresos_dia = @ingresos
                    WHERE id_sede = @id_sede AND fecha = @fecha;
                END
                ELSE
                BEGIN
                    INSERT INTO estadistica_ocupacion 
                        (id_sede, fecha, total_celdas, celdas_ocupadas, celdas_disponibles,
                         celdas_mantenimiento, porcentaje_ocupacion, ingresos_dia)
                    VALUES (@id_sede, @fecha, @total_celdas, @celdas_ocupadas, @celdas_disponibles,
                           @celdas_mantenimiento, @porcentaje, @ingresos);
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
        PRINT 'Error al actualizar estadísticas: ';
        PRINT @error_msg;
    END CATCH
END
GO
-- =======================================================================================================================
-- PROCEDIMIENTO 2: Asignar celda automáticamente según disponibilidad y convenio
-- =======================================================================================================================
GO
CREATE OR ALTER PROCEDURE sp_AsignarCeldaAutomatica
    @id_vehiculo INT,
    @id_sede INT,
    @id_usuario INT,
    @modo_ingreso NVARCHAR(20) = 'Ocasional',
    @id_parqueo INT OUTPUT,
    @id_celda_asignada INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error_message NVARCHAR(4000);
    DECLARE @id_tipo_vehiculo INT;
    DECLARE @id_cliente INT, @id_convenio INT;
    DECLARE @id_tarjeta INT;
    DECLARE @ocupacion DECIMAL(5,2);
    DECLARE @codigo_tarjeta NVARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el vehículo existe
        IF NOT EXISTS (SELECT 1 FROM VEHICULO WHERE id_vehiculo = @id_vehiculo)
        BEGIN
            SET @error_message = 'El vehículo especificado no está registrado.';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Obtener tipo de vehículo y cliente
        SELECT @id_cliente = v.id_cliente
        FROM VEHICULO v
        WHERE v.id_vehiculo = @id_vehiculo;
        
        -- Obtener tipo de vehículo desde la relación M:N
        SELECT TOP 1 @id_tipo_vehiculo = vt.id_tipo_vehiculo
        FROM Vehiculo_TipoVehiculo vt
        WHERE vt.id_vehiculo = @id_vehiculo;
        
        -- Verificar disponibilidad de celda
        SET @id_celda_asignada = dbo.fn_ValidarDisponibilidadCelda(@id_sede);
        
        IF @id_celda_asignada IS NULL
        BEGIN
            -- Verificar ocupación actual
            SET @ocupacion = dbo.fn_CalcularOcupacionSede(@id_sede);
            SET @error_message = 'No hay celdas disponibles. Ocupación actual: ' + CAST(@ocupacion AS VARCHAR(10)) + '%';
            RAISERROR(@error_message, 16, 1);
        END
        
        -- Verificar si el cliente tiene convenio activo
        SELECT TOP 1 @id_convenio = ac.id_convenio,
               @id_tarjeta = ac.id_tarjeta
        FROM ASIGNACION_CONVENIO ac
        WHERE ac.id_vehiculo = @id_vehiculo
              AND ac.estado = 'Activo'
              AND GETDATE() BETWEEN ac.fecha_inicio AND ac.fecha_fin;
        
        -- Si no tiene convenio, generar nueva tarjeta ocasional
        IF @id_tarjeta IS NULL
        BEGIN
            SET @codigo_tarjeta = 'TO-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + 
                                 RIGHT('0000' + CAST(@id_vehiculo AS VARCHAR), 4);
            
            INSERT INTO TARJETA (fecha_hora_emision, codigo_tarjeta, estado_tarjeta)
            VALUES (GETDATE(), @codigo_tarjeta, 'Activa');
            
            SET @id_tarjeta = SCOPE_IDENTITY();
            
            -- Crear tarjeta ocasional
            INSERT INTO TARJETA_OCASIONAL (id_tarjeta, valor, pagada, hora_entrada)
            VALUES (@id_tarjeta, 0.00, 0, GETDATE());
            
            SET @modo_ingreso = 'Ocasional';
        END
        ELSE
        BEGIN
            SET @modo_ingreso = 'Convenio';
        END
        
        -- Crear registro de parqueo
        INSERT INTO PARQUEO (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida,
                           estado_parqueo, modo_ingreso, valor_cobrado, id_celda)
        VALUES (@id_tarjeta, GETDATE(), NULL, 'activo', @modo_ingreso, 0.00, @id_celda_asignada);
        
        SET @id_parqueo = SCOPE_IDENTITY();
        
        -- El trigger se encarga de actualizar el estado de la celda y tarjeta
        
        COMMIT TRANSACTION;
        
        -- Mensaje de éxito
        PRINT 'Celda asignada exitosamente.';
        PRINT 'Parqueo #' + CAST(@id_parqueo AS VARCHAR(10));
        PRINT 'Celda #' + CAST(@id_celda_asignada AS VARCHAR(10));
        PRINT 'Tarjeta #' + CAST(@id_tarjeta AS VARCHAR(10));
        PRINT 'Modo de ingreso: ' + @modo_ingreso;
        
        IF @id_convenio IS NOT NULL
            PRINT 'Cliente con convenio activo ID: ' + CAST(@id_convenio AS VARCHAR(10));
        
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
-- EJEMPLOS DE USO
-- ============================================================================

/*
-- Procedimiento 1: Procesar salida y generar factura
DECLARE @id_factura INT, @total DECIMAL(10,2);
EXEC sp_ProcesarSalidaVehiculo 
    @id_parqueo = 1,
    @id_usuario = 7,
    @metodo_pago = 'Tarjeta',
    @id_factura = @id_factura OUTPUT,
    @total_factura = @total OUTPUT;
    
SELECT @id_factura AS FacturaGenerada, @total AS TotalAPagar;

-- Procedimiento 2: Asignar celda automáticamente
DECLARE @id_parqueo INT, @id_celda INT;
EXEC sp_AsignarCeldaAutomatica
    @id_vehiculo = 1,
    @id_sede = 1,
    @id_usuario = 7,
    @modo_ingreso = 'Ocasional',
    @id_parqueo = @id_parqueo OUTPUT,
    @id_celda_asignada = @id_celda OUTPUT;
    
SELECT @id_parqueo AS ParqueoCreado, @id_celda AS CeldaAsignada;

-- Consultar estadísticas del día
SELECT 
    s.nombre AS sede,
    eo.*
FROM estadistica_ocupacion eo
INNER JOIN SEDE s ON s.id_sede = eo.id_sede
WHERE fecha = CAST(GETDATE() AS DATE)
ORDER BY eo.porcentaje_ocupacion DESC;

-- Ver ocupación actual de todas las sedes
SELECT 
    s.id_sede, 
    s.nombre,
    s.ciudad,
    s.capacidad_total,
    dbo.fn_CalcularOcupacionSede(s.id_sede) AS porcentaje_ocupacion
FROM SEDE s
ORDER BY porcentaje_ocupacion DESC;

-- Ver tiempo promedio de parqueo última semana
SELECT 
    s.nombre AS sede,
    dbo.fn_TiempoPromedioParqueo(s.id_sede, DATEADD(DAY, -7, GETDATE()), GETDATE()) AS horas_promedio
FROM SEDE s;
*/
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




