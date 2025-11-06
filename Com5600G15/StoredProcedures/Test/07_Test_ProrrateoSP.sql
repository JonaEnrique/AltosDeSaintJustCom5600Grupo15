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

-------<<<<<<<TABLA PRORRATEO>>>>>>>-------

--PREPARACION (creamos registros en consorcio y unidadFuncional)

DECLARE @id_consorcio INT;
DECLARE @id_unidad1 INT;
DECLARE @id_unidad2 INT;

EXEC Consorcio.CrearConsorcio
    @nombre = 'Consorcio Prueba Prorrateo',
    @direccion = 'Av. Test 123',
    @cant_unidades_funcionales = 2,
    @m2_totales = 500.00,
    @vencimiento1 = '2025-11-01',
    @vencimiento2 = '2025-11-15',
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

-- INSERCION

--INSERCION EXITOSA
DECLARE @id_prorrateo1 INT;
DECLARE @id_prorrateo2 INT;
DECLARE @id_prorrateo3 INT;

EXEC Pago.CrearProrrateo
    @id_unidad = @id_unidad1,
    @fecha = '2025-11-01',
    @porcentaje_m2 = 50.000,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Perez',
    @precio_cocheras = 10000.00,
    @precio_bauleras = 5000.00,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = 0,
    @expensas_ordinarias = 20000.00,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 35000.00,
    @id_prorrateo = @id_prorrateo1 OUTPUT;

--ERROR PRORRATEO YA EXISTE PARA LA FECHA Y UNIDAD INDICADAS
EXEC Pago.CrearProrrateo
    @id_unidad = @id_unidad1,
    @fecha = '2025-11-01',
    @porcentaje_m2 = 50.000,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Perez',
    @precio_cocheras = 10000.00,
    @precio_bauleras = 5000.00,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = 0,
    @expensas_ordinarias = 20000.00,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 35000.00,
    @id_prorrateo = @id_prorrateo2 OUTPUT;

--ERROR VALOR NEGATIVO
EXEC Pago.CrearProrrateo
    @id_unidad = @id_unidad2,
    @fecha = '2025-11-01',
    @porcentaje_m2 = 50.000,
    @piso = '1',
    @depto = 'B',
    @nombre_propietario = 'Maria Gomez',
    @precio_cocheras = -5000.00,
    @precio_bauleras = 0,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = 0,
    @expensas_ordinarias = 20000.00,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 20000.00,
    @id_prorrateo = @id_prorrateo3 OUTPUT;

--MODIFICACION

--MODIFICACION EXITOSA
EXEC Pago.ModificarProrrateo
    @id_prorrateo = @id_prorrateo1,
    @precio_cocheras = 8000.00,
    @precio_bauleras = 4000.00,
    @expensas_extraordinarias = 3000.00;

--ERROR ID INEXISTENTE
EXEC Pago.ModificarProrrateo
    @id_prorrateo = 999,
    @precio_cocheras = 5000.00;

--ERROR: VALOR NEGATIVO
EXEC Pago.ModificarProrrateo
    @id_prorrateo = @id_prorrateo1,
    @expensas_ordinarias = -20000.00;

--ELIMINACION

--ELIMINACION EXITOSA
EXEC Pago.EliminarProrrateo @id_prorrateo = @id_prorrateo1;

--ERROR ID INEXISTENTE
EXEC Pago.EliminarProrrateo @id_prorrateo = 999;

GO