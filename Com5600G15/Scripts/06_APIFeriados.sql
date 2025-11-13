/*
    ---------------------------------------------------------------------
    Entrega 6 - API: Feriados Argentina
    Grupo: 15
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Pérez
    - Cristian Vergara
    - Consigna: Uso de una API en la base de datos
    - API: https://api.argentinadatos.com/v1/feriados/2025
    ---------------------------------------------------------------------
*/

USE Com5600G15
GO

-- Habilitar OLE
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO

-- SP para obtener feriados
CREATE OR ALTER PROCEDURE Reporte.SP_ObtenerFeriados
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @Anio IS NULL 
        SET @Anio = YEAR(GETDATE())
    
    DECLARE @URL NVARCHAR(500) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(@Anio AS VARCHAR(4))
    DECLARE @Object INT
    DECLARE @Response VARCHAR(8000)
    DECLARE @HR INT
    
    PRINT '=== CONSULTANDO FERIADOS ' + CAST(@Anio AS VARCHAR(4)) + ' ==='
    PRINT 'Fuente: ' + @URL
    PRINT ''
    
    BEGIN TRY
        EXEC @HR = sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT
        EXEC @HR = sp_OAMethod @Object, 'open', NULL, 'GET', @URL, false
        EXEC @HR = sp_OAMethod @Object, 'send'
        EXEC @HR = sp_OAGetProperty @Object, 'responseText', @Response OUT
        EXEC sp_OADestroy @Object
        
        IF @Response IS NOT NULL AND LEN(@Response) > 10
        BEGIN
            SELECT 
                CAST(JSON_VALUE(value, '$.fecha') AS DATE) AS Fecha,
                JSON_VALUE(value, '$.nombre') AS Feriado,
                JSON_VALUE(value, '$.tipo') AS Tipo
            FROM OPENJSON(@Response)
            WHERE JSON_VALUE(value, '$.fecha') IS NOT NULL
            ORDER BY CAST(JSON_VALUE(value, '$.fecha') AS DATE)
        END
        ELSE
        BEGIN
            PRINT 'ERROR: No se pudo obtener respuesta de la API'
        END
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: ' + ERROR_MESSAGE()
        IF @Object IS NOT NULL
            EXEC sp_OADestroy @Object
    END CATCH
END
GO

-- SP para validar vencimiento
CREATE OR ALTER PROCEDURE Consorcio.SP_ValidarVencimiento
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @NuevaFecha DATE = @Fecha
    DECLARE @Anio INT = YEAR(@Fecha)
    DECLARE @URL NVARCHAR(500) = 'https://api.argentinadatos.com/v1/feriados/' + CAST(@Anio AS VARCHAR(4))
    DECLARE @Object INT
    DECLARE @Response VARCHAR(8000)
    DECLARE @HR INT
    -- Tabla temporal en memoria para guardar los feriados del año
    DECLARE @Feriados TABLE (Fecha DATE, Nombre NVARCHAR(200))
    
    BEGIN TRY
        EXEC @HR = sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT
        EXEC @HR = sp_OAMethod @Object, 'open', NULL, 'GET', @URL, false
        EXEC @HR = sp_OAMethod @Object, 'send'
        EXEC @HR = sp_OAGetProperty @Object, 'responseText', @Response OUT
        EXEC sp_OADestroy @Object
        
        IF @Response IS NOT NULL AND LEN(@Response) > 10
        BEGIN
            INSERT INTO @Feriados (Fecha, Nombre)
            SELECT 
                CAST(JSON_VALUE(value, '$.fecha') AS DATE),
                JSON_VALUE(value, '$.nombre')
            FROM OPENJSON(@Response)
            WHERE JSON_VALUE(value, '$.fecha') IS NOT NULL
        END
        
        DECLARE @Intentos INT = 0
        WHILE @Intentos < 30
        BEGIN
            DECLARE @NombreDia NVARCHAR(20) = DATENAME(WEEKDAY, @NuevaFecha)
            
            IF @NombreDia IN ('Saturday', 'Sunday', 'sábado', 'domingo') 
               OR EXISTS (SELECT 1 FROM @Feriados WHERE Fecha = @NuevaFecha)
            BEGIN
                SET @NuevaFecha = DATEADD(DAY, 1, @NuevaFecha)
                SET @Intentos = @Intentos + 1
            END
            ELSE
                BREAK
        END
        
        DECLARE @NombreFeriado NVARCHAR(200)
        SELECT @NombreFeriado = Nombre FROM @Feriados WHERE Fecha = @Fecha
        -- resultado
        SELECT 
            @Fecha AS FechaOriginal,
            @NuevaFecha AS FechaHabil,
            DATEDIFF(DAY, @Fecha, @NuevaFecha) AS DiasPostergados,
            CASE 
                WHEN @Fecha = @NuevaFecha THEN 'OK - Dia habil'
                WHEN @NombreFeriado IS NOT NULL THEN 'MODIFICADO - ' + @NombreFeriado
                ELSE 'MODIFICADO - Fin de semana'
            END AS Motivo
            
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: ' + ERROR_MESSAGE()
        IF @Object IS NOT NULL
            EXEC sp_OADestroy @Object
    END CATCH
END
GO