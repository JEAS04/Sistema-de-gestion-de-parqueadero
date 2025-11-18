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
