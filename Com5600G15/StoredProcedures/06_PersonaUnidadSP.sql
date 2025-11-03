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
-- =============================================
-- Crear PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearPersonaUnidad
    @id_unidad INT,
    @dni INT,
    @rol CHAR(1),
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --validar existencia de la persona
        IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
            THROW 51000, 'no existe una persona con ese DNI.', 1;

        --validar existencia de la unidad funcional
        IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
            THROW 51000, 'no existe una unidad funcional con ese ID.', 1;

        --validar rol
        IF @rol NOT IN ('P','I')
            THROW 51000, 'el rol debe ser P (Propietario) o I (Inquilino).', 1;

        --validar fechas
        IF @fecha_fin IS NOT NULL AND @fecha_fin < @fecha_inicio
            THROW 51000, 'la fecha de fin no puede ser anterior a la de inicio.', 1;

        INSERT INTO Consorcio.PersonaUnidad (id_unidad, dni, rol, fecha_inicio, fecha_fin)
        VALUES (@id_unidad, @dni, @rol, @fecha_inicio, @fecha_fin);

        PRINT 'registro creado correctamente en PersonaUnidad.';
    END TRY
    BEGIN CATCH
        PRINT 'error al crear registro en PersonaUnidad.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- =============================================
-- Modificar PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarPersonaUnidad
    @id_persona_unidad INT,
    @id_unidad INT = NULL,
    @dni INT = NULL,
    @rol CHAR(1) = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --validar existencia del registro
        IF NOT EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE id_persona_unidad = @id_persona_unidad)
            THROW 51000, 'no existe un registro con el id_persona_unidad indicado.', 1;

        --validar unidad si se pasa
        IF @id_unidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
            THROW 51000, 'no existe una unidad funcional con ese ID.', 1;

        --validar persona si se pasa
        IF @dni IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
            THROW 51000, 'no existe una persona con ese DNI.', 1;

        --validar rol si se pasa
        IF @rol IS NOT NULL AND @rol NOT IN ('P','I')
            THROW 51000, 'el rol debe ser P (Propietario) o I (Inquilino).', 1;

        --validar fechas
        IF @fecha_fin IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_fin < @fecha_inicio
            THROW 51000, 'la fecha de fin no puede ser anterior a la de inicio.', 1;

        UPDATE Consorcio.PersonaUnidad
        SET id_unidad = ISNULL(@id_unidad, id_unidad),
            dni = ISNULL(@dni, dni),
            rol = ISNULL(@rol, rol),
            fecha_inicio = ISNULL(@fecha_inicio, fecha_inicio),
            --fecha fin puede ser null porque quizá no se ha determinado el fin del contrato
            fecha_fin = @fecha_fin
        WHERE id_persona_unidad = @id_persona_unidad;

        PRINT 'registro modificado correctamente en PersonaUnidad.';
    END TRY
    BEGIN CATCH
        PRINT 'error al modificar registro en PersonaUnidad.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- =============================================
-- Eliminar PersonaUnidad
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.sp_EliminarPersonaUnidad
    @id_persona_unidad INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --validar existencia
        IF NOT EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE id_persona_unidad = @id_persona_unidad)
            THROW 51000, 'no existe un registro con el id_persona_unidad indicado.', 1;

        DELETE FROM Consorcio.PersonaUnidad
        WHERE id_persona_unidad = @id_persona_unidad;

        PRINT 'registro eliminado correctamente de PersonaUnidad.';
    END TRY
    BEGIN CATCH
        PRINT 'error al eliminar registro en PersonaUnidad.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO