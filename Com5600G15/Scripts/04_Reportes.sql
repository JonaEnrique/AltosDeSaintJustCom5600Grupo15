/*
    ---------------------------------------------------------------------
    -Fecha: 27/10/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada

    - Integrantes:
        - Jonathan Enrique
		- Ariel De Brito
		- Franco Perez
		- Cristian Vergara

	 -Consigna:Generacion de los reportes solicitados.
    ---------------------------------------------------------------------
*/

USE Com5600G15;
GO

--------------------------------------------------------------------------------
--REPORTE 1
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_flujo_caja_semanal_XML
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------
    -- INGRESOS SEMANALES (Pagos Asociados)
    --------------------------------------------------------------
    ;WITH ingresos AS (
        SELECT 
            DATEPART(YEAR, p.fecha) AS anio,
            DATEPART(WEEK, p.fecha) AS semana,
            SUM(p.importe) AS total_ingreso
        FROM Pago.PagoAsociado p
        JOIN Consorcio.UnidadFuncional u 
            ON u.id_unidad = p.id_unidad
        WHERE u.id_consorcio = @id_consorcio
          AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
        GROUP BY DATEPART(YEAR, p.fecha), DATEPART(WEEK, p.fecha)
    ),

    --------------------------------------------------------------
    -- GASTOS SEMANALES (Ordinarios + Extraordinarios)
    --------------------------------------------------------------
    gastos AS (
        SELECT 
            DATEPART(YEAR, g.fecha) AS anio,
            DATEPART(WEEK, g.fecha) AS semana,
            SUM(g.importe) AS total_gasto
        FROM (
            SELECT id_consorcio, fecha, importe FROM Pago.GastoOrdinario
            UNION ALL
            SELECT id_consorcio, fecha, importe FROM Pago.GastoExtraordinario
        ) g
        WHERE g.id_consorcio = @id_consorcio
          AND g.fecha BETWEEN @fecha_desde AND @fecha_hasta
        GROUP BY DATEPART(YEAR, g.fecha), DATEPART(WEEK, g.fecha)
    ),

    --------------------------------------------------------------
    -- COMBINACIÓN INGRESOS - GASTOS
    --------------------------------------------------------------
    flujo AS (
        SELECT 
            COALESCE(i.anio, g.anio) AS anio,
            COALESCE(i.semana, g.semana) AS semana,
            ISNULL(i.total_ingreso, 0) AS total_ingreso,
            ISNULL(g.total_gasto, 0) AS total_gasto
        FROM ingresos i
        FULL OUTER JOIN gastos g
            ON i.anio = g.anio AND i.semana = g.semana
    )

    --------------------------------------------------------------
    -- RESULTADO FINAL: FLUJO, PROMEDIO Y ACUMULADO (XML)
    --------------------------------------------------------------
    SELECT 
        anio AS [@Año],
        semana AS [@Semana],
        total_ingreso AS [Ingresos],
        total_gasto AS [Gastos],
        (total_ingreso - total_gasto) AS [SaldoSemanal],
        ROUND(AVG(total_ingreso) OVER(), 2) AS [PromedioIngresos],
        SUM(total_ingreso - total_gasto) OVER(ORDER BY anio, semana) AS [Acumulado]
    FROM flujo
    ORDER BY anio, semana
    FOR XML PATH('Semana'), ROOT('FlujoCajaSemanal'), ELEMENTS;
END;
GO

Reporte.sp_reporte_flujo_caja_semanal_XML
     @id_consorcio = 1,
     @fecha_desde = '2024-01-01',
     @fecha_hasta = '2024-12-31';

--------------------------------------------------------------------------------
--REPORTE 4
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_top_ingresos_gastos
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

EXEC sp_reporte_top_ingresos_gastos
     @id_consorcio = 2,
     @fecha_desde = '2024-01-01',
     @fecha_hasta = '2024-12-31',
     @topN = 3;
