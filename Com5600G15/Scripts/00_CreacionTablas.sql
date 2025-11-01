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

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Consorcio')  EXEC('CREATE SCHEMA Consorcio');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Pago')       EXEC('CREATE SCHEMA Pago');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Reporte')    EXEC('CREATE SCHEMA Reporte');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Seguridad')  EXEC('CREATE SCHEMA Seguridad');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Importacion')EXEC('CREATE SCHEMA Importacion');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name='Persona')    EXEC('CREATE SCHEMA Persona');


-- *************** CREACIÓN DE TABLAS *************** --

IF OBJECT_ID('Consorcio.Consorcio','U')        IS NOT NULL DROP TABLE Consorcio.Consorcio;
IF OBJECT_ID('Consorcio.UnidadFuncional','U')  IS NOT NULL DROP TABLE Consorcio.UnidadFuncional;
IF OBJECT_ID('Consorcio.Persona','U')          IS NOT NULL DROP TABLE Consorcio.Persona;
IF OBJECT_ID('Pago.Prorrateo','U')            IS NOT NULL DROP TABLE Pago.Prorrateo;
IF OBJECT_ID('Pago.PagoAsociado','U')          IS NOT NULL DROP TABLE Pago.PagoAsociado;
IF OBJECT_ID('Pago.GastoOrdinario','U')        IS NOT NULL DROP TABLE Pago.GastoOrdinario;
IF OBJECT_ID('Pago.GastoExtraordinario','U')   IS NOT NULL DROP TABLE Pago.GastoExtraordinario;
IF OBJECT_ID('Consorcio.PersonaUnidad','U')    IS NOT NULL DROP TABLE Consorcio.PersonaUnidad;
IF OBJECT_ID('Consorcio.EstadoFinanciero','U') IS NOT NULL DROP TABLE Consorcio.EstadoFinanciero;
IF OBJECT_ID('Consorcio.Proveedor','U')        IS NOT NULL DROP TABLE Consorcio.Proveedor;


CREATE TABLE Consorcio.Consorcio(
    id_consorcio INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    cant_unidades_funcionales INT NOT NULL,
    m2_totales DECIMAL(10,2) NOT NULL,
    vencimiento1 DATE NOT NULL,
    vencimiento2 DATETIME NOT NULL
);

CREATE TABLE Consorcio.UnidadFuncional(
    id_unidad   INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio INT NOT NULL,
    piso        VARCHAR(3)  NOT NULL,
    departamento CHAR(1)    NOT NULL,
    coeficiente DECIMAL(4,1) NOT NULL,
    m2_unidad   DECIMAL(10,2) NOT NULL,
    m2_baulera  DECIMAL(10,2) NOT NULL DEFAULT(0),
    m2_cochera  DECIMAL(10,2) NOT NULL DEFAULT(0),
    precio_cochera DECIMAL(10,2) NOT NULL DEFAULT(0),
    precio_baulera DECIMAL(10,2) NOT NULL DEFAULT(0),
    CONSTRAINT fk_UF_consorcio
      FOREIGN KEY (id_consorcio) REFERENCES Consorcio.Consorcio(id_consorcio)
);

CREATE TABLE Consorcio.Persona(
    dni      INT          PRIMARY KEY,
    nombre   NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    mail     NVARCHAR(254),
    telefono VARCHAR(20),
    cbu_cvu  VARCHAR(25)
);

CREATE TABLE Consorcio.Proveedor(
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio INT NOT NULL,
    nombre_proveedor VARCHAR(50) NOT NULL,
    cuenta VARCHAR(50),
    tipo   VARCHAR(50),
    CONSTRAINT fk_proveedor_consorcio
      FOREIGN KEY (id_consorcio) REFERENCES Consorcio.Consorcio(id_consorcio)
);

CREATE TABLE Pago.GastoExtraordinario(
    id_gasto     INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio INT NOT NULL,
    detalle      VARCHAR(255) NOT NULL,
    importe      DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    fecha        DATE NOT NULL,
    pago_cuotas  BIT  NOT NULL DEFAULT(0),
    nro_cuota    INT  NULL,
    total_cuotas INT  NULL,
    CONSTRAINT fk_gextra_consorcio
      FOREIGN KEY (id_consorcio) REFERENCES Consorcio.Consorcio(id_consorcio)
);

CREATE TABLE Pago.GastoOrdinario(
    id_gasto     INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio INT NOT NULL,
    tipo_gasto   VARCHAR(60),
    fecha        DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
    importe      DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    nro_factura  INT NOT NULL,
    id_proveedor INT NOT NULL,
    descripcion  VARCHAR(60),
    CONSTRAINT fk_gord_consorcio
      FOREIGN KEY (id_consorcio) REFERENCES Consorcio.Consorcio(id_consorcio),
    CONSTRAINT fk_gord_proveedor
      FOREIGN KEY (id_proveedor) REFERENCES Consorcio.Proveedor(id_proveedor)
);

CREATE TABLE Consorcio.EstadoFinanciero(
    id_estado    INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio INT NOT NULL,
    fecha        DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
    saldo_anterior      DECIMAL(10,2) NOT NULL DEFAULT(0),
    ingreso_en_termino  DECIMAL(10,2) NOT NULL DEFAULT(0), -- coma corregida
    ingreso_adeudado    DECIMAL(10,2) NOT NULL DEFAULT(0),
    ingreso_adelantado  DECIMAL(10,2) NOT NULL DEFAULT(0),
    egresos_mes         DECIMAL(10,2) NOT NULL DEFAULT(0),
    saldo_cierre        DECIMAL(10,2) NOT NULL DEFAULT(0),
    CONSTRAINT fk_estfin_consorcio
      FOREIGN KEY (id_consorcio) REFERENCES Consorcio.Consorcio(id_consorcio)
);

CREATE TABLE Consorcio.PersonaUnidad(
    id_persona_unidad INT IDENTITY(1,1) PRIMARY KEY,
    id_unidad INT NOT NULL,
    dni       INT NOT NULL,
    rol       CHAR(1) NOT NULL CHECK (rol IN ('P','I')),
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE NULL,
    CONSTRAINT fk_persunid_unidad
      FOREIGN KEY (id_unidad) REFERENCES Consorcio.UnidadFuncional(id_unidad),
    CONSTRAINT fk_persunid_persona
      FOREIGN KEY (dni) REFERENCES Consorcio.Persona(dni)
);

CREATE TABLE Pago.PagoAsociado(
    id_expensa     INT IDENTITY(1,1) PRIMARY KEY,
    id_unidad      INT NOT NULL,
    fecha          DATE NOT NULL,
    cvu_cbu        VARCHAR(25) NOT NULL,
    codigo_cuenta  INT NOT NULL,
    importe        DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    CONSTRAINT fk_pagoasoc_unidad
      FOREIGN KEY (id_unidad) REFERENCES Consorcio.UnidadFuncional(id_unidad),
    CONSTRAINT fk_pagoasoc_persona
      FOREIGN KEY (cvu_cbu)   REFERENCES Consorcio.Persona(cbu_cvu)
);

CREATE TABLE Pago.Prorrateo(
    id_prorrateo            INT IDENTITY(1,1) PRIMARY KEY,
    id_unidad                INT   NOT NULL,
    fecha                    DATE  NOT NULL,
    porcentaje_m2            DECIMAL(6,3) NOT NULL CHECK (porcentaje_m2 > 0),
    piso                     VARCHAR(5) NOT NULL,
    depto                    CHAR(1)    NOT NULL,
    nombre_propietario       VARCHAR(100),
    precio_cocheras          DECIMAL(10,2) NOT NULL DEFAULT(0),
    precio_bauleras          DECIMAL(10,2) NOT NULL DEFAULT(0),
    saldo_anterior_abonado   DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (saldo_anterior_abonado >= 0),
    pagos_recibidos          DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (pagos_recibidos >= 0),
    deudas                   DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (deudas >= 0),
    intereses                DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (intereses >= 0),
    expensas_ordinarias      DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (expensas_ordinarias >= 0),
    expensas_extraordinarias DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (expensas_extraordinarias >= 0),
    total_a_pagar            DECIMAL(10,2) NOT NULL DEFAULT(0) CHECK (total_a_pagar >= 0),
    CONSTRAINT uq_prorrateo_unidad_fecha UNIQUE (id_unidad, fecha),
    CONSTRAINT fk_prorrateo_unidad
      FOREIGN KEY (id_unidad) REFERENCES Consorcio.UnidadFuncional(id_unidad)
);
