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

-------<<<<<<<TABLA ESTADO FINANCIERO>>>>>>>-------

-- PREPARACION: Crear consorcio para las pruebas
DECLARE @id_consorcio_test INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Test EF',
    @direccion = 'Calle Test 456',
    @cant_unidades_funcionales = 15,
    @m2_totales = 1500.00,
    @vencimiento1 = '2025-01-15',
    @vencimiento2 = '2025-01-15 23:59:59',
    @id_consorcio = @id_consorcio_test OUTPUT;
GO

-- INSERCION EXITOSA
DECLARE @id_estado1 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-01-31',
    @saldo_anterior = 150000.00,
    @ingreso_en_termino = 500000.00,
    @ingreso_adeudado = 50000.00,
    @ingreso_adelantado = 20000.00,
    @egresos_mes = 450000.00,
    @saldo_cierre = 270000.00,
    @id_estado = @id_estado1 OUTPUT;
GO

DECLARE @id_estado2 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-02-28',
    @saldo_anterior = 270000.00,
    @ingreso_en_termino = 550000.00,
    @ingreso_adeudado = 30000.00,
    @ingreso_adelantado = 10000.00,
    @egresos_mes = 480000.00,
    @saldo_cierre = 380000.00,
    @id_estado = @id_estado2 OUTPUT;
GO

DECLARE @id_estado3 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-03-31',
    @id_estado = @id_estado3 OUTPUT;
GO

-- ERROR: CONSORCIO INEXISTENTE
DECLARE @id_estado_error1 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 99999,
    @fecha = '2025-04-30',
    @saldo_anterior = 100000.00,
    @id_estado = @id_estado_error1 OUTPUT;
GO

-- ERROR: FECHA DUPLICADA PARA EL MISMO CONSORCIO
DECLARE @id_estado_error2 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-01-31',
    @saldo_anterior = 200000.00,
    @id_estado = @id_estado_error2 OUTPUT;
GO

-- ERROR: AÑO DE FECHA INVALIDO (MENOR A 1959)
DECLARE @id_estado_error3 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '1958-01-31',
    @saldo_anterior = 100000.00,
    @id_estado = @id_estado_error3 OUTPUT;
GO

-- ERROR: AÑO DE FECHA INVALIDO (MAYOR AL ACTUAL)
DECLARE @id_estado_error4 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2030-01-31',
    @saldo_anterior = 100000.00,
    @id_estado = @id_estado_error4 OUTPUT;
GO

-- ERROR: SALDO ANTERIOR NEGATIVO
DECLARE @id_estado_error5 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-05-31',
    @saldo_anterior = -50000.00,
    @id_estado = @id_estado_error5 OUTPUT;
GO

-- ERROR: INGRESO EN TERMINO NEGATIVO
DECLARE @id_estado_error6 INT;
EXEC Consorcio.CrearEstadoFinanciero
    @id_consorcio = 1,
    @fecha = '2025-06-30',
    @ingreso_en_termino = -100000.00,
    @id_estado = @id_estado_error6 OUTPUT;
GO

-- MODIFICAR ESTADO FINANCIERO
-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarEstadoFinanciero
    @id_estado = 1,
    @fecha = '2025-01-31',
    @saldo_anterior = 160000.00,
    @ingreso_en_termino = 520000.00,
    @ingreso_adeudado = 55000.00,
    @ingreso_adelantado = 25000.00,
    @egresos_mes = 460000.00,
    @saldo_cierre = 300000.00;
GO

-- ERROR: ID INVALIDO
EXEC Consorcio.ModificarEstadoFinanciero
    @id_estado = 99999,
    @fecha = '2025-01-31',
    @saldo_anterior = 100000.00,
    @ingreso_en_termino = 500000.00,
    @ingreso_adeudado = 0,
    @ingreso_adelantado = 0,
    @egresos_mes = 400000.00,
    @saldo_cierre = 200000.00;
GO

-- ERROR: FECHA DUPLICADA CON OTRO ESTADO
EXEC Consorcio.ModificarEstadoFinanciero
    @id_estado = 1,
    @fecha = '2025-02-28',
    @saldo_anterior = 100000.00,
    @ingreso_en_termino = 500000.00,
    @ingreso_adeudado = 0,
    @ingreso_adelantado = 0,
    @egresos_mes = 400000.00,
    @saldo_cierre = 200000.00;
GO

-- ERROR: FECHA CON AÑO INVALIDO
EXEC Consorcio.ModificarEstadoFinanciero
    @id_estado = 1,
    @fecha = '1950-01-31',
    @saldo_anterior = 100000.00,
    @ingreso_en_termino = 500000.00,
    @ingreso_adeudado = 0,
    @ingreso_adelantado = 0,
    @egresos_mes = 400000.00,
    @saldo_cierre = 200000.00;
GO

-- ERROR: EGRESOS NEGATIVOS
EXEC Consorcio.ModificarEstadoFinanciero
    @id_estado = 1,
    @fecha = '2025-01-31',
    @saldo_anterior = 100000.00,
    @ingreso_en_termino = 500000.00,
    @ingreso_adeudado = 0,
    @ingreso_adelantado = 0,
    @egresos_mes = -50000.00,
    @saldo_cierre = 200000.00;
GO

-- ELIMINAR ESTADO FINANCIERO
-- ERROR: ID INVALIDO
EXEC Consorcio.EliminarEstadoFinanciero @id_estado = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Consorcio.EliminarEstadoFinanciero @id_estado = 3;
GO

-- MOSTRAR TABLA ESTADO FINANCIERO
SELECT * FROM Consorcio.EstadoFinanciero;
GO
