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
-- Crear PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearPersonaUnidad
    @id_unidad INT,
    @dni INT,
    @rol CHAR(1),
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL,
    @id_persona_unidad INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que la unidad funcional exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que la persona exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
        THROW 51000, 'No existe una persona con ese DNI', 1;
    
    -- Validar rol
    IF @rol NOT IN ('P', 'I')
        THROW 51000, 'El rol debe ser P (Propietario) o I (Inquilino)', 1;
    
    -- Validar fechas
    IF @fecha_fin IS NOT NULL AND @fecha_fin < @fecha_inicio
        THROW 51000, 'La fecha fin no puede ser anterior a la fecha inicio', 1;
    
    -- Validar que no exista una relación activa de la misma persona con la misma unidad
    IF EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad 
               WHERE id_unidad = @id_unidad 
               AND dni = @dni 
               AND (fecha_fin IS NULL OR fecha_fin >= GETDATE()))
        THROW 51000, 'Ya existe una relación activa de esta persona con esta unidad', 1;
    
    -- Inserción
    INSERT INTO Consorcio.PersonaUnidad (
        id_unidad,
        dni,
        rol,
        fecha_inicio,
        fecha_fin
    )
    VALUES (
        @id_unidad,
        @dni,
        @rol,
        @fecha_inicio,
        @fecha_fin
    );
    
    SET @id_persona_unidad = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarPersonaUnidad
    @id_persona_unidad INT,
    @rol CHAR(1),
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE id_persona_unidad = @id_persona_unidad)
        THROW 51000, 'No existe una relación persona-unidad con ese ID', 1;
    
    -- Validar rol
    IF @rol NOT IN ('P', 'I')
        THROW 51000, 'El rol debe ser P (Propietario) o I (Inquilino)', 1;
    
    -- Validar fechas
    IF @fecha_fin IS NOT NULL AND @fecha_fin < @fecha_inicio
        THROW 51000, 'La fecha fin no puede ser anterior a la fecha inicio', 1;
    
    -- Actualización
    UPDATE Consorcio.PersonaUnidad
    SET
        rol = @rol,
        fecha_inicio = @fecha_inicio,
        fecha_fin = @fecha_fin
    WHERE id_persona_unidad = @id_persona_unidad;
END
GO

-- =============================================
-- Eliminar PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarPersonaUnidad
    @id_persona_unidad INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE id_persona_unidad = @id_persona_unidad)
        THROW 51000, 'No existe una relación persona-unidad con ese ID', 1;
    
    -- Borrado físico (no tiene dependencias críticas)
    DELETE FROM Consorcio.PersonaUnidad
    WHERE id_persona_unidad = @id_persona_unidad;
END
GO
