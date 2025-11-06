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
-- Crear Prorrateo
-- =============================================
CREATE OR ALTER PROCEDURE Pago.CrearProrrateo
    @id_unidad INT,
    @fecha DATE,
    @porcentaje_m2 DECIMAL(6,3),
    @piso VARCHAR(5),
    @depto CHAR(1),
    @nombre_propietario VARCHAR(100) = NULL,
    @precio_cocheras DECIMAL(10,2) = 0,
    @precio_bauleras DECIMAL(10,2) = 0,
    @saldo_anterior_abonado DECIMAL(10,2) = 0,
    @pagos_recibidos DECIMAL(10,2) = 0,
    @deudas DECIMAL(10,2) = 0,
    @intereses DECIMAL(10,2) = 0,
    @expensas_ordinarias DECIMAL(10,2) = 0,
    @expensas_extraordinarias DECIMAL(10,2) = 0,
    @total_a_pagar DECIMAL(10,2) = 0,
    @id_prorrateo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --Validar existencia de unidad
        IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
            THROW 51000, 'No existe una unidad funcional con ese ID', 1;

        --Validaciones básicas
        IF @porcentaje_m2 <= 0
            THROW 51000, 'El porcentaje de m2 debe ser mayor a 0', 1;

        IF @precio_cocheras < 0 OR @precio_bauleras < 0 OR @saldo_anterior_abonado < 0 OR @pagos_recibidos < 0 OR @deudas < 0 OR @intereses < 0 OR 
        @expensas_ordinarias < 0 OR @expensas_extraordinarias < 0 OR @total_a_pagar < 0
            THROW 51000, 'Los valores monetarios no pueden ser negativos', 1;

        --Validar unicidad unidad + fecha
        IF EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_unidad = @id_unidad AND fecha = @fecha)
            THROW 51000, 'Ya existe un prorrateo para esta unidad en la fecha indicada', 1;

        --Insercion
        INSERT INTO Pago.Prorrateo (
            id_unidad, fecha, porcentaje_m2, piso, depto, nombre_propietario,
            precio_cocheras, precio_bauleras, saldo_anterior_abonado, pagos_recibidos,
            deudas, intereses, expensas_ordinarias, expensas_extraordinarias, total_a_pagar
        )
        VALUES (
            @id_unidad, @fecha, @porcentaje_m2, @piso, @depto, @nombre_propietario,
            @precio_cocheras, @precio_bauleras, @saldo_anterior_abonado, @pagos_recibidos,
            @deudas, @intereses, @expensas_ordinarias, @expensas_extraordinarias, @total_a_pagar
        );
        --Devolvemos el id insertado
        SET @id_prorrateo = SCOPE_IDENTITY();
        PRINT 'registro creado correctamente en Prorrateo.';
    END TRY
    BEGIN CATCH
        PRINT 'error al crear registro en Prorrateo.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Modificar Prorrateo
-- =============================================
CREATE OR ALTER PROCEDURE Pago.ModificarProrrateo
    @id_prorrateo INT,
    @id_unidad INT = NULL,
    @fecha DATE = NULL,
    @porcentaje_m2 DECIMAL(6,3) = NULL,
    @piso VARCHAR(5) = NULL,
    @depto CHAR(1) = NULL,
    @nombre_propietario VARCHAR(100) = NULL,
    @precio_cocheras DECIMAL(10,2) = NULL,
    @precio_bauleras DECIMAL(10,2) = NULL,
    @saldo_anterior_abonado DECIMAL(10,2) = NULL,
    @pagos_recibidos DECIMAL(10,2) = NULL,
    @deudas DECIMAL(10,2) = NULL,
    @intereses DECIMAL(10,2) = NULL,
    @expensas_ordinarias DECIMAL(10,2) = NULL,
    @expensas_extraordinarias DECIMAL(10,2) = NULL,
    @total_a_pagar DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --Validar existencia
        IF NOT EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_prorrateo = @id_prorrateo)
            THROW 51000, 'No existe un prorrateo con ese ID', 1;

        --Validar unidad si se modifica
        IF @id_unidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
            THROW 51000, 'No existe una unidad funcional con ese ID', 1;

        --Validaciones
        IF @porcentaje_m2 IS NOT NULL AND @porcentaje_m2 <= 0
            THROW 51000, 'El porcentaje de m2 debe ser mayor a 0', 1;


           -- Validaciones de valores monetarios (no negativos)
        IF COALESCE(@precio_cocheras, 0) < 0 THROW 51000, 'El precio de cocheras no puede ser negativo', 1;
        IF COALESCE(@precio_bauleras, 0) < 0 THROW 51000, 'El precio de bauleras no puede ser negativo', 1;
        IF COALESCE(@saldo_anterior_abonado, 0) < 0 THROW 51000, 'El saldo anterior abonado no puede ser negativo', 1;
        IF COALESCE(@pagos_recibidos, 0) < 0 THROW 51000, 'Los pagos recibidos no pueden ser negativos', 1;
        IF COALESCE(@deudas, 0) < 0 THROW 51000, 'Las deudas no pueden ser negativas', 1;
        IF COALESCE(@intereses, 0) < 0 THROW 51000, 'Los intereses no pueden ser negativos', 1;
        IF COALESCE(@expensas_ordinarias, 0) < 0 THROW 51000, 'Las expensas ordinarias no pueden ser negativas', 1;
        IF COALESCE(@expensas_extraordinarias, 0) < 0 THROW 51000, 'Las expensas extraordinarias no pueden ser negativas', 1;
        IF COALESCE(@total_a_pagar, 0) < 0 THROW 51000, 'El total a pagar no puede ser negativo', 1;


        --Actualizacion
        UPDATE Pago.Prorrateo
        SET
            id_unidad = ISNULL(@id_unidad, id_unidad),
            fecha = ISNULL(@fecha, fecha),
            porcentaje_m2 = ISNULL(@porcentaje_m2, porcentaje_m2),
            piso = ISNULL(@piso, piso),
            depto = ISNULL(@depto, depto),
            nombre_propietario = ISNULL(@nombre_propietario, nombre_propietario),
            precio_cocheras = ISNULL(@precio_cocheras, precio_cocheras),
            precio_bauleras = ISNULL(@precio_bauleras, precio_bauleras),
            saldo_anterior_abonado = ISNULL(@saldo_anterior_abonado, saldo_anterior_abonado),
            pagos_recibidos = ISNULL(@pagos_recibidos, pagos_recibidos),
            deudas = ISNULL(@deudas, deudas),
            intereses = ISNULL(@intereses, intereses),
            expensas_ordinarias = ISNULL(@expensas_ordinarias, expensas_ordinarias),
            expensas_extraordinarias = ISNULL(@expensas_extraordinarias, expensas_extraordinarias),
            total_a_pagar = ISNULL(@total_a_pagar, total_a_pagar)
        WHERE id_prorrateo = @id_prorrateo;
        PRINT 'registro modificado correctamente en Prorrateo.';
    END TRY
    BEGIN CATCH
        PRINT 'error al modificar registro en Prorrateo.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Eliminar Prorrateo
-- =============================================
CREATE OR ALTER PROCEDURE Pago.EliminarProrrateo
    @id_prorrateo INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --Validar existencia
        IF NOT EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_prorrateo = @id_prorrateo)
            THROW 51000, 'No existe un prorrateo con ese ID', 1;

        --Eliminacion
        DELETE FROM Pago.Prorrateo WHERE id_prorrateo = @id_prorrateo;
        PRINT 'registro eliminado correctamente de Prorrateo.';
    END TRY
    BEGIN CATCH
        PRINT 'error al eliminar registro en Prorrateo.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO