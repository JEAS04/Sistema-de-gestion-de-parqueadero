-- =====================================================
-- CREACION Y USO DE LA BASE DE DATOS.
-- =====================================================
CREATE DATABASE SISTEMA_PARQUEADERO
GO
USE SISTEMA_PARQUEADERO
GO
-- 
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
    documento NVARCHAR(20) NOT NULL UNIQUE,
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
    documento NVARCHAR(20) NOT NULL UNIQUE,
    fecha_registro DATE NOT NULL DEFAULT GETDATE(),
    telefono NVARCHAR(20),
    direccion NVARCHAR(255),
    correo NVARCHAR(100) UNIQUE
);

CREATE TABLE VEHICULO (
    id_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    año INT NOT NULL,
    placa NVARCHAR(20) NOT NULL UNIQUE,
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

-- Agregar FK a Factura que faltaba
ALTER TABLE FACTURA
ADD id_asignacion_convenio INT NULL,
    CONSTRAINT FK_Factura_AsignacionConvenio FOREIGN KEY (id_asignacion_convenio)
        REFERENCES ASIGNACION_CONVENIO(id_asignacion_convenio);

-- Agregar FK a Servicio_lavado para convenio
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

-- Convenio Parqueadero (especialización de Convenio)
CREATE TABLE CONVENIO_PARQUEADERO (
    id_convenio INT PRIMARY KEY,
    requiere_tarjeta BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ConvenioParqueadero_Convenio FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO(id_convenio)
);

-- Convenio Lavado (especialización de Convenio)
CREATE TABLE CONVENIO_LAVADO (
    id_convenio INT PRIMARY KEY,
    cantidad_lavado_mes INT NOT NULL,
    CONSTRAINT FK_ConvenioLavado_Convenio FOREIGN KEY (id_convenio) 
        REFERENCES CONVENIO(id_convenio)
);

-- Sub-especializaciones de Convenio_Parqueadero
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

-- Ahora sí podemos crear TURNO_LAVADO que depende de CELDA_LAVADO
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
('Lavado Básico', 'Limpieza exterior básica del vehículo', 15000.00, '00:30:00', 1),
('Lavado Completo', 'Limpieza exterior e interior completa', 35000.00, '01:00:00', 1),
('Lavado Premium', 'Lavado completo + encerado + limpieza de motor', 55000.00, '01:45:00', 1),
('Lavado Express', 'Lavado rápido exterior', 10000.00, '00:15:00', 1),
('Lavado de Motor', 'Limpieza especializada del motor', 25000.00, '00:45:00', 1),
('Pulido y Encerado', 'Tratamiento de pintura profesional', 80000.00, '02:30:00', 1),
('Limpieza de Tapicería', 'Limpieza profunda de asientos y alfombras', 40000.00, '01:15:00', 1),
('Lavado Ecológico', 'Lavado con productos biodegradables', 20000.00, '00:40:00', 1),
('Desinfección Interior', 'Sanitización completa del habitáculo', 30000.00, '00:50:00', 1),
('Lavado VIP', 'Servicio premium todo incluido', 120000.00, '03:00:00', 1);

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
('msuarez', '3213213210', 'hash444', 'Mónica', 'Suárez Ortiz', '3113213213', 'activo');

-- =====================================================
-- INSERTS PARA GERENTE
-- =====================================================
INSERT INTO GERENTE (id_usuario, fecha_inicio_gestion) VALUES
(1, '2023-01-15'),
(2, '2023-03-20');

-- =====================================================
-- INSERTS PARA ADMINISTRADOR
-- =====================================================
INSERT INTO ADMINISTRADOR (id_usuario, nivel_acceso) VALUES
(3, 5),
(4, 4);

-- =====================================================
-- INSERTS PARA SUPERVISOR
-- =====================================================
INSERT INTO SUPERVISOR (id_usuario, fecha_inicio_gestion, nivel_acceso, area_responsable) VALUES
(5, '2023-06-01', 3, 'Parqueadero'),
(6, '2023-07-15', 3, 'Lavado');

-- =====================================================
-- INSERTS PARA SEDE
-- =====================================================
INSERT INTO SEDE (nombre, capacidad_total, horario_apertura, horario_cierre, telefono, ciudad, direccion, id_gerente) VALUES
('Sede Norte', 150, '06:00:00', '22:00:00', '6011234567', 'Bogotá', 'Calle 100 #15-20', 1),
('Sede Sur', 120, '07:00:00', '21:00:00', '6012345678', 'Bogotá', 'Carrera 50 #8-30', 2),
('Sede Centro', 180, '06:30:00', '23:00:00', '6013456789', 'Bogotá', 'Avenida Jiménez #7-50', 1),
('Sede Chapinero', 100, '07:00:00', '20:00:00', '6014567890', 'Bogotá', 'Carrera 13 #60-25', 2),
('Sede Suba', 140, '06:00:00', '22:00:00', '6015678901', 'Bogotá', 'Avenida Suba #100-45', 1),
('Sede Medellín Centro', 160, '06:30:00', '22:30:00', '6046789012', 'Medellín', 'Carrera 43A #1-50', 2),
('Sede Envigado', 110, '07:00:00', '21:00:00', '6047890123', 'Envigado', 'Calle 30 Sur #45-20', 1),
('Sede Cali Norte', 130, '06:00:00', '22:00:00', '6028901234', 'Cali', 'Avenida 6N #28-50', 2),
('Sede Barranquilla', 145, '07:00:00', '22:00:00', '6059012345', 'Barranquilla', 'Calle 82 #52-100', 1),
('Sede Cartagena', 125, '06:30:00', '21:30:00', '6050123456', 'Cartagena', 'Avenida Pedro de Heredia #30-10', 2);

-- =====================================================
-- INSERTS PARA OPERARIO
-- =====================================================
INSERT INTO OPERARIO (id_usuario, fecha_inicio, id_supervisor, id_parqueo) VALUES
(7, '2024-01-10', 5, NULL),
(8, '2024-02-15', 5, NULL);

-- =====================================================
-- INSERTS PARA LAVADOR
-- =====================================================
INSERT INTO LAVADOR (id_usuario, fecha_inicio_gestion, cantidad_servicios, especialidad_lavado, id_sede) VALUES
(9, '2024-03-01', 45, 'Pulido', 1),
(10, '2024-04-01', 38, 'Tapicería', 2);

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
('Sofía', 'Reyes', '1212121212', '3111212121', 'Avenida 19 #120-45', 'sofia.reyes@email.com');

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
(2022, 'BCD890', 'Gris', 'Grand Vitara', 'Suzuki', 10);

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
('Eléctrico', 0, 'Vehículo eléctrico');

-- =====================================================
-- INSERTS PARA Vehiculo_TipoVehiculo
-- =====================================================
INSERT INTO Vehiculo_TipoVehiculo (id_vehiculo, id_tipo_vehiculo) VALUES
(1, 1), (2, 2), (3, 2), (4, 2), (5, 4),
(6, 5), (7, 5), (8, 5), (9, 5), (10, 5);

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
('F-601', 'disponible', 6);

-- =====================================================
-- INSERTS PARA CELDA_PARQUEO
-- =====================================================
INSERT INTO CELDA_PARQUEO (id_celda, id_convenio) VALUES
(1, NULL), (2, NULL), (3, NULL), (4, NULL), (5, NULL),
(6, NULL), (7, NULL), (8, NULL), (9, NULL), (10, NULL);

-- =====================================================
-- INSERTS PARA CELDA_LAVADO
-- =====================================================
INSERT INTO CELDA_LAVADO (id_celda, condicion_luz, espacio) VALUES
(1, 'Natural', 'Amplio'),
(2, 'Artificial', 'Mediano'),
(3, 'Natural', 'Amplio'),
(4, 'Mixta', 'Grande'),
(5, 'Natural', 'Amplio'),
(6, 'Artificial', 'Mediano'),
(7, 'Natural', 'Grande'),
(8, 'Mixta', 'Amplio'),
(9, 'Natural', 'Mediano'),
(10, 'Artificial', 'Amplio');

-- =====================================================
-- INSERTS PARA CELDA_RECARGA_ELECTRICA
-- =====================================================
INSERT INTO CELDA_RECARGA_ELECTRICA (id_celda, potencia) VALUES
(1, 7.50), (2, 11.00), (3, 22.00), (4, 7.50), (5, 11.00),
(6, 22.00), (7, 50.00), (8, 7.50), (9, 11.00), (10, 22.00);

-- =====================================================
-- INSERTS PARA CELDA_MOVILIDAD_REDUCIDA
-- =====================================================
INSERT INTO CELDA_MOVILIDAD_REDUCIDA (id_celda, ancho) VALUES
(1, 3.50), (2, 3.80), (3, 3.50), (4, 4.00), (5, 3.70),
(6, 3.90), (7, 3.60), (8, 3.50), (9, 3.80), (10, 4.00);

-- =====================================================
-- INSERTS PARA Celda_TipoVehiculo
-- =====================================================
INSERT INTO Celda_TipoVehiculo (id_celda, id_tipo_vehiculo) VALUES
(1, 1), (1, 2), (2, 2), (3, 3), (4, 1),
(5, 4), (6, 5), (7, 3), (8, 2), (9, 1), (10, 5);

-- =====================================================
-- INSERTS PARA CONVENIO
-- =====================================================
INSERT INTO CONVENIO (descripcion, precio_base, vigencia_inicio, vigencia_fin, plazo, reglas_especiales) VALUES
('Convenio Empresarial Mensual', 180000.00, '2024-01-01', '2024-12-31', 30, 'Acceso ilimitado de lunes a viernes'),
('Convenio Celda Fija Premium', 250000.00, '2024-01-01', '2024-12-31', 30, 'Celda asignada exclusivamente'),
('Convenio 15 Días al Mes', 120000.00, '2024-01-01', '2024-12-31', 30, 'Acceso 15 días calendario'),
('Convenio 100 Horas Mensuales', 150000.00, '2024-01-01', '2024-12-31', 30, 'Máximo 100 horas de parqueo al mes'),
('Convenio Pico y Placa', 95000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo en días de restricción vehicular'),
('Convenio Lavado Corporativo', 200000.00, '2024-01-01', '2024-12-31', 30, '10 lavados completos al mes'),
('Convenio Multi-vehículo', 300000.00, '2024-01-01', '2024-12-31', 30, 'Hasta 3 vehículos por empresa'),
('Convenio Nocturno', 140000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo de 6pm a 6am ilimitado'),
('Convenio Weekend', 80000.00, '2024-01-01', '2024-12-31', 30, 'Sábados y domingos ilimitado'),
('Convenio VIP Todo Incluido', 450000.00, '2024-01-01', '2024-12-31', 30, 'Parqueo + 4 lavados premium mensuales');

-- =====================================================
-- INSERTS PARA CONVENIO_PARQUEADERO
-- =====================================================
INSERT INTO CONVENIO_PARQUEADERO (id_convenio, requiere_tarjeta) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
(7, 1), (8, 1), (9, 1), (10, 1);

-- =====================================================
-- INSERTS PARA CONVENIO_LAVADO
-- =====================================================
INSERT INTO CONVENIO_LAVADO (id_convenio, cantidad_lavado_mes) VALUES
(6, 10), (10, 4);

-- =====================================================
-- INSERTS PARA CONVENIO_IRRESTRICTIVO
-- =====================================================
INSERT INTO CONVENIO_IRRESTRICTIVO (id_convenio, cantidad_vehiculos) VALUES
(1, 1), (7, 3), (8, 1);

-- =====================================================
-- INSERTS PARA CONVENIO_CELDA_FIJA
-- =====================================================
INSERT INTO CONVENIO_CELDA_FIJA (id_convenio, id_celda) VALUES
(2, 1), (10, 3);

-- =====================================================
-- INSERTS PARA CONVENIO_DIAS_MES
-- =====================================================
INSERT INTO CONVENIO_DIAS_MES (id_convenio, cantidad_dias) VALUES
(3, 15), (9, 8);

-- =====================================================
-- INSERTS PARA CONVENIO_HORAS_MES
-- =====================================================
INSERT INTO CONVENIO_HORAS_MES (id_convenio, horas_permitidas, cantidad_horas_mes) VALUES
(4, 5, 100), (8, 12, 360);

-- =====================================================
-- INSERTS PARA CONVENIO_DIA_PLACA
-- =====================================================
INSERT INTO CONVENIO_DIA_PLACA (id_convenio, id_vehiculo) VALUES
(5, 1);

-- =====================================================
-- INSERTS PARA Convenio_TipoVehiculo
-- =====================================================
INSERT INTO Convenio_TipoVehiculo (id_convenio_parqueadero, id_tipo_vehiculo) VALUES
(1, 1), (1, 2), (2, 2), (3, 1), (4, 2),
(7, 3), (8, 1), (9, 2), (10, 5);

-- =====================================================
-- INSERTS PARA Convenio_Sede
-- =====================================================
INSERT INTO Convenio_Sede (id_convenio, id_sede) VALUES
(1, 1), (2, 1), (3, 2), (4, 2), (5, 3),
(6, 1), (7, 4), (8, 5), (9, 6), (10, 1);

-- =====================================================
-- INSERTS PARA Convenio_TipoLavado
-- =====================================================
INSERT INTO Convenio_TipoLavado (id_convenio_lavado, id_tipo_lavado) VALUES
(6, 2), (6, 3), (10, 3), (10, 6), (10, 10);

-- =====================================================
-- INSERTS PARA Convenio_Celda
-- =====================================================
INSERT INTO Convenio_Celda (id_convenio, id_celda) VALUES
(6, 1), (6, 2), (10, 3), (10, 7), (10, 8);

-- =====================================================
-- INSERTS PARA TARJETA
-- =====================================================
INSERT INTO TARJETA (fecha_hora_emision, codigo_tarjeta, estado_tarjeta, fecha_vencimiento) VALUES
('2024-01-15 08:30:00', 'TJ-2024-0001', 'Activa', '2024-12-31'),
('2024-01-20 09:15:00', 'TJ-2024-0002', 'Activa', '2024-12-31'),
('2024-02-10 10:00:00', 'TJ-2024-0003', 'Activa', '2024-12-31'),
('2024-11-17 14:30:00', 'TO-2024-0001', 'Activa', NULL),
('2024-11-17 15:00:00', 'TO-2024-0002', 'Inactiva', NULL),
('2024-03-05 11:20:00', 'TJ-2024-0004', 'Activa', '2024-12-31'),
('2024-11-17 16:15:00', 'TO-2024-0003', 'Activa', NULL),
('2024-04-12 08:45:00', 'TJ-2024-0005', 'Activa', '2024-12-31'),
('2024-11-17 17:00:00', 'TO-2024-0004', 'Activa', NULL),
('2024-05-20 13:30:00', 'TJ-2024-0006', 'Activa', '2024-12-31');

-- =====================================================
-- INSERTS PARA TARJETA_CONVENIO
-- =====================================================
INSERT INTO TARJETA_CONVENIO (id_tarjeta, fecha_expiracion) VALUES
(1, '2024-12-31'),
(2, '2024-12-31'),
(3, '2024-12-31'),
(6, '2024-12-31'),
(8, '2024-12-31'),
(10, '2024-12-31');

-- =====================================================
-- INSERTS PARA TARJETA_OCASIONAL
-- =====================================================
INSERT INTO TARJETA_OCASIONAL (id_tarjeta, valor, pagada, hora_entrada, id_pago) VALUES
(4, 8000.00, 0, '2024-11-17 14:30:00', NULL),
(5, 12000.00, 1, '2024-11-17 10:00:00', NULL),
(7, 6000.00, 0, '2024-11-17 16:15:00', NULL),
(9, 15000.00, 0, '2024-11-17 17:00:00', NULL);

-- =====================================================
-- INSERTS PARA ASIGNACION_CONVENIO
-- =====================================================
INSERT INTO ASIGNACION_CONVENIO (fecha_inicio, fecha_fin, id_celda, id_vehiculo, limite_vehiculos, precio_negociado, estado, id_tarjeta, id_convenio) VALUES
('2024-01-01', '2024-12-31', NULL, 1, 1, 180000.00, 'Activo', 1, 1),
('2024-01-01', '2024-12-31', 1, NULL, 1, 250000.00, 'Activo', 2, 2),
('2024-01-01', '2024-12-31', NULL, 2, 1, 120000.00, 'Activo', 3, 3),
('2024-01-01', '2024-12-31', NULL, 3, 1, 150000.00, 'Activo', 6, 4),
('2024-01-01', '2024-12-31', NULL, 4, 1, 95000.00, 'Activo', 8, 5),
('2024-01-01', '2024-12-31', NULL, 5, 1, 200000.00, 'Activo', 10, 6),
('2024-01-01', '2024-12-31', NULL, 6, 3, 300000.00, 'Activo', 1, 7),
('2024-01-01', '2024-12-31', NULL, 7, 1, 140000.00, 'Activo', 2, 8),
('2024-01-01', '2024-12-31', NULL, 8, 1, 80000.00, 'Activo', 3, 9),
('2024-01-01', '2024-12-31', 3, 9, 1, 450000.00, 'Activo', 6, 10);

-- =====================================================
-- INSERTS PARA PARQUEO
-- =====================================================
INSERT INTO PARQUEO (
    fecha_hora_ingreso, fecha_hora_salida, estado_parqueo, modo_ingreso, valor_cobrado, id_tarjeta, id_celda, id_vehiculo) VALUES
('2024-11-17 08:00:00', '2024-11-17 18:00:00', 'finalizado', 'Convenio',   0.00, 1, 1, 1),
('2024-11-17 09:30:00', NULL,               'activo',     'Convenio',   0.00, 2, 2, 2),
('2024-11-17 14:30:00', NULL,               'activo',     'Ocasional',  8000.00, 4, 3, 3),
('2024-11-17 10:00:00', '2024-11-17 15:00:00','finalizado','Ocasional', 12000.00, 5, 4, 4),
('2024-11-17 07:45:00', NULL,               'activo',     'Convenio',   0.00, 3, 5, 5),
('2024-11-17 11:20:00', '2024-11-17 17:30:00','finalizado','Convenio',   0.00, 6, 6, 6),
('2024-11-17 16:15:00', NULL,               'activo',     'Ocasional',  6000.00, 7, 7, 7),
('2024-11-17 13:00:00', NULL,               'activo',     'Convenio',   0.00, 8, 8, 8),
('2024-11-17 17:00:00', NULL,               'activo',     'Ocasional', 15000.00, 9, 9, 9),
('2024-11-17 06:30:00', '2024-11-17 19:00:00','finalizado','Convenio',   0.00, 10, 10, 10);

-- =====================================================
-- INSERTS PARA TURNO_LABORAL
-- =====================================================
INSERT INTO TURNO_LABORAL (observaciones, estado, horas_trabajadas, fecha_hora_entrada, fecha_hora_salida, id_usuario) VALUES
('Turno normal', 'finalizado', 8.00, '2024-11-17 06:00:00', '2024-11-17 14:00:00', 7),
('Turno tarde', 'activo', 0.00, '2024-11-17 14:00:00', NULL, 8),
('Turno mañana', 'finalizado', 8.00, '2024-11-17 06:00:00', '2024-11-17 14:00:00', 9),
('Turno completo', 'activo', 0.00, '2024-11-17 08:00:00', NULL, 10),
('Turno nocturno', 'finalizado', 8.00, '2024-11-16 22:00:00', '2024-11-17 06:00:00', 7),
('Turno partido', 'finalizado', 6.00, '2024-11-17 10:00:00', '2024-11-17 16:00:00', 8),
('Extra fin de semana', 'finalizado', 10.00, '2024-11-16 08:00:00', '2024-11-16 18:00:00', 9),
('Turno supervisión', 'activo', 0.00, '2024-11-17 07:00:00', NULL, 5),
('Turno gerencia', 'activo', 0.00, '2024-11-17 08:00:00', NULL, 1),
('Turno administración', 'activo', 0.00, '2024-11-17 09:00:00', NULL, 3);

-- =====================================================
-- INSERTS PARA FACTURA
-- =====================================================
INSERT INTO FACTURA (total_bruto, numero_factura, metodo_pago, total_neto, fecha_hora_emision, id_usuario, id_parqueo, id_cliente, id_asignacion_convenio) VALUES
(35000.00, 'FAC-2024-0001', 'Efectivo', 35000.00, '2024-11-17 12:00:00', 7, NULL, 1, NULL),
(12000.00, 'FAC-2024-0002', 'Tarjeta', 12000.00, '2024-11-17 15:00:00', 7, 4, 2, NULL),
(55000.00, 'FAC-2024-0003', 'Transferencia', 55000.00, '2024-11-17 16:30:00', 8, NULL, 3, NULL),
(180000.00, 'FAC-2024-0004', 'Transferencia', 180000.00, '2024-01-15 10:00:00', 3, NULL, 1, 1),
(8000.00, 'FAC-2024-0005', 'Efectivo', 8000.00, '2024-11-17 18:00:00', 7, 1, 1, NULL),
(40000.00, 'FAC-2024-0006', 'Tarjeta', 40000.00, '2024-11-17 14:45:00', 8, NULL, 4, NULL),
(120000.00, 'FAC-2024-0007', 'Transferencia', 120000.00, '2024-02-10 11:00:00', 3, NULL, 2, 3),
(25000.00, 'FAC-2024-0008', 'Efectivo', 25000.00, '2024-11-17 17:15:00', 9, NULL, 5, NULL),
(80000.00, 'FAC-2024-0009', 'Tarjeta', 80000.00, '2024-11-17 19:00:00', 10, NULL, 6, NULL),
(250000.00, 'FAC-2024-0010', 'Transferencia', 250000.00, '2024-01-20 09:30:00', 3, NULL, 2, 2);

-- =====================================================
-- INSERTS PARA PAGO
-- =====================================================
INSERT INTO PAGO (metodo_pago, monto_pago, fecha_hora_pago, referencia_transaccion, id_factura, id_cliente) VALUES
('Efectivo', 35000.00, '2024-11-17 12:00:00', 'EFE-20241117-001', 1, 1),
('Tarjeta', 12000.00, '2024-11-17 15:00:00', 'TRX-20241117-001', 2, 2),
('Transferencia', 55000.00, '2024-11-17 16:30:00', 'TRF-20241117-002', 3, 3),
('Transferencia', 180000.00, '2024-01-15 10:00:00', 'TRF-20240115-001', 4, 1),
('Efectivo', 8000.00, '2024-11-17 18:00:00', 'EFE-20241117-002', 5, 1),
('Tarjeta', 40000.00, '2024-11-17 14:45:00', 'TRX-20241117-003', 6, 4),
('Transferencia', 120000.00, '2024-02-10 11:00:00', 'TRF-20240210-001', 7, 2),
('Efectivo', 25000.00, '2024-11-17 17:15:00', 'EFE-20241117-003', 8, 5),
('Tarjeta', 80000.00, '2024-11-17 19:00:00', 'TRX-20241117-004', 9, 6),
('Transferencia', 250000.00, '2024-01-20 09:30:00', 'TRF-20240120-001', 10, 2);

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
(10, 1, 1, 250000.00, 'Convenio Celda Fija', 'Pago convenio celda fija mes de enero', NULL);

-- =====================================================
-- INSERTS PARA SERVICIO_LAVADO
-- =====================================================
INSERT INTO SERVICIO_LAVADO (fecha_hora_inicio, fecha_hora_fin, valor, estado, id_tipo_lavado, id_usuario, id_celda, id_factura, id_cliente, id_vehiculo, id_convenio) VALUES
('2024-11-17 10:00:00', '2024-11-17 11:00:00', 35000.00, 'completado', 2, 9, 1, 1, 1, 1, NULL),
('2024-11-17 14:00:00', '2024-11-17 15:45:00', 55000.00, 'completado', 3, 9, 2, 3, 3, 3, NULL),
('2024-11-17 11:30:00', '2024-11-17 12:45:00', 40000.00, 'completado', 7, 10, 3, 6, 4, 4, NULL),
('2024-11-17 16:00:00', '2024-11-17 16:45:00', 25000.00, 'completado', 5, 9, 4, 8, 5, 5, NULL),
('2024-11-17 17:30:00', '2024-11-17 20:00:00', 80000.00, 'completado', 6, 10, 5, 9, 6, 6, NULL),
('2024-11-17 08:30:00', '2024-11-17 09:00:00', 15000.00, 'completado', 1, 9, 6, NULL, 7, 7, NULL),
('2024-11-17 12:00:00', NULL, 35000.00, 'en_proceso', 2, 10, 7, NULL, 8, 8, NULL),
('2024-11-17 15:30:00', '2024-11-17 15:45:00', 10000.00, 'completado', 4, 9, 8, NULL, 9, 9, NULL),
('2024-11-17 09:00:00', '2024-11-17 09:50:00', 30000.00, 'completado', 9, 10, 9, NULL, 10, 10, NULL),
('2024-11-16 16:00:00', '2024-11-16 18:30:00', 80000.00, 'completado', 6, 9, 10, NULL, 1, 2, 6);

-- =====================================================
-- INSERTS PARA TARIFA_LAVADO
-- =====================================================
INSERT INTO TARIFA_LAVADO (precio, activo, tiempo_estimado, id_tipo_lavado, id_tipo_vehiculo, id_servicio_lavado) VALUES
(35000.00, 1, 60, 2, 2, 1),
(55000.00, 1, 105, 3, 2, 2),
(40000.00, 1, 75, 7, 2, 3),
(25000.00, 1, 45, 5, 2, 4),
(80000.00, 1, 150, 6, 5, 5),
(15000.00, 1, 30, 1, 1, 6),
(35000.00, 1, 60, 2, 2, 7),
(10000.00, 1, 15, 4, 4, 8),
(30000.00, 1, 50, 9, 2, 9),
(80000.00, 1, 150, 6, 2, 10);

-- =====================================================
-- INSERTS PARA TURNO_LAVADO
-- =====================================================
INSERT INTO TURNO_LAVADO (fecha, fecha_hora_inicio, fecha_hora_salida, estado, id_tipo_lavado, id_vehiculo, id_usuario, id_celda_lavado, id_servicio_lavado) VALUES
('2024-11-17', '10:00:00', '11:00:00', 'Completado', 2, 1, 9, 1, 1),
('2024-11-17', '14:00:00', '15:45:00', 'Completado', 3, 3, 9, 2, 2),
('2024-11-17', '11:30:00', '12:45:00', 'Completado', 7, 4, 10, 3, 3),
('2024-11-17', '16:00:00', '16:45:00', 'Completado', 5, 5, 9, 4, 4),
('2024-11-17', '17:30:00', '20:00:00', 'Completado', 6, 6, 10, 5, 5),
('2024-11-17', '08:30:00', '09:00:00', 'Completado', 1, 7, 9, 6, 6),
('2024-11-17', '12:00:00', '13:00:00', 'En Proceso', 2, 8, 10, 7, 7),
('2024-11-17', '15:30:00', '15:45:00', 'Completado', 4, 9, 9, 8, 8),
('2024-11-17', '09:00:00', '09:50:00', 'Completado', 9, 10, 10, 9, 9),
('2024-11-16', '16:00:00', '18:30:00', 'Completado', 6, 2, 9, 10, 10);

-- =====================================================
-- FIN DE LOS INSERTS
-- =====================================================

-- Consulta para verificar cantidad de registros por tabla
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
ORDER BY Tabla;

/*Hacer 4 consultas útiles para el usuario, que implementen los 4 tipos de Joins que hay.
Cada consulta debe ir con su respectivo enunciado, y debe generar algún resultado.*/
/* 1 creacion de consulta con inner join 
autor David 
enunciado : Mostrar los parqueos realizados, junto con la información del vehículo y la sede donde se estacionó.
El objetivo es que el usuario pueda ver los movimientos de parqueo con su contexto completo.*/
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

/* 2  creacion de consulta con left   join 
autor David 
enunciado : Mostrar todos los clientes registrados, junto con los vehículos que tienen.  */
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

 /* 3   creacion de consulta con rigth    join 
autor David 
enunciado : Mostrar todos los lavados realizados, junto con su factura asociada (si existe).
Si hay algún lavado que todavía no ha sido facturado, debe aparecer igualmente. */
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

	/* 4   creacion de consulta con FULL OUTER JOIN
autor David 
 Listar todos los convenios y todos los clientes, para ver:
   - clientes sin convenio,
   - convenios sin clientes,
   - y los que sí están asociados. */

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


/*Desarrollar 3 funciones de tablas y 3 funciones escalares dentro de las necesidades del proyecto a desarrollar.
Estos procedimientos deben estar debidamente documentados.*/

/*  1 creacion de funciones de tabla : Disponibilidad de Celdas 
autor: David Martinez Giraldo 
fecha : 7/11/2025 

*/
-- Función 1: Celdas de PARQUEO disponibles
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

-- Función 2: Celdas de LAVADO disponibles
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
-- Función 3: Celdas de RECARGA ELÉCTRICA disponibles
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
-- Función 4: Celdas de MOVILIDAD REDUCIDA disponibles
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

  /*2 creacion de funcion de tabla: dbo.tvf_ParqueosAbiertosPorSede
 autor: David Martinez Giraldo 
fecha : 7/11/2025 
descripcion :Devuelve los parqueos abiertos (sin cierre ) de una sede específica, mostrando placa, hora de ingreso y el tiempo transcurrido en horas hasta ahora
 (o hasta la hora de salida si ya está registrada).*/

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
 SELECT * FROM dbo.tvf_ParqueosAbiertosPorSede(1);
  /*3 creacion de funcion de tabla: dbo.tvf_HistorialLavadosPorVehiculo
 autor: David Martinez Giraldo 
fecha : 7/11/2025 
descripcion :Mostrar el historial de lavados realizados a un vehículo específico, con las fechas, estado y precio.
Ideal para consultas rápidas del cliente o para generar reportes de uso del servicio.*/
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

--- funciones escalares 

/*  1 creacion de funcion escalar: dbo.ufn_TotalLavadosVehiculo 
autor David Martinez Giraldo 
descripcion funcion que devuelve las veces en que se ha lavado un vehiculo 
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
 /*  2  creacion de funcion escalar: dbo.ufn_CeldasDisponiblesEnSede 
autor David Martinez Giraldo 
descripcion:  funcion que devuelve cuantas celdas estan libres en una cede 
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

  /*  3  creacion de funcion escalar:  dbo.ufn_CeldasOcupadasEnSede 
autor David Martinez Giraldo 
descripcion:  funcion que devuelve cuantas celdas estan ocupado  en una cede 
*/
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

/*Hacer 4 consultas que utilice teoría de conjuntos. Deben ir con su enunciado y producir algún resultado.*/

/* 1  creacion de consulta con UNION (teoría de conjuntos)
autor David
enunciado : Listar todas las placas que han tenido actividad en el sistema (ya sea parqueo o lavado), sin duplicados. */
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p)
UNION
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT sl.id_vehiculo FROM SERVICIO_LAVADO AS sl);

/* 2  creacion de consulta con UNION ALL (teoría de conjuntos)
autor David
enunciado : Contar el total de actividades por placa sumando parqueos y lavados (conservando duplicados para sumar frecuencia). */
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

/* 3  creacion de consulta con INTERSECT (teoría de conjuntos)
autor David
enunciado : Obtener las placas que aparecen tanto en parqueos como en lavados (intersección). */
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p)
INTERSECT
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT sl.id_vehiculo FROM SERVICIO_LAVADO AS sl);
/* 4  creacion de consulta con EXCEPT (teoría de conjuntos)
autor David
enunciado : Listar los vehículos registrados que nunca se han parqueado (diferencia de conjuntos). */
SELECT v.placa
FROM VEHICULO AS v
EXCEPT
SELECT v.placa
FROM VEHICULO AS v
WHERE v.id_vehiculo IN (SELECT p.id_vehiculo FROM PARQUEO AS p);

/* ============================================================
   VISTA 1: v_ParqueoEditableSimple
   autor: David Martínez
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
   autor: David Martínez
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
-- Autor: Julian Alvarez (Adaptado)
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
    SET @horas = CAST(@minutos AS DECIMAL(10,2)) / 60.0;
    
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
                SET @monto = @precio_base * CEILING(@horas / 24.0); -- Por día
            ELSE
                SET @monto = @precio_base * CEILING(@horas); -- Por hora
        END
    END
    ELSE
    BEGIN
        -- Tarifas ocasionales según tipo de vehículo
        IF @id_tipo_vehiculo = 1 -- Pequeño
            SET @monto = 2000 * CEILING(@horas);
        ELSE IF @id_tipo_vehiculo = 2 -- Mediano
            SET @monto = 3000 * CEILING(@horas);
        ELSE IF @id_tipo_vehiculo = 3 -- Grande/SUV
            SET @monto = 5000 * CEILING(@horas);
        ELSE IF @id_tipo_vehiculo = 4 -- Compacto
            SET @monto = 1500 * CEILING(@horas);
        ELSE
            SET @monto = 2500 * CEILING(@horas);
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

-- PROCEDIMIENTO 1: Procesar salida de vehículo y generar factura completa
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

-- PROCEDIMIENTO 2: Asignar celda automáticamente según disponibilidad y convenio
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
    @id_cliente INT, @id_convenio INT;
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

-- ANALISIS DE DATOS APLICADO AL PROYECTO

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




