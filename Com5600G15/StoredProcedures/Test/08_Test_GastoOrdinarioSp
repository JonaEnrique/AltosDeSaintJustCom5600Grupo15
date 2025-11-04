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

-------<<<<<<<TABLA GASTO ORDINARIO>>>>>>>-------

-- PREPARACION: Crear consorcio y proveedor para las pruebas
DECLARE @id_consorcio_test INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Test GO',
    @direccion = 'Calle Test 456',
    @cant_unidades_funcionales = 15,
    @m2_totales = 1800.00,
    @vencimiento1 = '2025-02-10',
    @vencimiento2 = '2025-02-10 23:59:59',
    @id_consorcio = @id_consorcio_test OUTPUT;
GO

DECLARE @id_proveedor1 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Electricidad SA',
    @cuenta = '12345678',
    @tipo = 'Servicios',
    @id_proveedor = @id_proveedor1 OUTPUT;
GO

DECLARE @id_proveedor2 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Gas Natural',
    @cuenta = '87654321',
    @tipo = 'Servicios',
    @id_proveedor = @id_proveedor2 OUTPUT;
GO

-- INSERCION EXITOSA
DECLARE @id_gasto1 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2025-01-15',
    @importe = 45000.50,
    @nro_factura = 1001,
    @id_proveedor = 1,
    @descripcion = 'Consumo energía eléctrica enero',
    @id_gasto = @id_gasto1 OUTPUT;
GO

DECLARE @id_gasto2 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Gas',
    @fecha = '2025-01-20',
    @importe = 32000.00,
    @nro_factura = 2001,
    @id_proveedor = 2,
    @descripcion = 'Consumo gas natural enero',
    @id_gasto = @id_gasto2 OUTPUT;
GO

DECLARE @id_gasto3 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Mantenimiento',
    @fecha = '2025-02-01',
    @importe = 15000.00,
    @nro_factura = 1002,
    @id_proveedor = 1,
    @descripcion = 'Mantenimiento ascensor',
    @id_gasto = @id_gasto3 OUTPUT;
GO

-- ERROR: CONSORCIO INEXISTENTE
DECLARE @id_gasto_error1 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 99999,
    @tipo_gasto = 'Luz',
    @fecha = '2025-01-15',
    @importe = 10000.00,
    @nro_factura = 3001,
    @id_proveedor = 1,
    @descripcion = 'Test error',
    @id_gasto = @id_gasto_error1 OUTPUT;
GO

-- ERROR: PROVEEDOR INEXISTENTE
DECLARE @id_gasto_error2 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Agua',
    @fecha = '2025-01-15',
    @importe = 10000.00,
    @nro_factura = 4001,
    @id_proveedor = 99999,
    @descripcion = 'Test error',
    @id_gasto = @id_gasto_error2 OUTPUT;
GO

-- ERROR: NUMERO DE FACTURA DUPLICADO PARA EL MISMO PROVEEDOR
DECLARE @id_gasto_error3 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2025-02-15',
    @importe = 50000.00,
    @nro_factura = 1001,
    @id_proveedor = 1,
    @descripcion = 'Duplicado',
    @id_gasto = @id_gasto_error3 OUTPUT;
GO

-- ERROR: IMPORTE <= 0
DECLARE @id_gasto_error4 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Gas',
    @fecha = '2025-01-15',
    @importe = -5000.00,
    @nro_factura = 5001,
    @id_proveedor = 2,
    @descripcion = 'Importe negativo',
    @id_gasto = @id_gasto_error4 OUTPUT;
GO

-- ERROR: FECHA AÑO <= 1958
DECLARE @id_gasto_error5 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Agua',
    @fecha = '1950-01-15',
    @importe = 10000.00,
    @nro_factura = 6001,
    @id_proveedor = 1,
    @descripcion = 'Fecha inválida',
    @id_gasto = @id_gasto_error5 OUTPUT;
GO

-- ERROR: FECHA AÑO FUTURO
DECLARE @id_gasto_error6 INT;
EXEC Pago.CrearGastoOrdinario
    @id_consorcio = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2030-01-15',
    @importe = 10000.00,
    @nro_factura = 7001,
    @id_proveedor = 1,
    @descripcion = 'Fecha futura',
    @id_gasto = @id_gasto_error6 OUTPUT;
GO

-- MODIFICAR GASTO ORDINARIO
-- MODIFICACION EXITOSA
EXEC Pago.ModificarGastoOrdinario
    @id_gasto = 1,
    @tipo_gasto = 'Luz Modificado',
    @fecha = '2025-01-16',
    @importe = 48000.00,
    @nro_factura = 1001,
    @id_proveedor = 1,
    @descripcion = 'Consumo modificado enero';
GO

-- ERROR: ID GASTO INVALIDO
EXEC Pago.ModificarGastoOrdinario
    @id_gasto = 99999,
    @tipo_gasto = 'Gas',
    @fecha = '2025-01-15',
    @importe = 30000.00,
    @nro_factura = 8001,
    @id_proveedor = 2,
    @descripcion = 'No existe';
GO

-- ERROR: PROVEEDOR INEXISTENTE
EXEC Pago.ModificarGastoOrdinario
    @id_gasto = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2025-01-15',
    @importe = 45000.00,
    @nro_factura = 1001,
    @id_proveedor = 99999,
    @descripcion = 'Proveedor inválido';
GO

-- ERROR: NUMERO FACTURA DUPLICADO CON OTRO GASTO DEL MISMO PROVEEDOR
EXEC Pago.ModificarGastoOrdinario
    @id_gasto = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2025-01-15',
    @importe = 45000.00,
    @nro_factura = 1002,
    @id_proveedor = 1,
    @descripcion = 'Numero duplicado';
GO

-- ERROR: IMPORTE <= 0
EXEC Pago.ModificarGastoOrdinario
    @id_gasto = 1,
    @tipo_gasto = 'Luz',
    @fecha = '2025-01-15',
    @importe = 0,
    @nro_factura = 1001,
    @id_proveedor = 1,
    @descripcion = 'Importe cero';
GO

-- ELIMINAR GASTO ORDINARIO
-- ERROR: ID INVALIDO
EXEC Pago.EliminarGastoOrdinario @id_gasto = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Pago.EliminarGastoOrdinario @id_gasto = 3;
GO

-- MOSTRAR TABLA GASTO ORDINARIO
SELECT * FROM Pago.GastoOrdinario;
GO
