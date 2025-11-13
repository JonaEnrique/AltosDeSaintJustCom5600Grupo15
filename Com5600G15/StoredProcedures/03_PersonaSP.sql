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
-- Crear Persona
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearPersona
    @dni INT,
    @nombre NVARCHAR(50),
    @apellido NVARCHAR(50),
    @mail NVARCHAR(254) = NULL,
    @telefono VARCHAR(20) = NULL,
    @cvu_cbu VARCHAR(25) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que no exista una persona con el mismo DNI
    IF EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
        THROW 51000, 'Ya existe una persona con ese DNI', 1;
    
    -- Validar formato de email si se proporciona
    IF @mail IS NOT NULL AND @mail <> ''
    BEGIN
        IF NOT (@mail LIKE '%_@%_.%_')
            THROW 51000, 'El formato del email es invalido', 1;
    END
    
    -- Validar que el CBU/CVU sea único si se proporciona
    IF @cvu_cbu IS NOT NULL AND @cvu_cbu <> ''
    BEGIN
        IF EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cvu_cbu = @cvu_cbu)
            THROW 51000, 'Ya existe una persona con ese CBU/CVU', 1;
    END
    
    -- Validar DNI positivo
    IF @dni <= 0
        THROW 51000, 'El DNI debe ser mayor a 0', 1;
    
    -- Inserción
    INSERT INTO Consorcio.Persona (
        dni,
        nombre,
        apellido,
        mail,
        telefono,
        cvu_cbu
    )
    VALUES (
        @dni,
        @nombre,
        @apellido,
        @mail,
        @telefono,
        @cvu_cbu
    );
END
GO

-- =============================================
-- Modificar Persona
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarPersona
    @dni INT,
    @nombre NVARCHAR(50),
    @apellido NVARCHAR(50),
    @mail NVARCHAR(254) = NULL,
    @telefono VARCHAR(20) = NULL,
    @cvu_cbu VARCHAR(25) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
        THROW 51000, 'No existe una persona con ese DNI', 1;
    
    -- Validar formato de email si se proporciona
    IF @mail IS NOT NULL AND @mail <> ''
    BEGIN
        IF NOT (@mail LIKE '%_@%_.%_')
            THROW 51000, 'El formato del email es invalido', 1;
    END
    
    -- Validar que el CBU/CVU sea único si se proporciona
    IF @cvu_cbu IS NOT NULL AND @cvu_cbu <> ''
    BEGIN
        IF EXISTS (SELECT 1 FROM Consorcio.Persona WHERE cvu_cbu = @cvu_cbu AND dni <> @dni)
            THROW 51000, 'Ya existe otra persona con ese CBU/CVU', 1;
    END
    
    -- Actualización
    UPDATE Consorcio.Persona
    SET
        nombre = @nombre,
        apellido = @apellido,
        mail = @mail,
        telefono = @telefono,
        cvu_cbu = @cvu_cbu
    WHERE dni = @dni;
END
GO

-- =============================================
-- Eliminar Persona
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarPersona
    @dni INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Persona WHERE dni = @dni)
        THROW 51000, 'No existe una persona con ese DNI', 1;
    
    -- Revisar relaciones
    IF EXISTS (SELECT 1 FROM Consorcio.PersonaUnidad WHERE dni = @dni)
    BEGIN
        PRINT 'La persona tiene unidades asociadas, no se puede eliminar';
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM Pago.PagoAsociado WHERE cvu_cbu = (SELECT cvu_cbu FROM Consorcio.Persona WHERE dni = @dni))
    BEGIN
        PRINT 'La persona tiene pagos asociados, no se puede eliminar';
        RETURN;
    END
    
    -- Borrado físico
    DELETE FROM Consorcio.Persona
    WHERE dni = @dni;
END
GO
