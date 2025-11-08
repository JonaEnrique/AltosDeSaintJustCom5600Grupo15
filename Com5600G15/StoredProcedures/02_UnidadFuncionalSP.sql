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
-- Crear UnidadFuncional
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearUnidadFuncional
    @id_consorcio INT,
    @piso VARCHAR(3),
    @departamento CHAR(1),
    @coeficiente DECIMAL(4,1),
    @m2_unidad DECIMAL(10,2),
    @m2_baulera DECIMAL(10,2) = 0,
    @m2_cochera DECIMAL(10,2) = 0,
    @id_unidad INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que el consorcio exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;
    
    -- Validar que no exista la misma unidad (piso y departamento) en el mismo consorcio
    IF EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional 
               WHERE id_consorcio = @id_consorcio 
               AND piso = @piso 
               AND departamento = @departamento)
        THROW 51000, 'Ya existe una unidad funcional con ese piso y departamento en el consorcio', 1;
    
    -- Validaciones básicas
    IF @coeficiente <= 0
        THROW 51000, 'El coeficiente debe ser mayor a 0', 1;
    
    IF @m2_unidad <= 0
        THROW 51000, 'Los m2 de la unidad deben ser mayores a 0', 1;
    
    IF @m2_baulera < 0
        THROW 51000, 'Los m2 de baulera no pueden ser negativos', 1;
    
    IF @m2_cochera < 0
        THROW 51000, 'Los m2 de cochera no pueden ser negativos', 1;
    
    -- Inserción
    INSERT INTO Consorcio.UnidadFuncional (
        id_consorcio,
        piso,
        departamento,
        coeficiente,
        m2_unidad,
        m2_baulera,
        m2_cochera
    )
    VALUES (
        @id_consorcio,
        @piso,
        @departamento,
        @coeficiente,
        @m2_unidad,
        @m2_baulera,
        @m2_cochera
    );
    
    SET @id_unidad = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar UnidadFuncional
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarUnidadFuncional
    @id_unidad INT,
    @piso VARCHAR(3),
    @departamento CHAR(1),
    @coeficiente DECIMAL(4,1),
    @m2_unidad DECIMAL(10,2),
    @m2_baulera DECIMAL(10,2),
    @m2_cochera DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que no choque con otra unidad del mismo consorcio
    IF EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional 
               WHERE piso = @piso 
               AND departamento = @departamento 
               AND id_unidad <> @id_unidad
               AND id_consorcio = (SELECT id_consorcio FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad))
        THROW 51000, 'Ya existe otra unidad funcional con ese piso y departamento en el consorcio', 1;
    
    -- Validaciones básicas
    IF @coeficiente <= 0
        THROW 51000, 'El coeficiente debe ser mayor a 0', 1;
    
    IF @m2_unidad <= 0
        THROW 51000, 'Los m2 de la unidad deben ser mayores a 0', 1;
    
    IF @m2_baulera < 0
        THROW 51000, 'Los m2 de baulera no pueden ser negativos', 1;
    
    IF @m2_cochera < 0
        THROW 51000, 'Los m2 de cochera no pueden ser negativos', 1;
    
    -- Actualización
    UPDATE Consorcio.UnidadFuncional
    SET
        piso = @piso,
        departamento = @departamento,
        coeficiente = @coeficiente,
        m2_unidad = @m2_unidad,
        m2_baulera = @m2_baulera,
        m2_cochera = @m2_cochera
    WHERE id_unidad = @id_unidad;
END
GO

-- =============================================
-- Eliminar UnidadFuncional
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarUnidadFuncional
    @id_unidad INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Revisar relaciones
    IF EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE id_unidad = @id_unidad)
    BEGIN
        PRINT 'La unidad funcional tiene personas asociadas, no se puede eliminar';
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM Pago.PagoAsociado WHERE id_unidad = @id_unidad)
    BEGIN
        PRINT 'La unidad funcional tiene pagos asociados, no se puede eliminar';
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_unidad = @id_unidad)
    BEGIN
        PRINT 'La unidad funcional tiene prorrateos asociados, no se puede eliminar';
        RETURN;
    END
    
    -- Borrado físico
    DELETE FROM Consorcio.UnidadFuncional
    WHERE id_unidad = @id_unidad;
END
GO
