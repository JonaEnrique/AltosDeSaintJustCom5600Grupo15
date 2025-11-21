/*
    ---------------------------------------------------------------------
    -Fecha: 02/11/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Perez
    - Cristian Vergara
    -Script: PRUEBAS Stored Procedures de modificacion de tablas
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO

-------<<<<<<<TABLA PERSONA UNIDAD>>>>>>>-------

-- PREPARACION: Crear datos necesarios
-- Crear persona
INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cvu_cbu)
VALUES (12345678, 'Juan', 'Pérez', 'juan.perez@mail.com', '1122334455', '0000003100012345678901');
GO

INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cvu_cbu)
VALUES (87654321, 'María', 'González', 'maria.gonzalez@mail.com', '1198765432', '0000003100087654321098');
GO

INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono)
VALUES (11223344, 'Carlos', 'López', 'carlos.lopez@mail.com', '1155667788');
GO

-- INSERCION EXITOSA - PROPIETARIO
DECLARE @id_pu1 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 1,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2024-01-01',
    @id_persona_unidad = @id_pu1 OUTPUT;
GO

-- INSERCION EXITOSA - INQUILINO CON FECHA FIN
DECLARE @id_pu2 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 2,
    @dni = 87654321,
    @rol = 'I',
    @fecha_inicio = '2024-06-01',
    @fecha_fin = '2025-06-01',
    @id_persona_unidad = @id_pu2 OUTPUT;
GO

-- INSERCION EXITOSA - INQUILINO SIN FECHA FIN
DECLARE @id_pu3 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 3,
    @dni = 11223344,
    @rol = 'I',
    @fecha_inicio = '2025-01-01',
    @id_persona_unidad = @id_pu3 OUTPUT;
GO

-- ERROR: UNIDAD FUNCIONAL INEXISTENTE
DECLARE @id_pu_error1 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 99999,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2024-01-01',
    @id_persona_unidad = @id_pu_error1 OUTPUT;
GO

-- ERROR: PERSONA INEXISTENTE
DECLARE @id_pu_error2 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 1,
    @dni = 99999999,
    @rol = 'P',
    @fecha_inicio = '2024-01-01',
    @id_persona_unidad = @id_pu_error2 OUTPUT;
GO

-- ERROR: ROL INVALIDO
DECLARE @id_pu_error3 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 1,
    @dni = 12345678,
    @rol = 'X',
    @fecha_inicio = '2024-01-01',
    @id_persona_unidad = @id_pu_error3 OUTPUT;
GO

-- ERROR: FECHA FIN ANTERIOR A FECHA INICIO
DECLARE @id_pu_error4 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 2,
    @dni = 11223344,
    @rol = 'I',
    @fecha_inicio = '2025-01-01',
    @fecha_fin = '2024-01-01',
    @id_persona_unidad = @id_pu_error4 OUTPUT;
GO

-- ERROR: RELACION ACTIVA YA EXISTE
DECLARE @id_pu_error5 INT;
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 1,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2025-01-01',
    @id_persona_unidad = @id_pu_error5 OUTPUT;
GO

-- MODIFICAR PERSONA UNIDAD
-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @rol = 'P',
    @fecha_inicio = '2024-01-01',
    @fecha_fin = '2025-12-31';
GO

-- ERROR: ID INVALIDO
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 99999,
    @rol = 'P',
    @fecha_inicio = '2024-01-01',
    @fecha_fin = NULL;
GO

-- ERROR: ROL INVALIDO
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @rol = 'Z',
    @fecha_inicio = '2024-01-01',
    @fecha_fin = NULL;
GO

-- ERROR: FECHA FIN ANTERIOR A FECHA INICIO
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @rol = 'P',
    @fecha_inicio = '2025-01-01',
    @fecha_fin = '2024-01-01';
GO

-- ELIMINAR PERSONA UNIDAD
-- ERROR: ID INVALIDO
EXEC Consorcio.EliminarPersonaUnidad @id_persona_unidad = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Consorcio.EliminarPersonaUnidad @id_persona_unidad = 3;
GO

-- MOSTRAR TABLA PERSONA UNIDAD
SELECT * FROM Consorcio.PersonaUnidad;
GO

