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

	 -Consigna:Generar los procedimientos almacenados (stored procedures) de inserción, modificación y eliminación para cada tabla.
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO
-- =============================================
-- Crear Consorcio
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearConsorcio
    @nombre VARCHAR(50),
    @direccion VARCHAR(50),
    @cant_unidades_funcionales INT,
    @m2_totales DECIMAL(10,2),
    @vencimiento1 DATE,
    @vencimiento2 DATETIME,
    @id_consorcio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que no exista un consorcio con el mismo nombre
    IF EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE nombre = @nombre)
        THROW 51000, 'Ya existe un consorcio con ese nombre', 1;

    -- Validaciones básicas
    IF @cant_unidades_funcionales <= 0
        THROW 51000, 'La cantidad de unidades funcionales debe ser mayor a 0', 1;

    IF @m2_totales <= 0
        THROW 51000, 'Los m2 totales deben ser mayores a 0', 1;

    -- Inserción
    INSERT INTO Consorcio.Consorcio (
        nombre,
        direccion,
        cant_unidades_funcionales,
        m2_totales,
        vencimiento1,
        vencimiento2
    )
    VALUES (
        @nombre,
        @direccion,
        @cant_unidades_funcionales,
        @m2_totales,
        @vencimiento1,
        @vencimiento2
    );

    SET @id_consorcio = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar Consorcio
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarConsorcio
    @id_consorcio INT,
    @nombre VARCHAR(50),
    @direccion VARCHAR(50),
    @cant_unidades_funcionales INT,
    @m2_totales DECIMAL(10,2),
    @vencimiento1 DATE,
    @vencimiento2 DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;

    -- Validar que el nombre no choque con otro consorcio
    IF EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE nombre = @nombre AND id_consorcio <> @id_consorcio)
        THROW 51000, 'Ya existe otro consorcio con ese nombre', 1;

    -- Actualización
    UPDATE Consorcio.Consorcio
    SET
        nombre = @nombre,
        direccion = @direccion,
        cant_unidades_funcionales = @cant_unidades_funcionales,
        m2_totales = @m2_totales,
        vencimiento1 = @vencimiento1,
        vencimiento2 = @vencimiento2
    WHERE id_consorcio = @id_consorcio;
END
GO

-- =============================================
-- Eliminar Consorcio
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarConsorcio
    @id_consorcio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;

    -- Revisar relaciones
    IF EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_consorcio = @id_consorcio)
    BEGIN
        PRINT 'El consorcio tiene unidades funcionales asociadas, se realizará borrado lógico';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Consorcio.Proveedor WHERE id_consorcio = @id_consorcio)
    BEGIN
        PRINT 'El consorcio tiene proveedores asociados, se realizará borrado lógico';
        RETURN;
    END

    -- Borrado físico
    DELETE FROM Consorcio.Consorcio
    WHERE id_consorcio = @id_consorcio;
END
GO
