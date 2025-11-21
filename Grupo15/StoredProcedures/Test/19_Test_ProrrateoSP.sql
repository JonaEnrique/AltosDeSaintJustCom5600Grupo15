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

-- INSERCION EXITOSA
DECLARE @id_prorr1 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @porcentaje_m2 = 5.250,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Pérez',
    @precio_cocheras = 15000.00,
    @precio_bauleras = 5000.00,
    @saldo_anterior_abonado = 0.00,
    @pagos_recibidos = 50000.00,
    @deudas = 0.00,
    @intereses = 0.00,
    @expensas_ordinarias = 45000.00,
    @expensas_extraordinarias = 5000.00,
    @total_a_pagar = 50000.00,
    @id_prorrateo = @id_prorr1 OUTPUT;
GO

DECLARE @id_prorr2 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 2,
    @fecha = '2025-01-15',
    @porcentaje_m2 = 7.500,
    @piso = '2',
    @depto = 'B',
    @nombre_propietario = 'María González',
    @precio_cocheras = 20000.00,
    @precio_bauleras = 7000.00,
    @deudas = 10000.00,
    @intereses = 500.00,
    @expensas_ordinarias = 60000.00,
    @total_a_pagar = 70500.00,
    @id_prorrateo = @id_prorr2 OUTPUT;
GO

-- ERROR: UNIDAD FUNCIONAL INEXISTENTE
DECLARE @id_prorr_error1 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 99999,
    @fecha = '2025-01-15',
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @total_a_pagar = 50000.00,
    @id_prorrateo = @id_prorr_error1 OUTPUT;
GO

-- ERROR: PRORRATEO DUPLICADO (MISMA UNIDAD Y FECHA)
DECLARE @id_prorr_error2 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @porcentaje_m2 = 6.000,
    @piso = '1',
    @depto = 'A',
    @total_a_pagar = 60000.00,
    @id_prorrateo = @id_prorr_error2 OUTPUT;
GO

-- ERROR: PORCENTAJE_M2 <= 0
DECLARE @id_prorr_error3 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-03-15',
    @porcentaje_m2 = 0,
    @piso = '1',
    @depto = 'A',
    @total_a_pagar = 50000.00,
    @id_prorrateo = @id_prorr_error3 OUTPUT;
GO

-- ERROR: SALDO_ANTERIOR_ABONADO NEGATIVO
DECLARE @id_prorr_error4 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-03-15',
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @saldo_anterior_abonado = -1000.00,
    @total_a_pagar = 50000.00,
    @id_prorrateo = @id_prorr_error4 OUTPUT;
GO

-- ERROR: DEUDAS NEGATIVAS
DECLARE @id_prorr_error5 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-03-15',
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @deudas = -5000.00,
    @total_a_pagar = 50000.00,
    @id_prorrateo = @id_prorr_error5 OUTPUT;
GO

-- ERROR: TOTAL_A_PAGAR NEGATIVO
DECLARE @id_prorr_error6 INT;
EXEC Pago.CrearProrrateo
    @id_unidad = 1,
    @fecha = '2025-03-15',
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @total_a_pagar = -50000.00,
    @id_prorrateo = @id_prorr_error6 OUTPUT;
GO

-- MODIFICAR PRORRATEO
-- MODIFICACION EXITOSA
EXEC Pago.ModificarProrrateo
    @id_prorrateo = 1,
    @porcentaje_m2 = 5.500,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Pérez',
    @precio_cocheras = 18000.00,
    @precio_bauleras = 6000.00,
    @saldo_anterior_abonado = 0.00,
    @pagos_recibidos = 55000.00,
    @deudas = 0.00,
    @intereses = 0.00,
    @expensas_ordinarias = 48000.00,
    @expensas_extraordinarias = 7000.00,
    @total_a_pagar = 55000.00;
GO

-- ERROR: ID INVALIDO
EXEC Pago.ModificarProrrateo
    @id_prorrateo = 99999,
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Nombre',
    @precio_cocheras = 0,
    @precio_bauleras = 0,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = 0,
    @expensas_ordinarias = 0,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 0;
GO

-- ERROR: PORCENTAJE_M2 <= 0
EXEC Pago.ModificarProrrateo
    @id_prorrateo = 1,
    @porcentaje_m2 = -1.000,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Pérez',
    @precio_cocheras = 0,
    @precio_bauleras = 0,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = 0,
    @expensas_ordinarias = 0,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 0;
GO

-- ERROR: INTERESES NEGATIVOS
EXEC Pago.ModificarProrrateo
    @id_prorrateo = 1,
    @porcentaje_m2 = 5.000,
    @piso = '1',
    @depto = 'A',
    @nombre_propietario = 'Juan Pérez',
    @precio_cocheras = 0,
    @precio_bauleras = 0,
    @saldo_anterior_abonado = 0,
    @pagos_recibidos = 0,
    @deudas = 0,
    @intereses = -100.00,
    @expensas_ordinarias = 0,
    @expensas_extraordinarias = 0,
    @total_a_pagar = 0;
GO

-- ELIMINAR PRORRATEO
-- ERROR: ID INVALIDO
EXEC Pago.EliminarProrrateo @id_prorrateo = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Pago.EliminarProrrateo @id_prorrateo = 2;
GO

-- MOSTRAR TABLA PRORRATEO
SELECT * FROM Pago.Prorrateo;
GO

