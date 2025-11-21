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
    @id_unidad INT = NULL,
    @fecha DATE,
    @cvu_cbu VARCHAR(25) = NULL,
    @importe DECIMAL(10,2),
    @id_expensa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que la unidad funcional exista (si se proporciona)
    IF @id_unidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que el cvu_cbu exista en Persona (si se proporciona)
    IF @cvu_cbu IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cvu_cbu = @cvu_cbu)
        THROW 51000, 'No existe una persona con ese CVU/CBU', 1;
    
    -- Validar importe
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    -- Inserción
    INSERT INTO Pago.PagoAsociado (
        id_unidad,
        fecha,
        cvu_cbu,
        importe
    )
    VALUES (
        @id_unidad,
        @fecha,
        @cvu_cbu,
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
    @id_unidad INT = NULL,
    @fecha DATE,
    @cvu_cbu VARCHAR(25) = NULL,
    @importe DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.PagoAsociado WHERE id_expensa = @id_expensa)
        THROW 51000, 'No existe un pago asociado con ese ID', 1;
    
    -- Validar que la unidad funcional exista (si se proporciona)
    IF @id_unidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que el cvu_cbu exista en Persona (si se proporciona)
    IF @cvu_cbu IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cvu_cbu = @cvu_cbu)
        THROW 51000, 'No existe una persona con ese CVU/CBU', 1;
    
    -- Validar importe
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    -- Actualización
    UPDATE Pago.PagoAsociado
    SET
        id_unidad = @id_unidad,
        fecha = @fecha,
        cvu_cbu = @cvu_cbu,
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
    
    -- Borrado físico (no tiene dependencias críticas)
    DELETE FROM Pago.PagoAsociado
    WHERE id_expensa = @id_expensa;
END
GO
