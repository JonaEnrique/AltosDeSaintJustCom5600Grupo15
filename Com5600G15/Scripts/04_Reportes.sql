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
--------------------------------------------------------------------------------
--REPORTE 2
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_recaudacion_mes_depto
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Datos AS (
        SELECT 
            MONTH(p.fecha) AS MesNumero,
            FORMAT(p.fecha,'MMMM yyyy','es-es') AS Mes, --Notita mental, format para que de los meses en español
            u.departamento AS Departamento,
            p.importe
        FROM Pago.PagoAsociado p
        INNER JOIN Consorcio.UnidadFuncional u
            ON p.id_unidad = u.id_unidad
        WHERE u.id_consorcio = @id_consorcio
          AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
    )
    SELECT 
        Mes,
        ISNULL([A],0) AS [A],
        ISNULL([B],0) AS [B],
        ISNULL([C],0) AS [C],
        ISNULL([D],0) AS [D],
        ISNULL([E],0) AS [E]
    FROM Datos
    PIVOT (
        SUM(importe) FOR Departamento IN ([A],[B],[C],[D],[E])
    ) AS TablaCruzada
    ORDER BY MesNumero;
END;
GO
--------------------------------------------------------------------------------
--REPORTE 3
--------------------------------------------------------------------------------
/*NOTA: Este reporte calcula la recaudacion total ESPERADA (no real) segun su procedencia
para un consorcio y período determinado, basandose en registros de la tabla de Pago.Prorrateo*/
CREATE OR ALTER PROCEDURE Reporte.sp_reporte_recaudacion_segun_procedencia
(
    @nombre_consorcio VARCHAR(200),
    @fecha_desde DATE,
    @fecha_hasta DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FORMAT(p.fecha, 'yyyy-MM') AS Periodo,
        SUM(p.expensas_ordinarias) AS TotalOrdinario,
        SUM(p.expensas_extraordinarias) AS TotalExtraordinario,
        SUM(p.intereses) AS TotalIntereses,
        SUM(p.total_a_pagar) AS TotalAPagar
    FROM Pago.Prorrateo AS p
        INNER JOIN Consorcio.UnidadFuncional AS uf
            ON p.id_unidad = uf.id_unidad
        INNER JOIN Consorcio.Consorcio AS c
            ON uf.id_consorcio = c.id_consorcio
    WHERE c.nombre = @nombre_consorcio
      AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
    GROUP BY FORMAT(p.fecha, 'yyyy-MM')
    ORDER BY Periodo;
END;
GO
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

--------------------------------------------------------------------------------
-- REPORTE 5: Top 3 propietarios con mayor morosidad (XML)
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_top_morosos_XML
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @topN INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------
    -- Calcula deuda total por propietario en el periodo
    --------------------------------------------------------------
    ;WITH MorosidadPorPropietario AS (
        SELECT 
            per.dni,
            per.nombre,
            per.apellido,
            per.mail,
            per.telefono,
            u.id_unidad,
            u.piso,
            u.departamento,
            SUM(pr.deudas + pr.intereses) AS deuda_total,
            SUM(pr.saldo_anterior_abonado) AS saldo_pendiente_anterior,
            COUNT(DISTINCT pr.fecha) AS meses_con_deuda
        FROM Pago.Prorrateo pr
        INNER JOIN Consorcio.UnidadFuncional u 
            ON pr.id_unidad = u.id_unidad
        INNER JOIN Consorcio.PersonaUnidad pu 
            ON u.id_unidad = pu.id_unidad
        INNER JOIN Consorcio.Persona per 
            ON pu.dni = per.dni
        WHERE u.id_consorcio = @id_consorcio
          AND pu.rol = 'P' -- Solo propietarios
          AND pr.fecha BETWEEN @fecha_desde AND @fecha_hasta
          AND (pu.fecha_fin IS NULL OR pu.fecha_fin >= pr.fecha) -- Propietario activo en ese periodo
          AND (pr.deudas > 0 OR pr.intereses > 0) -- Solo con deudas
        GROUP BY per.dni, per.nombre, per.apellido, per.mail, per.telefono,
                 u.id_unidad, u.piso, u.departamento
    ),
    
    --------------------------------------------------------------
    -- Top N propietarios más morosos
    --------------------------------------------------------------
    TopMorosos AS (
        SELECT TOP (@topN)
            dni,
            nombre,
            apellido,
            mail,
            telefono,
            piso,
            departamento,
            deuda_total,
            saldo_pendiente_anterior,
            meses_con_deuda,
            RANK() OVER (ORDER BY deuda_total DESC) AS ranking
        FROM MorosidadPorPropietario
        ORDER BY deuda_total DESC
    )

    --------------------------------------------------------------
    -- RESULTADO EN XML
    --------------------------------------------------------------
    SELECT 
        ranking AS [@Ranking],
        dni AS [DatosContacto/DNI],
        nombre AS [DatosContacto/Nombre],
        apellido AS [DatosContacto/Apellido],
        ISNULL(mail, 'No registrado') AS [DatosContacto/Email],
        ISNULL(telefono, 'No registrado') AS [DatosContacto/Telefono],
        CONCAT(piso, departamento) AS [Unidad],
        deuda_total AS [DeudaTotal],
        saldo_pendiente_anterior AS [SaldoPendienteAnterior],
        meses_con_deuda AS [MesesConDeuda]
    FROM TopMorosos
    ORDER BY ranking
    FOR XML PATH('Propietario'), ROOT('PropietariosMorosos'), ELEMENTS;
END;
GO
--------------------------------------------------------------------------------
-- REPORTE 6: Fechas de pagos y días entre pagos por Unidad Funcional
--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_dias_entre_pagos
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    --------------------------------------------------------------
    -- Obtiene pagos ordenados por UF y fecha
    --------------------------------------------------------------
    ;WITH PagosOrdenados AS (
        SELECT 
            u.id_unidad,
            CONCAT(u.piso, u.departamento) AS unidad,
            p.fecha AS fecha_pago,
            p.importe,
            -- Obtiene la fecha del pago anterior
            LAG(p.fecha) OVER (PARTITION BY u.id_unidad ORDER BY p.fecha) AS fecha_pago_anterior,
            -- Calcula días entre pagos
            DATEDIFF(DAY, 
                LAG(p.fecha) OVER (PARTITION BY u.id_unidad ORDER BY p.fecha),
                p.fecha
            ) AS dias_entre_pagos,
            -- Número de secuencia del pago
            ROW_NUMBER() OVER (PARTITION BY u.id_unidad ORDER BY p.fecha) AS nro_pago
        FROM Pago.PagoAsociado p
        INNER JOIN Consorcio.UnidadFuncional u 
            ON p.id_unidad = u.id_unidad
        WHERE u.id_consorcio = @id_consorcio
          AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
    ),

    --------------------------------------------------------------
    -- Estadísticas por unidad
    --------------------------------------------------------------
    EstadisticasPorUnidad AS (
        SELECT 
            id_unidad,
            unidad,
            COUNT(*) AS total_pagos,
            AVG(CAST(dias_entre_pagos AS FLOAT)) AS promedio_dias_entre_pagos,
            MIN(dias_entre_pagos) AS min_dias,
            MAX(dias_entre_pagos) AS max_dias
        FROM PagosOrdenados
        WHERE dias_entre_pagos IS NOT NULL
        GROUP BY id_unidad, unidad
    )

    --------------------------------------------------------------
    -- RESULTADO FINAL
    --------------------------------------------------------------
    SELECT 
        po.unidad AS Unidad,
        po.nro_pago AS NroPago,
        CONVERT(VARCHAR(10), po.fecha_pago, 103) AS FechaPago,
        po.importe AS ImportePagado,
        CASE 
            WHEN po.fecha_pago_anterior IS NULL THEN 'Primer pago'
            ELSE CONVERT(VARCHAR(10), po.fecha_pago_anterior, 103)
        END AS FechaPagoAnterior,
        ISNULL(po.dias_entre_pagos, 0) AS DiasEntrePagos,
        CASE 
            WHEN po.dias_entre_pagos IS NULL THEN '-'
            WHEN po.dias_entre_pagos <= 30 THEN 'Normal'
            WHEN po.dias_entre_pagos <= 60 THEN 'Atraso Leve'
            WHEN po.dias_entre_pagos <= 90 THEN 'Atraso Moderado'
            ELSE 'Atraso Grave'
        END AS EstadoPago,
        ISNULL(CAST(est.promedio_dias_entre_pagos AS DECIMAL(10,2)), 0) AS PromedioUnidad,
        est.total_pagos AS TotalPagosUnidad
    FROM PagosOrdenados po
    LEFT JOIN EstadisticasPorUnidad est 
        ON po.id_unidad = est.id_unidad
    ORDER BY po.unidad, po.fecha_pago;
END;
GO
