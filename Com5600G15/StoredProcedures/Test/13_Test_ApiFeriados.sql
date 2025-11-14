/*
    ---------------------------------------------------------------------
    Entrega 6 - API: Feriados Argentina
    Grupo: 15
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Pérez
    - Cristian Vergara
    - Consigna: Test Api feriados
    - API: https://api.argentinadatos.com/v1/feriados/2025
    ---------------------------------------------------------------------
*/


USE Com5600G15
GO

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

-- Insertar consorcio de prueba
INSERT INTO Consorcio.Consorcio (nombre, direccion, cant_unidades_funcionales, m2_totales, vencimiento1, vencimiento2)
VALUES 
    ('Edificio San Martin', 'Av San Martin 1234', 12, 1500.00, '2025-12-25', '2026-01-01'),
    ('Torre Central', 'Calle Central 567', 8, 1000.00, '2025-03-24', '2025-04-18'),
    ('Residencial Norte', 'Av Norte 890', 15, 2000.00, '2025-11-16', '2025-12-08')
GO

-- Insertar unidades funcionales
INSERT INTO Consorcio.UnidadFuncional (id_consorcio, piso, departamento, coeficiente, m2_unidad, m2_baulera, m2_cochera)
VALUES 
    (1, '1', 'A', 1.2, 80.00, 5.00, 12.00),
    (1, '2', 'B', 1.0, 70.00, 5.00, 12.00),
    (2, '3', 'C', 1.5, 100.00, 8.00, 15.00),
    (3, '5', 'D', 1.1, 85.00, 6.00, 13.00)
GO

-- Insertar personas
INSERT INTO Consorcio.Persona (dni, nombre, apellido, mail, telefono, cvu_cbu)
VALUES 
    (30123456, 'Juan', 'Perez', 'juan.perez@mail.com', '1122334455', '0000003100012345678901'),
    (28765432, 'Maria', 'Gonzalez', 'maria.g@mail.com', '1198765432', '0000003100098765432109'),
    (35987654, 'Carlos', 'Lopez', 'carlos.l@mail.com', '1155667788', '0000003100055667788990')
GO

-- ============================================
-- PRUEBA 1: Consultar feriados del año
-- ============================================
PRINT '========================================='
PRINT 'PRUEBA 1: Consultar feriados 2025'
PRINT '========================================='
PRINT ''

EXEC Reporte.SP_ObtenerFeriados @Anio = 2025
GO

-- ============================================
-- PRUEBA 2: Validar vencimientos de consorcios
-- ============================================
PRINT ''
PRINT '========================================='
PRINT 'PRUEBA 2: Validar vencimientos'
PRINT '========================================='
PRINT ''

-- Consorcio 1: Vencimientos en feriados
PRINT '--- Consorcio: Edificio San Martin ---'
PRINT 'Vencimiento 1: 25/12/2025 (Navidad - Jueves)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2025-12-25'
PRINT ''

PRINT 'Vencimiento 2: 01/01/2026 (Año Nuevo - Miercoles)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2026-01-01'
PRINT ''

-- Consorcio 2: Vencimientos en feriados
PRINT '--- Consorcio: Torre Central ---'
PRINT 'Vencimiento 1: 24/03/2025 (Memoria - Lunes)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2025-03-24'
PRINT ''

PRINT 'Vencimiento 2: 18/04/2025 (Viernes Santo)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2025-04-18'
PRINT ''

-- Consorcio 3: Vencimientos en fin de semana
PRINT '--- Consorcio: Residencial Norte ---'
PRINT 'Vencimiento 1: 16/11/2025 (Domingo)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2025-11-16'
PRINT ''

PRINT 'Vencimiento 2: 08/12/2025 (Inmaculada Concepcion - Lunes)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = '2025-12-08'
PRINT ''

-- ============================================
-- PRUEBA 3: Resumen de vencimientos por consorcio
-- ============================================
PRINT ''
PRINT '========================================='
PRINT 'PRUEBA 3: Resumen de vencimientos'
PRINT '========================================='
PRINT ''

SELECT 
    c.id_consorcio,
    c.nombre AS Consorcio,
    c.vencimiento1 AS Vencimiento1Original,
    c.vencimiento2 AS Vencimiento2Original,
    DATENAME(WEEKDAY, c.vencimiento1) AS DiaSemanaVenc1,
    DATENAME(WEEKDAY, c.vencimiento2) AS DiaSemanaVenc2
FROM Consorcio.Consorcio c
ORDER BY c.id_consorcio
GO

-- ============================================
-- PRUEBA 4: Simular registro de pago con validacion
-- ============================================
PRINT ''
PRINT '========================================='
PRINT 'PRUEBA 4: Registro de pagos'
PRINT '========================================='
PRINT ''

-- Insertar pagos en diferentes fechas
DECLARE @FechaPago1 DATE = '2025-12-25'  -- Navidad
DECLARE @FechaPago2 DATE = '2025-11-17'  -- Lunes normal
DECLARE @FechaPago3 DATE = '2025-11-16'  -- Domingo

-- Validar fecha de pago 1
PRINT 'Validando fecha de pago: 25/12/2025 (Navidad)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = @FechaPago1

-- Insertar el pago con la fecha validada
INSERT INTO Pago.PagoAsociado (id_unidad, fecha, cvu_cbu, importe)
VALUES (1, @FechaPago1, '0000003100012345678901', 50000.00)
PRINT 'Pago registrado'
PRINT ''

-- Validar fecha de pago 2
PRINT 'Validando fecha de pago: 17/11/2025 (Lunes habil)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = @FechaPago2

INSERT INTO Pago.PagoAsociado (id_unidad, fecha, cvu_cbu, importe)
VALUES (2, @FechaPago2, '0000003100098765432109', 45000.00)
PRINT 'Pago registrado'
PRINT ''

-- Validar fecha de pago 3
PRINT 'Validando fecha de pago: 16/11/2025 (Domingo)'
EXEC Consorcio.SP_ValidarVencimiento @Fecha = @FechaPago3

INSERT INTO Pago.PagoAsociado (id_unidad, fecha, cvu_cbu, importe)
VALUES (3, @FechaPago3, '0000003100055667788990', 60000.00)
PRINT 'Pago registrado'
PRINT ''

-- ============================================
-- PRUEBA 5: Reporte de pagos realizados
-- ============================================
PRINT ''
PRINT '========================================='
PRINT 'PRUEBA 5: Reporte de pagos'
PRINT '========================================='
PRINT ''

SELECT 
    pa.id_expensa,
    c.nombre AS Consorcio,
    uf.piso + uf.departamento AS Unidad,
    p.nombre + ' ' + p.apellido AS Propietario,
    pa.fecha AS FechaPago,
    DATENAME(WEEKDAY, pa.fecha) AS DiaSemana,
    pa.importe AS Importe,
    CASE 
        WHEN DATENAME(WEEKDAY, pa.fecha) IN ('Saturday', 'Sunday', 'sabado', 'domingo') 
        THEN 'Fin de semana'
        ELSE 'Dia habil'
    END AS TipoDia
FROM Pago.PagoAsociado pa
INNER JOIN Consorcio.UnidadFuncional uf ON pa.id_unidad = uf.id_unidad
INNER JOIN Consorcio.Consorcio c ON uf.id_consorcio = c.id_consorcio
INNER JOIN Consorcio.Persona p ON pa.cvu_cbu = p.cvu_cbu
ORDER BY pa.fecha
GO

-- ============================================
-- PRUEBA 6: Detectar vencimientos problematicos
-- ============================================
PRINT ''
PRINT '========================================='
PRINT 'PRUEBA 6: Vencimientos problematicos'
PRINT '========================================='
PRINT ''

SELECT 
    c.nombre AS Consorcio,
    c.vencimiento1 AS Vencimiento,
    DATENAME(WEEKDAY, c.vencimiento1) AS DiaSemana,
    CASE 
        WHEN DATENAME(WEEKDAY, c.vencimiento1) IN ('Saturday', 'Sunday', 'sabado', 'domingo')
        THEN 'ATENCION: Fin de semana'
        ELSE 'OK'
    END AS Estado,
    '1' AS NumeroVencimiento
FROM Consorcio.Consorcio c
WHERE DATENAME(WEEKDAY, c.vencimiento1) IN ('Saturday', 'Sunday', 'sabado', 'domingo')

UNION ALL

SELECT 
    c.nombre,
    c.vencimiento2,
    DATENAME(WEEKDAY, c.vencimiento2),
    CASE 
        WHEN DATENAME(WEEKDAY, c.vencimiento2) IN ('Saturday', 'Sunday', 'sabado', 'domingo')
        THEN 'ATENCION: Fin de semana'
        ELSE 'OK'
    END,
    '2'
FROM Consorcio.Consorcio c
WHERE DATENAME(WEEKDAY, c.vencimiento2) IN ('Saturday', 'Sunday', 'sabado', 'domingo')
GO

PRINT ''
PRINT '========================================='
PRINT 'FIN DE LAS PRUEBAS'
PRINT '========================================='