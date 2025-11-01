/*
    ---------------------------------------------------------------------
    -Fecha: 27/10/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Jonathan Enrique
		- Ariel De Brito
		- Franco Perez
		- Cristian Vergara
    ---------------------------------------------------------------------
*/

USE MASTER;
GO

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = 'Com5600G15')
BEGIN
    ALTER DATABASE Com5600G15 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
END
GO

DROP DATABASE IF EXISTS Com5600G15
CREATE DATABASE Com5600G15 COLLATE Modern_Spanish_CI_AS
GO

USE Com5600G15
GO
-- *************** CREACIÓN DE SCHEMAS *************** --

DROP SCHEMA IF EXISTS Importacion;
GO
CREATE SCHEMA Importacion;
GO

-- *************** CREACIÓN DE TABLAS *************** --

CREATE TABLE PagoAsociado (
    id_expensa       INT IDENTITY(1,1) PRIMARY KEY,
    id_unidad   INT NOT NULL,
	fecha DATE NOT NULL,
    cvu_cbu     INT NOT NULL,
    codigo_cuenta    INT NOT NULL,
    importe          DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    -- Foreign keys
    FOREIGN KEY (id_unidad) REFERENCES UnidadFuncional(id_unidad),
    FOREIGN KEY (cbu/cvu)   REFERENCES Persona(tipo_cuenta)
)
GO

CREATE TABLE GastoExtraordinario (
    id_gasto        INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio    INT NOT NULL,
    detalle         VARCHAR(255) NOT NULL,
    importe         DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    fecha           DATE NOT NULL,
    pago_cuotas     BIT NOT NULL DEFAULT 0,  -- 0 = no, 1 = sí
    nro_cuota       INT NULL,
    total_cuotas    INT NULL,
    FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
)
GO

CREATE TABLE Proveedor (
	id_proveedor INT PRIMARY KEY IDENTITY(1,1),
	id_consorcio INT NOT NULL,
	nombre_proveedor VARCHAR(50) NOT NULL,
	cuenta VARCHAR(50),
	tipo VARCHAR(50),
	CONSTRAINT fk_consorcio_proveedor FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
);

GO

CREATE TABLE GastoOrdinario (
	id_gasto INT PRIMARY KEY IDENTITY(1,1), 
	id_consorcio INT NOT NULL,
	tipo_gasto VARCHAR(60),
	fecha DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
	importe DECIMAL(10,2) NOT NULL,
	nro_factura INT NOT NULL,
	id_proveedor INT NOT NULL,
	descripcion VARCHAR(60),
	CONSTRAINT fk_gastoOrdinario_consorcio FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio),
	CONSTRAINT fk_gastoOrdinario_proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

GO

CREATE TABLE EstadoFinanciero (
	id_estado INT PRIMARY KEY IDENTITY(1,1), 
	id_consorcio INT NOT NULL,
	fecha DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
	saldo_anterior DECIMAL(10,2),
	ingreso_en_termino DECIMAL(10,2)
	ingreso_adeudado DECIMAL(10,2),
	ingreso_adelantado DECIMAL(10,2),
	egresos_mes DECIMAL(10,2),
	saldo_cierre DECIMAL(10,2),
	CONSTRAINT fk_estadoFinanciero_consorcio FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
);

CREATE TABLE PersonaUnidad
(
    id_persona_unidad INT IDENTITY(1,1) PRIMARY KEY,
    id_unidad INT,
    dni INT,
    rol CHAR(1) CHECK (rol IN ('P', 'I')), --P = Propietario, I = inquilino
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT FK_PersonaUnidad_Unidad FOREIGN KEY (id_unidad) REFERENCES UnidadFuncional(id_unidad_funcional),
    CONSTRAINT FK_PersonaUnidad_Persona FOREIGN KEY (dni) REFERENCES Persona(dni)
)
GO

CREATE TABLE Persona
(
    dni INT PRIMARY KEY,
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    mail NVARCHAR(254),
    telefono VARCHAR(20),
    tipo_cuenta CHAR(3) CHECK (tipo_cuenta IN ('CBU', 'CVU')),
    codigo_cuenta CHAR(22) NOT NULL
)
GO


