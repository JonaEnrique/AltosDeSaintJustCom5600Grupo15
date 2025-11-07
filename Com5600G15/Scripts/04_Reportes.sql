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

/*
  REPORTE 3 (PIVOT)
  Devuelve las procedencias (Ordinario, Extraordinario, Deuda, Interes, Cochera, Baulera)
  como filas y los meses del periodo (yyyy-MM) como columnas utilizando PIVOT dinámico.
*/

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_recaudacion_prorrateo_pivot
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Generar lista de meses (periodos) en formato yyyy-MM dentro del rango
    DECLARE @cols NVARCHAR(MAX);
    SELECT @cols = STUFF((
        SELECT DISTINCT ',' + QUOTENAME(FORMAT(p.fecha,'yyyy-MM'))
        FROM Pago.Prorrateo p
        JOIN Consorcio.UnidadFuncional u ON u.id_unidad = p.id_unidad
        WHERE u.id_consorcio = @id_consorcio
          AND p.fecha BETWEEN @fecha_desde AND @fecha_hasta
        ORDER BY MIN(p.fecha)
        FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 1, '');

    IF @cols IS NULL OR LTRIM(RTRIM(@cols)) = ''
    BEGIN
        -- No hay datos en el rango
        SELECT 'No hay datos para el periodo especificado.' AS Mensaje;
        RETURN;
    END

    -- Construir SQL dinámico: agregamos por mes y luego unpivot y pivot dinámico
    DECLARE @sql NVARCHAR(MAX) = N'';

    SET @sql = N'
    ;WITH agreg AS (
        SELECT
            FORMAT(p.fecha, ''yyyy-MM'') AS periodo,
            SUM(ISNULL(p.expensas_ordinarias,0)) AS Ordinario,
            SUM(ISNULL(p.expensas_extraordinarias,0)) AS Extraordinario,
            SUM(ISNULL(p.deudas,0)) AS Deuda,
            SUM(ISNULL(p.intereses,0)) AS Interes,
            SUM(ISNULL(p.precio_cocheras,0)) AS Cochera,
            SUM(ISNULL(p.precio_bauleras,0)) AS Baulera
        FROM Pago.Prorrateo p
        JOIN Consorcio.UnidadFuncional u ON u.id_unidad = p.id_unidad
        WHERE u.id_consorcio = ' + CAST(@id_consorcio AS NVARCHAR(10)) + '
          AND p.fecha BETWEEN ''' + CONVERT(NVARCHAR(10),@fecha_desde,120) + ''' AND ''' + CONVERT(NVARCHAR(10),@fecha_hasta,120) + '''
        GROUP BY FORMAT(p.fecha, ''yyyy-MM'')
    )

    SELECT procedencia, ' + @cols + ' FROM (
        SELECT periodo, procedencia, monto FROM (
            SELECT periodo, Ordinario, Extraordinario, Deuda, Interes, Cochera, Baulera
            FROM agreg
        ) a
        UNPIVOT (monto FOR procedencia IN (Ordinario, Extraordinario, Deuda, Interes, Cochera, Baulera)) up
    ) src
    PIVOT (
        SUM(monto) FOR periodo IN (' + @cols + ')
    ) pvt
    ORDER BY CASE WHEN procedencia = ''Ordinario'' THEN 1
                  WHEN procedencia = ''Extraordinario'' THEN 2
                  WHEN procedencia = ''Deuda'' THEN 3
                  WHEN procedencia = ''Interes'' THEN 4
                  WHEN procedencia = ''Cochera'' THEN 5
                  WHEN procedencia = ''Baulera'' THEN 6
                  ELSE 99 END;'
;

    EXEC sp_executesql @sql;
END;
GO


-- Ejemplo de ejecución (usar EXEC si quieres correrlo)
-- EXEC Reporte.sp_reporte_flujo_caja_semanal_XML
--      @id_consorcio = 1,
--      @fecha_desde = '2024-01-01',
--      @fecha_hasta = '2024-12-31';
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


-- Ejemplo de ejecución
EXEC Reporte.sp_reporte_recaudacion_mes_depto
     @id_consorcio = 1,
     @fecha_desde = '2024-01-01',
     @fecha_hasta = '2024-12-31';

--------------------------------------------------------------------------------
--REPORTE 3
--------------------------------------------------------------------------------
SELECT * FROM Pago.Prorrateo
------------------------------
-- 1) Insert de CONSORCIOS
------------------------------
INSERT INTO Consorcio.Consorcio
    (nombre,                direccion,                   cant_unidades_funcionales, m2_totales, vencimiento1,  vencimiento2)
VALUES
    ('Altos de Saint Just', 'Av. Siempre Viva 1234',     3,                         600.00,     '2025-01-10', '2025-01-20'),
    ('Edificio Patagonia',  'Calle del Lago 456',        2,                         400.00,     '2025-01-12', '2025-01-22');

go

-- Capturamos IDs por nombre (evitamos depender del IDENTITY)
DECLARE @idConsorcio1 INT, @idConsorcio2 INT;
SELECT @idConsorcio1 = id_consorcio FROM Consorcio.Consorcio WHERE nombre = 'Altos de Saint Just';
SELECT @idConsorcio2 = id_consorcio FROM Consorcio.Consorcio WHERE nombre = 'Edificio Patagonia';

--------------------------------------
-- 2) Unidades funcionales (Consorcio 1)
--    Diseñadas para tus prorrateos: 1A, 2B, 3C
--------------------------------------
INSERT INTO Consorcio.UnidadFuncional
    (id_consorcio,   piso, departamento, coeficiente, m2_unidad, m2_baulera, m2_cochera, precio_cochera, precio_baulera)
VALUES
    (@idConsorcio1, '1',   'A',          33.3,        200.00,    4.00,       12.50,      5000.00,        2000.00),
    (@idConsorcio1, '2',   'B',          33.3,        200.00,    0.00,       0.00,       0.00,           0.00),
    (@idConsorcio1, '3',   'C',          33.4,        200.00,    0.00,       0.00,       0.00,           0.00);
--------------------------------------
-- 3) Unidades funcionales (Consorcio 2)
--    (opcionales, por si necesitás más datos)
--------------------------------------
INSERT INTO Consorcio.UnidadFuncional
    (id_consorcio,   piso, departamento, coeficiente, m2_unidad, m2_baulera, m2_cochera, precio_cochera, precio_baulera)
VALUES
    (@idConsorcio2, '1',   'A',          50.0,        200.00,    2.00,       0.00,       0.00,           1000.00),
    (@idConsorcio2, '1',   'B',          50.0,        200.00,    2.00,       0.00,       0.00,           1000.00);

--------------------------------------
-- 4) Verificación rápida
--------------------------------------
SELECT 'Consorcios' AS Tabla, * FROM Consorcio.Consorcio ORDER BY id_consorcio;
SELECT 'UFs'        AS Tabla, * FROM Consorcio.UnidadFuncional ORDER BY id_unidad;


USE Com5600G15;
GO

DECLARE @Consorcio NVARCHAR(200) = N'Altos de Saint Just';

;WITH UF AS (
    SELECT TOP (3)
        u.id_unidad, u.piso, u.departamento,
        u.coeficiente,                                   -- 33.3, 33.3, 33.4
        u.precio_cochera, u.precio_baulera
    FROM Consorcio.UnidadFuncional u
    JOIN Consorcio.Consorcio c ON c.id_consorcio = u.id_consorcio
    WHERE c.nombre = @Consorcio
    ORDER BY u.id_unidad
)
-- Si vas a re-ejecutar, destapá este borrado para no violar la UNIQUE (id_unidad, fecha)
-- DELETE p
-- FROM Pago.Prorrateo p
-- WHERE p.id_unidad IN (SELECT id_unidad FROM UF)
--   AND p.fecha IN ('2025-01-01','2025-02-01','2025-03-01');

INSERT INTO Pago.Prorrateo
(
    id_unidad, fecha, porcentaje_m2, piso, depto, nombre_propietario,
    precio_cocheras, precio_bauleras,
    saldo_anterior_abonado, pagos_recibidos, deudas, intereses,
    expensas_ordinarias, expensas_extraordinarias, total_a_pagar
)
SELECT
    u.id_unidad,
    v.fecha,
    CAST(u.coeficiente/100.0 AS DECIMAL(6,3)) AS porcentaje_m2, -- 0.333, 0.334 ...
    u.piso,
    u.departamento,
    CONCAT(N'Prop UF ', u.piso, u.departamento) AS nombre_propietario,
    u.precio_cochera     AS precio_cocheras,
    u.precio_baulera     AS precio_bauleras,
    v.saldo_anterior_abonado,
    v.pagos_recibidos,
    v.deudas,
    v.intereses,
    v.expensas_ordinarias,
    v.expensas_extraordinarias,
    /* total_a_pagar = suma de conceptos del período */
    v.expensas_ordinarias
  + v.expensas_extraordinarias
  + v.deudas
  + v.intereses
  + u.precio_cochera
  + u.precio_baulera AS total_a_pagar
FROM UF u
CROSS APPLY (VALUES
    /* ---------- ENERO 2025 ---------- */
    (CAST('2025-01-01' AS date),
     0.00, 0.00,           -- saldo_anterior_abonado, pagos_recibidos
     1000.00, 150.00,      -- deudas, intereses
     25000.00, 0.00),      -- expensas_ordinarias, expensas_extraordinarias

    /* ---------- FEBRERO 2025 ---------- */
    ('2025-02-01',
     0.00, 0.00,
     700.00, 60.00,
     24000.00, 4000.00),

    /* ---------- MARZO 2025 ---------- */
    ('2025-03-01',
     0.00, 0.00,
     1000.00, 80.00,
     24000.00, 2000.00)
) v(fecha, saldo_anterior_abonado, pagos_recibidos, deudas, intereses, expensas_ordinarias, expensas_extraordinarias);

-- Verificación rápida
SELECT fecha, id_unidad, piso, depto,
       expensas_ordinarias, expensas_extraordinarias,
        deudas, intereses, precio_cocheras, precio_bauleras, total_a_pagar
FROM Pago.Prorrateo
WHERE fecha IN ('2025-01-01','2025-02-01','2025-03-01')
  AND id_unidad IN (SELECT id_unidad FROM Consorcio.UnidadFuncional u
                    JOIN Consorcio.Consorcio c ON c.id_consorcio=u.id_consorcio
                    WHERE c.nombre=@Consorcio)
ORDER BY fecha, id_unidad;


SELECT * FROM Pago.Prorrateo

CREATE OR ALTER PROCEDURE Reporte.sp_reporte_top_ingresos_gastos
    @id_consorcio INT,
    @fecha_desde DATE,
    @fecha_hasta DATE
AS
BEGIN
		WITH Aux AS (SELECT
            --Periodo  = DATEFROMPARTS(YEAR(fecha), MONTH(fecha), 1),
			Periodo = FORMAT(p.fecha, 'yyyy-MM'),
            expensas_ordinarias,
			expensas_extraordinarias,
			precio_cocheras,
			precio_bauleras,
			deudas,
			intereses
        FROM Pago.Prorrateo p-- <- usa tu tabla con (fecha, concepto, importe)
        WHERE fecha >= @fecha_desde AND fecha < DATEADD(day, 1, @fecha_hasta))
END;
GO

EXEC Reporte.sp_reporte_top_ingresos_gastos
     @id_consorcio = 1,
     @fecha_desde  = '2025-01-01',
     @fecha_hasta  = '2025-03-31'


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

-- Ejemplo de ejecución
EXEC Reporte.sp_reporte_top_morosos_XML
     @id_consorcio = 1,
     @fecha_desde = '2024-01-01',
     @fecha_hasta = '2024-12-31',
     @topN = 3;