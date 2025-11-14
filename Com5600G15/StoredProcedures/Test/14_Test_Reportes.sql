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
	Consigna: Script para probar cada uno de los 6 reportes generados
    ---------------------------------------------------------------------
*/

USE Com5600G15;
GO

PRINT '========================================================================';
PRINT 'INICIO DE PRUEBAS DE REPORTES';
PRINT '========================================================================';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 1: Flujo de Caja Semanal (XML)
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 1: Flujo de Caja Semanal (Formato XML)';
PRINT 'Descripción: Muestra ingresos, gastos y saldo semanal con acumulado';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_flujo_caja_semanal_XML
    @id_consorcio = 1,
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31';

PRINT '';
PRINT 'REPORTE 1 EJECUTADO CORRECTAMENTE';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 2: Recaudación por Mes y Departamento
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 2: Recaudación Mensual por Departamento';
PRINT 'Descripción: Tabla cruzada de recaudación por mes y departamento (A-E)';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_recaudacion_mes_depto
    @id_consorcio = 1,
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31';

PRINT '';
PRINT 'REPORTE 2 EJECUTADO CORRECTAMENTE';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 3: Recaudación según Procedencia
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 3: Recaudación según Procedencia (Ordinarias/Extraordinarias)';
PRINT 'Descripción: Total esperado por tipo de expensa e intereses';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_recaudacion_segun_procedencia
    @nombre_consorcio = 'Consorcio Torre Central',
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31';

PRINT '';
PRINT 'REPORTE 3 EJECUTADO CORRECTAMENTE';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 4: Top de Ingresos y Gastos Mensuales
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 4: Top 5 Meses con Mayores Ingresos y Gastos';
PRINT 'Descripción: Ranking de meses con mayor movimiento económico';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_top_ingresos_gastos
    @id_consorcio = 1,
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31',
    @topN = 5;

PRINT '';
PRINT 'REPORTE 4 EJECUTADO CORRECTAMENTE';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 5: Top 3 Propietarios Morosos (XML)
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 5: Top 3 Propietarios con Mayor Morosidad (Formato XML)';
PRINT 'Descripción: Propietarios con mayor deuda, incluyendo datos de contacto';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_top_morosos_XML
    @id_consorcio = 1,
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31',
    @topN = 3;

PRINT '';
PRINT 'REPORTE 5 EJECUTADO CORRECTAMENTE';
PRINT '';

--------------------------------------------------------------------------------
-- REPORTE 6: Días entre Pagos por Unidad Funcional
--------------------------------------------------------------------------------
PRINT '------------------------------------------------------------------------';
PRINT 'REPORTE 6: Análisis de Días entre Pagos por Unidad';
PRINT 'Descripción: Historial de pagos con estadísticas y clasificación';
PRINT '------------------------------------------------------------------------';

EXEC Reporte.sp_reporte_dias_entre_pagos
    @id_consorcio = 1,
    @fecha_desde = '2024-01-01',
    @fecha_hasta = '2024-12-31';

PRINT '';
PRINT 'REPORTE 6 EJECUTADO CORRECTAMENTE';
PRINT '';
