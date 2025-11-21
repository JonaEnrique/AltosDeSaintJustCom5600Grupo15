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
    
    -- Validar que la unidad funcional exista
    IF NOT EXISTS (SELECT 1 FROM Consorcio.UnidadFuncional WHERE id_unidad = @id_unidad)
        THROW 51000, 'No existe una unidad funcional con ese ID', 1;
    
    -- Validar que no exista prorrateo para esa unidad en esa fecha
    IF EXISTS (SELECT 1 FROM Pago.Prorrateo 
               WHERE id_unidad = @id_unidad 
               AND fecha = @fecha)
        THROW 51000, 'Ya existe un prorrateo para esa unidad en esa fecha', 1;
    
    -- Validaciones básicas
    IF @porcentaje_m2 <= 0
        THROW 51000, 'El porcentaje de m2 debe ser mayor a 0', 1;
    
    IF @saldo_anterior_abonado < 0
        THROW 51000, 'El saldo anterior abonado no puede ser negativo', 1;
    
    IF @pagos_recibidos < 0
        THROW 51000, 'Los pagos recibidos no pueden ser negativos', 1;
    
    IF @deudas < 0
        THROW 51000, 'Las deudas no pueden ser negativas', 1;
    
    IF @intereses < 0
        THROW 51000, 'Los intereses no pueden ser negativos', 1;
    
    IF @expensas_ordinarias < 0
        THROW 51000, 'Las expensas ordinarias no pueden ser negativas', 1;
    
    IF @expensas_extraordinarias < 0
        THROW 51000, 'Las expensas extraordinarias no pueden ser negativas', 1;
    
    IF @total_a_pagar < 0
        THROW 51000, 'El total a pagar no puede ser negativo', 1;
    
    -- Inserción
    INSERT INTO Pago.Prorrateo (
        id_unidad,
        fecha,
        porcentaje_m2,
        piso,
        depto,
        nombre_propietario,
        precio_cocheras,
        precio_bauleras,
        saldo_anterior_abonado,
        pagos_recibidos,
        deudas,
        intereses,
        expensas_ordinarias,
        expensas_extraordinarias,
        total_a_pagar
    )
    VALUES (
        @id_unidad,
        @fecha,
        @porcentaje_m2,
        @piso,
        @depto,
        @nombre_propietario,
        @precio_cocheras,
        @precio_bauleras,
        @saldo_anterior_abonado,
        @pagos_recibidos,
        @deudas,
        @intereses,
        @expensas_ordinarias,
        @expensas_extraordinarias,
        @total_a_pagar
    );
    
    SET @id_prorrateo = SCOPE_IDENTITY();
END
GO

-- =============================================
-- Modificar Prorrateo
-- =============================================
CREATE OR ALTER PROCEDURE Pago.ModificarProrrateo
    @id_prorrateo INT,
    @porcentaje_m2 DECIMAL(6,3),
    @piso VARCHAR(5),
    @depto CHAR(1),
    @nombre_propietario VARCHAR(100),
    @precio_cocheras DECIMAL(10,2),
    @precio_bauleras DECIMAL(10,2),
    @saldo_anterior_abonado DECIMAL(10,2),
    @pagos_recibidos DECIMAL(10,2),
    @deudas DECIMAL(10,2),
    @intereses DECIMAL(10,2),
    @expensas_ordinarias DECIMAL(10,2),
    @expensas_extraordinarias DECIMAL(10,2),
    @total_a_pagar DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_prorrateo = @id_prorrateo)
        THROW 51000, 'No existe un prorrateo con ese ID', 1;
    
    -- Validaciones básicas
    IF @porcentaje_m2 <= 0
        THROW 51000, 'El porcentaje de m2 debe ser mayor a 0', 1;
    
    IF @saldo_anterior_abonado < 0
        THROW 51000, 'El saldo anterior abonado no puede ser negativo', 1;
    
    IF @pagos_recibidos < 0
        THROW 51000, 'Los pagos recibidos no pueden ser negativos', 1;
    
    IF @deudas < 0
        THROW 51000, 'Las deudas no pueden ser negativas', 1;
    
    IF @intereses < 0
        THROW 51000, 'Los intereses no pueden ser negativos', 1;
    
    IF @expensas_ordinarias < 0
        THROW 51000, 'Las expensas ordinarias no pueden ser negativas', 1;
    
    IF @expensas_extraordinarias < 0
        THROW 51000, 'Las expensas extraordinarias no pueden ser negativas', 1;
    
    IF @total_a_pagar < 0
        THROW 51000, 'El total a pagar no puede ser negativo', 1;
    
    -- Actualización
    UPDATE Pago.Prorrateo
    SET
        porcentaje_m2 = @porcentaje_m2,
        piso = @piso,
        depto = @depto,
        nombre_propietario = @nombre_propietario,
        precio_cocheras = @precio_cocheras,
        precio_bauleras = @precio_bauleras,
        saldo_anterior_abonado = @saldo_anterior_abonado,
        pagos_recibidos = @pagos_recibidos,
        deudas = @deudas,
        intereses = @intereses,
        expensas_ordinarias = @expensas_ordinarias,
        expensas_extraordinarias = @expensas_extraordinarias,
        total_a_pagar = @total_a_pagar
    WHERE id_prorrateo = @id_prorrateo;
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
    
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Pago.Prorrateo WHERE id_prorrateo = @id_prorrateo)
        THROW 51000, 'No existe un prorrateo con ese ID', 1;
    
    -- Borrado físico (no tiene relaciones con otras tablas)
    DELETE FROM Pago.Prorrateo
    WHERE id_prorrateo = @id_prorrateo;
END
GO
