/*
    ---------------------------------------------------------------------
    -Fecha: 02/11/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Perez
    - Cristian Vergara
    -Script: PRUEBAS generar registro estado financiero
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO
-- ============================================================================
-- EJEMPLOS DE USO
-- ============================================================================

-- 1. Generar TODOS los estados financieros del consorcio 1
--    (desde la primera transacción hasta hoy, con saldo inicial $0)
EXEC Consorcio.GenerarTodosEstadosFinancieros @id_consorcio = 1;

-- 2. Generar todos los estados financieros con un saldo inicial
EXEC Consorcio.GenerarTodosEstadosFinancieros 
@id_consorcio = 1, 
@saldo_inicial = 50000.00;

-- 3. Generar estados financieros hasta una fecha específica
EXEC Consorcio.GenerarTodosEstadosFinancieros 
@id_consorcio = 1, 
@fecha_hasta = '2025-10-31',
@saldo_inicial = 50000.00;

-- 4. Generar un solo mes (útil para actualizar)
EXEC Consorcio.GenerarEstadoFinanciero 
@id_consorcio = 1, 
@fecha_cierre = '2025-10-31';

-- 5. Consultar los resultados
SELECT * FROM Consorcio.EstadoFinanciero 
WHERE id_consorcio = 1 
ORDER BY fecha;
