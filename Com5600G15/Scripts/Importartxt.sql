USE Com5600G15
GO

--------------------------------------------------------------------------------
--STORED PROCEDURE: Importacion.CargarUnidadFuncional
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarUnidadFuncional
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @FilasImportadas INT = 0;

    BEGIN TRY
        -- Validar que la ruta no esté vacía
        IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
        BEGIN
            RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
            RETURN;
        END

        -- Crear tabla temporal
        CREATE TABLE #TmpUnidadFuncional (
            NombreConsorcio NVARCHAR(100),
            nroUnidadFuncional NVARCHAR(20),
            Piso NVARCHAR(10),
            Departamento NVARCHAR(10),
            Coeficiente NVARCHAR(20),
            m2_unidad_funcional NVARCHAR(20),
            Bauleras NVARCHAR(10),
            Cochera NVARCHAR(10),
            m2_baulera NVARCHAR(20),
            m2_cochera NVARCHAR(20)
        );

        -- Construir el BULK INSERT con TAB como delimitador
        SET @SQL = N'
        BULK INSERT #TmpUnidadFuncional
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIELDTERMINATOR = ''\t'',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 1,
            CODEPAGE = ''ACP''
        );';

        -- Ejecutar el BULK INSERT
        EXEC sp_executesql @SQL;

        -- Insertar los datos nuevos en UnidadFuncional
        INSERT INTO dbo.UnidadFuncional (
            id_consorcio,
            nombre_consorcio,
            nroUnidadFuncional,
            piso,
            departamento,
            coeficiente,
            m2_unidad_funcional,
            bauleras,
            cochera,
            m2_baulera,
            m2_cochera
        )
        SELECT 
            c.id_consorcio,
            c.nombre,
            TRY_CAST(t.nroUnidadFuncional AS INT),
            LTRIM(RTRIM(t.Piso)),
            LTRIM(RTRIM(t.Departamento)),
            TRY_CAST(REPLACE(t.Coeficiente, ',', '.') AS DECIMAL(10,4)),
            TRY_CAST(t.m2_unidad_funcional AS DECIMAL(10,2)),
            CASE WHEN UPPER(LTRIM(RTRIM(t.Bauleras))) = 'SI' THEN 1 ELSE 0 END,
            CASE WHEN UPPER(LTRIM(RTRIM(t.Cochera))) = 'SI' THEN 1 ELSE 0 END,
            TRY_CAST(t.m2_baulera AS DECIMAL(10,2)),
            TRY_CAST(t.m2_cochera AS DECIMAL(10,2))
        FROM #TmpUnidadFuncional t
        INNER JOIN dbo.Consorcio c
            ON c.nombre = LTRIM(RTRIM(t.NombreConsorcio))
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dbo.UnidadFuncional u
            WHERE u.id_consorcio = c.id_consorcio
              AND u.nroUnidadFuncional = TRY_CAST(t.nroUnidadFuncional AS INT)
        );

        SET @FilasImportadas = @@ROWCOUNT;

        -- Limpiar tabla temporal
        DROP TABLE #TmpUnidadFuncional;

        PRINT 'Importación completada: ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados.';

    END TRY
    BEGIN CATCH
        -- Limpiar temporal si existe
        IF OBJECT_ID('tempdb..#TmpUnidadFuncional') IS NOT NULL
            DROP TABLE #TmpUnidadFuncional;
            
        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarUnidadFuncional: %s', 16, 1, @ErrorMensaje);
    END CATCH
END;
GO