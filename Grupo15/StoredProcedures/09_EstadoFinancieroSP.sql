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
-- Crear EstadoFinanciero
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.CrearEstadoFinanciero
    @id_consorcio INT,
    @fecha DATE,
    @saldo_anterior DECIMAL(10,2) = 0,
    @ingreso_en_termino DECIMAL(10,2) = 0,
    @ingreso_adeudado DECIMAL(10,2) = 0,
    @ingreso_adelantado DECIMAL(10,2) = 0,
    @egresos_mes DECIMAL(10,2) = 0,
    @saldo_cierre DECIMAL(10,2) = 0,
    @id_estado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que el consorcio exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.Consorcio WHERE id_consorcio = @id_consorcio)
        THROW 51000, 'No existe un consorcio con ese ID', 1;
    
    -- Validar que no exista un estado financiero para ese consorcio en esa fecha
    IF EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero 
               WHERE id_consorcio = @id_consorcio 
               AND fecha = @fecha)
        THROW 51000, 'Ya existe un estado financiero para ese consorcio en esa fecha', 1;
    
    -- Validar fecha
    IF YEAR(@fecha) <= 1958 OR YEAR(@fecha) > YEAR(GETDATE())
        THROW 51000, 'El año de la fecha debe ser mayor a 1958 y menor o igual al año actual', 1;
    
    -- Validaciones básicas de valores no negativos
    IF @saldo_anterior < 0
        THROW 51000, 'El saldo anterior no puede ser negativo', 1;
    
    IF @ingreso_en_termino < 0
        THROW 51000, 'El ingreso en término no puede ser negativo', 1;
    
    IF @ingreso_adeudado < 0
        THROW 51000, 'El ingreso adeudado no puede ser negativo', 1;
    
    IF @ingreso_adelantado < 0
        THROW 51000, 'El ingreso adelantado no puede ser negativo', 1;
    
    IF @egresos_mes < 0
        THROW 51000, 'Los egresos del mes no pueden ser negativos', 1;
    
    IF @saldo_cierre < 0
        THROW 51000, 'El saldo de cierre no puede ser negativo', 1;
    
    -- Inserción
    INSERT INTO Consorcio.EstadoFinanciero (
        id_consorcio,
        fecha,
        saldo_anterior,
        ingreso_en_termino,
        ingreso_adeudado,
        ingreso_adelantado,
        egresos_mes,
        saldo_cierre
    )
    VALUES (
        @id_consorcio,
        @fecha,
        @saldo_anterior,
        @ingreso_en_termino,
        @ingreso_adeudado,
        @ingreso_adelantado,
        @egresos_mes,
        @saldo_cierre
    );
    
    SET @id_estado = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar EstadoFinanciero
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.ModificarEstadoFinanciero
    @id_estado INT,
    @fecha DATE,
    @saldo_anterior DECIMAL(10,2),
    @ingreso_en_termino DECIMAL(10,2),
    @ingreso_adeudado DECIMAL(10,2),
    @ingreso_adelantado DECIMAL(10,2),
    @egresos_mes DECIMAL(10,2),
    @saldo_cierre DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero WHERE id_estado = @id_estado)
        THROW 51000, 'No existe un estado financiero con ese ID', 1;
    
    -- Validar que no choque con otro estado del mismo consorcio en la misma fecha
    IF EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero 
               WHERE fecha = @fecha 
               AND id_estado <> @id_estado
               AND id_consorcio = (SELECT id_consorcio FROM Consorcio.EstadoFinanciero WHERE id_estado = @id_estado))
        THROW 51000, 'Ya existe otro estado financiero para ese consorcio en esa fecha', 1;
    
    -- Validar fecha
    IF YEAR(@fecha) <= 1958 OR YEAR(@fecha) > YEAR(GETDATE())
        THROW 51000, 'El año de la fecha debe ser mayor a 1958 y menor o igual al año actual', 1;
    
    -- Validaciones básicas de valores no negativos
    IF @saldo_anterior < 0
        THROW 51000, 'El saldo anterior no puede ser negativo', 1;
    
    IF @ingreso_en_termino < 0
        THROW 51000, 'El ingreso en término no puede ser negativo', 1;
    
    IF @ingreso_adeudado < 0
        THROW 51000, 'El ingreso adeudado no puede ser negativo', 1;
    
    IF @ingreso_adelantado < 0
        THROW 51000, 'El ingreso adelantado no puede ser negativo', 1;
    
    IF @egresos_mes < 0
        THROW 51000, 'Los egresos del mes no pueden ser negativos', 1;
    
    IF @saldo_cierre < 0
        THROW 51000, 'El saldo de cierre no puede ser negativo', 1;
    
    -- Actualización
    UPDATE Consorcio.EstadoFinanciero
    SET
        fecha = @fecha,
        saldo_anterior = @saldo_anterior,
        ingreso_en_termino = @ingreso_en_termino,
        ingreso_adeudado = @ingreso_adeudado,
        ingreso_adelantado = @ingreso_adelantado,
        egresos_mes = @egresos_mes,
        saldo_cierre = @saldo_cierre
    WHERE id_estado = @id_estado;
END
GO

-- =============================================
-- Eliminar EstadoFinanciero
-- =============================================
CREATE OR ALTER PROCEDURE Consorcio.EliminarEstadoFinanciero
    @id_estado INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero WHERE id_estado = @id_estado)
        THROW 51000, 'No existe un estado financiero con ese ID', 1;
    
    -- Borrado físico (no tiene relaciones con otras tablas)
    DELETE FROM Consorcio.EstadoFinanciero
    WHERE id_estado = @id_estado;
END
GO