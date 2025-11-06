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
-- Crear Proveedor
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearProveedor
    @id_consorcio INT,
    @nombre_proveedor VARCHAR(50),
    @cuenta VARCHAR(50) = NULL,
    @tipo VARCHAR(50) = NULL,
    @id_proveedor INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que el consorcio exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;
    
    -- Validar que no exista el mismo proveedor en el mismo consorcio
    IF EXISTS (SELECT 1 FROM Consorcio.Proveedor 
               WHERE id_consorcio = @id_consorcio 
               AND nombre_proveedor = @nombre_proveedor)
        THROW 51000, 'Ya existe un proveedor con ese nombre en el consorcio', 1;
    
    -- Validar nombre no vacío
    IF LTRIM(RTRIM(@nombre_proveedor)) = ''
        THROW 51000, 'El nombre del proveedor no puede estar vacío', 1;
    
    -- Inserción
    INSERT INTO Consorcio.Proveedor (
        id_consorcio,
        nombre_proveedor,
        cuenta,
        tipo
    )
    VALUES (
        @id_consorcio,
        @nombre_proveedor,
        @cuenta,
        @tipo
    );
    
    SET @id_proveedor = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar Proveedor
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarProveedor
    @id_proveedor INT,
    @nombre_proveedor VARCHAR(50),
    @cuenta VARCHAR(50),
    @tipo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor WHERE id_proveedor = @id_proveedor)
        THROW 51000, 'No existe un proveedor con ese ID', 1;
    
    -- Validar que no choque con otro proveedor del mismo consorcio
    IF EXISTS (SELECT 1 FROM Consorcio.Proveedor 
               WHERE nombre_proveedor = @nombre_proveedor 
               AND id_proveedor <> @id_proveedor
               AND id_consorcio = (SELECT id_consorcio FROM Consorcio.Proveedor WHERE id_proveedor = @id_proveedor))
        THROW 51000, 'Ya existe otro proveedor con ese nombre en el consorcio', 1;
    
    -- Validar nombre no vacío
    IF LTRIM(RTRIM(@nombre_proveedor)) = ''
        THROW 51000, 'El nombre del proveedor no puede estar vacío', 1;
    
    -- Actualización
    UPDATE Consorcio.Proveedor
    SET
        nombre_proveedor = @nombre_proveedor,
        cuenta = @cuenta,
        tipo = @tipo
    WHERE id_proveedor = @id_proveedor;
END
GO

-- =============================================
-- Eliminar Proveedor
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarProveedor
    @id_proveedor INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Proveedor WHERE id_proveedor = @id_proveedor)
        THROW 51000, 'No existe un proveedor con ese ID', 1;
    
    -- Revisar relaciones
    IF EXISTS (SELECT 1 FROM Pago.GastoOrdinario WHERE id_proveedor = @id_proveedor)
    BEGIN
        PRINT 'El proveedor tiene gastos ordinarios asociados, no se puede eliminar';
        RETURN;
    END
    
    -- Borrado físico
    DELETE FROM Consorcio.Proveedor
    WHERE id_proveedor = @id_proveedor;
END
GO
