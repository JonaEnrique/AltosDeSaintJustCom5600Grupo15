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


CREATE OR ALTER PROCEDURE Importacion.ImportarJSON 
    @RutaArchivo NVARCHAR(4096)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
        BEGIN
            RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
            RETURN;
        END
            
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

    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
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

IF OBJECT_ID('Importacion.ImportConsorciosProveedores', 'P') IS NOT NULL
    DROP PROCEDURE Importacion.ImportConsorciosProveedores;
GO

CREATE PROCEDURE Importacion.ImportarConsorciosProveedores
    @ExcelPath NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @prevShowAdvanced INT,
			@prevAdHoc INT;

		-- Guarda valores de configracion actual
		SELECT @prevShowAdvanced = CONVERT(INT, value_in_use)
		FROM sys.configurations 
		WHERE name = 'show advanced options';

		SELECT @prevAdHoc = CONVERT(INT, value_in_use)
		FROM sys.configurations 
		WHERE name = 'Ad Hoc Distributed Queries';

		IF @prevShowAdvanced = 0
		BEGIN
			EXEC sp_configure 'show advanced options', 1;
			RECONFIGURE;
		END

		IF @prevAdHoc = 0
		BEGIN
			EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
			RECONFIGURE;
		END

	BEGIN TRANSACTION;

	BEGIN TRY


		CREATE TABLE #TempConsorcios (
			nombre_consorcio NVARCHAR(200),  --(luego usar para resolver id_consorcio en proveedores)
			direccion NVARCHAR(200), 
			cant_unidades_funcionales INT,            
			m2_totales DECIMAL(10,2)   
		);

		CREATE TABLE #TempProveedores (
			tipo NVARCHAR(200),   
			nombre_proveedor NVARCHAR(200),  
			cuenta NVARCHAR(200),  
			nombre_consorcio NVARCHAR(200)   --(luego usar para resolver id_consorcio)
		);

		-- Importar Consorcios
		DECLARE @SQL NVARCHAR(1000);
		SET @SQL = N'
			INSERT INTO #TempConsorcios
			SELECT 
				CAST(F2 AS NVARCHAR(200)) AS F2,
				CAST(F3 AS NVARCHAR(200)) AS F3,
				CAST(F4 AS INT) AS F4,
				CAST(F5 AS DECIMAL(10,2)) AS F5
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.16.0'',
				''Excel 12.0 Xml;HDR=NO;Database=' + @ExcelPath +N''',
				''SELECT * FROM [Consorcios$]''
			) AS X
			WHERE NOT (F4 IS NULL OR F4 = '''')' ;

		EXEC sp_executesql @SQL;

		-- Importar Proveedores
		SET @SQL = N'
			INSERT INTO #TempProveedores
			SELECT *
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.16.0'',
				''Excel 12.0 Xml;HDR=NO;Database=' + @ExcelPath +N''',
				''SELECT * FROM [Proveedores$]''
			) AS X
			WHERE NOT (F1 IS NULL OR F1 = '''')' ;

		EXEC sp_executesql @SQL;

		-- Insertar en tabla Consorcio de la BD
		INSERT INTO Consorcio.Consorcio(nombre, direccion, cant_unidades_funcionales, m2_totales, vencimiento1, vencimiento2)
		SELECT T.nombre_consorcio, T.direccion, T.cant_unidades_funcionales, T.m2_totales, GETDATE(), GETDATE()
		FROM #TempConsorcios T;

		-- Insertar en tabla Proveedor dela BD, mapeando Consorcio
		INSERT INTO Consorcio.Proveedor(id_consorcio, nombre_proveedor, cuenta, tipo)
		SELECT C.id_consorcio, P.nombre_proveedor, P.cuenta, P.tipo
		FROM #TempProveedores P
		INNER JOIN Consorcio C
			ON C.nombre = P.nombre_consorcio;  -- JOIN en el nombre del consorcio

		COMMIT TRANSACTION;
		
		--Volvemos a la configuracion original
		EXEC sp_configure 'Ad Hoc Distributed Queries', @prevAdHoc;
		EXEC sp_configure 'show advanced options', @prevShowAdvanced;
		RECONFIGURE;

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		--Volvemos a la onfiguracion original
		EXEC sp_configure 'Ad Hoc Distributed Queries', @prevAdHoc;
		EXEC sp_configure 'show advanced options', @prevShowAdvanced;
		RECONFIGURE;

		-- Declaramos e informamos el error
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		THROW;  
	END CATCH;
END;
GO
