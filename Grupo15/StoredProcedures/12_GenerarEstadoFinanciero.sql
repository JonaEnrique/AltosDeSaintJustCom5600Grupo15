/*
    ---------------------------------------------------------------------
    -Fecha: 21/11/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito	
    - Franco Pérez
    - Cristian Vergara
    - Consigna: Generar los registros de Estado financiero
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO
-- ============================================================================
-- Procedimiento: Generar Estado Financiero Mensual (Individual)
-- Descripción: Calcula el estado financiero para un mes específico
-- ============================================================================
CREATE OR ALTER PROCEDURE Consorcio.GenerarEstadoFinanciero
    @id_consorcio INT,
    @fecha_cierre DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @saldo_anterior DECIMAL(10,2) = 0;
    DECLARE @ingreso_termino DECIMAL(10,2) = 0;
    DECLARE @ingreso_adeudado DECIMAL(10,2) = 0;
    DECLARE @ingreso_adelantado DECIMAL(10,2) = 0;
    DECLARE @egresos_mes DECIMAL(10,2) = 0;
    DECLARE @saldo_cierre DECIMAL(10,2) = 0;
    
    DECLARE @primer_dia_mes DATE;
    DECLARE @ultimo_dia_mes DATE;
    DECLARE @vencimiento1 DATE;
    DECLARE @vencimiento2 DATE;
    
    -- Calcular primer y último día del mes
    SET @primer_dia_mes = DATEFROMPARTS(YEAR(@fecha_cierre), MONTH(@fecha_cierre), 1);
    SET @ultimo_dia_mes = EOMONTH(@fecha_cierre);
    
    -- Obtener fechas de vencimiento del consorcio
    SELECT @vencimiento1 = vencimiento1, @vencimiento2 = vencimiento2
    FROM Consorcio.Consorcio
    WHERE id_consorcio = @id_consorcio;
    
    -- 1. SALDO ANTERIOR
    SELECT TOP 1 @saldo_anterior = ISNULL(saldo_cierre, 0)
    FROM Consorcio.EstadoFinanciero
    WHERE id_consorcio = @id_consorcio 
      AND fecha < @primer_dia_mes
    ORDER BY fecha DESC;
    
    -- 2. INGRESOS EN TÉRMINO
    SELECT @ingreso_termino = ISNULL(SUM(PA.importe), 0)
    FROM Pago.PagoAsociado PA
    INNER JOIN Consorcio.UnidadFuncional UF ON PA.id_unidad = UF.id_unidad
    WHERE UF.id_consorcio = @id_consorcio
      AND PA.fecha >= @primer_dia_mes
      AND PA.fecha <= DATEFROMPARTS(YEAR(@fecha_cierre), MONTH(@fecha_cierre), DAY(@vencimiento2))
      AND PA.fecha <= @ultimo_dia_mes;
    
    -- 3. INGRESOS ADEUDADOS
    SELECT @ingreso_adeudado = ISNULL(SUM(PA.importe), 0)
    FROM Pago.PagoAsociado PA
    INNER JOIN Consorcio.UnidadFuncional UF ON PA.id_unidad = UF.id_unidad
    INNER JOIN Pago.Prorrateo PR ON PR.id_unidad = UF.id_unidad 
        AND MONTH(PR.fecha) = MONTH(@fecha_cierre)
        AND YEAR(PR.fecha) = YEAR(@fecha_cierre)
    WHERE UF.id_consorcio = @id_consorcio
      AND PA.fecha >= @primer_dia_mes
      AND PA.fecha <= @ultimo_dia_mes
      AND PA.fecha > DATEFROMPARTS(YEAR(@fecha_cierre), MONTH(@fecha_cierre), DAY(@vencimiento2))
      AND PR.deudas > 0;
    
    -- 4. INGRESOS ADELANTADOS
    SELECT @ingreso_adelantado = ISNULL(SUM(
        CASE 
            WHEN PA.importe > PR.total_a_pagar 
            THEN PA.importe - PR.total_a_pagar
            ELSE 0
        END
    ), 0)
    FROM Pago.PagoAsociado PA
    INNER JOIN Consorcio.UnidadFuncional UF ON PA.id_unidad = UF.id_unidad
    LEFT JOIN Pago.Prorrateo PR ON PR.id_unidad = UF.id_unidad 
        AND MONTH(PR.fecha) = MONTH(@fecha_cierre)
        AND YEAR(PR.fecha) = YEAR(@fecha_cierre)
    WHERE UF.id_consorcio = @id_consorcio
      AND PA.fecha >= @primer_dia_mes
      AND PA.fecha <= @ultimo_dia_mes;
    
    -- 5. EGRESOS DEL MES
    DECLARE @egresos_ordinarios DECIMAL(10,2) = 0;
    DECLARE @egresos_extraordinarios DECIMAL(10,2) = 0;
    
    SELECT @egresos_ordinarios = ISNULL(SUM(importe), 0)
    FROM Pago.GastoOrdinario
    WHERE id_consorcio = @id_consorcio
      AND fecha >= @primer_dia_mes
      AND fecha <= @ultimo_dia_mes;
    
    SELECT @egresos_extraordinarios = ISNULL(SUM(importe), 0)
    FROM Pago.GastoExtraordinario
    WHERE id_consorcio = @id_consorcio
      AND fecha >= @primer_dia_mes
      AND fecha <= @ultimo_dia_mes;
    
    SET @egresos_mes = @egresos_ordinarios + @egresos_extraordinarios;
    
    -- 6. SALDO AL CIERRE
    SET @saldo_cierre = @saldo_anterior + @ingreso_termino + @ingreso_adeudado 
                        + @ingreso_adelantado - @egresos_mes;
    
    -- 7. INSERTAR O ACTUALIZAR
    IF EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero 
               WHERE id_consorcio = @id_consorcio 
               AND YEAR(fecha) = YEAR(@fecha_cierre)
               AND MONTH(fecha) = MONTH(@fecha_cierre))
    BEGIN
        UPDATE Consorcio.EstadoFinanciero
        SET saldo_anterior = @saldo_anterior,
            ingreso_en_termino = @ingreso_termino,
            ingreso_adeudado = @ingreso_adeudado,
            ingreso_adelantado = @ingreso_adelantado,
            egresos_mes = @egresos_mes,
            saldo_cierre = @saldo_cierre
        WHERE id_consorcio = @id_consorcio
          AND YEAR(fecha) = YEAR(@fecha_cierre)
          AND MONTH(fecha) = MONTH(@fecha_cierre);
    END
    ELSE
    BEGIN
        INSERT INTO Consorcio.EstadoFinanciero 
            (id_consorcio, fecha, saldo_anterior, ingreso_en_termino, 
             ingreso_adeudado, ingreso_adelantado, egresos_mes, saldo_cierre)
        VALUES 
            (@id_consorcio, @fecha_cierre, @saldo_anterior, @ingreso_termino,
             @ingreso_adeudado, @ingreso_adelantado, @egresos_mes, @saldo_cierre);
    END
END
GO

-- ============================================================================
-- Procedimiento: Generar TODOS los Estados Financieros de un Consorcio
-- Descripción: Genera estados financieros desde la fecha más antigua
--              con datos hasta la fecha especificada (o fecha actual)
-- ============================================================================

CREATE OR ALTER PROCEDURE Consorcio.GenerarTodosEstadosFinancieros
    @id_consorcio INT,
    @fecha_hasta DATE = NULL,
    @saldo_inicial DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Si no se especifica fecha, usar la fecha actual
    IF @fecha_hasta IS NULL
        SET @fecha_hasta = CAST(GETDATE() AS DATE);
    
    DECLARE @fecha_desde DATE;
    DECLARE @fecha_actual DATE;
    
    -- Determinar la fecha desde la cual empezar
    -- Buscar la fecha más antigua entre gastos y pagos
    SELECT @fecha_desde = MIN(fecha_minima)
    FROM (
        SELECT MIN(fecha) AS fecha_minima
        FROM Pago.GastoOrdinario
        WHERE id_consorcio = @id_consorcio
        
        UNION ALL
        
        SELECT MIN(fecha) AS fecha_minima
        FROM Pago.GastoExtraordinario
        WHERE id_consorcio = @id_consorcio
        
        UNION ALL
        
        SELECT MIN(PA.fecha) AS fecha_minima
        FROM Pago.PagoAsociado PA
        INNER JOIN Consorcio.UnidadFuncional UF ON PA.id_unidad = UF.id_unidad
        WHERE UF.id_consorcio = @id_consorcio
    ) AS Fechas;
    
    -- Si no hay datos, no hacer nada
    IF @fecha_desde IS NULL
    BEGIN
        PRINT 'No hay datos de pagos o gastos para este consorcio.';
        RETURN;
    END
    
    -- Comenzar desde el primer día del mes de la fecha más antigua
    SET @fecha_desde = DATEFROMPARTS(YEAR(@fecha_desde), MONTH(@fecha_desde), 1);
    
    PRINT '========================================';
    PRINT 'Generando Estados Financieros';
    PRINT 'Consorcio: ' + CAST(@id_consorcio AS VARCHAR);
    PRINT 'Desde: ' + CONVERT(VARCHAR, @fecha_desde, 103);
    PRINT 'Hasta: ' + CONVERT(VARCHAR, @fecha_hasta, 103);
    PRINT 'Saldo Inicial: $' + CAST(@saldo_inicial AS VARCHAR);
    PRINT '========================================';
    
    -- Si hay un saldo inicial, insertarlo como estado financiero del mes anterior
    IF @saldo_inicial <> 0
    BEGIN
        DECLARE @fecha_saldo_inicial DATE = DATEADD(MONTH, -1, @fecha_desde);
        SET @fecha_saldo_inicial = EOMONTH(@fecha_saldo_inicial);
        
        IF NOT EXISTS (SELECT 1 FROM Consorcio.EstadoFinanciero 
                       WHERE id_consorcio = @id_consorcio 
                       AND fecha = @fecha_saldo_inicial)
        BEGIN
            INSERT INTO Consorcio.EstadoFinanciero 
                (id_consorcio, fecha, saldo_anterior, saldo_cierre)
            VALUES 
                (@id_consorcio, @fecha_saldo_inicial, 0, @saldo_inicial);
            
            PRINT 'Saldo inicial registrado para: ' + CONVERT(VARCHAR, @fecha_saldo_inicial, 103);
        END
    END
    
    -- Iterar mes por mes generando los estados financieros
    SET @fecha_actual = @fecha_desde;
    
    WHILE @fecha_actual <= @fecha_hasta
    BEGIN
        DECLARE @fecha_mes DATE = EOMONTH(@fecha_actual);
        
        -- Generar estado financiero del mes
        EXEC Consorcio.GenerarEstadoFinanciero 
            @id_consorcio = @id_consorcio, 
            @fecha_cierre = @fecha_mes;
        
        PRINT 'Estado financiero generado: ' + 
              DATENAME(MONTH, @fecha_mes) + ' ' + CAST(YEAR(@fecha_mes) AS VARCHAR);
        
        -- Avanzar al siguiente mes
        SET @fecha_actual = DATEADD(MONTH, 1, @fecha_actual);
    END
    
    PRINT '========================================';
    PRINT 'Proceso completado exitosamente';
    PRINT '========================================';
    
    -- Mostrar resumen final
    SELECT 
        DATENAME(MONTH, fecha) + ' ' + CAST(YEAR(fecha) AS VARCHAR) AS 'Mes',
        FORMAT(saldo_anterior, 'C', 'es-AR') AS 'Saldo Anterior',
        FORMAT(ingreso_en_termino, 'C', 'es-AR') AS 'Ing. Término',
        FORMAT(ingreso_adeudado, 'C', 'es-AR') AS 'Ing. Adeudado',
        FORMAT(ingreso_adelantado, 'C', 'es-AR') AS 'Ing. Adelantado',
        FORMAT(egresos_mes, 'C', 'es-AR') AS 'Egresos',
        FORMAT(saldo_cierre, 'C', 'es-AR') AS 'Saldo Cierre'
    FROM Consorcio.EstadoFinanciero
    WHERE id_consorcio = @id_consorcio
    ORDER BY fecha;
END
GO
