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

SET NOCOUNT ON;

-- REPORTE 1: Flujo de Caja Semanal (XML)
-- Consorcio Azcuenaga - período con datos
EXEC Reporte.sp_reporte_flujo_caja_semanal_XML
    @id_consorcio = 1,
    @fecha_desde = '2025-08-01',
    @fecha_hasta = '2025-10-31';

-- REPORTE 2: Recaudación por Mes y Departamento
-- Consorcio Alzaga
EXEC Reporte.sp_reporte_recaudacion_mes_depto
    @id_consorcio = 1,
    @fecha_desde = '2024-11-01',
    @fecha_hasta = '2025-10-31';

-- REPORTE 3: Recaudación según Procedencia
-- Consorcio Alberdi
EXEC Reporte.sp_reporte_recaudacion_segun_procedencia
    @nombre_consorcio = 'Alberdi',
    @fecha_desde = '2025-08-01',
    @fecha_hasta = '2025-10-31';

-- REPORTE 4: Top de Ingresos y Gastos Mensuales
-- Consorcio Unzue
EXEC Reporte.sp_reporte_top_ingresos_gastos
    @id_consorcio = 4,
    @fecha_desde = '2025-08-01',
    @fecha_hasta = '2025-10-31',
    @topN = 3;

-- REPORTE 5: Top 3 Propietarios Morosos (XML)
-- Consorcio Pereyra Iraola
EXEC Reporte.sp_reporte_top_morosos_XML
    @id_consorcio = 5,
    @fecha_desde = '2025-08-01',
    @fecha_hasta = '2025-10-31',
    @topN = 3;

-- REPORTE 6: Días entre Pagos por Unidad Funcional
-- Consorcio Azcuenaga
EXEC Reporte.sp_reporte_dias_entre_pagos
    @id_consorcio = 1,
    @fecha_desde = '2025-08-01',
    @fecha_hasta = '2025-11-30';

PRINT 'Reportes ejecutados correctamente';
GO