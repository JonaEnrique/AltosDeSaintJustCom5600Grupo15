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
    id_unidadfecha   INT NOT NULL,
    tipodecuenta     INT NOT NULL,
    codigo_cuenta    INT NOT NULL,
    importe          DECIMAL(10,2) NOT NULL CHECK (importe > 0),

    -- Foreign keys
    FOREIGN KEY (id_unidadfecha) REFERENCES --tabla que no creamos,
    FOREIGN KEY (tipodecuenta)   REFERENCES --tabla que no creamos,
    FOREIGN KEY (codigo_cuenta)  REFERENCES --tabla que no creamos
)
GO

CREATE TABLE GastoExtraordinario (
    id_gasto        INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio    INT NOT NULL, -- FK a agregar después
    detalle         VARCHAR(255) NOT NULL,
    importe         DECIMAL(10,2) NOT NULL CHECK (importe > 0),
    fecha           DATE NOT NULL,
    pago_cuotas     BIT NOT NULL DEFAULT 0,  -- 0 = no, 1 = sí
    nro_cuota       INT NULL,
    total_cuotas    INT NULL,
    
    -- FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
)
GO

