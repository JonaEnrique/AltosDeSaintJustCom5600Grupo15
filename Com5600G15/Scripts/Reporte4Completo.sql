CREATE OR ALTER PROCEDURE sp_reporte_top_ingresos_gastoss
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @topN INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------
    -- GASTOS MENSUALES (Ordinarios + Extraordinarios)
    --------------------------------------------------------------
    ;WITH gastos AS (
        SELECT YEAR(fecha) AS anio, MONTH(fecha) AS mes, SUM(importe) AS total_gasto
        FROM (
            SELECT fecha, importe
            FROM Pago.GastoOrdinario
            WHERE id_consorcio = @id_consorcio
              AND fecha BETWEEN @fecha_desde AND @fecha_hasta
            
            UNION ALL
            
            SELECT fecha, importe
            FROM Pago.GastoExtraordinario
            WHERE id_consorcio = @id_consorcio
              AND fecha BETWEEN @fecha_desde AND @fecha_hasta
        ) g
        GROUP BY YEAR(fecha), MONTH(fecha)
    ),

    topGastos AS (
        SELECT TOP(@topN) anio, mes, total_gasto
        FROM gastos
        ORDER BY total_gasto DESC
    ),

    --------------------------------------------------------------
    -- INGRESOS MENSUALES desde pagos asociados
    --------------------------------------------------------------
    ingresos AS (
        SELECT YEAR(p.fecha) AS anio, MONTH(p.fecha) AS mes,
               SUM(p.importe) AS total_ingreso
        FROM Pago.PagoAsociado p
        JOIN Consorcio.UnidadFuncional u ON u.id_unidad = p.id_unidad
        WHERE u.id_consorcio = @id_consorcio
          AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
        GROUP BY YEAR(p.fecha), MONTH(p.fecha)
    ),

    topIngresos AS (
        SELECT TOP(@topN) anio, mes, total_ingreso
        FROM ingresos
        ORDER BY total_ingreso DESC
    )

    --------------------------------------------------------------
    -- RESULTADO FINAL
    --------------------------------------------------------------
    SELECT 
        'TOP GASTOS' AS tipo, 
        FORMAT(DATEFROMPARTS(anio, mes, 1), 'yyyy-MM') AS periodo, 
        total_gasto AS monto
    FROM topGastos

    UNION ALL

    SELECT 
        'TOP INGRESOS', 
        FORMAT(DATEFROMPARTS(anio, mes, 1), 'yyyy-MM'), 
        total_ingreso
    FROM topIngresos

    ORDER BY tipo, monto DESC;
END;
GO

EXEC sp_reporte_top_ingresos_gastoss 
     @id_consorcio = 2,
     @fecha_desde = '2024-01-01',
     @fecha_hasta = '2024-12-31',
     @topN = 3;