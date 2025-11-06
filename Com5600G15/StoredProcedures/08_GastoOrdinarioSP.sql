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
-- Crear GastoOrdinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.CrearGastoOrdinario
    @id_consorcio INT,
    @tipo_gasto VARCHAR(60),
    @fecha DATE,
    @importe DECIMAL(10,2),
    @nro_factura INT,
    @id_proveedor INT,
    @descripcion VARCHAR(60),
    @id_gasto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que el consorcio exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;
    
    -- Validar que el proveedor exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor WHERE id_proveedor = @id_proveedor)
        THROW 51000, 'No existe un proveedor con ese ID', 1;
    
    -- Validar que el proveedor pertenezca al consorcio
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor 
                   WHERE id_proveedor = @id_proveedor 
                   AND id_consorcio = @id_consorcio)
        THROW 51000, 'El proveedor no pertenece al consorcio especificado', 1;
    
    -- Validar que no exista el mismo número de factura para el mismo proveedor
    IF EXISTS (SELECT 1 FROM Pago.GastoOrdinario 
               WHERE nro_factura = @nro_factura 
               AND id_proveedor = @id_proveedor)
        THROW 51000, 'Ya existe una factura con ese número para el mismo proveedor', 1;
    
    -- Validaciones básicas
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    IF YEAR(@fecha) <= 1958
        THROW 51000, 'El año de la fecha debe ser mayor a 1958', 1;
    
    IF YEAR(@fecha) > YEAR(SYSDATETIME())
        THROW 51000, 'El año de la fecha no puede ser mayor al año actual', 1;
    
    IF @nro_factura <= 0
        THROW 51000, 'El número de factura debe ser mayor a 0', 1;
    
    -- Inserción
    INSERT INTO Pago.GastoOrdinario (
        id_consorcio,
        tipo_gasto,
        fecha,
        importe,
        nro_factura,
        id_proveedor,
        descripcion
    )
    VALUES (
        @id_consorcio,
        @tipo_gasto,
        @fecha,
        @importe,
        @nro_factura,
        @id_proveedor,
        @descripcion
    );
    
    SET @id_gasto = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar GastoOrdinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.ModificarGastoOrdinario
    @id_gasto INT,
    @tipo_gasto VARCHAR(60),
    @fecha DATE,
    @importe DECIMAL(10,2),
    @nro_factura INT,
    @id_proveedor INT,
    @descripcion VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia del gasto
    IF NOT EXISTS (SELECT 1 FROM Pago.GastoOrdinario WHERE id_gasto = @id_gasto)
        THROW 51000, 'No existe un gasto ordinario con ese ID', 1;
    
    -- Validar que el proveedor exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor WHERE id_proveedor = @id_proveedor)
        THROW 51000, 'No existe un proveedor con ese ID', 1;
    
    -- Validar que el proveedor pertenezca al mismo consorcio del gasto
    DECLARE @id_consorcio_gasto INT;
    SELECT @id_consorcio_gasto = id_consorcio FROM Pago.GastoOrdinario WHERE id_gasto = @id_gasto;
    
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor 
                   WHERE id_proveedor = @id_proveedor 
                   AND id_consorcio = @id_consorcio_gasto)
        THROW 51000, 'El proveedor no pertenece al consorcio del gasto', 1;
    
    -- Validar que no exista el mismo número de factura para el mismo proveedor (excepto el actual)
    IF EXISTS (SELECT 1 FROM Pago.GastoOrdinario 
               WHERE nro_factura = @nro_factura 
               AND id_proveedor = @id_proveedor
               AND id_gasto <> @id_gasto)
        THROW 51000, 'Ya existe otra factura con ese número para el mismo proveedor', 1;
    
    -- Validaciones básicas
    IF @importe <= 0
        THROW 51000, 'El importe debe ser mayor a 0', 1;
    
    IF YEAR(@fecha) <= 1958
        THROW 51000, 'El año de la fecha debe ser mayor a 1958', 1;
    
    IF YEAR(@fecha) > YEAR(SYSDATETIME())
        THROW 51000, 'El año de la fecha no puede ser mayor al año actual', 1;
    
    IF @nro_factura <= 0
        THROW 51000, 'El número de factura debe ser mayor a 0', 1;
    
    -- Actualización
    UPDATE Pago.GastoOrdinario
    SET
        tipo_gasto = @tipo_gasto,
        fecha = @fecha,
        importe = @importe,
        nro_factura = @nro_factura,
        id_proveedor = @id_proveedor,
        descripcion = @descripcion
    WHERE id_gasto = @id_gasto;
END
GO

-- =============================================
-- Eliminar GastoOrdinario
-- =============================================
CREATE OR ALTER PROCEDURE Pago.EliminarGastoOrdinario
    @id_gasto INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.GastoOrdinario WHERE id_gasto = @id_gasto)
        THROW 51000, 'No existe un gasto ordinario con ese ID', 1;
    
    -- Borrado físico (no hay relaciones que impidan el borrado)
    DELETE FROM Pago.GastoOrdinario
    WHERE id_gasto = @id_gasto;
END
GO
