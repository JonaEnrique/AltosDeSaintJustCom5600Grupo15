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

-------<<<<<<<TABLA GASTO EXTRAORDINARIO>>>>>>>-------

-- PREPARACION: Crear consorcio para las pruebas
DECLARE @id_consorcio_test INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Test GE',
    @direccion = 'Calle Test 456',
    @cant_unidades_funcionales = 15,
    @m2_totales = 1500.00,
    @vencimiento1 = '2025-02-10',
    @vencimiento2 = '2025-02-10 23:59:59',
    @id_consorcio = @id_consorcio_test OUTPUT;
GO

-- INSERCION EXITOSA - Gasto sin cuotas
DECLARE @id_ge1 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Reparación de ascensor',
    @importe = 150000.00,
    @fecha = '2025-01-15',
    @pago_cuotas = 0,
    @id_gasto = @id_ge1 OUTPUT;
GO

-- INSERCION EXITOSA - Gasto con cuotas
DECLARE @id_ge2 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Pintura de fachada - Cuota 1',
    @importe = 50000.00,
    @fecha = '2025-02-01',
    @pago_cuotas = 1,
    @nro_cuota = 1,
    @total_cuotas = 6,
    @id_gasto = @id_ge2 OUTPUT;
GO

DECLARE @id_ge3 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Impermeabilización de terraza',
    @importe = 85000.00,
    @fecha = '2025-03-10',
    @pago_cuotas = 0,
    @id_gasto = @id_ge3 OUTPUT;
GO

-- ERROR: CONSORCIO INEXISTENTE
DECLARE @id_ge_error1 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 99999,
    @detalle = 'Gasto de prueba',
    @importe = 10000.00,
    @fecha = '2025-01-01',
    @id_gasto = @id_ge_error1 OUTPUT;
GO

-- ERROR: IMPORTE <= 0
DECLARE @id_ge_error2 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Gasto inválido',
    @importe = 0,
    @fecha = '2025-01-01',
    @id_gasto = @id_ge_error2 OUTPUT;
GO

-- ERROR: IMPORTE NEGATIVO
DECLARE @id_ge_error3 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Gasto inválido',
    @importe = -5000.00,
    @fecha = '2025-01-01',
    @id_gasto = @id_ge_error3 OUTPUT;
GO

-- ERROR: PAGO EN CUOTAS SIN NRO_CUOTA
DECLARE @id_ge_error4 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Gasto con cuotas incompleto',
    @importe = 20000.00,
    @fecha = '2025-01-01',
    @pago_cuotas = 1,
    @total_cuotas = 3,
    @id_gasto = @id_ge_error4 OUTPUT;
GO

-- ERROR: NRO_CUOTA MAYOR A TOTAL_CUOTAS
DECLARE @id_ge_error5 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Gasto con cuotas inválidas',
    @importe = 20000.00,
    @fecha = '2025-01-01',
    @pago_cuotas = 1,
    @nro_cuota = 8,
    @total_cuotas = 5,
    @id_gasto = @id_ge_error5 OUTPUT;
GO

-- ERROR: NRO_CUOTA <= 0
DECLARE @id_ge_error6 INT;
EXEC Pago.CrearGastoExtraordinario
    @id_consorcio = 1,
    @detalle = 'Gasto con nro cuota inválido',
    @importe = 20000.00,
    @fecha = '2025-01-01',
    @pago_cuotas = 1,
    @nro_cuota = 0,
    @total_cuotas = 5,
    @id_gasto = @id_ge_error6 OUTPUT;
GO

-- MODIFICAR GASTO EXTRAORDINARIO
-- MODIFICACION EXITOSA
EXEC Pago.ModificarGastoExtraordinario
    @id_gasto = 1,
    @detalle = 'Reparación de ascensor - ACTUALIZADO',
    @importe = 175000.00,
    @fecha = '2025-01-20',
    @pago_cuotas = 0;
GO

-- MODIFICACION EXITOSA - Cambiar a pago con cuotas
EXEC Pago.ModificarGastoExtraordinario
    @id_gasto = 3,
    @detalle = 'Impermeabilización de terraza - En cuotas',
    @importe = 85000.00,
    @fecha = '2025-03-10',
    @pago_cuotas = 1,
    @nro_cuota = 1,
    @total_cuotas = 4;
GO

-- ERROR: ID INVALIDO
EXEC Pago.ModificarGastoExtraordinario
    @id_gasto = 99999,
    @detalle = 'Gasto inexistente',
    @importe = 10000.00,
    @fecha = '2025-01-01',
    @pago_cuotas = 0;
GO

-- ERROR: IMPORTE <= 0
EXEC Pago.ModificarGastoExtraordinario
    @id_gasto = 1,
    @detalle = 'Gasto con importe inválido',
    @importe = -1000.00,
    @fecha = '2025-01-01',
    @pago_cuotas = 0;
GO

-- ERROR: NRO_CUOTA MAYOR A TOTAL_CUOTAS
EXEC Pago.ModificarGastoExtraordinario
    @id_gasto = 2,
    @detalle = 'Gasto con cuotas inválidas',
    @importe = 50000.00,
    @fecha = '2025-02-01',
    @pago_cuotas = 1,
    @nro_cuota = 10,
    @total_cuotas = 6;
GO

-- ELIMINAR GASTO EXTRAORDINARIO
-- ERROR: ID INVALIDO
EXEC Pago.EliminarGastoExtraordinario @id_gasto = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Pago.EliminarGastoExtraordinario @id_gasto = 3;
GO

-- MOSTRAR TABLA GASTO EXTRAORDINARIO
SELECT * FROM Pago.GastoExtraordinario;
GO
