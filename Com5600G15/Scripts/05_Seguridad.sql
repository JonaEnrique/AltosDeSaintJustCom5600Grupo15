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
	 -Consigna:Cumplimiento de los requisitos de seguridad solicitados en la Entrega 7
    ---------------------------------------------------------------------
*/

USE Com5600G15;
GO

-- =========================================
-- LIMPIEZA: Eliminar objetos si ya existen
-- =========================================

-- 1. Eliminar usuarios (dependen de roles y logins)
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioAdministrativoGeneral')
    DROP USER UsuarioAdministrativoGeneral;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioAdministrativoBancario')
    DROP USER UsuarioAdministrativoBancario;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioAdministrativoOperativo')
    DROP USER UsuarioAdministrativoOperativo;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UsuarioSistemas')
    DROP USER UsuarioSistemas;

-- 2. Eliminar roles
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoGeneral' AND type = 'R')
    DROP ROLE AdministrativoGeneral;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoBancario' AND type = 'R')
    DROP ROLE AdministrativoBancario;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoOperativo' AND type = 'R')
    DROP ROLE AdministrativoOperativo;

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Sistemas' AND type = 'R')
    DROP ROLE Sistemas;
GO

-- 3. Eliminar logins (ahora en contexto master)
USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LoginAdministrativoGeneral')
    DROP LOGIN LoginAdministrativoGeneral;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LoginAdministrativoBancario')
    DROP LOGIN LoginAdministrativoBancario;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LoginAdministrativoOperativo')
    DROP LOGIN LoginAdministrativoOperativo;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'LoginSistemas')
    DROP LOGIN LoginSistemas;
GO

-- =========================================
-- CREACIÓN DE LOGINS
-- =========================================
--(Las contraseñas pueden ser cambiadas a gusto)

CREATE LOGIN LoginAdministrativoGeneral WITH PASSWORD = 'AdminGeneral';
CREATE LOGIN LoginAdministrativoBancario WITH PASSWORD = 'Bancario';
CREATE LOGIN LoginAdministrativoOperativo WITH PASSWORD = 'Operativo';
CREATE LOGIN LoginSistemas WITH PASSWORD = 'Sistemas';
GO

USE Com5600G15;
GO

-- =========================================
-- CREACIÓN DE ROLES
-- =========================================

CREATE ROLE AdministrativoGeneral;
CREATE ROLE AdministrativoBancario;
CREATE ROLE AdministrativoOperativo;
CREATE ROLE Sistemas;
GO

-- =========================================
-- ASIGNACIÓN DE PERMISOS A ROLES
-- =========================================

/*
+--------------------------+------------------------------+-------------------------------------+------------------------+
|                          |                              | Acciones                            |                        |
+--------------------------+------------------------------+-------------------------------------+------------------------+
| Rol                      | Actualizacion de datos de UF | Importacion de informacion bancaria | Generacion de reportes |
+--------------------------+------------------------------+-------------------------------------+------------------------+
| adminstrativo general    | si                           | no                                  | si                     |
+--------------------------+------------------------------+-------------------------------------+------------------------+
| Administrativo Bancario  | no                           | si                                  | si                     |
+--------------------------+------------------------------+-------------------------------------+------------------------+
| Administrativo operativo | si                           | no                                  | si                     |
+--------------------------+------------------------------+-------------------------------------+------------------------+
| Sistemas                 | no                           | no                                  | si                     |
+--------------------------+------------------------------+-------------------------------------+------------------------+
*/

--Actualizacion de datos de UF
GRANT EXECUTE ON Consorcio.CrearUnidadFuncional TO AdministrativoGeneral;
GRANT EXECUTE ON Consorcio.ModificarUnidadFuncional TO AdministrativoGeneral;
GRANT EXECUTE ON Consorcio.EliminarUnidadFuncional TO AdministrativoGeneral;

GRANT EXECUTE ON Consorcio.CrearUnidadFuncional TO AdministrativoOperativo;
GRANT EXECUTE ON Consorcio.ModificarUnidadFuncional TO AdministrativoOperativo;
GRANT EXECUTE ON Consorcio.EliminarUnidadFuncional TO AdministrativoOperativo;

--Importacion de informacion bancaria
GRANT EXECUTE ON Pago.CrearPagoAsociado TO AdministrativoBancario;
--Para la modifiacion de CBU_CVU de personas
GRANT EXECUTE ON Consorcio.ModificarPersona TO AdministrativoBancario;

--Generacion de reportes
--Estado Financiero
GRANT EXECUTE ON Consorcio.GenerarEstadoFinanciero TO AdministrativoGeneral;
GRANT EXECUTE ON Consorcio.GenerarEstadoFinanciero TO AdministrativoBancario;
GRANT EXECUTE ON Consorcio.GenerarEstadoFinanciero TO AdministrativoOperativo;
GRANT EXECUTE ON Consorcio.GenerarEstadoFinanciero TO Sistemas;

--Prorrateo
GRANT EXECUTE ON Reporte.calcularProrrateo TO AdministrativoGeneral;
GRANT EXECUTE ON Reporte.calcularProrrateo TO AdministrativoBancario;
GRANT EXECUTE ON Reporte.calcularProrrateo TO AdministrativoOperativo;
GRANT EXECUTE ON Reporte.calcularProrrateo TO Sistemas;

-- =========================================
-- CREACIÓN DE USUARIOS Y ASIGNACIÓN A ROLES
-- =========================================

--Creamos y asignamos los usuarios para los login creados anteriormente
CREATE USER UsuarioAdministrativoGeneral FOR LOGIN LoginAdministrativoGeneral;
CREATE USER UsuarioAdministrativoBancario FOR LOGIN LoginAdministrativoBancario;
CREATE USER UsuarioAdministrativoOperativo FOR LOGIN LoginAdministrativoOperativo;
CREATE USER UsuarioSistemas FOR LOGIN LoginSistemas;

--Asignamos los Usuarios a los Roles
ALTER ROLE AdministrativoGeneral ADD MEMBER UsuarioAdministrativoGeneral;
ALTER ROLE AdministrativoBancario ADD MEMBER UsuarioAdministrativoBancario;
ALTER ROLE AdministrativoOperativo ADD MEMBER UsuarioAdministrativoOperativo;
ALTER ROLE Sistemas ADD MEMBER UsuarioSistemas;

--Restringimos el acceso general a las tablas al rol Public
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Consorcio TO PUBLIC;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Pago TO PUBLIC;
GO

-- ================
-- CIFRADO DE DATOS
-- ================

--En nuestro caso, cifraremos toda la info de la tabla persona y el campo CBU_CVU de PagoAsociado

/* ==========================================================
   MODIFICACIÓN DE ESTRUCTURA DE TABLAS PARA HASHING UNIDIRECCIONAL
   Consigna: cumplir con la Ley 25.326 (AR) y el GDPR (UE),
   aplicando hashing SHA2_256 a datos personales y sensibles.
   NOTA: En este caso decidimos no eliminar los datos originales de las tablas.
   ========================================================== */

-- Verificar y eliminar columnas si existen en Persona
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Consorcio.Persona') AND name = 'dni_hash')
    ALTER TABLE Consorcio.Persona DROP COLUMN dni_hash;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Consorcio.Persona') AND name = 'mail_hash')
    ALTER TABLE Consorcio.Persona DROP COLUMN mail_hash;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Consorcio.Persona') AND name = 'telefono_hash')
    ALTER TABLE Consorcio.Persona DROP COLUMN telefono_hash;

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Consorcio.Persona') AND name = 'cvu_cbu_hash')
    ALTER TABLE Consorcio.Persona DROP COLUMN cvu_cbu_hash;

-- Verificar y eliminar columna si existe en PagoAsociado
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Pago.PagoAsociado') AND name = 'cvu_cbu_hash')
    ALTER TABLE Pago.PagoAsociado DROP COLUMN cvu_cbu_hash;
GO

-- Tabla Persona - Agregar columnas de hash
ALTER TABLE Consorcio.Persona
ADD dni_hash VARBINARY(64),
    mail_hash VARBINARY(64),
    telefono_hash VARBINARY(64),
    cvu_cbu_hash VARBINARY(64);

-- Tabla PagoAsociado - Agregar columna de hash
ALTER TABLE Pago.PagoAsociado
ADD cvu_cbu_hash VARBINARY(64);
GO

--Triggers para futuras inserciones de datos
--Persona
CREATE OR ALTER TRIGGER Consorcio.TgrHashPersona
ON Consorcio.Persona
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET 
        dni_hash       = HASHBYTES('SHA2_256', CAST(p.dni AS NVARCHAR(50))),
        mail_hash      = HASHBYTES('SHA2_256', p.mail),
        telefono_hash  = HASHBYTES('SHA2_256', p.telefono),
        cvu_cbu_hash   = HASHBYTES('SHA2_256', p.cvu_cbu)
    FROM Consorcio.Persona p
    INNER JOIN inserted i ON p.dni = i.dni;
END;
GO

--PagoAsociado
CREATE OR ALTER TRIGGER Pago.TgrHashPagoAsociado
ON Pago.PagoAsociado
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pa
    SET 
        cvu_cbu_hash = HASHBYTES('SHA2_256', pa.cvu_cbu)
    FROM Pago.PagoAsociado pa
    INNER JOIN inserted i ON pa.id_expensa = i.id_expensa;
END;
GO

--Cifrado de datos ya existentes
UPDATE Consorcio.Persona
SET dni_hash       = HASHBYTES('SHA2_256', CAST(dni AS NVARCHAR(50))),
    mail_hash      = HASHBYTES('SHA2_256', mail),
    telefono_hash  = HASHBYTES('SHA2_256', telefono),
    cvu_cbu_hash   = HASHBYTES('SHA2_256', cvu_cbu);

UPDATE Pago.PagoAsociado
SET cvu_cbu_hash = HASHBYTES('SHA2_256', cvu_cbu);
GO

--Vista para enmascarar los datos existentes en Persona
CREATE OR ALTER VIEW Consorcio.VerPersonasProtegidas
AS
SELECT 
    p.nombre,
    p.apellido,
    CONCAT(LEFT(p.mail, 3), '***') AS mail_enmascarado,
    CONCAT(LEFT(p.telefono, 3), '*****') AS telefono_enmascarado,
    p.dni_hash,
    p.cvu_cbu_hash
FROM Consorcio.Persona AS p;
GO

--Denegamos select sobre la tabla persona al rol publico
DENY SELECT ON Consorcio.Persona TO PUBLIC;
--le damos permisos a los roles para que puedan ver la tabla persona protegida
GRANT SELECT ON Consorcio.VerPersonasProtegidas TO AdministrativoGeneral;
GRANT SELECT ON Consorcio.VerPersonasProtegidas TO AdministrativoBancario;
GRANT SELECT ON Consorcio.VerPersonasProtegidas TO AdministrativoOperativo;
GRANT SELECT ON Consorcio.VerPersonasProtegidas TO Sistemas;
GO

--Vista para enmascarar los cvu_cbu en PagoAsociado
CREATE OR ALTER VIEW Pago.VerPagosAsociadosProtegidos AS
SELECT
    pa.id_expensa,
    pa.id_unidad,
    pa.fecha,
    pa.importe,
    pa.cvu_cbu_hash AS cvu_cbu_protegido
FROM Pago.PagoAsociado AS pa;
GO

--Denegamos select sobre la tabla pagoAsociado al rol publico
DENY SELECT ON Pago.PagoAsociado TO PUBLIC;

--le damos permisos a los roles para que puedan ver la tabla PagoAsociado protegido
GRANT SELECT ON Pago.VerPagosAsociadosProtegidos TO AdministrativoGeneral;
GRANT SELECT ON Pago.VerPagosAsociadosProtegidos TO AdministrativoBancario;
GRANT SELECT ON Pago.VerPagosAsociadosProtegidos TO AdministrativoOperativo;
GRANT SELECT ON Pago.VerPagosAsociadosProtegidos TO Sistemas;
GO

-- =====================
-- Politicas de respaldo
-- =====================
/*
Consigna: plantear politicas de respaldo
*/

/*
Aclaracion: el enunciado dicta que "La información de cada expensa generada es de vital importancia para el negocio,
por ello se requiere que se establezcan políticas de respaldo tanto en las ventas diarias generadas como
en los reportes generados" asumiremos que ventas diarias es igual a PagosAsociados y reportes generados
es igual a Prorrateo y EstadoFinanciero
*/

/*
La politica elegida aplica a las bases de datos del sistema, priorizando las tablas de alta criticidad y 
actualizacion frecuente. Mas especificamente:

*Pago.PagoAsociado
*Pago.GastoOrdinario
*Pago.GastoExtraordinario

Además, se incluyen las tablas Consorcio.Prorrateo y Consorcio.EstadoFinanciero como parte del respaldo
completo semanal, dado su valor contable y de auditoría.

=======================
Estrategia seleccionada
=======================
Backup completo + diferencial:

Completo semanal: copia integra de todas las bases de datos y archivos asociados.
Diferencial diario: copia de los datos modificados desde el ultimo respaldo completo.

Programación (Schedule):
-Backup completo: todos los domingos a las 02:00 AM.
-Backup diferencial: todos los días a las 23:00 PM.
-Retencion: los respaldos diferenciales se conservan por 7 días; los completos, por 1 mes.
-Ubicacion: los archivos .bak se almacenan en un servidor de respaldo dedicado y/o 
en un almacenamiento externo seguro (NAS o servicio en la nube).

RPO (Recovery Point Objective)

El RPO se establece en 24 horas, ya que los backup diferenciales se realizan diariame
*/

