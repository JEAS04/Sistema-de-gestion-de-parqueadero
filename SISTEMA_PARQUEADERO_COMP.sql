 CREATE DATABASE SIS_PARQUEADERO
   GO
USE SIS_PARQUEADERO
   GO 

CREATE TABLE CELDA (
id_celda INT PRIMARY KEY IDENTITY(1,1),
id_sede INT NOT NULL,
id_tipo_celda INT   ,
estado_celda VARCHAR(50) CHECK (estado_celda  IN ('Ocupada', 'Libre')) NOT NULL
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
estado_celda VARCHAR(20) CHECK (estado_celda  IN ('Ocupada', 'Libre')) NOT NULL,
tamaño VARCHAR(50)
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

ALTER TABLE parqueo
ADD id_celda INT NULL;

ALTER TABLE parqueo
ADD CONSTRAINT FK_parqueo_celda
FOREIGN KEY (id_celda)
REFERENCES CELDA(id_celda);


---- tuplas 
-- BLOQUE 1: CATALOGOS (110 filas c/u)
USE SIS_PARQUEADERO;
GO

-- 1) sede (110) --- solo las 1 y 2 son reales y necesarias para la solucion del problema 
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 1', 'Calle 1 #1-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 2', 'Calle 2 #2-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 3', 'Calle 3 #3-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 4', 'Calle 4 #4-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 5', 'Calle 5 #5-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 6', 'Calle 6 #6-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 7', 'Calle 7 #7-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 8', 'Calle 8 #8-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 9', 'Calle 9 #9-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 10', 'Calle 10 #10-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 11', 'Calle 11 #11-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 12', 'Calle 12 #12-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 13', 'Calle 13 #13-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 14', 'Calle 14 #14-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 15', 'Calle 15 #15-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 16', 'Calle 16 #16-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 17', 'Calle 17 #17-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 18', 'Calle 18 #18-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 19', 'Calle 19 #19-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 20', 'Calle 20 #20-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 21', 'Calle 21 #21-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 22', 'Calle 22 #22-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 23', 'Calle 23 #23-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 24', 'Calle 24 #24-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 25', 'Calle 25 #25-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 26', 'Calle 26 #26-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 27', 'Calle 27 #27-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 28', 'Calle 28 #28-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 29', 'Calle 29 #29-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 30', 'Calle 30 #30-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 31', 'Calle 31 #31-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 32', 'Calle 32 #32-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 33', 'Calle 33 #33-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 34', 'Calle 34 #34-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 35', 'Calle 35 #35-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 36', 'Calle 36 #36-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 37', 'Calle 37 #37-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 38', 'Calle 38 #38-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 39', 'Calle 39 #39-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 40', 'Calle 40 #40-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 41', 'Calle 41 #41-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 42', 'Calle 42 #42-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 43', 'Calle 43 #43-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 44', 'Calle 44 #44-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 45', 'Calle 45 #45-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 46', 'Calle 46 #46-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 47', 'Calle 47 #47-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 48', 'Calle 48 #48-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 49', 'Calle 49 #49-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 50', 'Calle 50 #50-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 51', 'Calle 51 #51-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 52', 'Calle 52 #52-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 53', 'Calle 53 #53-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 54', 'Calle 54 #54-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 55', 'Calle 55 #55-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 56', 'Calle 56 #56-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 57', 'Calle 57 #57-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 58', 'Calle 58 #58-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 59', 'Calle 59 #59-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 60', 'Calle 60 #60-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 61', 'Calle 61 #61-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 62', 'Calle 62 #62-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 63', 'Calle 63 #63-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 64', 'Calle 64 #64-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 65', 'Calle 65 #65-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 66', 'Calle 66 #66-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 67', 'Calle 67 #67-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 68', 'Calle 68 #68-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 69', 'Calle 69 #69-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 70', 'Calle 70 #70-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 71', 'Calle 71 #71-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 72', 'Calle 72 #72-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 73', 'Calle 73 #73-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 74', 'Calle 74 #74-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 75', 'Calle 75 #75-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 76', 'Calle 76 #76-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 77', 'Calle 77 #77-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 78', 'Calle 78 #78-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 79', 'Calle 79 #79-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 80', 'Calle 80 #80-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 81', 'Calle 81 #81-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 82', 'Calle 82 #82-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 83', 'Calle 83 #83-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 84', 'Calle 84 #84-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 85', 'Calle 85 #85-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 86', 'Calle 86 #86-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 87', 'Calle 87 #87-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 88', 'Calle 88 #88-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 89', 'Calle 89 #89-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 90', 'Calle 90 #90-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 91', 'Calle 91 #91-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 92', 'Calle 92 #92-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 93', 'Calle 93 #93-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 94', 'Calle 94 #94-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 95', 'Calle 95 #95-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 96', 'Calle 96 #96-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 97', 'Calle 97 #97-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 98', 'Calle 98 #98-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 99', 'Calle 99 #99-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 100', 'Calle 100 #100-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 101', 'Calle 101 #101-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 102', 'Calle 102 #102-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 103', 'Calle 103 #103-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 104', 'Calle 104 #104-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 105', 'Calle 105 #105-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 106', 'Calle 106 #106-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 107', 'Calle 107 #107-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 108', 'Calle 108 #108-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 109', 'Calle 109 #109-00');
INSERT INTO sede (nombre_sede, direccion) VALUES ('Sede 110', 'Calle 110 #110-00');

-- 2) rol (110)
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_001', 'Descripcion del rol 1');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_002', 'Descripcion del rol 2');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_003', 'Descripcion del rol 3');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_004', 'Descripcion del rol 4');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_005', 'Descripcion del rol 5');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_006', 'Descripcion del rol 6');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_007', 'Descripcion del rol 7');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_008', 'Descripcion del rol 8');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_009', 'Descripcion del rol 9');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_010', 'Descripcion del rol 10');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_011', 'Descripcion del rol 11');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_012', 'Descripcion del rol 12');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_013', 'Descripcion del rol 13');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_014', 'Descripcion del rol 14');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_015', 'Descripcion del rol 15');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_016', 'Descripcion del rol 16');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_017', 'Descripcion del rol 17');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_018', 'Descripcion del rol 18');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_019', 'Descripcion del rol 19');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_020', 'Descripcion del rol 20');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_021', 'Descripcion del rol 21');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_022', 'Descripcion del rol 22');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_023', 'Descripcion del rol 23');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_024', 'Descripcion del rol 24');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_025', 'Descripcion del rol 25');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_026', 'Descripcion del rol 26');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_027', 'Descripcion del rol 27');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_028', 'Descripcion del rol 28');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_029', 'Descripcion del rol 29');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_030', 'Descripcion del rol 30');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_031', 'Descripcion del rol 31');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_032', 'Descripcion del rol 32');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_033', 'Descripcion del rol 33');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_034', 'Descripcion del rol 34');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_035', 'Descripcion del rol 35');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_036', 'Descripcion del rol 36');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_037', 'Descripcion del rol 37');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_038', 'Descripcion del rol 38');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_039', 'Descripcion del rol 39');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_040', 'Descripcion del rol 40');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_041', 'Descripcion del rol 41');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_042', 'Descripcion del rol 42');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_043', 'Descripcion del rol 43');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_044', 'Descripcion del rol 44');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_045', 'Descripcion del rol 45');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_046', 'Descripcion del rol 46');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_047', 'Descripcion del rol 47');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_048', 'Descripcion del rol 48');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_049', 'Descripcion del rol 49');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_050', 'Descripcion del rol 50');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_051', 'Descripcion del rol 51');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_052', 'Descripcion del rol 52');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_053', 'Descripcion del rol 53');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_054', 'Descripcion del rol 54');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_055', 'Descripcion del rol 55');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_056', 'Descripcion del rol 56');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_057', 'Descripcion del rol 57');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_058', 'Descripcion del rol 58');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_059', 'Descripcion del rol 59');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_060', 'Descripcion del rol 60');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_061', 'Descripcion del rol 61');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_062', 'Descripcion del rol 62');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_063', 'Descripcion del rol 63');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_064', 'Descripcion del rol 64');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_065', 'Descripcion del rol 65');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_066', 'Descripcion del rol 66');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_067', 'Descripcion del rol 67');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_068', 'Descripcion del rol 68');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_069', 'Descripcion del rol 69');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_070', 'Descripcion del rol 70');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_071', 'Descripcion del rol 71');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_072', 'Descripcion del rol 72');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_073', 'Descripcion del rol 73');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_074', 'Descripcion del rol 74');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_075', 'Descripcion del rol 75');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_076', 'Descripcion del rol 76');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_077', 'Descripcion del rol 77');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_078', 'Descripcion del rol 78');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_079', 'Descripcion del rol 79');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_080', 'Descripcion del rol 80');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_081', 'Descripcion del rol 81');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_082', 'Descripcion del rol 82');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_083', 'Descripcion del rol 83');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_084', 'Descripcion del rol 84');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_085', 'Descripcion del rol 85');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_086', 'Descripcion del rol 86');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_087', 'Descripcion del rol 87');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_088', 'Descripcion del rol 88');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_089', 'Descripcion del rol 89');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_090', 'Descripcion del rol 90');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_091', 'Descripcion del rol 91');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_092', 'Descripcion del rol 92');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_093', 'Descripcion del rol 93');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_094', 'Descripcion del rol 94');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_095', 'Descripcion del rol 95');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_096', 'Descripcion del rol 96');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_097', 'Descripcion del rol 97');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_098', 'Descripcion del rol 98');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_099', 'Descripcion del rol 99');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_100', 'Descripcion del rol 100');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_101', 'Descripcion del rol 101');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_102', 'Descripcion del rol 102');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_103', 'Descripcion del rol 103');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_104', 'Descripcion del rol 104');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_105', 'Descripcion del rol 105');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_106', 'Descripcion del rol 106');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_107', 'Descripcion del rol 107');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_108', 'Descripcion del rol 108');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_109', 'Descripcion del rol 109');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('Rol_110', 'Descripcion del rol 110');

-- 3) TIPO_CELDA (110)
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_001', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_002', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_003', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_004', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_005', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_006', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_007', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_008', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_009', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_010', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_011', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_012', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_013', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_014', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_015', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_016', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_017', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_018', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_019', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_020', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_021', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_022', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_023', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_024', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_025', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_026', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_027', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_028', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_029', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_030', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_031', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_032', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_033', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_034', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_035', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_036', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_037', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_038', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_039', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_040', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_041', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_042', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_043', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_044', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_045', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_046', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_047', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_048', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_049', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_050', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_051', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_052', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_053', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_054', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_055', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_056', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_057', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_058', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_059', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_060', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_061', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_062', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_063', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_064', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_065', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_066', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_067', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_068', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_069', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_070', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_071', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_072', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_073', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_074', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_075', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_076', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_077', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_078', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_079', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_080', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_081', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_082', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_083', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_084', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_085', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_086', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_087', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_088', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_089', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_090', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_091', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_092', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_093', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_094', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_095', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_096', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_097', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_098', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_099', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_100', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_101', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_102', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_103', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_104', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_105', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_106', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_107', 'Mediana');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_108', 'Grande');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_109', 'Pequeña');
INSERT INTO TIPO_CELDA (nombre_tipo, tamaño_referencial) VALUES ('TipoCelda_110', 'Mediana');

-- 4) TIPO_VEHICULO (110)
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_001', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_002', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_003', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_004', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_005', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_006', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_007', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_008', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_009', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_010', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_011', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_012', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_013', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_014', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_015', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_016', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_017', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_018', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_019', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_020', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_021', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_022', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_023', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_024', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_025', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_026', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_027', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_028', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_029', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_030', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_031', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_032', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_033', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_034', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_035', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_036', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_037', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_038', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_039', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_040', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_041', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_042', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_043', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_044', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_045', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_046', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_047', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_048', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_049', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_050', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_051', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_052', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_053', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_054', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_055', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_056', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_057', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_058', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_059', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_060', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_061', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_062', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_063', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_064', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_065', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_066', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_067', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_068', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_069', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_070', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_071', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_072', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_073', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_074', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_075', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_076', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_077', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_078', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_079', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_080', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_081', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_082', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_083', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_084', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_085', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_086', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_087', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_088', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_089', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_090', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_091', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_092', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_093', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_094', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_095', '250cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_096', '300cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_097', '350cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_098', '400cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_099', '450cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_100', '500cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_101', '550cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_102', '600cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_103', '650cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_104', '700cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_105', '750cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_106', '50cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_107', '100cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_108', '150cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_109', '200cc');
INSERT INTO TIPO_VEHICULO (nombre_tipo, cilindraje) VALUES ('TipoVeh_110', '250cc');

-- 5) tipo_lavado (110)
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_001', 8025.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_002', 8050.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_003', 8075.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_004', 8100.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_005', 8125.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_006', 8150.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_007', 8175.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_008', 8200.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_009', 8225.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_010', 8250.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_011', 8275.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_012', 8300.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_013', 8325.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_014', 8350.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_015', 8375.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_016', 8400.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_017', 8425.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_018', 8450.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_019', 8475.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_020', 8500.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_021', 8525.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_022', 8550.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_023', 8575.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_024', 8600.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_025', 8625.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_026', 8650.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_027', 8675.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_028', 8700.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_029', 8725.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_030', 8750.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_031', 8775.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_032', 8800.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_033', 8825.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_034', 8850.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_035', 8875.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_036', 8900.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_037', 8925.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_038', 8950.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_039', 8975.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_040', 9000.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_041', 9025.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_042', 9050.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_043', 9075.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_044', 9100.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_045', 9125.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_046', 9150.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_047', 9175.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_048', 9200.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_049', 9225.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_050', 9250.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_051', 9275.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_052', 9300.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_053', 9325.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_054', 9350.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_055', 9375.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_056', 9400.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_057', 9425.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_058', 9450.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_059', 9475.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_060', 9500.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_061', 9525.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_062', 9550.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_063', 9575.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_064', 9600.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_065', 9625.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_066', 9650.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_067', 9675.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_068', 9700.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_069', 9725.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_070', 9750.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_071', 9775.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_072', 9800.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_073', 9825.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_074', 9850.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_075', 9875.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_076', 9900.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_077', 9925.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_078', 9950.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_079', 9975.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_080', 10000.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_081', 10025.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_082', 10050.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_083', 10075.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_084', 10100.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_085', 10125.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_086', 10150.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_087', 10175.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_088', 10200.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_089', 10225.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_090', 10250.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_091', 10275.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_092', 10300.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_093', 10325.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_094', 10350.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_095', 10375.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_096', 10400.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_097', 10425.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_098', 10450.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_099', 10475.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_100', 10500.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_101', 10525.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_102', 10550.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_103', 10575.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_104', 10600.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_105', 10625.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_106', 10650.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_107', 10675.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_108', 10700.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_109', 10725.00);
INSERT INTO tipo_lavado (descripcion, precio) VALUES ('Lavado_110', 10750.00);

-- 6) celda_lavado (110)
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'M');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'L');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Ocupada', 'S');
INSERT INTO celda_lavado (estado_celda, tamaño) VALUES ('Libre', 'M');

-- 7) convenio (110)  -- id_sede = 1..110
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_001', 'Condiciones y beneficios #1', 10050.00, 'Mes', '2025-01-01', '2025-12-31', 1);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_002', 'Condiciones y beneficios #2', 10100.00, 'Hora', '2025-01-01', '2025-12-31', 2);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_003', 'Condiciones y beneficios #3', 10150.00, 'Mes', '2025-01-01', '2025-12-31', 3);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_004', 'Condiciones y beneficios #4', 10200.00, 'Hora', '2025-01-01', '2025-12-31', 4);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_005', 'Condiciones y beneficios #5', 10250.00, 'Mes', '2025-01-01', '2025-12-31', 5);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_006', 'Condiciones y beneficios #6', 10300.00, 'Hora', '2025-01-01', '2025-12-31', 6);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_007', 'Condiciones y beneficios #7', 10350.00, 'Mes', '2025-01-01', '2025-12-31', 7);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_008', 'Condiciones y beneficios #8', 10400.00, 'Hora', '2025-01-01', '2025-12-31', 8);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_009', 'Condiciones y beneficios #9', 10450.00, 'Mes', '2025-01-01', '2025-12-31', 9);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_010', 'Condiciones y beneficios #10', 10500.00, 'Hora', '2025-01-01', '2025-12-31', 10);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_011', 'Condiciones y beneficios #11', 10550.00, 'Mes', '2025-01-01', '2025-12-31', 11);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_012', 'Condiciones y beneficios #12', 10600.00, 'Hora', '2025-01-01', '2025-12-31', 12);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_013', 'Condiciones y beneficios #13', 10650.00, 'Mes', '2025-01-01', '2025-12-31', 13);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_014', 'Condiciones y beneficios #14', 10700.00, 'Hora', '2025-01-01', '2025-12-31', 14);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_015', 'Condiciones y beneficios #15', 10750.00, 'Mes', '2025-01-01', '2025-12-31', 15);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_016', 'Condiciones y beneficios #16', 10800.00, 'Hora', '2025-01-01', '2025-12-31', 16);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_017', 'Condiciones y beneficios #17', 10850.00, 'Mes', '2025-01-01', '2025-12-31', 17);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_018', 'Condiciones y beneficios #18', 10900.00, 'Hora', '2025-01-01', '2025-12-31', 18);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_019', 'Condiciones y beneficios #19', 10950.00, 'Mes', '2025-01-01', '2025-12-31', 19);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_020', 'Condiciones y beneficios #20', 11000.00, 'Hora', '2025-01-01', '2025-12-31', 20);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_021', 'Condiciones y beneficios #21', 11050.00, 'Mes', '2025-01-01', '2025-12-31', 21);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_022', 'Condiciones y beneficios #22', 11100.00, 'Hora', '2025-01-01', '2025-12-31', 22);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_023', 'Condiciones y beneficios #23', 11150.00, 'Mes', '2025-01-01', '2025-12-31', 23);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_024', 'Condiciones y beneficios #24', 11200.00, 'Hora', '2025-01-01', '2025-12-31', 24);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_025', 'Condiciones y beneficios #25', 11250.00, 'Mes', '2025-01-01', '2025-12-31', 25);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_026', 'Condiciones y beneficios #26', 11300.00, 'Hora', '2025-01-01', '2025-12-31', 26);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_027', 'Condiciones y beneficios #27', 11350.00, 'Mes', '2025-01-01', '2025-12-31', 27);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_028', 'Condiciones y beneficios #28', 11400.00, 'Hora', '2025-01-01', '2025-12-31', 28);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_029', 'Condiciones y beneficios #29', 11450.00, 'Mes', '2025-01-01', '2025-12-31', 29);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_030', 'Condiciones y beneficios #30', 11500.00, 'Hora', '2025-01-01', '2025-12-31', 30);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_031', 'Condiciones y beneficios #31', 11550.00, 'Mes', '2025-01-01', '2025-12-31', 31);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_032', 'Condiciones y beneficios #32', 11600.00, 'Hora', '2025-01-01', '2025-12-31', 32);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_033', 'Condiciones y beneficios #33', 11650.00, 'Mes', '2025-01-01', '2025-12-31', 33);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_034', 'Condiciones y beneficios #34', 11700.00, 'Hora', '2025-01-01', '2025-12-31', 34);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_035', 'Condiciones y beneficios #35', 11750.00, 'Mes', '2025-01-01', '2025-12-31', 35);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_036', 'Condiciones y beneficios #36', 11800.00, 'Hora', '2025-01-01', '2025-12-31', 36);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_037', 'Condiciones y beneficios #37', 11850.00, 'Mes', '2025-01-01', '2025-12-31', 37);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_038', 'Condiciones y beneficios #38', 11900.00, 'Hora', '2025-01-01', '2025-12-31', 38);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_039', 'Condiciones y beneficios #39', 11950.00, 'Mes', '2025-01-01', '2025-12-31', 39);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_040', 'Condiciones y beneficios #40', 12000.00, 'Hora', '2025-01-01', '2025-12-31', 40);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_041', 'Condiciones y beneficios #41', 12050.00, 'Mes', '2025-01-01', '2025-12-31', 41);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_042', 'Condiciones y beneficios #42', 12100.00, 'Hora', '2025-01-01', '2025-12-31', 42);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_043', 'Condiciones y beneficios #43', 12150.00, 'Mes', '2025-01-01', '2025-12-31', 43);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_044', 'Condiciones y beneficios #44', 12200.00, 'Hora', '2025-01-01', '2025-12-31', 44);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_045', 'Condiciones y beneficios #45', 12250.00, 'Mes', '2025-01-01', '2025-12-31', 45);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_046', 'Condiciones y beneficios #46', 12300.00, 'Hora', '2025-01-01', '2025-12-31', 46);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_047', 'Condiciones y beneficios #47', 12350.00, 'Mes', '2025-01-01', '2025-12-31', 47);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_048', 'Condiciones y beneficios #48', 12400.00, 'Hora', '2025-01-01', '2025-12-31', 48);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_049', 'Condiciones y beneficios #49', 12450.00, 'Mes', '2025-01-01', '2025-12-31', 49);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_050', 'Condiciones y beneficios #50', 12500.00, 'Hora', '2025-01-01', '2025-12-31', 50);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_051', 'Condiciones y beneficios #51', 12550.00, 'Mes', '2025-01-01', '2025-12-31', 51);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_052', 'Condiciones y beneficios #52', 12600.00, 'Hora', '2025-01-01', '2025-12-31', 52);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_053', 'Condiciones y beneficios #53', 12650.00, 'Mes', '2025-01-01', '2025-12-31', 53);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_054', 'Condiciones y beneficios #54', 12700.00, 'Hora', '2025-01-01', '2025-12-31', 54);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_055', 'Condiciones y beneficios #55', 12750.00, 'Mes', '2025-01-01', '2025-12-31', 55);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_056', 'Condiciones y beneficios #56', 12800.00, 'Hora', '2025-01-01', '2025-12-31', 56);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_057', 'Condiciones y beneficios #57', 12850.00, 'Mes', '2025-01-01', '2025-12-31', 57);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_058', 'Condiciones y beneficios #58', 12900.00, 'Hora', '2025-01-01', '2025-12-31', 58);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_059', 'Condiciones y beneficios #59', 12950.00, 'Mes', '2025-01-01', '2025-12-31', 59);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_060', 'Condiciones y beneficios #60', 13000.00, 'Hora', '2025-01-01', '2025-12-31', 60);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_061', 'Condiciones y beneficios #61', 13050.00, 'Mes', '2025-01-01', '2025-12-31', 61);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_062', 'Condiciones y beneficios #62', 13100.00, 'Hora', '2025-01-01', '2025-12-31', 62);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_063', 'Condiciones y beneficios #63', 13150.00, 'Mes', '2025-01-01', '2025-12-31', 63);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_064', 'Condiciones y beneficios #64', 13200.00, 'Hora', '2025-01-01', '2025-12-31', 64);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_065', 'Condiciones y beneficios #65', 13250.00, 'Mes', '2025-01-01', '2025-12-31', 65);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_066', 'Condiciones y beneficios #66', 13300.00, 'Hora', '2025-01-01', '2025-12-31', 66);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_067', 'Condiciones y beneficios #67', 13350.00, 'Mes', '2025-01-01', '2025-12-31', 67);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_068', 'Condiciones y beneficios #68', 13400.00, 'Hora', '2025-01-01', '2025-12-31', 68);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_069', 'Condiciones y beneficios #69', 13450.00, 'Mes', '2025-01-01', '2025-12-31', 69);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_070', 'Condiciones y beneficios #70', 13500.00, 'Hora', '2025-01-01', '2025-12-31', 70);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_071', 'Condiciones y beneficios #71', 13550.00, 'Mes', '2025-01-01', '2025-12-31', 71);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_072', 'Condiciones y beneficios #72', 13600.00, 'Hora', '2025-01-01', '2025-12-31', 72);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_073', 'Condiciones y beneficios #73', 13650.00, 'Mes', '2025-01-01', '2025-12-31', 73);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_074', 'Condiciones y beneficios #74', 13700.00, 'Hora', '2025-01-01', '2025-12-31', 74);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_075', 'Condiciones y beneficios #75', 13750.00, 'Mes', '2025-01-01', '2025-12-31', 75);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_076', 'Condiciones y beneficios #76', 13800.00, 'Hora', '2025-01-01', '2025-12-31', 76);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_077', 'Condiciones y beneficios #77', 13850.00, 'Mes', '2025-01-01', '2025-12-31', 77);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_078', 'Condiciones y beneficios #78', 13900.00, 'Hora', '2025-01-01', '2025-12-31', 78);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_079', 'Condiciones y beneficios #79', 13950.00, 'Mes', '2025-01-01', '2025-12-31', 79);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_080', 'Condiciones y beneficios #80', 14000.00, 'Hora', '2025-01-01', '2025-12-31', 80);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_081', 'Condiciones y beneficios #81', 14050.00, 'Mes', '2025-01-01', '2025-12-31', 81);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_082', 'Condiciones y beneficios #82', 14100.00, 'Hora', '2025-01-01', '2025-12-31', 82);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_083', 'Condiciones y beneficios #83', 14150.00, 'Mes', '2025-01-01', '2025-12-31', 83);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_084', 'Condiciones y beneficios #84', 14200.00, 'Hora', '2025-01-01', '2025-12-31', 84);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_085', 'Condiciones y beneficios #85', 14250.00, 'Mes', '2025-01-01', '2025-12-31', 85);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_086', 'Condiciones y beneficios #86', 14300.00, 'Hora', '2025-01-01', '2025-12-31', 86);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_087', 'Condiciones y beneficios #87', 14350.00, 'Mes', '2025-01-01', '2025-12-31', 87);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_088', 'Condiciones y beneficios #88', 14400.00, 'Hora', '2025-01-01', '2025-12-31', 88);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_089', 'Condiciones y beneficios #89', 14450.00, 'Mes', '2025-01-01', '2025-12-31', 89);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_090', 'Condiciones y beneficios #90', 14500.00, 'Hora', '2025-01-01', '2025-12-31', 90);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_091', 'Condiciones y beneficios #91', 14550.00, 'Mes', '2025-01-01', '2025-12-31', 91);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_092', 'Condiciones y beneficios #92', 14600.00, 'Hora', '2025-01-01', '2025-12-31', 92);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_093', 'Condiciones y beneficios #93', 14650.00, 'Mes', '2025-01-01', '2025-12-31', 93);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_094', 'Condiciones y beneficios #94', 14700.00, 'Hora', '2025-01-01', '2025-12-31', 94);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_095', 'Condiciones y beneficios #95', 14750.00, 'Mes', '2025-01-01', '2025-12-31', 95);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_096', 'Condiciones y beneficios #96', 14800.00, 'Hora', '2025-01-01', '2025-12-31', 96);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_097', 'Condiciones y beneficios #97', 14850.00, 'Mes', '2025-01-01', '2025-12-31', 97);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_098', 'Condiciones y beneficios #98', 14900.00, 'Hora', '2025-01-01', '2025-12-31', 98);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_099', 'Condiciones y beneficios #99', 14950.00, 'Mes', '2025-01-01', '2025-12-31', 99);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_100', 'Condiciones y beneficios #100', 15000.00, 'Hora', '2025-01-01', '2025-12-31', 100);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_101', 'Condiciones y beneficios #101', 15050.00, 'Mes', '2025-01-01', '2025-12-31', 101);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_102', 'Condiciones y beneficios #102', 15100.00, 'Hora', '2025-01-01', '2025-12-31', 102);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_103', 'Condiciones y beneficios #103', 15150.00, 'Mes', '2025-01-01', '2025-12-31', 103);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_104', 'Condiciones y beneficios #104', 15200.00, 'Hora', '2025-01-01', '2025-12-31', 104);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_105', 'Condiciones y beneficios #105', 15250.00, 'Mes', '2025-01-01', '2025-12-31', 105);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_106', 'Condiciones y beneficios #106', 15300.00, 'Hora', '2025-01-01', '2025-12-31', 106);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_107', 'Condiciones y beneficios #107', 15350.00, 'Mes', '2025-01-01', '2025-12-31', 107);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_108', 'Condiciones y beneficios #108', 15400.00, 'Hora', '2025-01-01', '2025-12-31', 108);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_109', 'Condiciones y beneficios #109', 15450.00, 'Mes', '2025-01-01', '2025-12-31', 109);
INSERT INTO convenio (nombre_convenio, descripcion, precio_base, unidad_tarifaria, vigencia_inicio, vigencia_fin, id_sede) VALUES ('Convenio_110', 'Condiciones y beneficios #110', 15500.00, 'Hora', '2025-01-01', '2025-12-31', 110);
USE SIS_PARQUEADERO;
GO

-- 1) CLIENTE (110)
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C001', 'Cliente 001', '3000000001', 'cliente001@mail.com', 'Direccion 001', 1);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C002', 'Cliente 002', '3000000002', 'cliente002@mail.com', 'Direccion 002', 2);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C003', 'Cliente 003', '3000000003', 'cliente003@mail.com', 'Direccion 003', 3);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C004', 'Cliente 004', '3000000004', 'cliente004@mail.com', 'Direccion 004', 4);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C005', 'Cliente 005', '3000000005', 'cliente005@mail.com', 'Direccion 005', 5);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C006', 'Cliente 006', '3000000006', 'cliente006@mail.com', 'Direccion 006', 6);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C007', 'Cliente 007', '3000000007', 'cliente007@mail.com', 'Direccion 007', 7);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C008', 'Cliente 008', '3000000008', 'cliente008@mail.com', 'Direccion 008', 8);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C009', 'Cliente 009', '3000000009', 'cliente009@mail.com', 'Direccion 009', 9);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C010', 'Cliente 010', '3000000010', 'cliente010@mail.com', 'Direccion 010', 10);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C011', 'Cliente 011', '3000000011', 'cliente011@mail.com', 'Direccion 011', 11);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C012', 'Cliente 012', '3000000012', 'cliente012@mail.com', 'Direccion 012', 12);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C013', 'Cliente 013', '3000000013', 'cliente013@mail.com', 'Direccion 013', 13);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C014', 'Cliente 014', '3000000014', 'cliente014@mail.com', 'Direccion 014', 14);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C015', 'Cliente 015', '3000000015', 'cliente015@mail.com', 'Direccion 015', 15);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C016', 'Cliente 016', '3000000016', 'cliente016@mail.com', 'Direccion 016', 16);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C017', 'Cliente 017', '3000000017', 'cliente017@mail.com', 'Direccion 017', 17);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C018', 'Cliente 018', '3000000018', 'cliente018@mail.com', 'Direccion 018', 18);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C019', 'Cliente 019', '3000000019', 'cliente019@mail.com', 'Direccion 019', 19);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C020', 'Cliente 020', '3000000020', 'cliente020@mail.com', 'Direccion 020', 20);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C021', 'Cliente 021', '3000000021', 'cliente021@mail.com', 'Direccion 021', 21);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C022', 'Cliente 022', '3000000022', 'cliente022@mail.com', 'Direccion 022', 22);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C023', 'Cliente 023', '3000000023', 'cliente023@mail.com', 'Direccion 023', 23);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C024', 'Cliente 024', '3000000024', 'cliente024@mail.com', 'Direccion 024', 24);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C025', 'Cliente 025', '3000000025', 'cliente025@mail.com', 'Direccion 025', 25);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C026', 'Cliente 026', '3000000026', 'cliente026@mail.com', 'Direccion 026', 26);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C027', 'Cliente 027', '3000000027', 'cliente027@mail.com', 'Direccion 027', 27);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C028', 'Cliente 028', '3000000028', 'cliente028@mail.com', 'Direccion 028', 28);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C029', 'Cliente 029', '3000000029', 'cliente029@mail.com', 'Direccion 029', 29);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C030', 'Cliente 030', '3000000030', 'cliente030@mail.com', 'Direccion 030', 30);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C031', 'Cliente 031', '3000000031', 'cliente031@mail.com', 'Direccion 031', 31);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C032', 'Cliente 032', '3000000032', 'cliente032@mail.com', 'Direccion 032', 32);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C033', 'Cliente 033', '3000000033', 'cliente033@mail.com', 'Direccion 033', 33);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C034', 'Cliente 034', '3000000034', 'cliente034@mail.com', 'Direccion 034', 34);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C035', 'Cliente 035', '3000000035', 'cliente035@mail.com', 'Direccion 035', 35);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C036', 'Cliente 036', '3000000036', 'cliente036@mail.com', 'Direccion 036', 36);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C037', 'Cliente 037', '3000000037', 'cliente037@mail.com', 'Direccion 037', 37);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C038', 'Cliente 038', '3000000038', 'cliente038@mail.com', 'Direccion 038', 38);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C039', 'Cliente 039', '3000000039', 'cliente039@mail.com', 'Direccion 039', 39);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C040', 'Cliente 040', '3000000040', 'cliente040@mail.com', 'Direccion 040', 40);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C041', 'Cliente 041', '3000000041', 'cliente041@mail.com', 'Direccion 041', 41);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C042', 'Cliente 042', '3000000042', 'cliente042@mail.com', 'Direccion 042', 42);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C043', 'Cliente 043', '3000000043', 'cliente043@mail.com', 'Direccion 043', 43);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C044', 'Cliente 044', '3000000044', 'cliente044@mail.com', 'Direccion 044', 44);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C045', 'Cliente 045', '3000000045', 'cliente045@mail.com', 'Direccion 045', 45);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C046', 'Cliente 046', '3000000046', 'cliente046@mail.com', 'Direccion 046', 46);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C047', 'Cliente 047', '3000000047', 'cliente047@mail.com', 'Direccion 047', 47);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C048', 'Cliente 048', '3000000048', 'cliente048@mail.com', 'Direccion 048', 48);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C049', 'Cliente 049', '3000000049', 'cliente049@mail.com', 'Direccion 049', 49);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C050', 'Cliente 050', '3000000050', 'cliente050@mail.com', 'Direccion 050', 50);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C051', 'Cliente 051', '3000000051', 'cliente051@mail.com', 'Direccion 051', 51);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C052', 'Cliente 052', '3000000052', 'cliente052@mail.com', 'Direccion 052', 52);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C053', 'Cliente 053', '3000000053', 'cliente053@mail.com', 'Direccion 053', 53);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C054', 'Cliente 054', '3000000054', 'cliente054@mail.com', 'Direccion 054', 54);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C055', 'Cliente 055', '3000000055', 'cliente055@mail.com', 'Direccion 055', 55);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C056', 'Cliente 056', '3000000056', 'cliente056@mail.com', 'Direccion 056', 56);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C057', 'Cliente 057', '3000000057', 'cliente057@mail.com', 'Direccion 057', 57);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C058', 'Cliente 058', '3000000058', 'cliente058@mail.com', 'Direccion 058', 58);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C059', 'Cliente 059', '3000000059', 'cliente059@mail.com', 'Direccion 059', 59);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C060', 'Cliente 060', '3000000060', 'cliente060@mail.com', 'Direccion 060', 60);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C061', 'Cliente 061', '3000000061', 'cliente061@mail.com', 'Direccion 061', 61);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C062', 'Cliente 062', '3000000062', 'cliente062@mail.com', 'Direccion 062', 62);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C063', 'Cliente 063', '3000000063', 'cliente063@mail.com', 'Direccion 063', 63);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C064', 'Cliente 064', '3000000064', 'cliente064@mail.com', 'Direccion 064', 64);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C065', 'Cliente 065', '3000000065', 'cliente065@mail.com', 'Direccion 065', 65);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C066', 'Cliente 066', '3000000066', 'cliente066@mail.com', 'Direccion 066', 66);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C067', 'Cliente 067', '3000000067', 'cliente067@mail.com', 'Direccion 067', 67);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C068', 'Cliente 068', '3000000068', 'cliente068@mail.com', 'Direccion 068', 68);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C069', 'Cliente 069', '3000000069', 'cliente069@mail.com', 'Direccion 069', 69);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C070', 'Cliente 070', '3000000070', 'cliente070@mail.com', 'Direccion 070', 70);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C071', 'Cliente 071', '3000000071', 'cliente071@mail.com', 'Direccion 071', 71);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C072', 'Cliente 072', '3000000072', 'cliente072@mail.com', 'Direccion 072', 72);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C073', 'Cliente 073', '3000000073', 'cliente073@mail.com', 'Direccion 073', 73);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C074', 'Cliente 074', '3000000074', 'cliente074@mail.com', 'Direccion 074', 74);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C075', 'Cliente 075', '3000000075', 'cliente075@mail.com', 'Direccion 075', 75);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C076', 'Cliente 076', '3000000076', 'cliente076@mail.com', 'Direccion 076', 76);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C077', 'Cliente 077', '3000000077', 'cliente077@mail.com', 'Direccion 077', 77);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C078', 'Cliente 078', '3000000078', 'cliente078@mail.com', 'Direccion 078', 78);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C079', 'Cliente 079', '3000000079', 'cliente079@mail.com', 'Direccion 079', 79);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C080', 'Cliente 080', '3000000080', 'cliente080@mail.com', 'Direccion 080', 80);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C081', 'Cliente 081', '3000000081', 'cliente081@mail.com', 'Direccion 081', 81);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C082', 'Cliente 082', '3000000082', 'cliente082@mail.com', 'Direccion 082', 82);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C083', 'Cliente 083', '3000000083', 'cliente083@mail.com', 'Direccion 083', 83);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C084', 'Cliente 084', '3000000084', 'cliente084@mail.com', 'Direccion 084', 84);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C085', 'Cliente 085', '3000000085', 'cliente085@mail.com', 'Direccion 085', 85);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C086', 'Cliente 086', '3000000086', 'cliente086@mail.com', 'Direccion 086', 86);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C087', 'Cliente 087', '3000000087', 'cliente087@mail.com', 'Direccion 087', 87);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C088', 'Cliente 088', '3000000088', 'cliente088@mail.com', 'Direccion 088', 88);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C089', 'Cliente 089', '3000000089', 'cliente089@mail.com', 'Direccion 089', 89);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C090', 'Cliente 090', '3000000090', 'cliente090@mail.com', 'Direccion 090', 90);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C091', 'Cliente 091', '3000000091', 'cliente091@mail.com', 'Direccion 091', 91);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C092', 'Cliente 092', '3000000092', 'cliente092@mail.com', 'Direccion 092', 92);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C093', 'Cliente 093', '3000000093', 'cliente093@mail.com', 'Direccion 093', 93);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C094', 'Cliente 094', '3000000094', 'cliente094@mail.com', 'Direccion 094', 94);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C095', 'Cliente 095', '3000000095', 'cliente095@mail.com', 'Direccion 095', 95);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C096', 'Cliente 096', '3000000096', 'cliente096@mail.com', 'Direccion 096', 96);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C097', 'Cliente 097', '3000000097', 'cliente097@mail.com', 'Direccion 097', 97);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C098', 'Cliente 098', '3000000098', 'cliente098@mail.com', 'Direccion 098', 98);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C099', 'Cliente 099', '3000000099', 'cliente099@mail.com', 'Direccion 099', 99);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C100', 'Cliente 100', '3000000100', 'cliente100@mail.com', 'Direccion 100', 100);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C101', 'Cliente 101', '3000000101', 'cliente101@mail.com', 'Direccion 101', 101);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C102', 'Cliente 102', '3000000102', 'cliente102@mail.com', 'Direccion 102', 102);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C103', 'Cliente 103', '3000000103', 'cliente103@mail.com', 'Direccion 103', 103);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C104', 'Cliente 104', '3000000104', 'cliente104@mail.com', 'Direccion 104', 104);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C105', 'Cliente 105', '3000000105', 'cliente105@mail.com', 'Direccion 105', 105);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C106', 'Cliente 106', '3000000106', 'cliente106@mail.com', 'Direccion 106', 106);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C107', 'Cliente 107', '3000000107', 'cliente107@mail.com', 'Direccion 107', 107);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C108', 'Cliente 108', '3000000108', 'cliente108@mail.com', 'Direccion 108', 108);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C109', 'Cliente 109', '3000000109', 'cliente109@mail.com', 'Direccion 109', 109);
INSERT INTO cliente (documento, nombre, telefono, correo, direccion, id_convenio) VALUES ('C110', 'Cliente 110', '3000000110', 'cliente110@mail.com', 'Direccion 110', 110);

-- 2) VEHICULO (110)
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC001', 'Chevrolet', '2010', 'Rojo', 1, 'C001');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC002', 'Mazda', '2011', 'Negro', 2, 'C002');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC003', 'Kia', '2012', 'Gris', 3, 'C003');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC004', 'Toyota', '2013', 'Azul', 4, 'C004');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC005', 'Nissan', '2014', 'Blanco', 5, 'C005');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC006', 'Renault', '2015', 'Verde', 6, 'C006');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC007', 'Hyundai', '2016', 'Amarillo', 7, 'C007');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC008', 'Suzuki', '2017', 'Plateado', 8, 'C008');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC009', 'Ford', '2018', 'Marron', 9, 'C009');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC010', 'Peugeot', '2019', 'Naranja', 10, 'C010');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC011', 'Honda', '2020', 'Rojo', 11, 'C011');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC012', 'BMW', '2021', 'Negro', 12, 'C012');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC013', 'Audi', '2022', 'Gris', 13, 'C013');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC014', 'Volkswagen', '2023', 'Azul', 14, 'C014');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC015', 'Subaru', '2024', 'Blanco', 15, 'C015');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC016', 'Chevrolet', '2010', 'Verde', 16, 'C016');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC017', 'Mazda', '2011', 'Amarillo', 17, 'C017');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC018', 'Kia', '2012', 'Plateado', 18, 'C018');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC019', 'Toyota', '2013', 'Marron', 19, 'C019');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC020', 'Nissan', '2014', 'Naranja', 20, 'C020');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC021', 'Renault', '2015', 'Rojo', 21, 'C021');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC022', 'Hyundai', '2016', 'Negro', 22, 'C022');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC023', 'Suzuki', '2017', 'Gris', 23, 'C023');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC024', 'Ford', '2018', 'Azul', 24, 'C024');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC025', 'Peugeot', '2019', 'Blanco', 25, 'C025');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC026', 'Honda', '2020', 'Verde', 26, 'C026');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC027', 'BMW', '2021', 'Amarillo', 27, 'C027');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC028', 'Audi', '2022', 'Plateado', 28, 'C028');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC029', 'Volkswagen', '2023', 'Marron', 29, 'C029');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC030', 'Subaru', '2024', 'Naranja', 30, 'C030');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC031', 'Chevrolet', '2010', 'Rojo', 31, 'C031');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC032', 'Mazda', '2011', 'Negro', 32, 'C032');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC033', 'Kia', '2012', 'Gris', 33, 'C033');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC034', 'Toyota', '2013', 'Azul', 34, 'C034');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC035', 'Nissan', '2014', 'Blanco', 35, 'C035');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC036', 'Renault', '2015', 'Verde', 36, 'C036');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC037', 'Hyundai', '2016', 'Amarillo', 37, 'C037');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC038', 'Suzuki', '2017', 'Plateado', 38, 'C038');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC039', 'Ford', '2018', 'Marron', 39, 'C039');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC040', 'Peugeot', '2019', 'Naranja', 40, 'C040');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC041', 'Honda', '2020', 'Rojo', 41, 'C041');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC042', 'BMW', '2021', 'Negro', 42, 'C042');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC043', 'Audi', '2022', 'Gris', 43, 'C043');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC044', 'Volkswagen', '2023', 'Azul', 44, 'C044');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC045', 'Subaru', '2024', 'Blanco', 45, 'C045');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC046', 'Chevrolet', '2010', 'Verde', 46, 'C046');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC047', 'Mazda', '2011', 'Amarillo', 47, 'C047');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC048', 'Kia', '2012', 'Plateado', 48, 'C048');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC049', 'Toyota', '2013', 'Marron', 49, 'C049');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC050', 'Nissan', '2014', 'Naranja', 50, 'C050');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC051', 'Renault', '2015', 'Rojo', 51, 'C051');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC052', 'Hyundai', '2016', 'Negro', 52, 'C052');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC053', 'Suzuki', '2017', 'Gris', 53, 'C053');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC054', 'Ford', '2018', 'Azul', 54, 'C054');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC055', 'Peugeot', '2019', 'Blanco', 55, 'C055');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC056', 'Honda', '2020', 'Verde', 56, 'C056');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC057', 'BMW', '2021', 'Amarillo', 57, 'C057');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC058', 'Audi', '2022', 'Plateado', 58, 'C058');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC059', 'Volkswagen', '2023', 'Marron', 59, 'C059');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC060', 'Subaru', '2024', 'Naranja', 60, 'C060');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC061', 'Chevrolet', '2010', 'Rojo', 61, 'C061');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC062', 'Mazda', '2011', 'Negro', 62, 'C062');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC063', 'Kia', '2012', 'Gris', 63, 'C063');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC064', 'Toyota', '2013', 'Azul', 64, 'C064');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC065', 'Nissan', '2014', 'Blanco', 65, 'C065');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC066', 'Renault', '2015', 'Verde', 66, 'C066');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC067', 'Hyundai', '2016', 'Amarillo', 67, 'C067');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC068', 'Suzuki', '2017', 'Plateado', 68, 'C068');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC069', 'Ford', '2018', 'Marron', 69, 'C069');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC070', 'Peugeot', '2019', 'Naranja', 70, 'C070');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC071', 'Honda', '2020', 'Rojo', 71, 'C071');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC072', 'BMW', '2021', 'Negro', 72, 'C072');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC073', 'Audi', '2022', 'Gris', 73, 'C073');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC074', 'Volkswagen', '2023', 'Azul', 74, 'C074');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC075', 'Subaru', '2024', 'Blanco', 75, 'C075');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC076', 'Chevrolet', '2010', 'Verde', 76, 'C076');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC077', 'Mazda', '2011', 'Amarillo', 77, 'C077');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC078', 'Kia', '2012', 'Plateado', 78, 'C078');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC079', 'Toyota', '2013', 'Marron', 79, 'C079');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC080', 'Nissan', '2014', 'Naranja', 80, 'C080');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC081', 'Renault', '2015', 'Rojo', 81, 'C081');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC082', 'Hyundai', '2016', 'Negro', 82, 'C082');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC083', 'Suzuki', '2017', 'Gris', 83, 'C083');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC084', 'Ford', '2018', 'Azul', 84, 'C084');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC085', 'Peugeot', '2019', 'Blanco', 85, 'C085');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC086', 'Honda', '2020', 'Verde', 86, 'C086');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC087', 'BMW', '2021', 'Amarillo', 87, 'C087');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC088', 'Audi', '2022', 'Plateado', 88, 'C088');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC089', 'Volkswagen', '2023', 'Marron', 89, 'C089');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC090', 'Subaru', '2024', 'Naranja', 90, 'C090');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC091', 'Chevrolet', '2010', 'Rojo', 91, 'C091');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC092', 'Mazda', '2011', 'Negro', 92, 'C092');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC093', 'Kia', '2012', 'Gris', 93, 'C093');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC094', 'Toyota', '2013', 'Azul', 94, 'C094');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC095', 'Nissan', '2014', 'Blanco', 95, 'C095');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC096', 'Renault', '2015', 'Verde', 96, 'C096');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC097', 'Hyundai', '2016', 'Amarillo', 97, 'C097');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC098', 'Suzuki', '2017', 'Plateado', 98, 'C098');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC099', 'Ford', '2018', 'Marron', 99, 'C099');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC100', 'Peugeot', '2019', 'Naranja', 100, 'C100');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC101', 'Honda', '2020', 'Rojo', 101, 'C101');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC102', 'BMW', '2021', 'Negro', 102, 'C102');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC103', 'Audi', '2022', 'Gris', 103, 'C103');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC104', 'Volkswagen', '2023', 'Azul', 104, 'C104');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC105', 'Subaru', '2024', 'Blanco', 105, 'C105');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC106', 'Chevrolet', '2010', 'Verde', 106, 'C106');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC107', 'Mazda', '2011', 'Amarillo', 107, 'C107');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC108', 'Kia', '2012', 'Plateado', 108, 'C108');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC109', 'Toyota', '2013', 'Marron', 109, 'C109');
INSERT INTO vehiculo (placa, marca, modelo, color, id_tipo_vehiculo, documento_cliente) VALUES ('ABC110', 'Nissan', '2014', 'Naranja', 110, 'C110');

-- 3) PERSONAL (110)
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P001', 'Luis', 'Gomez', '3100000001', 'luis.gomez001@mail.com', 1, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P002', 'Marta', 'Lopez', '3100000002', 'marta.lopez002@mail.com', 2, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P003', 'Jorge', 'Arias', '3100000003', 'jorge.arias003@mail.com', 3, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P004', 'Paula', 'Ramirez', '3100000004', 'paula.ramirez004@mail.com', 4, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P005', 'David', 'Martinez', '3100000005', 'david.martinez005@mail.com', 5, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P006', 'Ana', 'Cano', '3100000006', 'ana.cano006@mail.com', 6, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P007', 'Diego', 'Zuluaga', '3100000007', 'diego.zuluaga007@mail.com', 7, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P008', 'Isabel', 'Hernandez', '3100000008', 'isabel.hernandez008@mail.com', 8, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P009', 'Felipe', 'Restrepo', '3100000009', 'felipe.restrepo009@mail.com', 9, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P010', 'Tatiana', 'Perez', '3100000010', 'tatiana.perez010@mail.com', 10, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P011', 'Camilo', 'Salazar', '3100000011', 'camilo.salazar011@mail.com', 11, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P012', 'Laura', 'Rojas', '3100000012', 'laura.rojas012@mail.com', 12, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P013', 'Santiago', 'Zapata', '3100000013', 'santiago.zapata013@mail.com', 13, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P014', 'Valentina', 'Cortes', '3100000014', 'valentina.cortes014@mail.com', 14, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P015', 'Andres', 'Velez', '3100000015', 'andres.velez015@mail.com', 15, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P016', 'Carolina', 'Mejia', '3100000016', 'carolina.mejia016@mail.com', 16, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P017', 'Juan', 'Quintero', '3100000017', 'juan.quintero017@mail.com', 17, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P018', 'Maria', 'Arango', '3100000018', 'maria.arango018@mail.com', 18, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P019', 'Esteban', 'Montoya', '3100000019', 'esteban.montoya019@mail.com', 19, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P020', 'Sofia', 'Bermudez', '3100000020', 'sofia.bermudez020@mail.com', 20, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P021', 'Pedro', 'Gomez', '3100000021', 'pedro.gomez021@mail.com', 21, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P022', 'Daniela', 'Lopez', '3100000022', 'daniela.lopez022@mail.com', 22, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P023', 'Carlos', 'Arias', '3100000023', 'carlos.arias023@mail.com', 23, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P024', 'Luisa', 'Ramirez', '3100000024', 'luisa.ramirez024@mail.com', 24, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P025', 'Miguel', 'Martinez', '3100000025', 'miguel.martinez025@mail.com', 25, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P026', 'Juliana', 'Cano', '3100000026', 'juliana.cano026@mail.com', 26, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P027', 'Ricardo', 'Zuluaga', '3100000027', 'ricardo.zuluaga027@mail.com', 27, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P028', 'Natalia', 'Hernandez', '3100000028', 'natalia.hernandez028@mail.com', 28, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P029', 'Sebastian', 'Restrepo', '3100000029', 'sebastian.restrepo029@mail.com', 29, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P030', 'Adriana', 'Perez', '3100000030', 'adriana.perez030@mail.com', 30, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P031', 'Hector', 'Salazar', '3100000031', 'hector.salazar031@mail.com', 31, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P032', 'Camila', 'Rojas', '3100000032', 'camila.rojas032@mail.com', 32, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P033', 'Mauricio', 'Zapata', '3100000033', 'mauricio.zapata033@mail.com', 33, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P034', 'Diana', 'Cortes', '3100000034', 'diana.cortes034@mail.com', 34, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P035', 'Fabian', 'Velez', '3100000035', 'fabian.velez035@mail.com', 35, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P036', 'Gloria', 'Mejia', '3100000036', 'gloria.mejia036@mail.com', 36, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P037', 'Oscar', 'Quintero', '3100000037', 'oscar.quintero037@mail.com', 37, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P038', 'Patricia', 'Arango', '3100000038', 'patricia.arango038@mail.com', 38, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P039', 'Hernan', 'Montoya', '3100000039', 'hernan.montoya039@mail.com', 39, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P040', 'Liliana', 'Bermudez', '3100000040', 'liliana.bermudez040@mail.com', 40, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P041', 'Ivan', 'Gomez', '3100000041', 'ivan.gomez041@mail.com', 41, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P042', 'Lina', 'Lopez', '3100000042', 'lina.lopez042@mail.com', 42, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P043', 'Fernando', 'Arias', '3100000043', 'fernando.arias043@mail.com', 43, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P044', 'Gina', 'Ramirez', '3100000044', 'gina.ramirez044@mail.com', 44, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P045', 'Victor', 'Martinez', '3100000045', 'victor.martinez045@mail.com', 45, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P046', 'Claudia', 'Cano', '3100000046', 'claudia.cano046@mail.com', 46, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P047', 'Rafael', 'Zuluaga', '3100000047', 'rafael.zuluaga047@mail.com', 47, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P048', 'Monica', 'Hernandez', '3100000048', 'monica.hernandez048@mail.com', 48, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P049', 'Gustavo', 'Restrepo', '3100000049', 'gustavo.restrepo049@mail.com', 49, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P050', 'Pilar', 'Perez', '3100000050', 'pilar.perez050@mail.com', 50, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P051', 'Luis', 'Salazar', '3100000051', 'luis.salazar051@mail.com', 51, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P052', 'Marta', 'Rojas', '3100000052', 'marta.rojas052@mail.com', 52, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P053', 'Jorge', 'Zapata', '3100000053', 'jorge.zapata053@mail.com', 53, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P054', 'Paula', 'Cortes', '3100000054', 'paula.cortes054@mail.com', 54, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P055', 'David', 'Velez', '3100000055', 'david.velez055@mail.com', 55, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P056', 'Ana', 'Mejia', '3100000056', 'ana.mejia056@mail.com', 56, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P057', 'Diego', 'Quintero', '3100000057', 'diego.quintero057@mail.com', 57, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P058', 'Isabel', 'Arango', '3100000058', 'isabel.arango058@mail.com', 58, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P059', 'Felipe', 'Montoya', '3100000059', 'felipe.montoya059@mail.com', 59, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P060', 'Tatiana', 'Bermudez', '3100000060', 'tatiana.bermudez060@mail.com', 60, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P061', 'Camilo', 'Gomez', '3100000061', 'camilo.gomez061@mail.com', 61, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P062', 'Laura', 'Lopez', '3100000062', 'laura.lopez062@mail.com', 62, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P063', 'Santiago', 'Arias', '3100000063', 'santiago.arias063@mail.com', 63, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P064', 'Valentina', 'Ramirez', '3100000064', 'valentina.ramirez064@mail.com', 64, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P065', 'Andres', 'Martinez', '3100000065', 'andres.martinez065@mail.com', 65, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P066', 'Carolina', 'Cano', '3100000066', 'carolina.cano066@mail.com', 66, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P067', 'Juan', 'Zuluaga', '3100000067', 'juan.zuluaga067@mail.com', 67, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P068', 'Maria', 'Hernandez', '3100000068', 'maria.hernandez068@mail.com', 68, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P069', 'Esteban', 'Restrepo', '3100000069', 'esteban.restrepo069@mail.com', 69, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P070', 'Sofia', 'Perez', '3100000070', 'sofia.perez070@mail.com', 70, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P071', 'Pedro', 'Salazar', '3100000071', 'pedro.salazar071@mail.com', 71, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P072', 'Daniela', 'Rojas', '3100000072', 'daniela.rojas072@mail.com', 72, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P073', 'Carlos', 'Zapata', '3100000073', 'carlos.zapata073@mail.com', 73, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P074', 'Luisa', 'Cortes', '3100000074', 'luisa.cortes074@mail.com', 74, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P075', 'Miguel', 'Velez', '3100000075', 'miguel.velez075@mail.com', 75, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P076', 'Juliana', 'Mejia', '3100000076', 'juliana.mejia076@mail.com', 76, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P077', 'Ricardo', 'Quintero', '3100000077', 'ricardo.quintero077@mail.com', 77, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P078', 'Natalia', 'Arango', '3100000078', 'natalia.arango078@mail.com', 78, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P079', 'Sebastian', 'Montoya', '3100000079', 'sebastian.montoya079@mail.com', 79, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P080', 'Adriana', 'Bermudez', '3100000080', 'adriana.bermudez080@mail.com', 80, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P081', 'Hector', 'Gomez', '3100000081', 'hector.gomez081@mail.com', 81, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P082', 'Camila', 'Lopez', '3100000082', 'camila.lopez082@mail.com', 82, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P083', 'Mauricio', 'Arias', '3100000083', 'mauricio.arias083@mail.com', 83, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P084', 'Diana', 'Ramirez', '3100000084', 'diana.ramirez084@mail.com', 84, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P085', 'Fabian', 'Martinez', '3100000085', 'fabian.martinez085@mail.com', 85, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P086', 'Gloria', 'Cano', '3100000086', 'gloria.cano086@mail.com', 86, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P087', 'Oscar', 'Zuluaga', '3100000087', 'oscar.zuluaga087@mail.com', 87, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P088', 'Patricia', 'Hernandez', '3100000088', 'patricia.hernandez088@mail.com', 88, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P089', 'Hernan', 'Restrepo', '3100000089', 'hernan.restrepo089@mail.com', 89, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P090', 'Liliana', 'Perez', '3100000090', 'liliana.perez090@mail.com', 90, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P091', 'Ivan', 'Salazar', '3100000091', 'ivan.salazar091@mail.com', 91, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P092', 'Lina', 'Rojas', '3100000092', 'lina.rojas092@mail.com', 92, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P093', 'Fernando', 'Zapata', '3100000093', 'fernando.zapata093@mail.com', 93, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P094', 'Gina', 'Cortes', '3100000094', 'gina.cortes094@mail.com', 94, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P095', 'Victor', 'Velez', '3100000095', 'victor.velez095@mail.com', 95, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P096', 'Claudia', 'Mejia', '3100000096', 'claudia.mejia096@mail.com', 96, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P097', 'Rafael', 'Quintero', '3100000097', 'rafael.quintero097@mail.com', 97, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P098', 'Monica', 'Arango', '3100000098', 'monica.arango098@mail.com', 98, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P099', 'Gustavo', 'Montoya', '3100000099', 'gustavo.montoya099@mail.com', 99, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P100', 'Pilar', 'Bermudez', '3100000100', 'pilar.bermudez100@mail.com', 100, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P101', 'Luis', 'Gomez', '3100000101', 'luis.gomez101@mail.com', 101, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P102', 'Marta', 'Lopez', '3100000102', 'marta.lopez102@mail.com', 102, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P103', 'Jorge', 'Arias', '3100000103', 'jorge.arias103@mail.com', 103, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P104', 'Paula', 'Ramirez', '3100000104', 'paula.ramirez104@mail.com', 104, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P105', 'David', 'Martinez', '3100000105', 'david.martinez105@mail.com', 105, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P106', 'Ana', 'Cano', '3100000106', 'ana.cano106@mail.com', 106, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P107', 'Diego', 'Zuluaga', '3100000107', 'diego.zuluaga107@mail.com', 107, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P108', 'Isabel', 'Hernandez', '3100000108', 'isabel.hernandez108@mail.com', 108, 2);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P109', 'Felipe', 'Restrepo', '3100000109', 'felipe.restrepo109@mail.com', 109, 1);
INSERT INTO personal (documento, nombre, apellido, telefono, correo, id_rol, id_sede) VALUES ('P110', 'Tatiana', 'Perez', '3100000110', 'tatiana.perez110@mail.com', 110, 2);

-- 4) USUARIO (110)
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user001', 'P@ss001', 'Usuario 001', 'user001@parqueadero.com', 1, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user002', 'P@ss002', 'Usuario 002', 'user002@parqueadero.com', 2, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user003', 'P@ss003', 'Usuario 003', 'user003@parqueadero.com', 3, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user004', 'P@ss004', 'Usuario 004', 'user004@parqueadero.com', 4, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user005', 'P@ss005', 'Usuario 005', 'user005@parqueadero.com', 5, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user006', 'P@ss006', 'Usuario 006', 'user006@parqueadero.com', 6, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user007', 'P@ss007', 'Usuario 007', 'user007@parqueadero.com', 7, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user008', 'P@ss008', 'Usuario 008', 'user008@parqueadero.com', 8, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user009', 'P@ss009', 'Usuario 009', 'user009@parqueadero.com', 9, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user010', 'P@ss010', 'Usuario 010', 'user010@parqueadero.com', 10, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user011', 'P@ss011', 'Usuario 011', 'user011@parqueadero.com', 11, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user012', 'P@ss012', 'Usuario 012', 'user012@parqueadero.com', 12, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user013', 'P@ss013', 'Usuario 013', 'user013@parqueadero.com', 13, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user014', 'P@ss014', 'Usuario 014', 'user014@parqueadero.com', 14, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user015', 'P@ss015', 'Usuario 015', 'user015@parqueadero.com', 15, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user016', 'P@ss016', 'Usuario 016', 'user016@parqueadero.com', 16, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user017', 'P@ss017', 'Usuario 017', 'user017@parqueadero.com', 17, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user018', 'P@ss018', 'Usuario 018', 'user018@parqueadero.com', 18, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user019', 'P@ss019', 'Usuario 019', 'user019@parqueadero.com', 19, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user020', 'P@ss020', 'Usuario 020', 'user020@parqueadero.com', 20, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user021', 'P@ss021', 'Usuario 021', 'user021@parqueadero.com', 21, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user022', 'P@ss022', 'Usuario 022', 'user022@parqueadero.com', 22, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user023', 'P@ss023', 'Usuario 023', 'user023@parqueadero.com', 23, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user024', 'P@ss024', 'Usuario 024', 'user024@parqueadero.com', 24, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user025', 'P@ss025', 'Usuario 025', 'user025@parqueadero.com', 25, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user026', 'P@ss026', 'Usuario 026', 'user026@parqueadero.com', 26, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user027', 'P@ss027', 'Usuario 027', 'user027@parqueadero.com', 27, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user028', 'P@ss028', 'Usuario 028', 'user028@parqueadero.com', 28, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user029', 'P@ss029', 'Usuario 029', 'user029@parqueadero.com', 29, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user030', 'P@ss030', 'Usuario 030', 'user030@parqueadero.com', 30, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user031', 'P@ss031', 'Usuario 031', 'user031@parqueadero.com', 31, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user032', 'P@ss032', 'Usuario 032', 'user032@parqueadero.com', 32, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user033', 'P@ss033', 'Usuario 033', 'user033@parqueadero.com', 33, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user034', 'P@ss034', 'Usuario 034', 'user034@parqueadero.com', 34, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user035', 'P@ss035', 'Usuario 035', 'user035@parqueadero.com', 35, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user036', 'P@ss036', 'Usuario 036', 'user036@parqueadero.com', 36, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user037', 'P@ss037', 'Usuario 037', 'user037@parqueadero.com', 37, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user038', 'P@ss038', 'Usuario 038', 'user038@parqueadero.com', 38, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user039', 'P@ss039', 'Usuario 039', 'user039@parqueadero.com', 39, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user040', 'P@ss040', 'Usuario 040', 'user040@parqueadero.com', 40, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user041', 'P@ss041', 'Usuario 041', 'user041@parqueadero.com', 41, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user042', 'P@ss042', 'Usuario 042', 'user042@parqueadero.com', 42, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user043', 'P@ss043', 'Usuario 043', 'user043@parqueadero.com', 43, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user044', 'P@ss044', 'Usuario 044', 'user044@parqueadero.com', 44, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user045', 'P@ss045', 'Usuario 045', 'user045@parqueadero.com', 45, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user046', 'P@ss046', 'Usuario 046', 'user046@parqueadero.com', 46, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user047', 'P@ss047', 'Usuario 047', 'user047@parqueadero.com', 47, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user048', 'P@ss048', 'Usuario 048', 'user048@parqueadero.com', 48, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user049', 'P@ss049', 'Usuario 049', 'user049@parqueadero.com', 49, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user050', 'P@ss050', 'Usuario 050', 'user050@parqueadero.com', 50, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user051', 'P@ss051', 'Usuario 051', 'user051@parqueadero.com', 51, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user052', 'P@ss052', 'Usuario 052', 'user052@parqueadero.com', 52, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user053', 'P@ss053', 'Usuario 053', 'user053@parqueadero.com', 53, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user054', 'P@ss054', 'Usuario 054', 'user054@parqueadero.com', 54, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user055', 'P@ss055', 'Usuario 055', 'user055@parqueadero.com', 55, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user056', 'P@ss056', 'Usuario 056', 'user056@parqueadero.com', 56, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user057', 'P@ss057', 'Usuario 057', 'user057@parqueadero.com', 57, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user058', 'P@ss058', 'Usuario 058', 'user058@parqueadero.com', 58, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user059', 'P@ss059', 'Usuario 059', 'user059@parqueadero.com', 59, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user060', 'P@ss060', 'Usuario 060', 'user060@parqueadero.com', 60, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user061', 'P@ss061', 'Usuario 061', 'user061@parqueadero.com', 61, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user062', 'P@ss062', 'Usuario 062', 'user062@parqueadero.com', 62, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user063', 'P@ss063', 'Usuario 063', 'user063@parqueadero.com', 63, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user064', 'P@ss064', 'Usuario 064', 'user064@parqueadero.com', 64, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user065', 'P@ss065', 'Usuario 065', 'user065@parqueadero.com', 65, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user066', 'P@ss066', 'Usuario 066', 'user066@parqueadero.com', 66, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user067', 'P@ss067', 'Usuario 067', 'user067@parqueadero.com', 67, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user068', 'P@ss068', 'Usuario 068', 'user068@parqueadero.com', 68, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user069', 'P@ss069', 'Usuario 069', 'user069@parqueadero.com', 69, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user070', 'P@ss070', 'Usuario 070', 'user070@parqueadero.com', 70, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user071', 'P@ss071', 'Usuario 071', 'user071@parqueadero.com', 71, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user072', 'P@ss072', 'Usuario 072', 'user072@parqueadero.com', 72, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user073', 'P@ss073', 'Usuario 073', 'user073@parqueadero.com', 73, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user074', 'P@ss074', 'Usuario 074', 'user074@parqueadero.com', 74, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user075', 'P@ss075', 'Usuario 075', 'user075@parqueadero.com', 75, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user076', 'P@ss076', 'Usuario 076', 'user076@parqueadero.com', 76, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user077', 'P@ss077', 'Usuario 077', 'user077@parqueadero.com', 77, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user078', 'P@ss078', 'Usuario 078', 'user078@parqueadero.com', 78, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user079', 'P@ss079', 'Usuario 079', 'user079@parqueadero.com', 79, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user080', 'P@ss080', 'Usuario 080', 'user080@parqueadero.com', 80, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user081', 'P@ss081', 'Usuario 081', 'user081@parqueadero.com', 81, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user082', 'P@ss082', 'Usuario 082', 'user082@parqueadero.com', 82, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user083', 'P@ss083', 'Usuario 083', 'user083@parqueadero.com', 83, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user084', 'P@ss084', 'Usuario 084', 'user084@parqueadero.com', 84, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user085', 'P@ss085', 'Usuario 085', 'user085@parqueadero.com', 85, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user086', 'P@ss086', 'Usuario 086', 'user086@parqueadero.com', 86, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user087', 'P@ss087', 'Usuario 087', 'user087@parqueadero.com', 87, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user088', 'P@ss088', 'Usuario 088', 'user088@parqueadero.com', 88, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user089', 'P@ss089', 'Usuario 089', 'user089@parqueadero.com', 89, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user090', 'P@ss090', 'Usuario 090', 'user090@parqueadero.com', 90, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user091', 'P@ss091', 'Usuario 091', 'user091@parqueadero.com', 91, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user092', 'P@ss092', 'Usuario 092', 'user092@parqueadero.com', 92, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user093', 'P@ss093', 'Usuario 093', 'user093@parqueadero.com', 93, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user094', 'P@ss094', 'Usuario 094', 'user094@parqueadero.com', 94, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user095', 'P@ss095', 'Usuario 095', 'user095@parqueadero.com', 95, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user096', 'P@ss096', 'Usuario 096', 'user096@parqueadero.com', 96, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user097', 'P@ss097', 'Usuario 097', 'user097@parqueadero.com', 97, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user098', 'P@ss098', 'Usuario 098', 'user098@parqueadero.com', 98, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user099', 'P@ss099', 'Usuario 099', 'user099@parqueadero.com', 99, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user100', 'P@ss100', 'Usuario 100', 'user100@parqueadero.com', 100, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user101', 'P@ss101', 'Usuario 101', 'user101@parqueadero.com', 101, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user102', 'P@ss102', 'Usuario 102', 'user102@parqueadero.com', 102, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user103', 'P@ss103', 'Usuario 103', 'user103@parqueadero.com', 103, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user104', 'P@ss104', 'Usuario 104', 'user104@parqueadero.com', 104, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user105', 'P@ss105', 'Usuario 105', 'user105@parqueadero.com', 105, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user106', 'P@ss106', 'Usuario 106', 'user106@parqueadero.com', 106, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user107', 'P@ss107', 'Usuario 107', 'user107@parqueadero.com', 107, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user108', 'P@ss108', 'Usuario 108', 'user108@parqueadero.com', 108, 1, 2);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user109', 'P@ss109', 'Usuario 109', 'user109@parqueadero.com', 109, 0, 1);
INSERT INTO usuario (nombre_usuario, contraseña, nombre_completo, correo, id_rol, estado_parqueo, id_sede) VALUES ('user110', 'P@ss110', 'Usuario 110', 'user110@parqueadero.com', 110, 1, 2);

-- 5) Tarjeta (110)
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-01 08:00:00', 1);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-02 08:00:00', 2);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-03 08:00:00', 3);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-04 08:00:00', 4);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-05 08:00:00', 5);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-06 08:00:00', 6);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-07 08:00:00', 7);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-08 08:00:00', 8);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-09 08:00:00', 9);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-10 08:00:00', 10);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-11 08:00:00', 11);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-12 08:00:00', 12);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-13 08:00:00', 13);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-14 08:00:00', 14);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-15 08:00:00', 15);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-16 08:00:00', 16);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-17 08:00:00', 17);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-18 08:00:00', 18);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-19 08:00:00', 19);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-20 08:00:00', 20);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-21 08:00:00', 21);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-22 08:00:00', 22);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-23 08:00:00', 23);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-24 08:00:00', 24);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-25 08:00:00', 25);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-26 08:00:00', 26);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-27 08:00:00', 27);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-28 08:00:00', 28);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-01-29 08:00:00', 29);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-01-30 08:00:00', 30);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-01-31 08:00:00', 31);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-01 08:00:00', 32);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-02 08:00:00', 33);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-03 08:00:00', 34);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-04 08:00:00', 35);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-05 08:00:00', 36);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-06 08:00:00', 37);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-07 08:00:00', 38);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-08 08:00:00', 39);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-09 08:00:00', 40);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-10 08:00:00', 41);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-11 08:00:00', 42);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-12 08:00:00', 43);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-13 08:00:00', 44);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-14 08:00:00', 45);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-15 08:00:00', 46);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-16 08:00:00', 47);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-17 08:00:00', 48);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-18 08:00:00', 49);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-19 08:00:00', 50);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-20 08:00:00', 51);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-21 08:00:00', 52);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-22 08:00:00', 53);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-23 08:00:00', 54);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-24 08:00:00', 55);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-25 08:00:00', 56);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-02-26 08:00:00', 57);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-02-27 08:00:00', 58);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-02-28 08:00:00', 59);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-01 08:00:00', 60);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-02 08:00:00', 61);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-03 08:00:00', 62);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-04 08:00:00', 63);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-05 08:00:00', 64);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-06 08:00:00', 65);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-07 08:00:00', 66);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-08 08:00:00', 67);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-09 08:00:00', 68);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-10 08:00:00', 69);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-11 08:00:00', 70);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-12 08:00:00', 71);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-13 08:00:00', 72);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-14 08:00:00', 73);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-15 08:00:00', 74);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-16 08:00:00', 75);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-17 08:00:00', 76);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-18 08:00:00', 77);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-19 08:00:00', 78);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-20 08:00:00', 79);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-21 08:00:00', 80);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-22 08:00:00', 81);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-23 08:00:00', 82);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-24 08:00:00', 83);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-25 08:00:00', 84);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-26 08:00:00', 85);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-27 08:00:00', 86);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-28 08:00:00', 87);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-03-29 08:00:00', 88);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-03-30 08:00:00', 89);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-03-31 08:00:00', 90);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-01 08:00:00', 91);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-02 08:00:00', 92);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-03 08:00:00', 93);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-04 08:00:00', 94);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-05 08:00:00', 95);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-06 08:00:00', 96);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-07 08:00:00', 97);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-08 08:00:00', 98);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-09 08:00:00', 99);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-10 08:00:00', 100);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-11 08:00:00', 101);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-12 08:00:00', 102);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-13 08:00:00', 103);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-14 08:00:00', 104);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-15 08:00:00', 105);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-16 08:00:00', 106);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-17 08:00:00', 107);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Bloqueada', '2025-04-18 08:00:00', 108);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Activa', '2025-04-19 08:00:00', 109);
INSERT INTO Tarjeta (estado_tarjeta, fecha_hora_emision, id_personal) VALUES ('Suspendida', '2025-04-20 08:00:00', 110);
USE SIS_PARQUEADERO;
GO

-- 1) CELDA (110)
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 1, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 2, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 3, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 4, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 5, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 6, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 7, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 8, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 9, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 10, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 11, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 12, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 13, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 14, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 15, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 16, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 17, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 18, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 19, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 20, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 21, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 22, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 23, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 24, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 25, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 26, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 27, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 28, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 29, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 30, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 31, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 32, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 33, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 34, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 35, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 36, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 37, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 38, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 39, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 40, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 41, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 42, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 43, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 44, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 45, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 46, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 47, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 48, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 49, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 50, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 51, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 52, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 53, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 54, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 55, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 56, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 57, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 58, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 59, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 60, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 61, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 62, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 63, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 64, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 65, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 66, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 67, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 68, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 69, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 70, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 71, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 72, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 73, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 74, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 75, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 76, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 77, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 78, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 79, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 80, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 81, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 82, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 83, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 84, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 85, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 86, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 87, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 88, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 89, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 90, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 91, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 92, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 93, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 94, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 95, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 96, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 97, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 98, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 99, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 100, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 101, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 102, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 103, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 104, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 105, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 106, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 107, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 108, 'Libre');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (1, 109, 'Ocupada');
INSERT INTO CELDA (id_sede, id_tipo_celda, estado_celda) VALUES (2, 110, 'Libre');

-- 2) LAVADO (110)
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9020.00, 'ABC001', '2025-01-01 08:00:00', '2025-01-01 09:00:00', 'EnProceso', 1, 1);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9040.00, 'ABC002', '2025-01-02 08:00:00', '2025-01-02 09:00:00', 'Finalizado', 2, 2);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9060.00, 'ABC003', '2025-01-03 08:00:00', '2025-01-03 09:00:00', 'EnProceso', 3, 3);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9080.00, 'ABC004', '2025-01-04 08:00:00', '2025-01-04 09:00:00', 'Finalizado', 4, 4);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9100.00, 'ABC005', '2025-01-05 08:00:00', '2025-01-05 09:00:00', 'EnProceso', 5, 5);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9120.00, 'ABC006', '2025-01-06 08:00:00', '2025-01-06 09:00:00', 'Finalizado', 6, 6);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9140.00, 'ABC007', '2025-01-07 08:00:00', '2025-01-07 09:00:00', 'EnProceso', 7, 7);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9160.00, 'ABC008', '2025-01-08 08:00:00', '2025-01-08 09:00:00', 'Finalizado', 8, 8);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9180.00, 'ABC009', '2025-01-09 08:00:00', '2025-01-09 09:00:00', 'EnProceso', 9, 9);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9200.00, 'ABC010', '2025-01-10 08:00:00', '2025-01-10 09:00:00', 'Finalizado', 10, 10);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9220.00, 'ABC011', '2025-01-11 08:00:00', '2025-01-11 09:00:00', 'EnProceso', 11, 11);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9240.00, 'ABC012', '2025-01-12 08:00:00', '2025-01-12 09:00:00', 'Finalizado', 12, 12);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9260.00, 'ABC013', '2025-01-13 08:00:00', '2025-01-13 09:00:00', 'EnProceso', 13, 13);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9280.00, 'ABC014', '2025-01-14 08:00:00', '2025-01-14 09:00:00', 'Finalizado', 14, 14);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9300.00, 'ABC015', '2025-01-15 08:00:00', '2025-01-15 09:00:00', 'EnProceso', 15, 15);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9320.00, 'ABC016', '2025-01-16 08:00:00', '2025-01-16 09:00:00', 'Finalizado', 16, 16);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9340.00, 'ABC017', '2025-01-17 08:00:00', '2025-01-17 09:00:00', 'EnProceso', 17, 17);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9360.00, 'ABC018', '2025-01-18 08:00:00', '2025-01-18 09:00:00', 'Finalizado', 18, 18);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9380.00, 'ABC019', '2025-01-19 08:00:00', '2025-01-19 09:00:00', 'EnProceso', 19, 19);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9400.00, 'ABC020', '2025-01-20 08:00:00', '2025-01-20 09:00:00', 'Finalizado', 20, 20);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9420.00, 'ABC021', '2025-01-21 08:00:00', '2025-01-21 09:00:00', 'EnProceso', 21, 21);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9440.00, 'ABC022', '2025-01-22 08:00:00', '2025-01-22 09:00:00', 'Finalizado', 22, 22);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9460.00, 'ABC023', '2025-01-23 08:00:00', '2025-01-23 09:00:00', 'EnProceso', 23, 23);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9480.00, 'ABC024', '2025-01-24 08:00:00', '2025-01-24 09:00:00', 'Finalizado', 24, 24);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9500.00, 'ABC025', '2025-01-25 08:00:00', '2025-01-25 09:00:00', 'EnProceso', 25, 25);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9520.00, 'ABC026', '2025-01-26 08:00:00', '2025-01-26 09:00:00', 'Finalizado', 26, 26);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9540.00, 'ABC027', '2025-01-27 08:00:00', '2025-01-27 09:00:00', 'EnProceso', 27, 27);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9560.00, 'ABC028', '2025-01-28 08:00:00', '2025-01-28 09:00:00', 'Finalizado', 28, 28);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9580.00, 'ABC029', '2025-01-29 08:00:00', '2025-01-29 09:00:00', 'EnProceso', 29, 29);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9600.00, 'ABC030', '2025-01-30 08:00:00', '2025-01-30 09:00:00', 'Finalizado', 30, 30);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9620.00, 'ABC031', '2025-01-31 08:00:00', '2025-01-31 09:00:00', 'EnProceso', 31, 31);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9640.00, 'ABC032', '2025-02-01 08:00:00', '2025-02-01 09:00:00', 'Finalizado', 32, 32);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9660.00, 'ABC033', '2025-02-02 08:00:00', '2025-02-02 09:00:00', 'EnProceso', 33, 33);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9680.00, 'ABC034', '2025-02-03 08:00:00', '2025-02-03 09:00:00', 'Finalizado', 34, 34);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9700.00, 'ABC035', '2025-02-04 08:00:00', '2025-02-04 09:00:00', 'EnProceso', 35, 35);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9720.00, 'ABC036', '2025-02-05 08:00:00', '2025-02-05 09:00:00', 'Finalizado', 36, 36);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9740.00, 'ABC037', '2025-02-06 08:00:00', '2025-02-06 09:00:00', 'EnProceso', 37, 37);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9760.00, 'ABC038', '2025-02-07 08:00:00', '2025-02-07 09:00:00', 'Finalizado', 38, 38);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9780.00, 'ABC039', '2025-02-08 08:00:00', '2025-02-08 09:00:00', 'EnProceso', 39, 39);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9800.00, 'ABC040', '2025-02-09 08:00:00', '2025-02-09 09:00:00', 'Finalizado', 40, 40);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9820.00, 'ABC041', '2025-02-10 08:00:00', '2025-02-10 09:00:00', 'EnProceso', 41, 41);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9840.00, 'ABC042', '2025-02-11 08:00:00', '2025-02-11 09:00:00', 'Finalizado', 42, 42);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9860.00, 'ABC043', '2025-02-12 08:00:00', '2025-02-12 09:00:00', 'EnProceso', 43, 43);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9880.00, 'ABC044', '2025-02-13 08:00:00', '2025-02-13 09:00:00', 'Finalizado', 44, 44);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9900.00, 'ABC045', '2025-02-14 08:00:00', '2025-02-14 09:00:00', 'EnProceso', 45, 45);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9920.00, 'ABC046', '2025-02-15 08:00:00', '2025-02-15 09:00:00', 'Finalizado', 46, 46);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9940.00, 'ABC047', '2025-02-16 08:00:00', '2025-02-16 09:00:00', 'EnProceso', 47, 47);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 9960.00, 'ABC048', '2025-02-17 08:00:00', '2025-02-17 09:00:00', 'Finalizado', 48, 48);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9980.00, 'ABC049', '2025-02-18 08:00:00', '2025-02-18 09:00:00', 'EnProceso', 49, 49);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10000.00, 'ABC050', '2025-02-19 08:00:00', '2025-02-19 09:00:00', 'Finalizado', 50, 50);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10020.00, 'ABC051', '2025-02-20 08:00:00', '2025-02-20 09:00:00', 'EnProceso', 51, 51);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10040.00, 'ABC052', '2025-02-21 08:00:00', '2025-02-21 09:00:00', 'Finalizado', 52, 52);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10060.00, 'ABC053', '2025-02-22 08:00:00', '2025-02-22 09:00:00', 'EnProceso', 53, 53);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10080.00, 'ABC054', '2025-02-23 08:00:00', '2025-02-23 09:00:00', 'Finalizado', 54, 54);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10100.00, 'ABC055', '2025-02-24 08:00:00', '2025-02-24 09:00:00', 'EnProceso', 55, 55);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10120.00, 'ABC056', '2025-02-25 08:00:00', '2025-02-25 09:00:00', 'Finalizado', 56, 56);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10140.00, 'ABC057', '2025-02-26 08:00:00', '2025-02-26 09:00:00', 'EnProceso', 57, 57);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10160.00, 'ABC058', '2025-02-27 08:00:00', '2025-02-27 09:00:00', 'Finalizado', 58, 58);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10180.00, 'ABC059', '2025-02-28 08:00:00', '2025-02-28 09:00:00', 'EnProceso', 59, 59);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10200.00, 'ABC060', '2025-03-01 08:00:00', '2025-03-01 09:00:00', 'Finalizado', 60, 60);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10220.00, 'ABC061', '2025-03-02 08:00:00', '2025-03-02 09:00:00', 'EnProceso', 61, 61);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10240.00, 'ABC062', '2025-03-03 08:00:00', '2025-03-03 09:00:00', 'Finalizado', 62, 62);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10260.00, 'ABC063', '2025-03-04 08:00:00', '2025-03-04 09:00:00', 'EnProceso', 63, 63);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10280.00, 'ABC064', '2025-03-05 08:00:00', '2025-03-05 09:00:00', 'Finalizado', 64, 64);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10300.00, 'ABC065', '2025-03-06 08:00:00', '2025-03-06 09:00:00', 'EnProceso', 65, 65);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10320.00, 'ABC066', '2025-03-07 08:00:00', '2025-03-07 09:00:00', 'Finalizado', 66, 66);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10340.00, 'ABC067', '2025-03-08 08:00:00', '2025-03-08 09:00:00', 'EnProceso', 67, 67);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10360.00, 'ABC068', '2025-03-09 08:00:00', '2025-03-09 09:00:00', 'Finalizado', 68, 68);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10380.00, 'ABC069', '2025-03-10 08:00:00', '2025-03-10 09:00:00', 'EnProceso', 69, 69);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10400.00, 'ABC070', '2025-03-11 08:00:00', '2025-03-11 09:00:00', 'Finalizado', 70, 70);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10420.00, 'ABC071', '2025-03-12 08:00:00', '2025-03-12 09:00:00', 'EnProceso', 71, 71);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10440.00, 'ABC072', '2025-03-13 08:00:00', '2025-03-13 09:00:00', 'Finalizado', 72, 72);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10460.00, 'ABC073', '2025-03-14 08:00:00', '2025-03-14 09:00:00', 'EnProceso', 73, 73);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10480.00, 'ABC074', '2025-03-15 08:00:00', '2025-03-15 09:00:00', 'Finalizado', 74, 74);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10500.00, 'ABC075', '2025-03-16 08:00:00', '2025-03-16 09:00:00', 'EnProceso', 75, 75);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10520.00, 'ABC076', '2025-03-17 08:00:00', '2025-03-17 09:00:00', 'Finalizado', 76, 76);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10540.00, 'ABC077', '2025-03-18 08:00:00', '2025-03-18 09:00:00', 'EnProceso', 77, 77);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10560.00, 'ABC078', '2025-03-19 08:00:00', '2025-03-19 09:00:00', 'Finalizado', 78, 78);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10580.00, 'ABC079', '2025-03-20 08:00:00', '2025-03-20 09:00:00', 'EnProceso', 79, 79);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10600.00, 'ABC080', '2025-03-21 08:00:00', '2025-03-21 09:00:00', 'Finalizado', 80, 80);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10620.00, 'ABC081', '2025-03-22 08:00:00', '2025-03-22 09:00:00', 'EnProceso', 81, 81);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10640.00, 'ABC082', '2025-03-23 08:00:00', '2025-03-23 09:00:00', 'Finalizado', 82, 82);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10660.00, 'ABC083', '2025-03-24 08:00:00', '2025-03-24 09:00:00', 'EnProceso', 83, 83);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10680.00, 'ABC084', '2025-03-25 08:00:00', '2025-03-25 09:00:00', 'Finalizado', 84, 84);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10700.00, 'ABC085', '2025-03-26 08:00:00', '2025-03-26 09:00:00', 'EnProceso', 85, 85);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10720.00, 'ABC086', '2025-03-27 08:00:00', '2025-03-27 09:00:00', 'Finalizado', 86, 86);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10740.00, 'ABC087', '2025-03-28 08:00:00', '2025-03-28 09:00:00', 'EnProceso', 87, 87);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10760.00, 'ABC088', '2025-03-29 08:00:00', '2025-03-29 09:00:00', 'Finalizado', 88, 88);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10780.00, 'ABC089', '2025-03-30 08:00:00', '2025-03-30 09:00:00', 'EnProceso', 89, 89);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10800.00, 'ABC090', '2025-03-31 08:00:00', '2025-03-31 09:00:00', 'Finalizado', 90, 90);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10820.00, 'ABC091', '2025-04-01 08:00:00', '2025-04-01 09:00:00', 'EnProceso', 91, 91);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10840.00, 'ABC092', '2025-04-02 08:00:00', '2025-04-02 09:00:00', 'Finalizado', 92, 92);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10860.00, 'ABC093', '2025-04-03 08:00:00', '2025-04-03 09:00:00', 'EnProceso', 93, 93);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10880.00, 'ABC094', '2025-04-04 08:00:00', '2025-04-04 09:00:00', 'Finalizado', 94, 94);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10900.00, 'ABC095', '2025-04-05 08:00:00', '2025-04-05 09:00:00', 'EnProceso', 95, 95);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10920.00, 'ABC096', '2025-04-06 08:00:00', '2025-04-06 09:00:00', 'Finalizado', 96, 96);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10940.00, 'ABC097', '2025-04-07 08:00:00', '2025-04-07 09:00:00', 'EnProceso', 97, 97);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 10960.00, 'ABC098', '2025-04-08 08:00:00', '2025-04-08 09:00:00', 'Finalizado', 98, 98);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 10980.00, 'ABC099', '2025-04-09 08:00:00', '2025-04-09 09:00:00', 'EnProceso', 99, 99);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11000.00, 'ABC100', '2025-04-10 08:00:00', '2025-04-10 09:00:00', 'Finalizado', 100, 100);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 11020.00, 'ABC101', '2025-04-11 08:00:00', '2025-04-11 09:00:00', 'EnProceso', 101, 101);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11040.00, 'ABC102', '2025-04-12 08:00:00', '2025-04-12 09:00:00', 'Finalizado', 102, 102);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 11060.00, 'ABC103', '2025-04-13 08:00:00', '2025-04-13 09:00:00', 'EnProceso', 103, 103);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11080.00, 'ABC104', '2025-04-14 08:00:00', '2025-04-14 09:00:00', 'Finalizado', 104, 104);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 11100.00, 'ABC105', '2025-04-15 08:00:00', '2025-04-15 09:00:00', 'EnProceso', 105, 105);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11120.00, 'ABC106', '2025-04-16 08:00:00', '2025-04-16 09:00:00', 'Finalizado', 106, 106);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 11140.00, 'ABC107', '2025-04-17 08:00:00', '2025-04-17 09:00:00', 'EnProceso', 107, 107);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11160.00, 'ABC108', '2025-04-18 08:00:00', '2025-04-18 09:00:00', 'Finalizado', 108, 108);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 11180.00, 'ABC109', '2025-04-19 08:00:00', '2025-04-19 09:00:00', 'EnProceso', 109, 109);
INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (2, 11200.00, 'ABC110', '2025-04-20 08:00:00', '2025-04-20 09:00:00', 'Finalizado', 110, 110);

-- 3) PARQUEO (110)
-- 3) PARQUEO (110)
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (1, '2025-01-01 16:00:00', '2025-01-01 18:00:00', 1, 'ABC001', 'Abierto', 1);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (2, '2025-01-02 16:00:00', '2025-01-02 18:00:00', 2, 'ABC002', 'Cerrado', 2);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (3, '2025-01-03 16:00:00', '2025-01-03 18:00:00', 1, 'ABC003', 'Abierto', 3);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (4, '2025-01-04 16:00:00', '2025-01-04 18:00:00', 2, 'ABC004', 'Cerrado', 4);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (5, '2025-01-05 16:00:00', '2025-01-05 18:00:00', 1, 'ABC005', 'Abierto', 5);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (6, '2025-01-06 16:00:00', '2025-01-06 18:00:00', 2, 'ABC006', 'Cerrado', 6);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (7, '2025-01-07 16:00:00', '2025-01-07 18:00:00', 1, 'ABC007', 'Abierto', 7);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (8, '2025-01-08 16:00:00', '2025-01-08 18:00:00', 2, 'ABC008', 'Cerrado', 8);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (9, '2025-01-09 16:00:00', '2025-01-09 18:00:00', 1, 'ABC009', 'Abierto', 9);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (10, '2025-01-10 16:00:00', '2025-01-10 18:00:00', 2, 'ABC010', 'Cerrado', 10);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (11, '2025-01-11 16:00:00', '2025-01-11 18:00:00', 1, 'ABC011', 'Abierto', 11);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (12, '2025-01-12 16:00:00', '2025-01-12 18:00:00', 2, 'ABC012', 'Cerrado', 12);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (13, '2025-01-13 16:00:00', '2025-01-13 18:00:00', 1, 'ABC013', 'Abierto', 13);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (14, '2025-01-14 16:00:00', '2025-01-14 18:00:00', 2, 'ABC014', 'Cerrado', 14);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (15, '2025-01-15 16:00:00', '2025-01-15 18:00:00', 1, 'ABC015', 'Abierto', 15);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (16, '2025-01-16 16:00:00', '2025-01-16 18:00:00', 2, 'ABC016', 'Cerrado', 16);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (17, '2025-01-17 16:00:00', '2025-01-17 18:00:00', 1, 'ABC017', 'Abierto', 17);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (18, '2025-01-18 16:00:00', '2025-01-18 18:00:00', 2, 'ABC018', 'Cerrado', 18);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (19, '2025-01-19 16:00:00', '2025-01-19 18:00:00', 1, 'ABC019', 'Abierto', 19);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (20, '2025-01-20 16:00:00', '2025-01-20 18:00:00', 2, 'ABC020', 'Cerrado', 20);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (21, '2025-01-21 16:00:00', '2025-01-21 18:00:00', 1, 'ABC021', 'Abierto', 21);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (22, '2025-01-22 16:00:00', '2025-01-22 18:00:00', 2, 'ABC022', 'Cerrado', 22);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (23, '2025-01-23 16:00:00', '2025-01-23 18:00:00', 1, 'ABC023', 'Abierto', 23);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (24, '2025-01-24 16:00:00', '2025-01-24 18:00:00', 2, 'ABC024', 'Cerrado', 24);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (25, '2025-01-25 16:00:00', '2025-01-25 18:00:00', 1, 'ABC025', 'Abierto', 25);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (26, '2025-01-26 16:00:00', '2025-01-26 18:00:00', 2, 'ABC026', 'Cerrado', 26);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (27, '2025-01-27 16:00:00', '2025-01-27 18:00:00', 1, 'ABC027', 'Abierto', 27);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (28, '2025-01-28 16:00:00', '2025-01-28 18:00:00', 2, 'ABC028', 'Cerrado', 28);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (29, '2025-01-29 16:00:00', '2025-01-29 18:00:00', 1, 'ABC029', 'Abierto', 29);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (30, '2025-01-30 16:00:00', '2025-01-30 18:00:00', 2, 'ABC030', 'Cerrado', 30);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (31, '2025-01-31 16:00:00', '2025-01-31 18:00:00', 1, 'ABC031', 'Abierto', 31);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (32, '2025-02-01 16:00:00', '2025-02-01 18:00:00', 2, 'ABC032', 'Cerrado', 32);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (33, '2025-02-02 16:00:00', '2025-02-02 18:00:00', 1, 'ABC033', 'Abierto', 33);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (34, '2025-02-03 16:00:00', '2025-02-03 18:00:00', 2, 'ABC034', 'Cerrado', 34);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (35, '2025-02-04 16:00:00', '2025-02-04 18:00:00', 1, 'ABC035', 'Abierto', 35);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (36, '2025-02-05 16:00:00', '2025-02-05 18:00:00', 2, 'ABC036', 'Cerrado', 36);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (37, '2025-02-06 16:00:00', '2025-02-06 18:00:00', 1, 'ABC037', 'Abierto', 37);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (38, '2025-02-07 16:00:00', '2025-02-07 18:00:00', 2, 'ABC038', 'Cerrado', 38);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (39, '2025-02-08 16:00:00', '2025-02-08 18:00:00', 1, 'ABC039', 'Abierto', 39);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (40, '2025-02-09 16:00:00', '2025-02-09 18:00:00', 2, 'ABC040', 'Cerrado', 40);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (41, '2025-02-10 16:00:00', '2025-02-10 18:00:00', 1, 'ABC041', 'Abierto', 41);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (42, '2025-02-11 16:00:00', '2025-02-11 18:00:00', 2, 'ABC042', 'Cerrado', 42);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (43, '2025-02-12 16:00:00', '2025-02-12 18:00:00', 1, 'ABC043', 'Abierto', 43);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (44, '2025-02-13 16:00:00', '2025-02-13 18:00:00', 2, 'ABC044', 'Cerrado', 44);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (45, '2025-02-14 16:00:00', '2025-02-14 18:00:00', 1, 'ABC045', 'Abierto', 45);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (46, '2025-02-15 16:00:00', '2025-02-15 18:00:00', 2, 'ABC046', 'Cerrado', 46);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (47, '2025-02-16 16:00:00', '2025-02-16 18:00:00', 1, 'ABC047', 'Abierto', 47);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (48, '2025-02-17 16:00:00', '2025-02-17 18:00:00', 2, 'ABC048', 'Cerrado', 48);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (49, '2025-02-18 16:00:00', '2025-02-18 18:00:00', 1, 'ABC049', 'Abierto', 49);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (50, '2025-02-19 16:00:00', '2025-02-19 18:00:00', 2, 'ABC050', 'Cerrado', 50);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (51, '2025-02-20 16:00:00', '2025-02-20 18:00:00', 1, 'ABC051', 'Abierto', 51);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (52, '2025-02-21 16:00:00', '2025-02-21 18:00:00', 2, 'ABC052', 'Cerrado', 52);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (53, '2025-02-22 16:00:00', '2025-02-22 18:00:00', 1, 'ABC053', 'Abierto', 53);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (54, '2025-02-23 16:00:00', '2025-02-23 18:00:00', 2, 'ABC054', 'Cerrado', 54);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (55, '2025-02-24 16:00:00', '2025-02-24 18:00:00', 1, 'ABC055', 'Abierto', 55);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (56, '2025-02-25 16:00:00', '2025-02-25 18:00:00', 2, 'ABC056', 'Cerrado', 56);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (57, '2025-02-26 16:00:00', '2025-02-26 18:00:00', 1, 'ABC057', 'Abierto', 57);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (58, '2025-02-27 16:00:00', '2025-02-27 18:00:00', 2, 'ABC058', 'Cerrado', 58);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (59, '2025-02-28 16:00:00', '2025-02-28 18:00:00', 1, 'ABC059', 'Abierto', 59);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (60, '2025-03-01 16:00:00', '2025-03-01 18:00:00', 2, 'ABC060', 'Cerrado', 60);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (61, '2025-03-02 16:00:00', '2025-03-02 18:00:00', 1, 'ABC061', 'Abierto', 61);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (62, '2025-03-03 16:00:00', '2025-03-03 18:00:00', 2, 'ABC062', 'Cerrado', 62);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (63, '2025-03-04 16:00:00', '2025-03-04 18:00:00', 1, 'ABC063', 'Abierto', 63);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (64, '2025-03-05 16:00:00', '2025-03-05 18:00:00', 2, 'ABC064', 'Cerrado', 64);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (65, '2025-03-06 16:00:00', '2025-03-06 18:00:00', 1, 'ABC065', 'Abierto', 65);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (66, '2025-03-07 16:00:00', '2025-03-07 18:00:00', 2, 'ABC066', 'Cerrado', 66);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (67, '2025-03-08 16:00:00', '2025-03-08 18:00:00', 1, 'ABC067', 'Abierto', 67);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (68, '2025-03-09 16:00:00', '2025-03-09 18:00:00', 2, 'ABC068', 'Cerrado', 68);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (69, '2025-03-10 16:00:00', '2025-03-10 18:00:00', 1, 'ABC069', 'Abierto', 69);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (70, '2025-03-11 16:00:00', '2025-03-11 18:00:00', 2, 'ABC070', 'Cerrado', 70);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (71, '2025-03-12 16:00:00', '2025-03-12 18:00:00', 1, 'ABC071', 'Abierto', 71);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (72, '2025-03-13 16:00:00', '2025-03-13 18:00:00', 2, 'ABC072', 'Cerrado', 72);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (73, '2025-03-14 16:00:00', '2025-03-14 18:00:00', 1, 'ABC073', 'Abierto', 73);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (74, '2025-03-15 16:00:00', '2025-03-15 18:00:00', 2, 'ABC074', 'Cerrado', 74);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (75, '2025-03-16 16:00:00', '2025-03-16 18:00:00', 1, 'ABC075', 'Abierto', 75);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (76, '2025-03-17 16:00:00', '2025-03-17 18:00:00', 2, 'ABC076', 'Cerrado', 76);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (77, '2025-03-18 16:00:00', '2025-03-18 18:00:00', 1, 'ABC077', 'Abierto', 77);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (78, '2025-03-19 16:00:00', '2025-03-19 18:00:00', 2, 'ABC078', 'Cerrado', 78);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (79, '2025-03-20 16:00:00', '2025-03-20 18:00:00', 1, 'ABC079', 'Abierto', 79);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (80, '2025-03-21 16:00:00', '2025-03-21 18:00:00', 2, 'ABC080', 'Cerrado', 80);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (81, '2025-03-22 16:00:00', '2025-03-22 18:00:00', 1, 'ABC081', 'Abierto', 81);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (82, '2025-03-23 16:00:00', '2025-03-23 18:00:00', 2, 'ABC082', 'Cerrado', 82);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (83, '2025-03-24 16:00:00', '2025-03-24 18:00:00', 1, 'ABC083', 'Abierto', 83);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (84, '2025-03-25 16:00:00', '2025-03-25 18:00:00', 2, 'ABC084', 'Cerrado', 84);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (85, '2025-03-26 16:00:00', '2025-03-26 18:00:00', 1, 'ABC085', 'Abierto', 85);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (86, '2025-03-27 16:00:00', '2025-03-27 18:00:00', 2, 'ABC086', 'Cerrado', 86);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (87, '2025-03-28 16:00:00', '2025-03-28 18:00:00', 1, 'ABC087', 'Abierto', 87);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (88, '2025-03-29 16:00:00', '2025-03-29 18:00:00', 2, 'ABC088', 'Cerrado', 88);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (89, '2025-03-30 16:00:00', '2025-03-30 18:00:00', 1, 'ABC089', 'Abierto', 89);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (90, '2025-03-31 16:00:00', '2025-03-31 18:00:00', 2, 'ABC090', 'Cerrado', 90);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (91, '2025-04-01 16:00:00', '2025-04-01 18:00:00', 1, 'ABC091', 'Abierto', 91);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (92, '2025-04-02 16:00:00', '2025-04-02 18:00:00', 2, 'ABC092', 'Cerrado', 92);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (93, '2025-04-03 16:00:00', '2025-04-03 18:00:00', 1, 'ABC093', 'Abierto', 93);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (94, '2025-04-04 16:00:00', '2025-04-04 18:00:00', 2, 'ABC094', 'Cerrado', 94);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (95, '2025-04-05 16:00:00', '2025-04-05 18:00:00', 1, 'ABC095', 'Abierto', 95);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (96, '2025-04-06 16:00:00', '2025-04-06 18:00:00', 2, 'ABC096', 'Cerrado', 96);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (97, '2025-04-07 16:00:00', '2025-04-07 18:00:00', 1, 'ABC097', 'Abierto', 97);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (98, '2025-04-08 16:00:00', '2025-04-08 18:00:00', 2, 'ABC098', 'Cerrado', 98);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (99, '2025-04-09 16:00:00', '2025-04-09 18:00:00', 1, 'ABC099', 'Abierto', 99);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (100, '2025-04-10 16:00:00', '2025-04-10 18:00:00', 2, 'ABC100', 'Cerrado', 100);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (101, '2025-04-11 16:00:00', '2025-04-11 18:00:00', 1, 'ABC101', 'Abierto', 101);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (102, '2025-04-12 16:00:00', '2025-04-12 18:00:00', 2, 'ABC102', 'Cerrado', 102);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (103, '2025-04-13 16:00:00', '2025-04-13 18:00:00', 1, 'ABC103', 'Abierto', 103);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (104, '2025-04-14 16:00:00', '2025-04-14 18:00:00', 2, 'ABC104', 'Cerrado', 104);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (105, '2025-04-15 16:00:00', '2025-04-15 18:00:00', 1, 'ABC105', 'Abierto', 105);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (106, '2025-04-16 16:00:00', '2025-04-16 18:00:00', 2, 'ABC106', 'Cerrado', 106);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (107, '2025-04-17 16:00:00', '2025-04-17 18:00:00', 1, 'ABC107', 'Abierto', 107);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (108, '2025-04-18 16:00:00', '2025-04-18 18:00:00', 2, 'ABC108', 'Cerrado', 108);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (109, '2025-04-19 16:00:00', '2025-04-19 18:00:00', 1, 'ABC109', 'Abierto', 109);
INSERT INTO parqueo (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo, id_celda) VALUES (110, '2025-04-20 16:00:00', '2025-04-20 18:00:00', 2, 'ABC110', 'Cerrado', 110);

-- 4) LIQUIDACION_LAVADO (110)
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (1, 9515.00, '2025-01-01');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (2, 9530.00, '2025-01-02');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (3, 9545.00, '2025-01-03');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (4, 9560.00, '2025-01-04');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (5, 9575.00, '2025-01-05');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (6, 9590.00, '2025-01-06');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (7, 9605.00, '2025-01-07');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (8, 9620.00, '2025-01-08');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (9, 9635.00, '2025-01-09');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (10, 9650.00, '2025-01-10');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (11, 9665.00, '2025-01-11');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (12, 9680.00, '2025-01-12');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (13, 9695.00, '2025-01-13');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (14, 9710.00, '2025-01-14');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (15, 9725.00, '2025-01-15');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (16, 9740.00, '2025-01-16');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (17, 9755.00, '2025-01-17');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (18, 9770.00, '2025-01-18');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (19, 9785.00, '2025-01-19');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (20, 9800.00, '2025-01-20');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (21, 9815.00, '2025-01-21');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (22, 9830.00, '2025-01-22');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (23, 9845.00, '2025-01-23');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (24, 9860.00, '2025-01-24');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (25, 9875.00, '2025-01-25');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (26, 9890.00, '2025-01-26');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (27, 9905.00, '2025-01-27');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (28, 9920.00, '2025-01-28');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (29, 9935.00, '2025-01-29');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (30, 9950.00, '2025-01-30');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (31, 9965.00, '2025-01-31');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (32, 9980.00, '2025-02-01');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (33, 9995.00, '2025-02-02');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (34, 10010.00, '2025-02-03');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (35, 10025.00, '2025-02-04');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (36, 10040.00, '2025-02-05');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (37, 10055.00, '2025-02-06');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (38, 10070.00, '2025-02-07');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (39, 10085.00, '2025-02-08');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (40, 10100.00, '2025-02-09');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (41, 10115.00, '2025-02-10');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (42, 10130.00, '2025-02-11');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (43, 10145.00, '2025-02-12');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (44, 10160.00, '2025-02-13');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (45, 10175.00, '2025-02-14');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (46, 10190.00, '2025-02-15');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (47, 10205.00, '2025-02-16');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (48, 10220.00, '2025-02-17');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (49, 10235.00, '2025-02-18');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (50, 10250.00, '2025-02-19');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (51, 10265.00, '2025-02-20');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (52, 10280.00, '2025-02-21');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (53, 10295.00, '2025-02-22');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (54, 10310.00, '2025-02-23');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (55, 10325.00, '2025-02-24');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (56, 10340.00, '2025-02-25');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (57, 10355.00, '2025-02-26');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (58, 10370.00, '2025-02-27');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (59, 10385.00, '2025-02-28');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (60, 10400.00, '2025-03-01');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (61, 10415.00, '2025-03-02');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (62, 10430.00, '2025-03-03');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (63, 10445.00, '2025-03-04');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (64, 10460.00, '2025-03-05');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (65, 10475.00, '2025-03-06');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (66, 10490.00, '2025-03-07');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (67, 10505.00, '2025-03-08');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (68, 10520.00, '2025-03-09');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (69, 10535.00, '2025-03-10');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (70, 10550.00, '2025-03-11');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (71, 10565.00, '2025-03-12');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (72, 10580.00, '2025-03-13');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (73, 10595.00, '2025-03-14');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (74, 10610.00, '2025-03-15');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (75, 10625.00, '2025-03-16');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (76, 10640.00, '2025-03-17');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (77, 10655.00, '2025-03-18');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (78, 10670.00, '2025-03-19');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (79, 10685.00, '2025-03-20');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (80, 10700.00, '2025-03-21');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (81, 10715.00, '2025-03-22');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (82, 10730.00, '2025-03-23');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (83, 10745.00, '2025-03-24');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (84, 10760.00, '2025-03-25');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (85, 10775.00, '2025-03-26');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (86, 10790.00, '2025-03-27');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (87, 10805.00, '2025-03-28');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (88, 10820.00, '2025-03-29');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (89, 10835.00, '2025-03-30');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (90, 10850.00, '2025-03-31');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (91, 10865.00, '2025-04-01');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (92, 10880.00, '2025-04-02');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (93, 10895.00, '2025-04-03');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (94, 10910.00, '2025-04-04');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (95, 10925.00, '2025-04-05');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (96, 10940.00, '2025-04-06');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (97, 10955.00, '2025-04-07');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (98, 10970.00, '2025-04-08');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (99, 10985.00, '2025-04-09');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (100, 11000.00, '2025-04-10');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (101, 11015.00, '2025-04-11');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (102, 11030.00, '2025-04-12');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (103, 11045.00, '2025-04-13');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (104, 11060.00, '2025-04-14');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (105, 11075.00, '2025-04-15');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (106, 11090.00, '2025-04-16');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (107, 11105.00, '2025-04-17');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (108, 11120.00, '2025-04-18');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (109, 11135.00, '2025-04-19');
INSERT INTO liquidacion_lavado (id_lavado, monto_calculado, fecha_liquidacion) VALUES (110, 11150.00, '2025-04-20');

-- 5) FACTURA (110)
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-01', 'C001', 1, 20050.00, 1);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-02', 'C002', 2, 20100.00, 2);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-03', 'C003', 1, 20150.00, 3);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-04', 'C004', 2, 20200.00, 4);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-05', 'C005', 1, 20250.00, 5);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-06', 'C006', 2, 20300.00, 6);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-07', 'C007', 1, 20350.00, 7);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-08', 'C008', 2, 20400.00, 8);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-09', 'C009', 1, 20450.00, 9);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-10', 'C010', 2, 20500.00, 10);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-11', 'C011', 1, 20550.00, 11);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-12', 'C012', 2, 20600.00, 12);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-13', 'C013', 1, 20650.00, 13);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-14', 'C014', 2, 20700.00, 14);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-15', 'C015', 1, 20750.00, 15);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-16', 'C016', 2, 20800.00, 16);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-17', 'C017', 1, 20850.00, 17);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-18', 'C018', 2, 20900.00, 18);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-19', 'C019', 1, 20950.00, 19);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-20', 'C020', 2, 21000.00, 20);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-21', 'C021', 1, 21050.00, 21);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-22', 'C022', 2, 21100.00, 22);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-23', 'C023', 1, 21150.00, 23);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-24', 'C024', 2, 21200.00, 24);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-25', 'C025', 1, 21250.00, 25);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-26', 'C026', 2, 21300.00, 26);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-27', 'C027', 1, 21350.00, 27);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-28', 'C028', 2, 21400.00, 28);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-29', 'C029', 1, 21450.00, 29);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-30', 'C030', 2, 21500.00, 30);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-01-31', 'C031', 1, 21550.00, 31);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-01', 'C032', 2, 21600.00, 32);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-02', 'C033', 1, 21650.00, 33);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-03', 'C034', 2, 21700.00, 34);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-04', 'C035', 1, 21750.00, 35);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-05', 'C036', 2, 21800.00, 36);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-06', 'C037', 1, 21850.00, 37);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-07', 'C038', 2, 21900.00, 38);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-08', 'C039', 1, 21950.00, 39);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-09', 'C040', 2, 22000.00, 40);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-10', 'C041', 1, 22050.00, 41);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-11', 'C042', 2, 22100.00, 42);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-12', 'C043', 1, 22150.00, 43);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-13', 'C044', 2, 22200.00, 44);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-14', 'C045', 1, 22250.00, 45);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-15', 'C046', 2, 22300.00, 46);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-16', 'C047', 1, 22350.00, 47);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-17', 'C048', 2, 22400.00, 48);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-18', 'C049', 1, 22450.00, 49);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-19', 'C050', 2, 22500.00, 50);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-20', 'C051', 1, 22550.00, 51);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-21', 'C052', 2, 22600.00, 52);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-22', 'C053', 1, 22650.00, 53);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-23', 'C054', 2, 22700.00, 54);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-24', 'C055', 1, 22750.00, 55);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-25', 'C056', 2, 22800.00, 56);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-26', 'C057', 1, 22850.00, 57);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-27', 'C058', 2, 22900.00, 58);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-02-28', 'C059', 1, 22950.00, 59);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-01', 'C060', 2, 23000.00, 60);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-02', 'C061', 1, 23050.00, 61);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-03', 'C062', 2, 23100.00, 62);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-04', 'C063', 1, 23150.00, 63);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-05', 'C064', 2, 23200.00, 64);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-06', 'C065', 1, 23250.00, 65);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-07', 'C066', 2, 23300.00, 66);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-08', 'C067', 1, 23350.00, 67);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-09', 'C068', 2, 23400.00, 68);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-10', 'C069', 1, 23450.00, 69);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-11', 'C070', 2, 23500.00, 70);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-12', 'C071', 1, 23550.00, 71);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-13', 'C072', 2, 23600.00, 72);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-14', 'C073', 1, 23650.00, 73);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-15', 'C074', 2, 23700.00, 74);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-16', 'C075', 1, 23750.00, 75);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-17', 'C076', 2, 23800.00, 76);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-18', 'C077', 1, 23850.00, 77);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-19', 'C078', 2, 23900.00, 78);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-20', 'C079', 1, 23950.00, 79);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-21', 'C080', 2, 24000.00, 80);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-22', 'C081', 1, 24050.00, 81);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-23', 'C082', 2, 24100.00, 82);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-24', 'C083', 1, 24150.00, 83);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-25', 'C084', 2, 24200.00, 84);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-26', 'C085', 1, 24250.00, 85);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-27', 'C086', 2, 24300.00, 86);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-28', 'C087', 1, 24350.00, 87);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-29', 'C088', 2, 24400.00, 88);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-30', 'C089', 1, 24450.00, 89);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-03-31', 'C090', 2, 24500.00, 90);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-01', 'C091', 1, 24550.00, 91);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-02', 'C092', 2, 24600.00, 92);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-03', 'C093', 1, 24650.00, 93);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-04', 'C094', 2, 24700.00, 94);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-05', 'C095', 1, 24750.00, 95);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-06', 'C096', 2, 24800.00, 96);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-07', 'C097', 1, 24850.00, 97);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-08', 'C098', 2, 24900.00, 98);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-09', 'C099', 1, 24950.00, 99);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-10', 'C100', 2, 25000.00, 100);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-11', 'C101', 1, 25050.00, 101);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-12', 'C102', 2, 25100.00, 102);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-13', 'C103', 1, 25150.00, 103);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-14', 'C104', 2, 25200.00, 104);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-15', 'C105', 1, 25250.00, 105);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-16', 'C106', 2, 25300.00, 106);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-17', 'C107', 1, 25350.00, 107);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-18', 'C108', 2, 25400.00, 108);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-19', 'C109', 1, 25450.00, 109);
INSERT INTO factura (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado) VALUES ('2025-04-20', 'C110', 2, 25500.00, 110);

-- 6) DETALLE_FACTURA (110)
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (1, 1, 10030.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (2, 2, 10060.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (3, 3, 10090.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (4, 4, 10120.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (5, 5, 10150.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (6, 6, 10180.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (7, 7, 10210.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (8, 8, 10240.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (9, 9, 10270.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (10, 10, 10300.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (11, 11, 10330.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (12, 12, 10360.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (13, 13, 10390.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (14, 14, 10420.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (15, 15, 10450.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (16, 16, 10480.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (17, 17, 10510.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (18, 18, 10540.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (19, 19, 10570.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (20, 20, 10600.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (21, 21, 10630.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (22, 22, 10660.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (23, 23, 10690.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (24, 24, 10720.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (25, 25, 10750.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (26, 26, 10780.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (27, 27, 10810.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (28, 28, 10840.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (29, 29, 10870.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (30, 30, 10900.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (31, 31, 10930.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (32, 32, 10960.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (33, 33, 10990.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (34, 34, 11020.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (35, 35, 11050.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (36, 36, 11080.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (37, 37, 11110.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (38, 38, 11140.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (39, 39, 11170.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (40, 40, 11200.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (41, 41, 11230.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (42, 42, 11260.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (43, 43, 11290.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (44, 44, 11320.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (45, 45, 11350.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (46, 46, 11380.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (47, 47, 11410.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (48, 48, 11440.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (49, 49, 11470.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (50, 50, 11500.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (51, 51, 11530.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (52, 52, 11560.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (53, 53, 11590.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (54, 54, 11620.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (55, 55, 11650.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (56, 56, 11680.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (57, 57, 11710.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (58, 58, 11740.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (59, 59, 11770.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (60, 60, 11800.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (61, 61, 11830.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (62, 62, 11860.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (63, 63, 11890.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (64, 64, 11920.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (65, 65, 11950.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (66, 66, 11980.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (67, 67, 12010.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (68, 68, 12040.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (69, 69, 12070.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (70, 70, 12100.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (71, 71, 12130.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (72, 72, 12160.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (73, 73, 12190.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (74, 74, 12220.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (75, 75, 12250.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (76, 76, 12280.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (77, 77, 12310.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (78, 78, 12340.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (79, 79, 12370.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (80, 80, 12400.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (81, 81, 12430.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (82, 82, 12460.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (83, 83, 12490.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (84, 84, 12520.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (85, 85, 12550.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (86, 86, 12580.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (87, 87, 12610.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (88, 88, 12640.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (89, 89, 12670.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (90, 90, 12700.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (91, 91, 12730.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (92, 92, 12760.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (93, 93, 12790.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (94, 94, 12820.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (95, 95, 12850.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (96, 96, 12880.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (97, 97, 12910.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (98, 98, 12940.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (99, 99, 12970.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (100, 100, 13000.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (101, 101, 13030.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (102, 102, 13060.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (103, 103, 13090.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (104, 104, 13120.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (105, 105, 13150.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (106, 106, 13180.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (107, 107, 13210.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (108, 108, 13240.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (109, 109, 13270.00);
INSERT INTO detalle_factura (id_factura, id_referencia_servicio, sub_total) VALUES (110, 110, 13300.00);



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
    s.nombre_sede,
    p.estado_parqueo
FROM parqueo AS p
INNER JOIN vehiculo AS v ON p.placa_vehiculo = v.placa
INNER JOIN sede AS s ON p.id_sede = s.id_sede;
/* 2  creacion de consulta con left   join 
autor David 
enunciado : Mostrar todos los clientes registrados, junto con los vehículos que tienen.  */
SELECT 
    c.documento,
    c.nombre AS nombre_cliente,
    c.telefono,
    v.placa,
    v.marca,
    v.modelo,
    v.color
FROM cliente AS c
LEFT JOIN vehiculo AS v
    ON c.documento = v.documento_cliente;
    /* 3   creacion de consulta con rigth    join 
autor David 
enunciado : Mostrar todos los lavados realizados, junto con su factura asociada (si existe).
Si hay algún lavado que todavía no ha sido facturado, debe aparecer igualmente. */
SELECT 
    f.id_factura,
    f.fecha_emision,
    f.total_pagar,
    l.id_lavado,
    l.placa,
    l.precio_lavado,
    l.estado_lavado
FROM factura AS f
RIGHT JOIN lavado AS l
    ON f.id_liquidacion_lavado = l.id_lavado;
      /* 4   creacion de consulta con FULL OUTER JOIN
autor David 
enunciado : Listar todos los convenios y todos los clientes, para ver:

clientes sin convenio,

convenios sin clientes,

y los que sí están asociados. */
SELECT
    c.documento       AS documento_cliente,
    c.nombre          AS nombre_cliente,
    con.id_convenio,
    con.nombre_convenio
FROM cliente AS c
FULL OUTER JOIN convenio AS con
    ON c.id_convenio = con.id_convenio
ORDER BY con.id_convenio, c.documento;


/*Desarrollar 3 funciones de tablas y 3 funciones escalares dentro de las necesidades del proyecto a desarrollar.
Estos procedimientos deben estar debidamente documentados.*/

/*  1 creacion de funcion de tabla : dbo.tvf_DisponibilidadCeldas 
autor: David Martinez Giraldo 
fecha : 7/11/2025 

*/
CREATE FUNCTION dbo.tvf_DisponibilidadCeldas
(
    @id_sede INT,              --- variables 
    @id_tipo_celda INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT  c.id_celda,
            s.nombre_sede,
            tc.nombre_tipo AS tipo_celda,
            c.estado_celda
    FROM CELDA c
    INNER JOIN sede s       ON s.id_sede = c.id_sede
    INNER JOIN TIPO_CELDA tc ON tc.id_tipo_celda = c.id_tipo_celda
    WHERE c.id_sede = @id_sede --- las celdas pertenecientes a la sede 
      AND c.estado_celda = 'Libre' --- que la celda este libre 
      AND (@id_tipo_celda IS NULL OR c.id_tipo_celda = @id_tipo_celda) ---  comprobamos si es null el tipo de celda  o si  hay una en especifico 
);
GO

-- Ejemplo:
 --SELECT * FROM dbo.tvf_DisponibilidadCeldas(2, NULL);

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
    SELECT  p.id_parqueo,
            p.placa_vehiculo,
            p.fecha_hora_ingreso,
            DATEDIFF(MINUTE, p.fecha_hora_ingreso, ISNULL(p.fecha_hora_salida, GETDATE()))/60.0 AS horas_transcurridas -- DATEDIFF(MINUTE, inicio, fin) calcula minutos entre ingreso y salida.
            -- iSNULL(p.fecha_hora_salida, GETDATE()) usa la salida si existe; si es NULL (parqueo aún abierto), toma la hora actual del servidor.
    FROM parqueo p
    WHERE p.id_sede = @id_sede
      AND (p.estado_parqueo = 'Abierto' OR p.fecha_hora_salida IS NULL)
);
GO
-- -- Ejemplo:
 SELECT * FROM dbo.tvf_ParqueosAbiertosPorSede(1);
  /*3 creacion de funcion de tabla: dbo.tvf_HistorialLavadosPorVehiculo
 autor: David Martinez Giraldo 
fecha : 7/11/2025 
descripcion :Mostrar el historial de lavados realizados a un vehículo específico, con las fechas, estado y precio.
Ideal para consultas rápidas del cliente o para generar reportes de uso del servicio.*/
CREATE OR ALTER FUNCTION dbo.tvf_HistorialLavadosPorVehiculo
(
    @placa VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        l.id_lavado,
        s.nombre_sede,
        l.fecha_inicio,
        l.fecha_fin,
        l.estado_lavado,
        tl.descripcion AS tipo_lavado,
        tl.precio AS precio_base,
        l.precio_lavado
    FROM lavado l
    INNER JOIN sede s ON s.id_sede = l.id_sede
    LEFT JOIN tipo_lavado tl ON tl.id_tipo_lavado = l.id_tipo_lavado
    WHERE l.placa = @placa
    
);
GO
-- ejemplo 
--INSERT INTO lavado (id_sede, precio_lavado, placa, fecha_inicio, fecha_fin, estado_lavado, id_celda_lavado, id_tipo_lavado) VALUES (1, 9020.00, 'ABC001', '2025-02-02 08:00:00', '2025-02-02 09:00:00', 'finalizado ', 1, 1);
--SELECT * FROM dbo.tvf_HistorialLavadosPorVehiculo('ABC001');
--select * from lavado

--- funciones escalares 

/*  1 creacion de funcion escalar: dbo.ufn_TotalLavadosVehiculo 
autor David Martinez Giraldo 
descripcion funcion que devuelve las veces en que se ha lavado un vehiculo 
*/

CREATE OR ALTER FUNCTION dbo.ufn_TotalLavadosVehiculo
(
    @placa VARCHAR(20)
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total = COUNT(*)
    FROM lavado
    WHERE placa = @placa;

    RETURN ISNULL(@total, 0);
END;
GO
-- ejemplo :
 --SELECT dbo.ufn_TotalLavadosVehiculo('ABC001') AS TotalLavados;
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
    WHERE id_sede = @id_sede
      AND estado_celda = 'Libre';

    RETURN ISNULL(@disponibles, 0);
END
GO
-- ejemplo 
 --SELECT dbo.ufn_CeldasDisponiblesEnSede(2) AS CeldasLibres;
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
      AND estado_celda = 'Ocupada';

    RETURN ISNULL(@ocupadas, 0);
END;
GO
-- ejemplo 
--- SELECT dbo.ufn_CeldasOcupadasEnSede(1) AS CeldasOcupadas;

/*Hacer 4 consultas que utilice teoría de conjuntos. Deben ir con su enunciado y producir algún resultado.*/

/* 1  creacion de consulta con UNION (teoría de conjuntos)
autor David
enunciado : Listar todas las placas que han tenido actividad en el sistema (ya sea parqueo o lavado), sin duplicados. */
SELECT p.placa_vehiculo AS placa
FROM parqueo AS p
UNION
SELECT l.placa
FROM lavado AS l;

/* 2  creacion de consulta con UNION ALL (teoría de conjuntos)
autor David
enunciado : Contar el total de actividades por placa sumando parqueos y lavados (conservando duplicados para sumar frecuencia). */
SELECT placa, COUNT(*) AS total_actividades
FROM (
    SELECT p.placa_vehiculo AS placa FROM parqueo AS p
    UNION ALL
    SELECT l.placa          AS placa FROM lavado  AS l
) AS x
GROUP BY placa
ORDER BY total_actividades DESC, placa;

/* 3  creacion de consulta con INTERSECT (teoría de conjuntos)
autor David
enunciado : Obtener las placas que aparecen tanto en parqueos como en lavados (intersección). */
SELECT p.placa_vehiculo
FROM parqueo AS p
INTERSECT
SELECT l.placa
FROM lavado AS l;
/* 4  creacion de consulta con EXCEPT (teoría de conjuntos)
autor David
enunciado : Listar los vehículos registrados que nunca se han parqueado (diferencia de conjuntos). */
SELECT v.placa
FROM vehiculo AS v
EXCEPT
SELECT p.placa_vehiculo
FROM parqueo AS p;

/* ============================================================
   VISTA 1: v_ParqueoEditableSimple
   autor: David Martínez
   propósito: Mostrar los parqueos junto con datos básicos
   de tarjeta, sede y vehículo, y permitir insertar/actualizar
   parqueos directamente desde la vista.
   Tablas base: parqueo (editable), Tarjeta, sede, vehiculo
   ============================================================ */

CREATE OR ALTER VIEW dbo.v_ParqueoEditableSimple
AS
SELECT
    
    p.id_parqueo,           
    p.id_tarjeta,           -- FK a la tarjeta usada para ingresar
    p.id_sede,              -- FK a la sede donde ocurre el parqueo
    p.placa_vehiculo,       -- FK al vehículo que se parqueó
    p.fecha_hora_ingreso,   -- hora de entrada
    p.fecha_hora_salida,    -- hora de salida
    p.estado_parqueo,       -- estado actual del parqueo (Abierto/Cerrado)

    
    s.nombre_sede,          -- nombre de la sede
    t.estado_tarjeta,       -- estado de la tarjeta usada
    v.marca,                -- marca del vehículo
    v.modelo,               -- modelo del vehículo
    v.color                 -- color del vehículo
FROM parqueo  AS p
JOIN Tarjeta  AS t ON t.id_tarjeta = p.id_tarjeta
JOIN sede     AS s ON s.id_sede    = p.id_sede
JOIN vehiculo AS v ON v.placa      = p.placa_vehiculo;
GO

SELECT *FROM dbo.v_ParqueoEditableSimple

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
    SET NOCOUNT ON;  -- evita mensajes extra de "x filas afectadas"

    INSERT INTO parqueo
        (id_tarjeta, fecha_hora_ingreso, fecha_hora_salida, id_sede, placa_vehiculo, estado_parqueo)
    SELECT
        i.id_tarjeta,                            -- usa la tarjeta que viene en el insert
        ISNULL(i.fecha_hora_ingreso, GETDATE()), -- si no se envía una fecha, usa la actual
        NULL,                                    -- la salida se deja nula al abrir el parqueo
        i.id_sede,                               -- sede del parqueo
        i.placa_vehiculo,                        -- vehículo que ingresa
        'Abierto'                                -- nuevo parqueo siempre inicia en estado Abierto
    FROM inserted AS i;                          -- 'inserted' es la tabla temporal con los datos nuevos
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

        -- Misma lógica para id_sede
        p.id_sede =
            CASE 
                WHEN i.id_sede IS NOT NULL THEN i.id_sede
                ELSE p.id_sede
            END,

        -- Y también para la placa del vehículo
        p.placa_vehiculo =
            CASE 
                WHEN i.placa_vehiculo IS NOT NULL THEN i.placa_vehiculo
                ELSE p.placa_vehiculo
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

        -- Aquí se aplica la lógica del estado:
        -- Si hay una fecha de salida (no es NULL) → estado = 'Cerrado'
        -- Si NO hay fecha de salida → estado = 'Abierto'
        p.estado_parqueo =
            CASE
                WHEN (CASE 
                        WHEN i.fecha_hora_salida IS NOT NULL THEN i.fecha_hora_salida
                        ELSE p.fecha_hora_salida
                      END) IS NOT NULL
                THEN 'Cerrado'
                ELSE 'Abierto'
            END
    FROM parqueo p
    JOIN inserted i ON i.id_parqueo = p.id_parqueo;  -- se actualizan solo los registros que se están modificando
END;
GO

/* ============================================================
   VISTA 2: v_FacturaEditableSimple
   autor: David Martínez
   propósito: Permitir crear o modificar facturas de lavados
   y mostrar datos de cliente, sede y lavado asociados.
   Tablas base: factura (editable), cliente, sede, liquidacion_lavado, lavado
   ============================================================ */

CREATE OR ALTER VIEW dbo.v_FacturaEditableSimple
AS
SELECT
    -- Campos EDITABLES (de la tabla FACTURA)
    f.id_factura,           -- PK de la factura
    f.fecha_emision,        -- fecha de emisión de la factura
    f.documento_cliente,    -- cliente asociado
    f.id_sede,              -- sede donde se genera la factura
    f.total_pagar,          -- total a cobrar
    f.id_liquidacion_lavado,-- FK a la liquidación del lavado

    -- Campos informativos (de otras tablas)
    c.nombre       AS nombre_cliente,
    s.nombre_sede,
    lv.id_lavado,
    lv.precio_lavado
FROM factura f
JOIN cliente c             ON c.documento              = f.documento_cliente
JOIN sede s                ON s.id_sede                = f.id_sede
JOIN liquidacion_lavado lq ON lq.id_liquidacion_lavado = f.id_liquidacion_lavado
JOIN lavado lv             ON lv.id_lavado             = lq.id_lavado;
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
    SET NOCOUNT ON;

    INSERT INTO factura
        (fecha_emision, documento_cliente, id_sede, total_pagar, id_liquidacion_lavado)
    SELECT
        -- Si el usuario manda una fecha, se usa;
        -- si no, se usa la fecha actual del sistema.
        CASE 
            WHEN i.fecha_emision IS NOT NULL THEN i.fecha_emision
            ELSE CAST(GETDATE() AS DATE)
        END,

        -- Cliente, sede y liquidación se insertan directamente desde lo que venga en la vista.
        i.documento_cliente,
        i.id_sede,

        -- Si el usuario no envía el total, se guarda 0 para evitar NULL.
        CASE 
            WHEN i.total_pagar IS NOT NULL THEN i.total_pagar
            ELSE 0
        END,

        i.id_liquidacion_lavado
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
        f.fecha_emision =
            CASE 
                WHEN i.fecha_emision IS NOT NULL THEN i.fecha_emision
                ELSE f.fecha_emision
            END,

        -- Si se envía un nuevo total, se actualiza;
        -- de lo contrario, permanece igual.
        f.total_pagar =
            CASE 
                WHEN i.total_pagar IS NOT NULL THEN i.total_pagar
                ELSE f.total_pagar
            END,

        -- Si se cambia la sede, se actualiza.
        f.id_sede =
            CASE 
                WHEN i.id_sede IS NOT NULL THEN i.id_sede
                ELSE f.id_sede
            END,

        -- Actualiza el cliente si se envía un nuevo documento.
        f.documento_cliente =
            CASE 
                WHEN i.documento_cliente IS NOT NULL THEN i.documento_cliente
                ELSE f.documento_cliente
            END,

        -- Si se envía un nuevo id_liquidacion_lavado, se usa ese.
        f.id_liquidacion_lavado =
            CASE 
                WHEN i.id_liquidacion_lavado IS NOT NULL THEN i.id_liquidacion_lavado
                ELSE f.id_liquidacion_lavado
            END
    FROM factura f
    JOIN inserted i ON i.id_factura = f.id_factura;
END;
GO

-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS CRUD
-- Autor: Julian Alvarez
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
--ANALISIS DE DATOS APLICADO AL PROYECTO.
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
