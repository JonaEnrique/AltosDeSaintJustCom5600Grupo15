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