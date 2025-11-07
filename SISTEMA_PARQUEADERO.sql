 CREATE DATABASE SIS_PARQUEADERO
   GO
USE SIS_PARQUEADERO
   GO 

CREATE TABLE CELDA (
id_celda INT PRIMARY KEY IDENTITY(1,1),
id_sede INT NOT NULL,
id_tipo_celda INT   ,
ESTADO_CELDA VARCHAR(50) CHECK (ESTADO_CELDA  IN ('Ocupada', 'Libre')) NOT NULL
);

CREATE TABLE sede (
id_sede INT PRIMARY KEY IDENTITY(1,1),
nombre_sede VARCHAR(100) NOT NULL,
direccion VARCHAR(200)
);

CREATE TABLE TIPO_CELDA (
id_tipo_celda INT PRIMARY KEY IDENTITY(1,1),
nombre_tipo VARCHAR(50),
tamaño_referencial VARCHAR(50)
);

CREATE TABLE rol (
id_rol INT PRIMARY KEY IDENTITY(1,1),
nombre_rol VARCHAR(50) NOT NULL,
descripcion VARCHAR(200)
);

CREATE TABLE usuario (
id_usuario INT PRIMARY KEY IDENTITY(1,1),
nombre_usuario VARCHAR(100) NOT NULL,
contraseña VARCHAR(255) NOT NULL,
nombre_completo VARCHAR(150),
correo VARCHAR(100),
id_rol INT NOT NULL,
estado_parqueo BIT,
id_sede INT
);

CREATE TABLE personal (
id_personal INT PRIMARY KEY IDENTITY(1,1),
documento VARCHAR(50) NOT NULL,
nombre VARCHAR(100) NOT NULL,
apellido VARCHAR(100) NOT NULL,
telefono VARCHAR(20),
correo VARCHAR(100),
id_rol INT NOT NULL,
id_sede INT
);

CREATE TABLE cliente (
documento VARCHAR(50) PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
telefono VARCHAR(20),
correo VARCHAR(100),
direccion VARCHAR(200),
id_convenio INT
);

CREATE TABLE convenio (
id_convenio INT PRIMARY KEY IDENTITY(1,1),
nombre_convenio VARCHAR(100) NOT NULL,
descripcion VARCHAR(200),
precio_base DECIMAL(10,2),
unidad_tarifaria VARCHAR(50),
vigencia_inicio DATE,
vigencia_fin DATE,
id_sede INT
);

CREATE TABLE TIPO_VEHICULO (
    id_tipo_vehiculo INT PRIMARY KEY IDENTITY(1,1),
    nombre_tipo VARCHAR(50) NOT NULL,
    cilindraje VARCHAR(20)
);

CREATE TABLE vehiculo (
    placa VARCHAR(20) PRIMARY KEY,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    color VARCHAR(30),
    id_tipo_vehiculo INT NOT NULL,
    documento_cliente VARCHAR(50) NOT NULL
);

CREATE TABLE parqueo (
id_parqueo INT PRIMARY KEY IDENTITY(1,1),
id_tarjeta INT NOT NULL,
fecha_hora_ingreso DATETIME NOT NULL,
fecha_hora_salida DATETIME,
id_sede INT NOT NULL,
placa_vehiculo VARCHAR(20) NOT NULL,
estado_parqueo VARCHAR(20)
);

CREATE TABLE Tarjeta (
id_tarjeta INT PRIMARY KEY IDENTITY(1,1),
estado_tarjeta VARCHAR(20),
fecha_hora_emision DATETIME,
id_personal INT NOT NULL
);

CREATE TABLE lavado(
id_lavado INT PRIMARY KEY IDENTITY(1,1),
id_sede INT NOT NULL,
precio_lavado DECIMAL(10,2),
placa VARCHAR(20),
fecha_inicio DATETIME,
fecha_fin DATETIME,
estado_lavado VARCHAR(20)
);
ALTER TABLE lavado
add id_celda_lavado int

ALTER TABLE lavado
add id_tipo_lavado int

CREATE TABLE tipo_lavado (
id_tipo_lavado INT PRIMARY KEY IDENTITY(1,1),
descripcion VARCHAR(100),
precio DECIMAL(10,2)
);

CREATE TABLE celda_lavado (
id_celda_lavado INT PRIMARY KEY IDENTITY(1,1),
estado_celda VARCHAR(20) CHECK (ESTADO_CELDA  IN ('Ocupada', 'Libre')) NOT NULL,
tamaño VARCHAR(50),
);

CREATE TABLE factura (
id_factura INT PRIMARY KEY IDENTITY(1,1),
fecha_emision DATE NOT NULL,
documento_cliente VARCHAR(50) NOT NULL,
id_sede INT,
total_pagar DECIMAL(10,2),
id_liquidacion_lavado INT
);

CREATE TABLE detalle_factura (
id_detalle_factura INT PRIMARY KEY IDENTITY(1,1),
id_factura INT NOT NULL,
id_referencia_servicio INT,
sub_total DECIMAL(10,2)
);

CREATE TABLE liquidacion_lavado (
id_liquidacion_lavado INT PRIMARY KEY IDENTITY(1,1),
id_lavado INT NOT NULL,
monto_calculado DECIMAL(10,2),
fecha_liquidacion DATE
);

ALTER TABLE CELDA
ADD CONSTRAINT FK_CELDA_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE CELDA
ADD CONSTRAINT FK_CELDA_TIPO_CELDA
FOREIGN KEY (id_tipo_celda)
REFERENCES TIPO_CELDA(id_tipo_celda);

ALTER TABLE usuario
ADD CONSTRAINT FK_usuario_rol
FOREIGN KEY (id_rol)
REFERENCES rol(id_rol);

ALTER TABLE usuario
ADD CONSTRAINT FK_usuario_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE personal
ADD CONSTRAINT FK_personal_rol
FOREIGN KEY (id_rol)
REFERENCES rol(id_rol);

ALTER TABLE personal
ADD CONSTRAINT FK_personal_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE cliente
ADD CONSTRAINT FK_cliente_convenio
FOREIGN KEY (id_convenio)
REFERENCES convenio(id_convenio);

ALTER TABLE convenio
ADD CONSTRAINT FK_convenio_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE vehiculo
ADD CONSTRAINT FK_vehiculo_tipo
FOREIGN KEY (id_tipo_vehiculo)
REFERENCES TIPO_VEHICULO(id_tipo_vehiculo),
CONSTRAINT FK_vehiculo_cliente
FOREIGN KEY (documento_cliente)
REFERENCES cliente(documento);

ALTER TABLE parqueo
ADD CONSTRAINT FK_parqueo_tarjeta
FOREIGN KEY (id_tarjeta)
REFERENCES Tarjeta(id_tarjeta);

ALTER TABLE parqueo
ADD CONSTRAINT FK_parqueo_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE parqueo
ADD CONSTRAINT FK_parqueo_vehiculo
FOREIGN KEY (placa_vehiculo)
REFERENCES vehiculo(placa);

ALTER TABLE Tarjeta
ADD CONSTRAINT FK_tarjeta_personal
FOREIGN KEY (id_personal)
REFERENCES personal(id_personal);

ALTER TABLE lavado
ADD CONSTRAINT FK_lavado_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE lavado
ADD CONSTRAINT FK_lavado_celda_lavado
FOREIGN KEY (id_celda_lavado)
REFERENCES celda_lavado(id_celda_lavado);

ALTER TABLE lavado
ADD CONSTRAINT FK_lavado_tipo_lavado
FOREIGN KEY (id_tipo_lavado)
REFERENCES tipo_lavado(id_tipo_lavado);

ALTER TABLE factura
ADD CONSTRAINT FK_factura_cliente
FOREIGN KEY (documento_cliente)
REFERENCES cliente(documento);

ALTER TABLE factura
ADD CONSTRAINT FK_factura_sede
FOREIGN KEY (id_sede)
REFERENCES sede(id_sede);

ALTER TABLE factura
ADD CONSTRAINT FK_factura_liquidacion
FOREIGN KEY (id_liquidacion_lavado)
REFERENCES liquidacion_lavado(id_liquidacion_lavado);

ALTER TABLE detalle_factura
ADD CONSTRAINT FK_detalle_factura
FOREIGN KEY (id_factura)
REFERENCES factura(id_factura);

ALTER TABLE liquidacion_lavado
ADD CONSTRAINT FK_liquidacion_lavado
FOREIGN KEY (id_lavado)
REFERENCES lavado(id_lavado);
