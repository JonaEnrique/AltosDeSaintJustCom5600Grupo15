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

-------<<<<<<<TABLA PAGO ASOCIADO>>>>>>>-------

-- PREPARACION: Crear persona con CBU/CVU
INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cbu_cvu)
VALUES (12345678, 'Juan', 'Perez', 'juan.perez@mail.com', '1145678901', '0000003100010123456789');
GO

INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cbu_cvu)
VALUES (87654321, 'Maria', 'Gomez', 'maria.gomez@mail.com', '1156789012', '0000003100010987654321');
GO

-- INSERCION EXITOSA
DECLARE @id_pago1 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100001,
    @importe = 50000.00,
    @id_expensa = @id_pago1 OUTPUT;
GO

DECLARE @id_pago2 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 2,
    @fecha = '2025-01-20',
    @cvu_cbu = '0000003100010987654321',
    @codigo_cuenta = 100002,
    @importe = 75000.00,
    @id_expensa = @id_pago2 OUTPUT;
GO

DECLARE @id_pago3 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-02-10',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100003,
    @importe = 52000.00,
    @id_expensa = @id_pago3 OUTPUT;
GO

-- ERROR: UNIDAD FUNCIONAL INEXISTENTE
DECLARE @id_pago_error1 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 99999,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100004,
    @importe = 50000.00,
    @id_expensa = @id_pago_error1 OUTPUT;
GO

-- ERROR: CBU/CVU INEXISTENTE
DECLARE @id_pago_error2 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '9999999999999999999999',
    @codigo_cuenta = 100005,
    @importe = 50000.00,
    @id_expensa = @id_pago_error2 OUTPUT;
GO

-- ERROR: IMPORTE <= 0
DECLARE @id_pago_error3 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100006,
    @importe = 0,
    @id_expensa = @id_pago_error3 OUTPUT;
GO

-- ERROR: FECHA FUTURA
DECLARE @id_pago_error4 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2026-12-31',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100007,
    @importe = 50000.00,
    @id_expensa = @id_pago_error4 OUTPUT;
GO

-- ERROR: CODIGO CUENTA <= 0
DECLARE @id_pago_error5 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = -100,
    @importe = 50000.00,
    @id_expensa = @id_pago_error5 OUTPUT;
GO

-- MODIFICAR PAGO ASOCIADO
-- MODIFICACION EXITOSA
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 1,
    @fecha = '2025-01-16',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100001,
    @importe = 55000.00;
GO

-- ERROR: ID EXPENSA INVALIDO
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 99999,
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100001,
    @importe = 50000.00;
GO

-- ERROR: UNIDAD INEXISTENTE
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 99999,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100001,
    @importe = 50000.00;
GO

-- ERROR: IMPORTE <= 0
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100010123456789',
    @codigo_cuenta = 100001,
    @importe = -1000.00;
GO

-- ELIMINAR PAGO ASOCIADO
-- ERROR: ID INVALIDO
EXEC Pago.EliminarPagoAsociado @id_expensa = 99999;
GO

-- ELIMINACION EXITOSA
EXEC Pago.EliminarPagoAsociado @id_expensa = 3;
GO

-- MOSTRAR TABLA PAGO ASOCIADO
SELECT * FROM Pago.PagoAsociado;
GO