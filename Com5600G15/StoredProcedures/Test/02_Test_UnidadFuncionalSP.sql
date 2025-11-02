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

-------<<<<<<<TABLA UNIDAD FUNCIONAL>>>>>>>-------

-- PREPARACION: Crear consorcio para las pruebas
DECLARE @id_consorcio_test INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Test UF',
    @direccion = 'Calle Test 123',
    @cant_unidades_funcionales = 20,
    @m2_totales = 2000.00,
    @vencimiento1 = '2025-01-10',
    @vencimiento2 = '2025-01-10 23:59:59',
    @id_consorcio = @id_consorcio_test OUTPUT;
GO

-- INSERCION EXITOSA
DECLARE @id_uf1 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '1',
    @departamento = 'A',
    @coeficiente = 1.5,
    @m2_unidad = 85.50,
    @m2_baulera = 5.00,
    @m2_cochera = 12.00,
    @precio_cochera = 15000.00,
    @precio_baulera = 5000.00,
    @id_unidad = @id_uf1 OUTPUT;
GO

DECLARE @id_uf2 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '2',
    @departamento = 'B',
    @coeficiente = 2.0,
    @m2_unidad = 120.00,
    @m2_baulera = 8.00,
    @m2_cochera = 15.00,
    @precio_cochera = 20000.00,
    @precio_baulera = 7000.00,
    @id_unidad = @id_uf2 OUTPUT;
GO

DECLARE @id_uf3 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = 'PB',
    @departamento = 'C',
    @coeficiente = 1.2,
    @m2_unidad = 65.00,
    @id_unidad = @id_uf3 OUTPUT;
GO

-- ERROR: CONSORCIO INEXISTENTE
DECLARE @id_uf_error1 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 99999,
    @piso = '3',
    @departamento = 'A',
    @coeficiente = 1.5,
    @m2_unidad = 80.00,
    @id_unidad = @id_uf_error1 OUTPUT;
GO

-- ERROR: UNIDAD DUPLICADA (MISMO PISO Y DEPTO)
DECLARE @id_uf_error2 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '1',
    @departamento = 'A',
    @coeficiente = 1.8,
    @m2_unidad = 90.00,
    @id_unidad = @id_uf_error2 OUTPUT;
GO

-- ERROR: COEFICIENTE <= 0
DECLARE @id_uf_error3 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '4',
    @departamento = 'D',
    @coeficiente = 0,
    @m2_unidad = 75.00,
    @id_unidad = @id_uf_error3 OUTPUT;
GO

-- ERROR: M2_UNIDAD <= 0
DECLARE @id_uf_error4 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '5',
    @departamento = 'E',
    @coeficiente = 1.5,
    @m2_unidad = -10.00,
    @id_unidad = @id_uf_error4 OUTPUT;
GO

-- ERROR: PRECIO COCHERA NEGATIVO
DECLARE @id_uf_error5 INT;
EXEC Consorcio.CrearUnidadFuncional
    @id_consorcio = 1,
    @piso = '6',
    @departamento = 'F',
    @coeficiente = 1.5,
    @m2_unidad = 80.00,
    @precio_cochera = -5000.00,
    @id_unidad = @id_uf_error5 OUTPUT;
GO

-- MODIFICAR UNIDAD FUNCIONAL
-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarUnidadFuncional
    @id_unidad = 1,
    @piso = '1',
    @departamento = 'A',
    @coeficiente = 1.8,
    @m2_unidad = 90.00,
    @m2_baulera = 6.00,
    @m2_cochera = 13.00,
    @precio_cochera = 18000.00,
    @precio_baulera = 6000.00;
GO

-- ERROR: ID INVALIDO
EXEC Consorcio.ModificarUnidadFuncional
    @id_unidad = 99999,
    @piso = '1',
    @departamento = 'Z',
    @coeficiente = 1.5,
    @m2_unidad = 80.00,
    @m2_baulera = 0,
    @m2_cochera = 0,
    @precio_cochera = 0,
    @precio_baulera = 0;
GO

-- ERROR: PISO Y DEPTO YA EXISTEN EN OTRA UNIDAD
EXEC Consorcio.ModificarUnidadFuncional
    @id_unidad = 1,
    @piso = '2',
    @departamento = 'B',
    @coeficiente = 1.5,
    @m2_unidad = 80.00,
    @m2_baulera = 0,
    @m2_cochera = 0,
    @precio_cochera = 0,
    @precio_baulera = 0;
GO

-- ERROR: COEFICIENTE <= 0
EXEC Consorcio.ModificarUnidadFuncional
    @id_unidad = 1,
    @piso = '1',
    @departamento = 'A',
    @coeficiente = -1.5,
    @m2_unidad = 80.00,
    @m2_baulera = 0,
    @m2_cochera = 0,
    @precio_cochera = 0,
    @precio_baulera = 0;
GO

-- ELIMINAR UNIDAD FUNCIONAL
-- ERROR: ID INVALIDO
EXEC Consorcio.EliminarUnidadFuncional @id_unidad = 99999;
GO

-- ELIMINACION EXITOSA (SIN RELACIONES)
EXEC Consorcio.EliminarUnidadFuncional @id_unidad = 3;
GO

-- MOSTRAR TABLA UNIDAD FUNCIONAL
SELECT * FROM Consorcio.UnidadFuncional;
GO
