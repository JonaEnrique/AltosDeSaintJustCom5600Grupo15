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

-- PREPARACION: Asegurar que existan datos necesarios
-- Persona con CVU/CBU
INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cvu_cbu)
VALUES (45678901, 'Ana', 'Martínez', 'ana.martinez@mail.com', '1144556677', '0000003100045678901234');
GO

INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cvu_cbu)
VALUES (56789012, 'Luis', 'Fernández', 'luis.fernandez@mail.com', '1155667788', '0000003100056789012345');
GO

-- INSERCION EXITOSA - PAGO ASOCIADO A UNIDAD Y PERSONA
DECLARE @id_pago1 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '0000003100045678901234',
    @importe = 50000.00,
    @id_expensa = @id_pago1 OUTPUT;
GO

-- INSERCION EXITOSA - PAGO ASOCIADO SOLO A UNIDAD
DECLARE @id_pago2 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 2,
    @fecha = '2025-01-20',
    @importe = 75000.00,
    @id_expensa = @id_pago2 OUTPUT;
GO

-- INSERCION EXITOSA - PAGO NO ASOCIADO (NULL en ambos)
DECLARE @id_pago3 INT;
EXEC Pago.CrearPagoAsociado
    @fecha = '2025-01-25',
    @importe = 30000.00,
    @id_expensa = @id_pago3 OUTPUT;
GO

-- INSERCION EXITOSA - PAGO ASOCIADO SOLO A PERSONA
DECLARE @id_pago4 INT;
EXEC Pago.CrearPagoAsociado
    @fecha = '2025-02-01',
    @cvu_cbu = '0000003100056789012345',
    @importe = 45000.00,
    @id_expensa = @id_pago4 OUTPUT;
GO

-- ERROR: UNIDAD FUNCIONAL INEXISTENTE
DECLARE @id_pago_error1 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 99999,
    @fecha = '2025-01-15',
    @importe = 50000.00,
    @id_expensa = @id_pago_error1 OUTPUT;
GO

-- ERROR: CVU/CBU INEXISTENTE
DECLARE @id_pago_error2 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '9999999999999999999999',
    @importe = 50000.00,
    @id_expensa = @id_pago_error2 OUTPUT;
GO

-- ERROR: IMPORTE <= 0
DECLARE @id_pago_error3 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @importe = 0,
    @id_expensa = @id_pago_error3 OUTPUT;
GO

-- ERROR: IMPORTE NEGATIVO
DECLARE @id_pago_error4 INT;
EXEC Pago.CrearPagoAsociado
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @importe = -10000.00,
    @id_expensa = @id_pago_error4 OUTPUT;
GO

-- MODIFICAR PAGO ASOCIADO
-- MODIFICACION EXITOSA
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 1,
    @fecha = '2025-01-16',
    @cvu_cbu = '0000003100045678901234',
    @importe = 55000.00;
GO

-- ERROR: ID INVALIDO
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 99999,
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @importe = 50000.00;
GO

-- ERROR: UNIDAD FUNCIONAL INEXISTENTE
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 99999,
    @fecha = '2025-01-15',
    @importe = 50000.00;
GO

-- ERROR: CVU/CBU INEXISTENTE
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @cvu_cbu = '9999999999999999999999',
    @importe = 50000.00;
GO

-- ERROR: IMPORTE <= 0
EXEC Pago.ModificarPagoAsociado
    @id_expensa = 1,
    @id_unidad = 1,
    @fecha = '2025-01-15',
    @importe = -5000.00;
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
