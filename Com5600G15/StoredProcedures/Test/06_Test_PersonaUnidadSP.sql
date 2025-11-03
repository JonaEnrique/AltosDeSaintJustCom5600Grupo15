/*
    ---------------------------------------------------------------------
    -Fecha: 21/11/2025
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

--PREPARACION (Crear registros en Persona Y UnidadFuncional)
EXEC Consorcio.CrearPersona 
    @dni = 12345678,
    @nombre = N'Juan',
    @apellido = N'Perez',
    @mail = N'juan.perez@email.com',
    @telefono = '1111-1111',
    @cbu_cvu = '0000000000000000000001';
GO

EXEC Consorcio.CrearPersona 
    @dni = 23456789,
    @nombre = N'Ana',
    @apellido = N'Garcia',
    @mail = N'ana.garcia@email.com',
    @telefono = '2222-2222',
    @cbu_cvu = '0000000000000000000002';
GO

DECLARE @id_unidad1 INT;
DECLARE @id_unidad2 INT;
DECLARE @id_unidad3 INT;
DECLARE @id_consorcio INT;

EXEC Consorcio.CrearConsorcio
    @nombre = 'Consorcio Central',
    @direccion = 'Av. Siempreviva 742',
    @cant_unidades_funcionales = 3,
    @m2_totales = 350.50,
    @vencimiento1 = '2025-12-01',
    @vencimiento2 = '2025-12-15',
    @id_consorcio = @id_consorcio OUTPUT;


EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = @id_consorcio,
    @piso = '1',
    @departamento = 'A',
    @coeficiente = 10.0,
    @m2_unidad = 70.00,
    @m2_baulera = 5.00,
    @m2_cochera = 12.00,
    @precio_cochera = 15000.00,
    @precio_baulera = 5000.00,
    @id_unidad = @id_unidad1 OUTPUT;

EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = @id_consorcio,
    @piso = '2',
    @departamento = 'B',
    @coeficiente = 9.5,
    @m2_unidad = 68.00,
    @m2_baulera = 4.00,
    @m2_cochera = 10.00,
    @precio_cochera = 14000.00,
    @precio_baulera = 4500.00,
    @id_unidad = @id_unidad2 OUTPUT;

EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = @id_consorcio,
    @piso = '3',
    @departamento = 'C',
    @coeficiente = 8.8,
    @m2_unidad = 65.00,
    @m2_baulera = 3.00,
    @m2_cochera = 9.00,
    @precio_cochera = 13000.00,
    @precio_baulera = 4000.00,
    @id_unidad = @id_unidad3 OUTPUT;

-- INSERCION 

-- INSERCION EXITOSA
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = @id_unidad1,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2025-11-01',
    @fecha_fin = NULL;

--INSERCION EXITOSA (OTRO REGISTRO)
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = @id_unidad2,
    @dni = 23456789,
    @rol = 'I',
    @fecha_inicio = '2025-10-15',
    @fecha_fin = '2025-11-21';

--ERROR PERSONA INEXISTENTE
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = @id_unidad1,
    @dni = 99999999,
    @rol = 'P',
    @fecha_inicio = '2025-11-01',
    @fecha_fin = NULL;

--ERROR UNIDAD FUNCIONAL INEXISTENTE
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = 999,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2025-11-01',
    @fecha_fin = '2026-12-02';

--ERROR ROL INVALIDO
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = @id_unidad1,
    @dni = 12345678,
    @rol = 'Z',
    @fecha_inicio = '2025-11-01',
    @fecha_fin = NULL;

--ERROR: FECHA FIN ANTERIOR A FECHA INICIO
EXEC Consorcio.CrearPersonaUnidad
    @id_unidad = @id_unidad1,
    @dni = 12345678,
    @rol = 'P',
    @fecha_inicio = '2025-11-01',
    @fecha_fin = '2025-10-01';

--MODIFICACION
--MODIFICACION EXITOSA (CAMBIO DE ROL)
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @rol = 'I';

--MODIFICACION EXITOSA (AGREGAR FECHA FIN)
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @fecha_fin = '2025-12-31';

--MODIFICACIÓN EXITOSA (CAMBIO DE UNIDAD)
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 2,
    @id_unidad = @id_unidad3;

--ERROR ID_PERSONA_UNIDAD INEXISTENTE
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 999,
    @rol = 'I';

--ERROR ROL INVALIDO
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @rol = 'X';

--ERROR PERSONA INEXISTENTE (DNI)
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @dni = 99999999;

--ERROR UNIDAD FUNCIONAL INEXISTENTE
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @id_unidad = 888;

--MODIFICACION EXITOSA (QUITAR FECHA FIN - DEJAR NULL)
EXEC Consorcio.ModificarPersonaUnidad
    @id_persona_unidad = 1,
    @fecha_fin = NULL;

--ELIMINACION

--ELIMINACION EXITOSA
EXEC Consorcio.EliminarPersonaUnidad
    @id_persona_unidad = 2;

--ERROR ID_PERSONA_UNIDAD INEXISTENTE
EXEC Consorcio.EliminarPersonaUnidad
    @id_persona_unidad = 999;