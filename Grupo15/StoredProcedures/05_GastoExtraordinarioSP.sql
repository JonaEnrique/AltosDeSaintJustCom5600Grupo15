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
    -Consigna: Generar los procedimientos almacenados (stored procedures) de inserción, modificación y eliminación para cada tabla.
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO
-- =============================================
-- Crear GastoExtraordinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.CrearGastoExtraordinario
    @id_consorcio INT,
    @detalle VARCHAR(255),
    @importe DECIMAL(10,2),
    @importe_total DECIMAL(10,2),
    @fecha DATE,
    @pago_cuotas BIT = 0,
    @nro_cuota INT = NULL,
    @total_cuotas INT = NULL,
    @id_gasto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que el consorcio exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;
    
    -- Validar importe mayor a 0
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;

    -- Validar importe_total > 0
    IF @importe_total <= 0
    THROW 51000, 'El importe total debe ser mayor a 0', 1;
    
    -- Validar lógica de cuotas
    IF @pago_cuotas = 1
    BEGIN
        IF @nro_cuota IS NULL OR @total_cuotas IS NULL
            THROW 51000, 'Si el pago es en cuotas, debe especificar nro_cuota y total_cuotas', 1;
        
        IF @nro_cuota <= 0
            THROW 51000, 'El número de cuota debe ser mayor a 0', 1;
        
        IF @total_cuotas <= 0
            THROW 51000, 'El total de cuotas debe ser mayor a 0', 1;
        
        IF @nro_cuota > @total_cuotas
            THROW 51000, 'El número de cuota no puede ser mayor al total de cuotas', 1;

        IF @importe_total <= @importe
            THROW 51000, 'Si el pago es en cuotas, el importe total debe ser mayor que el importe de la cuota', 1;
    END
    ELSE
    BEGIN
        -- Si no es pago en cuotas, nro_cuota y total_cuotas deben ser NULL
        SET @nro_cuota = NULL;
        SET @total_cuotas = NULL;

        IF @importe_total <> @importe
           THROW 51000, 'Si no es pago en cuotas, el importe total debe ser igual al importe', 1;
    END
    
    -- Inserción
    INSERT INTO Pago.GastoExtraordinario (
        id_consorcio,
        detalle,
        importe,
        importe_total,
        fecha,
        pago_cuotas,
        nro_cuota,
        total_cuotas
    )
    VALUES (
        @id_consorcio,
        @detalle,
        @importe,
        @importe_total,
        @fecha,
        @pago_cuotas,
        @nro_cuota,
        @total_cuotas
    );
    
    SET @id_gasto = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar GastoExtraordinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.ModificarGastoExtraordinario
    @id_gasto INT,
    @detalle VARCHAR(255),
    @importe DECIMAL(10,2),
    @importe_total DECIMAL(10,2),
    @fecha DATE,
    @pago_cuotas BIT,
    @nro_cuota INT = NULL,
    @total_cuotas INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.GastoExtraordinario WHERE id_gasto = @id_gasto)
        THROW 51000, 'No existe un gasto extraordinario con ese ID', 1;
    
    -- Validar importe mayor a 0
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;

    IF @importe_total <= 0
        THROW 51000, 'El importe total debe ser mayor a 0', 1;
    
    -- Validar lógica de cuotas
    IF @pago_cuotas = 1
    BEGIN
        IF @nro_cuota IS NULL OR @total_cuotas IS NULL
            THROW 51000, 'Si el pago es en cuotas, debe especificar nro_cuota y total_cuotas', 1;
        
        IF @nro_cuota <= 0
            THROW 51000, 'El número de cuota debe ser mayor a 0', 1;
        
        IF @total_cuotas <= 0
            THROW 51000, 'El total de cuotas debe ser mayor a 0', 1;
        
        IF @nro_cuota > @total_cuotas
            THROW 51000, 'El número de cuota no puede ser mayor al total de cuotas', 1;

        IF @importe_total <= @importe
            THROW 51000, 'Si el pago es en cuotas, el importe total debe ser mayor que el importe de la cuota', 1;
    END
    ELSE
    BEGIN
        -- Si no es pago en cuotas, nro_cuota y total_cuotas deben ser NULL
        SET @nro_cuota = NULL;
        SET @total_cuotas = NULL;

        IF @importe_total <> @importe
            THROW 51000, 'Si no es pago en cuotas, el importe total debe ser igual al importe', 1;
    END
    
    -- Actualización
    UPDATE Pago.GastoExtraordinario
    SET
        detalle = @detalle,
        importe = @importe,
        importe_total = @importe_total,
        fecha = @fecha,
        pago_cuotas = @pago_cuotas,
        nro_cuota = @nro_cuota,
        total_cuotas = @total_cuotas
    WHERE id_gasto = @id_gasto;
END
GO

-- =============================================
-- Eliminar GastoExtraordinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.EliminarGastoExtraordinario
    @id_gasto INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.GastoExtraordinario WHERE id_gasto = @id_gasto)
        THROW 51000, 'No existe un gasto extraordinario con ese ID', 1;
    
    -- Borrado físico (no tiene relaciones con otras tablas)
    DELETE FROM Pago.GastoExtraordinario
    WHERE id_gasto = @id_gasto;
END
GO
