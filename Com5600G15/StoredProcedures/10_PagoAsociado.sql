/*
    ---------------------------------------------------------------------
    -Fecha: 21/11/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito	
    - Franco Pérez
    - Cristian Vergara
    - Consigna: Generar los procedimientos almacenados (stored procedures) de inserción, modificación y eliminación para cada tabla.
    ---------------------------------------------------------------------
*/

USE Com5600G15
GO
-- =============================================
-- Crear PagoAsociado
-- =============================================
CREATE OR ALTER PROCEDURE Pago.CrearPagoAsociado
    @id_unidad INT,
    @fecha DATE,
    @cvu_cbu VARCHAR(25),
    @codigo_cuenta INT,
    @importe DECIMAL(10,2),
    @id_expensa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que la unidad funcional exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que la persona exista (por su cbu_cvu)
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cbu_cvu = @cvu_cbu)
        THROW 51000, 'No existe una persona con ese CBU/CVU', 1;
    
    -- Validar que el importe sea mayor a 0
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    -- Validar que la fecha no sea futura
    IF @fecha > CAST(SYSDATETIME() AS DATE)
        THROW 51000, 'La fecha del pago no puede ser futura', 1;
    
    -- Validar que el codigo de cuenta sea positivo
    IF @codigo_cuenta <= 0
        THROW 51000, 'El codigo de cuenta debe ser mayor a 0', 1;
    
    -- Inserción
    INSERT INTO Pago.PagoAsociado (
        id_unidad,
        fecha,
        cvu_cbu,
        codigo_cuenta,
        importe
    )
    VALUES (
        @id_unidad,
        @fecha,
        @cvu_cbu,
        @codigo_cuenta,
        @importe
    );
    
    SET @id_expensa = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar PagoAsociado
-- =============================================
CREATE OR ALTER PROCEDURE Pago.ModificarPagoAsociado
    @id_expensa INT,
    @id_unidad INT,
    @fecha DATE,
    @cvu_cbu VARCHAR(25),
    @codigo_cuenta INT,
    @importe DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia del pago
    IF NOT EXISTS (SELECT 1 FROM Pago.PagoAsociado WHERE id_expensa = @id_expensa)
        THROW 51000, 'No existe un pago asociado con ese ID', 1;
    
    -- Validar que la unidad funcional exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que la persona exista (por su cbu_cvu)
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cbu_cvu = @cvu_cbu)
        THROW 51000, 'No existe una persona con ese CBU/CVU', 1;
    
    -- Validar que el importe sea mayor a 0
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    -- Validar que la fecha no sea futura
    IF @fecha > CAST(SYSDATETIME() AS DATE)
        THROW 51000, 'La fecha del pago no puede ser futura', 1;
    
    -- Validar que el codigo de cuenta sea positivo
    IF @codigo_cuenta <= 0
        THROW 51000, 'El codigo de cuenta debe ser mayor a 0', 1;
    
    -- Actualización
    UPDATE Pago.PagoAsociado
    SET
        id_unidad = @id_unidad,
        fecha = @fecha,
        cvu_cbu = @cvu_cbu,
        codigo_cuenta = @codigo_cuenta,
        importe = @importe
    WHERE id_expensa = @id_expensa;
END
GO

-- =============================================
-- Eliminar PagoAsociado
-- =============================================
CREATE OR ALTER PROCEDURE Pago.EliminarPagoAsociado
    @id_expensa INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.PagoAsociado WHERE id_expensa = @id_expensa)
        THROW 51000, 'No existe un pago asociado con ese ID', 1;
    
    -- Borrado físico (no tiene tablas dependientes)
    DELETE FROM Pago.PagoAsociado
    WHERE id_expensa = @id_expensa;
END
GO