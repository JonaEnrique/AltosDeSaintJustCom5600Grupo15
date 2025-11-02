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
        INSERT INTO Consorcio.UnidadFuncional (
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

--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.CargarInquilinoPropietariosDatos
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarInquilinoPropietariosDatos
    @RutaArchivo NVARCHAR(4000),
    @Persistir BIT = 0 -- 0 = cargar solo en tabla temporal, 1 = además insertar en Staging
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
    BEGIN
        RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
        RETURN;
    END

    BEGIN TRY
        CREATE TABLE #TmpInquilinoPropietariosDatos (
            Nombre NVARCHAR(200),
            Apellido NVARCHAR(200),
            DNI NVARCHAR(50),
            EmailPersonal NVARCHAR(200),
            TelefonoContacto NVARCHAR(50),
            CVU_CBU NVARCHAR(50),
            Inquilino NVARCHAR(10)
        );

        DECLARE @sql NVARCHAR(MAX);

        -- Usar BULK INSERT porque PARSER_VERSION puede no estar disponible en esta instancia
        SET @sql = N'
        BULK INSERT #TmpInquilinoPropietariosDatos
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''ACP''
        );';

        EXEC sp_executesql @sql;

        -- Normalizar espacios en blanco
        UPDATE #TmpInquilinoPropietariosDatos
        SET Nombre = LTRIM(RTRIM(Nombre)),
            Apellido = LTRIM(RTRIM(Apellido)),
            DNI = LTRIM(RTRIM(DNI)),
            EmailPersonal = LTRIM(RTRIM(EmailPersonal)),
            TelefonoContacto = LTRIM(RTRIM(TelefonoContacto)),
            CVU_CBU = LTRIM(RTRIM(CVU_CBU)),
            Inquilino = LTRIM(RTRIM(Inquilino));

        DECLARE @FilasImportadas INT;
        SELECT @FilasImportadas = COUNT(*) FROM #TmpInquilinoPropietariosDatos;

        PRINT 'Importación completada (datos): ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados en #TmpInquilinoPropietariosDatos.';

        IF @Persistir = 1
        BEGIN
            -- Asegurar esquema y tabla Staging
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Staging')
                EXEC('CREATE SCHEMA Staging');

            IF OBJECT_ID('Staging.InquilinoPropietariosDatos','U') IS NULL
            BEGIN
                CREATE TABLE Staging.InquilinoPropietariosDatos (
                    Nombre NVARCHAR(200),
                    Apellido NVARCHAR(200),
                    DNI NVARCHAR(50),
                    EmailPersonal NVARCHAR(200),
                    TelefonoContacto NVARCHAR(50),
                    CVU_CBU NVARCHAR(50),
                    Inquilino NVARCHAR(10),
                    FechaCarga DATETIME DEFAULT (GETDATE())
                );
            END

            BEGIN TRANSACTION;
            BEGIN TRY
                INSERT INTO Staging.InquilinoPropietariosDatos (Nombre, Apellido, DNI, EmailPersonal, TelefonoContacto, CVU_CBU, Inquilino)
                SELECT Nombre, Apellido, DNI, EmailPersonal, TelefonoContacto, CVU_CBU, Inquilino
                FROM #TmpInquilinoPropietariosDatos;

                DECLARE @FilasPersistidas INT = @@ROWCOUNT;
                COMMIT TRANSACTION;
                PRINT 'Persistido en Staging.InquilinoPropietariosDatos: ' + CAST(@FilasPersistidas AS NVARCHAR(10)) + ' registros.';
            END TRY
            BEGIN CATCH
                IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
                DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
                RAISERROR('Error al persistir InquilinoPropietariosDatos: %s',16,1,@Err);
            END CATCH
        END
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpInquilinoPropietariosDatos') IS NOT NULL
            DROP TABLE #TmpInquilinoPropietariosDatos;

        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarInquilinoPropietariosDatos: %s', 16, 1, @ErrorMensaje);
    END CATCH

	SELECT * FROM #TmpInquilinoPropietariosDatos;
END;
GO

--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.CargarInquilinoPropietariosUF
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarInquilinoPropietariosUF
    @RutaArchivo NVARCHAR(4000),
    @Persistir BIT = 0 -- 0 = solo temporal, 1 = además insertar en Staging
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
    BEGIN
        RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
        RETURN;
    END

    BEGIN TRY
        CREATE TABLE #TmpInquilinoPropietariosUF (
            CVU_CBU NVARCHAR(50),
            NombreConsorcio NVARCHAR(200),
            nroUnidadFuncional NVARCHAR(50),
            piso NVARCHAR(50),
            departamento NVARCHAR(50)
        );

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = N'
        BULK INSERT #TmpInquilinoPropietariosUF
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ''|'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''ACP''
        );';

        EXEC sp_executesql @sql;

        -- Normalizar espacios en blanco
        UPDATE #TmpInquilinoPropietariosUF
        SET CVU_CBU = LTRIM(RTRIM(CVU_CBU)),
            NombreConsorcio = LTRIM(RTRIM(NombreConsorcio)),
            nroUnidadFuncional = LTRIM(RTRIM(nroUnidadFuncional)),
            piso = LTRIM(RTRIM(piso)),
            departamento = LTRIM(RTRIM(departamento));

        DECLARE @FilasImportadas INT;
        SELECT @FilasImportadas = COUNT(*) FROM #TmpInquilinoPropietariosUF;
        PRINT 'Importación completada (UF): ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados en #TmpInquilinoPropietariosUF.';

        IF @Persistir = 1
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Staging')
                EXEC('CREATE SCHEMA Staging');

            IF OBJECT_ID('Staging.InquilinoPropietariosUF','U') IS NULL
            BEGIN
                CREATE TABLE Staging.InquilinoPropietariosUF (
                    CVU_CBU NVARCHAR(50),
                    NombreConsorcio NVARCHAR(200),
                    nroUnidadFuncional NVARCHAR(50),
                    piso NVARCHAR(50),
                    departamento NVARCHAR(50),
                    FechaCarga DATETIME DEFAULT (GETDATE())
                );
            END

            BEGIN TRANSACTION;
            BEGIN TRY
                INSERT INTO Staging.InquilinoPropietariosUF (CVU_CBU, NombreConsorcio, nroUnidadFuncional, piso, departamento)
                SELECT CVU_CBU, NombreConsorcio, nroUnidadFuncional, piso, departamento
                FROM #TmpInquilinoPropietariosUF;

                DECLARE @FilasPersistidas INT = @@ROWCOUNT;
                COMMIT TRANSACTION;
                PRINT 'Persistido en Staging.InquilinoPropietariosUF: ' + CAST(@FilasPersistidas AS NVARCHAR(10)) + ' registros.';
            END TRY
            BEGIN CATCH
                IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
                DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
                RAISERROR('Error al persistir InquilinoPropietariosUF: %s',16,1,@Err);
            END CATCH
        END

    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpInquilinoPropietariosUF') IS NOT NULL
            DROP TABLE #TmpInquilinoPropietariosUF;

        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarInquilinoPropietariosUF: %s', 16, 1, @ErrorMensaje);
    END CATCH

	SELECT * FROM #TmpInquilinoPropietariosUF;
END;
GO

--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.CargarPagosConsorciosAStaging
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarPagosConsorciosAStaging
    @RutaArchivo NVARCHAR(4096)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
    BEGIN
        RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
        RETURN;
    END

    BEGIN TRY
        CREATE TABLE #TmpPagosConsorcios (
            IdPago NVARCHAR(50),
            FechaRaw NVARCHAR(50),
            CVU_CBU NVARCHAR(50),
            ValorRaw NVARCHAR(100),
            ValorDecimal DECIMAL(18,3) NULL,
            Fecha DATE NULL
        );

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = N'
        BULK INSERT #TmpPagosConsorcios
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''ACP''
        );';

        EXEC sp_executesql @sql;

        -- Normalizar y convertir valores
        UPDATE #TmpPagosConsorcios
        SET ValorRaw = LTRIM(RTRIM(ValorRaw)),
            ValorRaw = REPLACE(ValorRaw, '$', ''),
            ValorRaw = REPLACE(ValorRaw, ' ', ''),
            ValorDecimal = TRY_CAST(REPLACE(ValorRaw, ',', '.') AS DECIMAL(18,3)),
            Fecha = TRY_CONVERT(DATE, LTRIM(RTRIM(FechaRaw)), 103);

        DECLARE @FilasImportadas INT;
        SELECT @FilasImportadas = COUNT(*) FROM #TmpPagosConsorcios;

        PRINT 'Importación completada (pagos->temp): ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados en #TmpPagosConsorcios.';

        -- Asegurar esquema y tabla Staging
        IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Staging')
            EXEC('CREATE SCHEMA Staging');

        IF OBJECT_ID('Staging.PagosConsorcios','U') IS NULL
        BEGIN
            CREATE TABLE Staging.PagosConsorcios (
                IdPago NVARCHAR(50),
                FechaRaw NVARCHAR(50),
                CVU_CBU NVARCHAR(50),
                ValorRaw NVARCHAR(100),
                ValorDecimal DECIMAL(18,3) NULL,
                Fecha DATE NULL,
                FechaCarga DATETIME DEFAULT (GETDATE())
            );
        END

        BEGIN TRANSACTION;
        BEGIN TRY
            INSERT INTO Staging.PagosConsorcios (IdPago, FechaRaw, CVU_CBU, ValorRaw, ValorDecimal, Fecha)
            SELECT IdPago, FechaRaw, CVU_CBU, ValorRaw, ValorDecimal, Fecha
            FROM #TmpPagosConsorcios;

            DECLARE @FilasPersistidas INT = @@ROWCOUNT;
            COMMIT TRANSACTION;
            PRINT 'Persistido en Staging.PagosConsorcios: ' + CAST(@FilasPersistidas AS NVARCHAR(10)) + ' registros.';
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
            DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR('Error al persistir PagosConsorcios: %s',16,1,@Err);
        END CATCH

        SELECT * FROM #TmpPagosConsorcios;

    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpPagosConsorcios') IS NOT NULL
            DROP TABLE #TmpPagosConsorcios;

        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarPagosConsorciosAStaging: %s', 16, 1, @ErrorMensaje);
    END CATCH
END;
GO