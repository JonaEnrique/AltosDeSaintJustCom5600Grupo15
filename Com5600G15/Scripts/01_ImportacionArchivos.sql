--Franco: JSON
USE Com5600G15

--Si la ruta del archivo es desconocida o no es constante, tenemos que usar sql dinamico

CREATE OR ALTER PROCEDURE Importacion.ImportarJSON 
    @RutaArchivo NVARCHAR(4096)
AS
BEGIN
    SET NOCOUNT ON;

    -- Se recomienda ejecutar esto una vez manualmente, no dentro del SP:
    -- EXEC sp_configure 'show advanced options', 1;
    -- RECONFIGURE;
    -- EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
    -- RECONFIGURE;

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    CREATE TABLE ##Consorcios (
        id NVARCHAR(50),
        nombre_consorcio NVARCHAR(100),
        mes NVARCHAR(20),
        bancarios DECIMAL(18,2),
        limpieza DECIMAL(18,2),
        administracion DECIMAL(18,2),
        seguros DECIMAL(18,2),
        gastos_generales DECIMAL(18,2),
        servicios_agua DECIMAL(18,2),
        servicio_luz DECIMAL(18,2)
    );

    INSERT INTO ##Consorcios
    (id, nombre_consorcio, mes, bancarios, limpieza, administracion, seguros, gastos_generales, servicios_agua, servicio_luz)
    SELECT 
        id,
        nombre_consorcio,
        mes,
        TRY_CAST(REPLACE(REPLACE(bancarios, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(limpieza, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(administracion, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(seguros, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(gastos_generales, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(servicios_agua, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2)),
        TRY_CAST(REPLACE(REPLACE(servicio_luz, ''.'', ''''), '','', ''.'') AS DECIMAL(18,2))
    FROM OPENROWSET (
         BULK ''' + @RutaArchivo + ''',
         SINGLE_CLOB
    ) AS j
    CROSS APPLY OPENJSON(BulkColumn)
    WITH (
        id NVARCHAR(50) ''$._id.$oid'',
        nombre_consorcio NVARCHAR(100) ''$.Nombre del consorcio'',
        mes NVARCHAR(20) ''$.Mes'',
        bancarios NVARCHAR(20) ''$.BANCARIOS'',
        limpieza NVARCHAR(20) ''$.LIMPIEZA'',
        administracion NVARCHAR(20) ''$.ADMINISTRACION'',
        seguros NVARCHAR(20) ''$.SEGUROS'',
        gastos_generales NVARCHAR(20) ''$.GASTOS GENERALES'',
        servicios_agua NVARCHAR(20) ''$.SERVICIOS PUBLICOS-Agua'',
        servicio_luz NVARCHAR(20) ''$.SERVICIOS PUBLICOS-Luz''
    );
    ';

    EXEC sp_executesql @sql;
END;
GO