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
    Consigna: Consigna: Insertar datos de ejemplo en la tablas de la db utilizando sus sps de creacion
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO

--Consorcios
DECLARE @id_consorcio1 INT, @id_consorcio2 INT, @id_consorcio3 INT, @id_consorcio4 INT, @id_consorcio5 INT;

-- 1. Consorcio con baulera y cochera
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Azcuenaga',
    @direccion = 'Azcuenaga 1550, CABA',
    @cant_unidades_funcionales = 12,
    @m2_totales = 1800.00,
    @vencimiento1 = '2025-11-10',
    @vencimiento2 = '2025-11-20',
    @id_consorcio = @id_consorcio1 OUTPUT;

-- 2. Consorcio sin baulera ni cochera
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Alzaga',
    @direccion = 'Alzaga 234, CABA',
    @cant_unidades_funcionales = 10,
    @m2_totales = 950.00,
    @vencimiento1 = '2025-11-10',
    @vencimiento2 = '2025-11-20',
    @id_consorcio = @id_consorcio2 OUTPUT;

-- 3. Consorcio con baulera solamente
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Alberdi',
    @direccion = 'Av Alberdi 3050, CABA',
    @cant_unidades_funcionales = 11,
    @m2_totales = 1200.00,
    @vencimiento1 = '2025-11-10',
    @vencimiento2 = '2025-11-20',
    @id_consorcio = @id_consorcio3 OUTPUT;

-- 4. Consorcio con cochera solamente
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Unzue',
    @direccion = 'Unzue 1289, CABA',
    @cant_unidades_funcionales = 14,
    @m2_totales = 2100.00,
    @vencimiento1 = '2025-11-10',
    @vencimiento2 = '2025-11-20',
    @id_consorcio = @id_consorcio4 OUTPUT;

-- 5. Consorcio con baulera y cochera
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Pereyra Iraola',
    @direccion = 'Av Pereyra Iraola 400, Vicente Lopez',
    @cant_unidades_funcionales = 15,
    @m2_totales = 2500.00,
    @vencimiento1 = '2025-11-10',
    @vencimiento2 = '2025-11-20',
    @id_consorcio = @id_consorcio5 OUTPUT;

--Proovedores, uno para cada tipo de gasto para cada consorcio:
DECLARE @id_proveedor INT;

-- ==========================================================
-- PROVEEDORES PARA CONSORCIO 1 - AZCUENAGA
-- ==========================================================
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'Banco Ciudad', @cuenta = 'CTA-001', @tipo = 'BANCARIOS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'Limpieza Total SRL', @cuenta = 'CTA-002', @tipo = 'LIMPIEZA', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'Administraciones del Sur', @cuenta = 'CTA-003', @tipo = 'ADMINISTRACION', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'La Solidez Seguros', @cuenta = 'CTA-004', @tipo = 'SEGUROS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'AySA', @cuenta = 'CTA-005', @tipo = 'SERVICIOS PUBLICOS-Agua', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio1, @nombre_proveedor = 'Edesur', @cuenta = 'CTA-006', @tipo = 'SERVICIOS PUBLICOS-Luz', @id_proveedor = @id_proveedor OUTPUT;

-- ==========================================================
-- PROVEEDORES PARA CONSORCIO 2 - ALZAGA
-- ==========================================================
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'Banco Galicia', @cuenta = 'CTA-101', @tipo = 'BANCARIOS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'Clean&Go', @cuenta = 'CTA-102', @tipo = 'LIMPIEZA', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'Gestiones Alzaga', @cuenta = 'CTA-103', @tipo = 'ADMINISTRACION', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'San Cristobal Seguros', @cuenta = 'CTA-104', @tipo = 'SEGUROS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'AySA', @cuenta = 'CTA-105', @tipo = 'SERVICIOS PUBLICOS-Agua', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio2, @nombre_proveedor = 'Edenor', @cuenta = 'CTA-106', @tipo = 'SERVICIOS PUBLICOS-Luz', @id_proveedor = @id_proveedor OUTPUT;

-- ==========================================================
-- PROVEEDORES PARA CONSORCIO 3 - ALBERDI
-- ==========================================================
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'Banco Nacion', @cuenta = 'CTA-201', @tipo = 'BANCARIOS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'Limpio YA', @cuenta = 'CTA-202', @tipo = 'LIMPIEZA', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'Alberdi Administraciones', @cuenta = 'CTA-203', @tipo = 'ADMINISTRACION', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'Provincia Seguros', @cuenta = 'CTA-204', @tipo = 'SEGUROS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'AySA', @cuenta = 'CTA-205', @tipo = 'SERVICIOS PUBLICOS-Agua', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio3, @nombre_proveedor = 'Edesur', @cuenta = 'CTA-206', @tipo = 'SERVICIOS PUBLICOS-Luz', @id_proveedor = @id_proveedor OUTPUT;

-- ==========================================================
-- PROVEEDORES PARA CONSORCIO 4 - UNZUE
-- ==========================================================
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'Banco BBVA', @cuenta = 'CTA-301', @tipo = 'BANCARIOS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'Limpieza Norte', @cuenta = 'CTA-302', @tipo = 'LIMPIEZA', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'Administraciones Unzue', @cuenta = 'CTA-303', @tipo = 'ADMINISTRACION', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'Mapfre Seguros', @cuenta = 'CTA-304', @tipo = 'SEGUROS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'AySA', @cuenta = 'CTA-305', @tipo = 'SERVICIOS PUBLICOS-Agua', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio4, @nombre_proveedor = 'Edenor', @cuenta = 'CTA-306', @tipo = 'SERVICIOS PUBLICOS-Luz', @id_proveedor = @id_proveedor OUTPUT;

-- ==========================================================
-- PROVEEDORES PARA CONSORCIO 5 - PEREYRA IRAOLA
-- ==========================================================
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'Banco Santander', @cuenta = 'CTA-401', @tipo = 'BANCARIOS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'Servicios Limpieza Pro', @cuenta = 'CTA-402', @tipo = 'LIMPIEZA', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'Administraciones VIP', @cuenta = 'CTA-403', @tipo = 'ADMINISTRACION', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'Allianz Seguros', @cuenta = 'CTA-404', @tipo = 'SEGUROS', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'AySA', @cuenta = 'CTA-405', @tipo = 'SERVICIOS PUBLICOS-Agua', @id_proveedor = @id_proveedor OUTPUT;
EXEC Consorcio.CrearProveedor @id_consorcio = @id_consorcio5, @nombre_proveedor = 'Edesur', @cuenta = 'CTA-406', @tipo = 'SERVICIOS PUBLICOS-Luz', @id_proveedor = @id_proveedor OUTPUT;

GO
-- =============================================
-- UNIDADES FUNCIONALES - AZCUENAGA (id_consorcio = 1)
-- Con baulera y cochera
-- =============================================
DECLARE @id_unidad INT;

EXEC Consorcio.CrearUnidadFuncional 1, '1', 'A', 8.3, 65.0, 4.0, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '1', 'B', 8.3, 63.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '2', 'A', 8.3, 66.0, 4.0, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '2', 'B', 8.3, 62.0, 3.0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '3', 'A', 8.3, 68.0, 4.5, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '3', 'B', 8.3, 64.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '4', 'A', 8.3, 70.0, 4.0, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '4', 'B', 8.3, 65.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '5', 'A', 8.3, 72.0, 4.0, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '5', 'B', 8.3, 67.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '6', 'A', 8.3, 75.0, 4.0, 12.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 1, '6', 'B', 8.3, 70.0, 3.5, 10.0, @id_unidad OUTPUT;

-- =============================================
-- UNIDADES FUNCIONALES - ALZAGA (id_consorcio = 2)
-- Sin baulera ni cochera
-- =============================================
EXEC Consorcio.CrearUnidadFuncional 2, '1', 'A', 10.0, 60.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '1', 'B', 10.0, 58.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '2', 'A', 10.0, 61.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '2', 'B', 10.0, 59.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '3', 'A', 10.0, 62.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '3', 'B', 10.0, 60.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '4', 'A', 10.0, 63.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '4', 'B', 10.0, 61.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '5', 'A', 10.0, 65.0, 0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 2, '5', 'B', 10.0, 62.0, 0, 0, @id_unidad OUTPUT;

-- =============================================
-- UNIDADES FUNCIONALES - ALBERDI (id_consorcio = 3)
-- Solo baulera
-- =============================================
EXEC Consorcio.CrearUnidadFuncional 3, '1', 'A', 9.1, 55.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '1', 'B', 9.1, 56.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '2', 'A', 9.1, 57.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '2', 'B', 9.1, 58.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '3', 'A', 9.1, 59.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '3', 'B', 9.1, 60.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '4', 'A', 9.1, 61.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '4', 'B', 9.1, 62.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '5', 'A', 9.1, 63.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '5', 'B', 9.1, 64.0, 3.0, 0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 3, '6', 'A', 9.1, 65.0, 3.0, 0, @id_unidad OUTPUT;

-- =============================================
-- UNIDADES FUNCIONALES - UNZUE (id_consorcio = 4)
-- Solo cochera
-- =============================================
EXEC Consorcio.CrearUnidadFuncional 4, '1', 'A', 7.1, 68.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '1', 'B', 7.1, 66.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '2', 'A', 7.1, 67.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '2', 'B', 7.1, 65.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '3', 'A', 7.1, 70.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '3', 'B', 7.1, 69.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '4', 'A', 7.1, 68.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '4', 'B', 7.1, 67.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '5', 'A', 7.1, 71.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '5', 'B', 7.1, 70.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '6', 'A', 7.1, 73.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '6', 'B', 7.1, 72.0, 0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '7', 'A', 7.1, 74.0, 0, 11.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 4, '7', 'B', 7.1, 75.0, 0, 10.0, @id_unidad OUTPUT;

-- =============================================
-- UNIDADES FUNCIONALES - PEREYRA IRAOLA (id_consorcio = 5)
-- Con baulera y cochera
-- =============================================
EXEC Consorcio.CrearUnidadFuncional 5, '1', 'A', 6.7, 68.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '1', 'B', 6.7, 67.0, 3.0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '2', 'A', 6.7, 69.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '2', 'B', 6.7, 68.0, 3.0, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '3', 'A', 6.7, 70.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '3', 'B', 6.7, 71.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '4', 'A', 6.7, 72.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '4', 'B', 6.7, 73.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '5', 'A', 6.7, 74.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '5', 'B', 6.7, 75.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '6', 'A', 6.7, 76.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '6', 'B', 6.7, 77.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '7', 'A', 6.7, 78.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '7', 'B', 6.7, 79.0, 3.5, 10.0, @id_unidad OUTPUT;
EXEC Consorcio.CrearUnidadFuncional 5, '8', 'A', 6.7, 80.0, 3.5, 10.0, @id_unidad OUTPUT;

GO

-- =============================================
-- PERSONAS Y RELACIONES PERSONA-UNIDAD
-- =============================================

-- =============================================
-- CREACION DE PERSONAS (una P y una I por unidad)
-- =============================================
-- Generamos 2 * (12 + 10 + 11 + 14 + 15) = 124 personas aprox.
-- Nota: se usa un patron simple para DNI, mail y CVU unicos

DECLARE @dni_base INT = 30000000;
DECLARE @n INT = 1;
DECLARE @dni_actual INT;
DECLARE @nombre NVARCHAR(50);
DECLARE @apellido NVARCHAR(50);
DECLARE @mail NVARCHAR(254);
DECLARE @telefono VARCHAR(20);
DECLARE @cvu_cbu VARCHAR(25);

WHILE @n <= 124
BEGIN
    SET @dni_actual = @dni_base + @n;
    SET @nombre = 'Persona' + CAST(@n AS VARCHAR(3));
    SET @apellido = 'Apellido' + CAST(@n AS VARCHAR(3));
    SET @mail = 'persona' + CAST(@n AS VARCHAR(3)) + '@mail.com';
    SET @telefono = '11' + RIGHT('000000' + CAST(@n AS VARCHAR(6)), 6);
    SET @cvu_cbu = '0000000000000000000' + RIGHT('00' + CAST(@n AS VARCHAR(3)), 3);

    EXEC Consorcio.CrearPersona 
        @dni = @dni_actual,
        @nombre = @nombre,
        @apellido = @apellido,
        @mail = @mail,
        @telefono = @telefono,
        @cvu_cbu = @cvu_cbu;

    SET @n += 1;
END;
GO

-- =============================================
-- RELACIONES PERSONA-UNIDAD
-- =============================================

DECLARE @id_persona_unidad INT; --variable para capturar el id de salida de los sp para evitar errores
DECLARE @dni_prop INT = 30000000; --base para dni propietarios
DECLARE @dni_inq INT = 30000124;  -- base para inquilinos
DECLARE @fecha DATE = '2024-01-15'; --fecha al azar, arbitraria
DECLARE @dni_actual INT; --variable auxiliar para enviar el dni actual ya que SQL SERVER no permite realizar operacones aritmeticas en los EXEC

-- =============================================
-- Azcuenaga (id_consorcio = 1) -> 12 unidades
-- =============================================
DECLARE @id_unidad INT = 1;
WHILE @id_unidad <= 12
BEGIN
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 1;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'P', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 2;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'I', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @id_unidad += 1;
END;

-- =============================================
-- Alzaga (id_consorcio = 2) -> 10 unidades (IDs 13–22)
-- =============================================
SET @id_unidad = 13;
WHILE @id_unidad <= 22
BEGIN
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 1;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'P', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 2;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'I', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @id_unidad += 1;
END;

-- =============================================
-- Alberdi (id_consorcio = 3) -> 11 unidades (IDs 23–33)
-- =============================================
SET @id_unidad = 23;
WHILE @id_unidad <= 33
BEGIN
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 1;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'P', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 2;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'I', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @id_unidad += 1;
END;

-- =============================================
-- Unzue (id_consorcio = 4) -> 14 unidades (IDs 34–47)
-- =============================================
SET @id_unidad = 34;
WHILE @id_unidad <= 47
BEGIN
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 1;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'P', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 2;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'I', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @id_unidad += 1;
END;

-- =============================================
-- Pereyra Iraola (id_consorcio = 5) -> 15 unidades (IDs 48–62)
-- =============================================
SET @id_unidad = 48;
WHILE @id_unidad <= 62
BEGIN
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 1;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'P', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @dni_actual = @dni_prop + ((@id_unidad - 1) * 2) + 2;
    EXEC Consorcio.CrearPersonaUnidad @id_unidad, @dni_actual, 'I', @fecha, NULL, @id_persona_unidad OUTPUT;
    SET @id_unidad += 1;
END;

--==================
--CREACION DE GASTOS
--==================

DECLARE @id_gasto INT;

-- ==========================================================
-- CONSORCIO 1 - AZCUENAGA (proveedores 1..6)
-- ==========================================================
-- Agosto 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 1, @tipo_gasto = 'Limpieza', @fecha = '2025-08-10', @importe = 180000, @nro_factura = 101, @id_proveedor = 2, @descripcion = 'Servicio de limpieza mensual - agosto', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 1, @tipo_gasto = 'Luz comun', @fecha = '2025-08-15', @importe = 95000,  @nro_factura = 102, @id_proveedor = 6, @descripcion = 'Factura de luz - agosto', @id_gasto = @id_gasto OUTPUT;

-- Septiembre 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 1, @tipo_gasto = 'Limpieza', @fecha = '2025-09-10', @importe = 182000, @nro_factura = 201, @id_proveedor = 2, @descripcion = 'Servicio de limpieza mensual - septiembre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 1, @tipo_gasto = 'Agua', @fecha = '2025-09-18', @importe = 80000,  @nro_factura = 202, @id_proveedor = 5, @descripcion = 'Factura de agua - septiembre', @id_gasto = @id_gasto OUTPUT;

-- Octubre 2025 (ordinario + extraordinario)
EXEC Pago.CrearGastoOrdinario @id_consorcio = 1, @tipo_gasto = 'ADMINISTRACION', @fecha = '2025-10-05', @importe = 120000, @nro_factura = 301, @id_proveedor = 3, @descripcion = 'Honorarios de administracion - octubre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoExtraordinario @id_consorcio = 1, @detalle = 'Reparacion de porton electrico', @importe = 350000, @importe_total = 350000, @fecha = '2025-10-20', @pago_cuotas = 0, @nro_cuota = NULL, @total_cuotas = NULL, @id_gasto = @id_gasto OUTPUT;


-- ==========================================================
-- CONSORCIO 2 - ALZAGA (proveedores 7..12)
-- ==========================================================
-- Agosto 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 2, @tipo_gasto = 'Limpieza', @fecha = '2025-08-10', @importe = 170000, @nro_factura = 103, @id_proveedor = 8, @descripcion = 'Servicio de limpieza mensual - agosto', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 2, @tipo_gasto = 'Luz comun', @fecha = '2025-08-15', @importe = 91000,  @nro_factura = 104, @id_proveedor = 12, @descripcion = 'Factura de luz - agosto', @id_gasto = @id_gasto OUTPUT;

-- Septiembre 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 2, @tipo_gasto = 'Limpieza', @fecha = '2025-09-10', @importe = 175000, @nro_factura = 205, @id_proveedor = 8, @descripcion = 'Servicio de limpieza mensual - septiembre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 2, @tipo_gasto = 'Agua', @fecha = '2025-09-18', @importe = 77000,  @nro_factura = 206, @id_proveedor = 11, @descripcion = 'Factura de agua - septiembre', @id_gasto = @id_gasto OUTPUT;

-- Octubre 2025 (ordinario + extraordinario)
EXEC Pago.CrearGastoOrdinario @id_consorcio = 2, @tipo_gasto = 'ADMINISTRACION', @fecha = '2025-10-05', @importe = 115000, @nro_factura = 302, @id_proveedor = 9, @descripcion = 'Honorarios de administracion - octubre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoExtraordinario @id_consorcio = 2, @detalle = 'Cambio de sistema de seguridad del edificio', @importe = 290000, @importe_total = 290000, @fecha = '2025-10-22', @pago_cuotas = 0, @nro_cuota = NULL, @total_cuotas = NULL, @id_gasto = @id_gasto OUTPUT;


-- ==========================================================
-- CONSORCIO 3 - ALBERDI (proveedores 13..18)
-- ==========================================================
-- Agosto 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 3, @tipo_gasto = 'Limpieza', @fecha = '2025-08-10', @importe = 160000, @nro_factura = 105, @id_proveedor = 14, @descripcion = 'Servicio de limpieza mensual - agosto', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 3, @tipo_gasto = 'Luz comun', @fecha = '2025-08-15', @importe = 89000,  @nro_factura = 106, @id_proveedor = 18, @descripcion = 'Factura de luz - agosto', @id_gasto = @id_gasto OUTPUT;

-- Septiembre 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 3, @tipo_gasto = 'Limpieza', @fecha = '2025-09-10', @importe = 165000, @nro_factura = 207, @id_proveedor = 14, @descripcion = 'Servicio de limpieza mensual - septiembre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 3, @tipo_gasto = 'Agua', @fecha = '2025-09-18', @importe = 76000,  @nro_factura = 208, @id_proveedor = 17, @descripcion = 'Factura de agua - septiembre', @id_gasto = @id_gasto OUTPUT;

-- Octubre 2025 (ordinario + extraordinario)
EXEC Pago.CrearGastoOrdinario @id_consorcio = 3, @tipo_gasto = 'ADMINISTRACION', @fecha = '2025-10-05', @importe = 118000, @nro_factura = 303, @id_proveedor = 15, @descripcion = 'Honorarios de administracion - octubre', @id_gasto = @id_gasto OUTPUT;
-- ejemplo de pago en cuotas: importe = cuota, importe_total = total; aqui hacemos no-cuotas
EXEC Pago.CrearGastoExtraordinario @id_consorcio = 3, @detalle = 'Pintura de fachada', @importe = 260000, @importe_total = 260000, @fecha = '2025-10-24', @pago_cuotas = 0, @nro_cuota = NULL, @total_cuotas = NULL, @id_gasto = @id_gasto OUTPUT;


-- ==========================================================
-- CONSORCIO 4 - UNZUE (proveedores 19..24)
-- ==========================================================
-- Agosto 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 4, @tipo_gasto = 'Limpieza', @fecha = '2025-08-10', @importe = 185000, @nro_factura = 107, @id_proveedor = 20, @descripcion = 'Servicio de limpieza mensual - agosto', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 4, @tipo_gasto = 'Luz comun', @fecha = '2025-08-15', @importe = 94000,  @nro_factura = 108, @id_proveedor = 24, @descripcion = 'Factura de luz - agosto', @id_gasto = @id_gasto OUTPUT;

-- Septiembre 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 4, @tipo_gasto = 'Limpieza', @fecha = '2025-09-10', @importe = 190000, @nro_factura = 209, @id_proveedor = 20, @descripcion = 'Servicio de limpieza mensual - septiembre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 4, @tipo_gasto = 'Agua', @fecha = '2025-09-18', @importe = 81000,  @nro_factura = 210, @id_proveedor = 23, @descripcion = 'Factura de agua - septiembre', @id_gasto = @id_gasto OUTPUT;

-- Octubre 2025 (ordinario + extraordinario)
EXEC Pago.CrearGastoOrdinario @id_consorcio = 4, @tipo_gasto = 'ADMINISTRACION', @fecha = '2025-10-05', @importe = 125000, @nro_factura = 304, @id_proveedor = 21, @descripcion = 'Honorarios de administracion - octubre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoExtraordinario @id_consorcio = 4, @detalle = 'Cambio de ascensor', @importe = 410000, @importe_total = 410000, @fecha = '2025-10-25', @pago_cuotas = 0, @nro_cuota = NULL, @total_cuotas = NULL, @id_gasto = @id_gasto OUTPUT;


-- ==========================================================
-- CONSORCIO 5 - PEREYRA IRAOLA (proveedores 25..30)
-- ==========================================================
-- Agosto 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 5, @tipo_gasto = 'Limpieza', @fecha = '2025-08-10', @importe = 178000, @nro_factura = 109, @id_proveedor = 26, @descripcion = 'Servicio de limpieza mensual - agosto', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 5, @tipo_gasto = 'Luz comun', @fecha = '2025-08-15', @importe = 97000,  @nro_factura = 110, @id_proveedor = 30, @descripcion = 'Factura de luz - agosto', @id_gasto = @id_gasto OUTPUT;

-- Septiembre 2025
EXEC Pago.CrearGastoOrdinario @id_consorcio = 5, @tipo_gasto = 'Limpieza', @fecha = '2025-09-10', @importe = 182000, @nro_factura = 211, @id_proveedor = 26, @descripcion = 'Servicio de limpieza mensual - septiembre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoOrdinario @id_consorcio = 5, @tipo_gasto = 'Agua', @fecha = '2025-09-18', @importe = 83000,  @nro_factura = 212, @id_proveedor = 29, @descripcion = 'Factura de agua - septiembre', @id_gasto = @id_gasto OUTPUT;

-- Octubre 2025 (ordinario + extraordinario)
EXEC Pago.CrearGastoOrdinario @id_consorcio = 5, @tipo_gasto = 'ADMINISTRACION', @fecha = '2025-10-05', @importe = 130000, @nro_factura = 305, @id_proveedor = 27, @descripcion = 'Honorarios de administracion - octubre', @id_gasto = @id_gasto OUTPUT;
EXEC Pago.CrearGastoExtraordinario @id_consorcio = 5, @detalle = 'Reacondicionamiento del hall de entrada', @importe = 330000, @importe_total = 330000, @fecha = '2025-10-28', @pago_cuotas = 0, @nro_cuota = NULL, @total_cuotas = NULL, @id_gasto = @id_gasto OUTPUT;

-- =============
-- Pagos Asociados
-- ==============

--Aqui crearemos una serie de registros en PagosAsociados basandonos en lo que le corresponderia pagar a cada UF

SET NOCOUNT ON;

DECLARE 
    @id_consorcio INT,
    @total_gastos DECIMAL(18,2),
    @m2_unit DECIMAL(18,4),
    @m2_totales_cons DECIMAL(18,4),
    @importe_unit DECIMAL(18,2),
    @cvu_cbu VARCHAR(25),
    @id_expensa INT;

-- Cursor sobre todos los consorcios
DECLARE cur_consorcios CURSOR LOCAL FAST_FORWARD FOR
SELECT id_consorcio, m2_totales
FROM Consorcio.Consorcio
ORDER BY id_consorcio;

OPEN cur_consorcios;
FETCH NEXT FROM cur_consorcios INTO @id_consorcio, @m2_totales_cons;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Calcular total de gastos para OCTUBRE 2025 para el consorcio
    SELECT 
        @total_gastos = 
            ISNULL( (SELECT SUM(importe) 
                     FROM Pago.GastoOrdinario g
                     WHERE g.id_consorcio = @id_consorcio
                       AND MONTH(g.fecha) = 10
                       AND YEAR(g.fecha) = 2025), 0)
          + ISNULL( (SELECT SUM(importe_total)
                     FROM Pago.GastoExtraordinario e
                     WHERE e.id_consorcio = @id_consorcio
                       AND MONTH(e.fecha) = 10
                       AND YEAR(e.fecha) = 2025), 0);

    -- Si no hay gastos en octubre, saltar al siguiente consorcio
    IF @total_gastos IS NULL OR @total_gastos = 0
    BEGIN
        FETCH NEXT FROM cur_consorcios INTO @id_consorcio, @m2_totales_cons;
        CONTINUE;
    END;

    -- Cursor sobre las unidades del consorcio
    DECLARE cur_unidades CURSOR LOCAL FAST_FORWARD FOR
    SELECT id_unidad, m2_unidad, m2_baulera, m2_cochera
    FROM Consorcio.UnidadFuncional
    WHERE id_consorcio = @id_consorcio
    ORDER BY id_unidad;

    OPEN cur_unidades;
    DECLARE @m2_baulera DECIMAL(18,4), @m2_cochera DECIMAL(18,4);

    FETCH NEXT FROM cur_unidades INTO @id_unidad, @m2_unit, @m2_baulera, @m2_cochera;
    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- m2_unidad + m2_baulera + m2_cochera
        SET @m2_unit = ISNULL(@m2_unit,0) + ISNULL(@m2_baulera,0) + ISNULL(@m2_cochera,0);

        -- Seguridad: si m2_totales_cons es cero o nulo, evitar division por cero
        IF @m2_totales_cons IS NULL OR @m2_totales_cons = 0
        BEGIN
            SET @importe_unit = 0;
        END
        ELSE
        BEGIN
            SET @importe_unit = ROUND((ISNULL(@m2_unit,0) / @m2_totales_cons) * @total_gastos, 2);
        END

        -- Intentar obtener un CVU/CBU del propietario (rol = 'P') de la unidad
        SELECT TOP 1 @cvu_cbu = p.cvu_cbu
        FROM Consorcio.Persona p
        JOIN Consorcio.PersonaUnidad pu ON p.dni = pu.dni
        WHERE pu.id_unidad = @id_unidad
          AND pu.rol = 'P'
          AND p.cvu_cbu IS NOT NULL
        ORDER BY pu.fecha_inicio DESC;

        -- Si no se encontro CVU de propietario, intentar cualquier CVU (inquilino)
        IF @cvu_cbu IS NULL
        BEGIN
            SELECT TOP 1 @cvu_cbu = p.cvu_cbu
            FROM Consorcio.Persona p
            JOIN Consorcio.PersonaUnidad pu ON p.dni = pu.dni
            WHERE pu.id_unidad = @id_unidad
              AND p.cvu_cbu IS NOT NULL
            ORDER BY pu.fecha_inicio DESC;
        END

        -- Si aun no hay CVU, dejamos NULL (pago no asociado)
        IF @cvu_cbu IS NULL
            SET @cvu_cbu = NULL;

        -- Ejecutar la Creacion del Pago Asociado
        EXEC Pago.CrearPagoAsociado
            @id_unidad = @id_unidad,
            @fecha = '2025-11-10',
            @cvu_cbu = @cvu_cbu,
            @importe = @importe_unit,
            @id_expensa = @id_expensa OUTPUT;

        -- limpiar cvu para la proxima unidad
        SET @cvu_cbu = NULL;

        FETCH NEXT FROM cur_unidades INTO @id_unidad, @m2_unit, @m2_baulera, @m2_cochera;
    END;

    CLOSE cur_unidades;
    DEALLOCATE cur_unidades;

    FETCH NEXT FROM cur_consorcios INTO @id_consorcio, @m2_totales_cons;
END;

CLOSE cur_consorcios;
DEALLOCATE cur_consorcios;

PRINT 'Proceso finalizado.';
GO

/*
SELECT * FROM Consorcio.Consorcio
SELECT * FROM Consorcio.Proveedor
SELECT * FROM Consorcio.Persona
SELECT * FROM Consorcio.PersonaUnidad
SELECT * FROM Consorcio.UnidadFuncional
SELECT * FROM Pago.GastoExtraordinario
SELECT * FROM Pago.GastoOrdinario
SELECT * FROM Pago.PagoAsociado

*/
