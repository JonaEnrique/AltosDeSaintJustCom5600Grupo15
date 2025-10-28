CREATE DATABASE Com5600G15

USE Com5600G15
GO

-- Tabla de consorcios
IF OBJECT_ID('dbo.Consorcio', 'U') IS NOT NULL DROP TABLE dbo.Consorcio;
GO

CREATE TABLE dbo.Consorcio (
    id_consorcio     INT IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(100) NOT NULL UNIQUE,
    direccion        NVARCHAR(150) NULL,
    m2_totales       DECIMAL(10,2) NULL,
    vencimiento1     DATE NULL,
    vencimiento2     DATE NULL
);
GO

-- Tabla de unidades funcionales
IF OBJECT_ID('dbo.UnidadFuncional', 'U') IS NOT NULL DROP TABLE dbo.UnidadFuncional;
GO

CREATE TABLE dbo.UnidadFuncional (
    id_unidad_funcional INT IDENTITY(1,1) PRIMARY KEY,
    id_consorcio        INT NOT NULL,
	nombre_consorcio NVARCHAR(100) NULL,
    nroUnidadFuncional  INT NOT NULL,
    piso                NVARCHAR(10) NULL,
    departamento        NVARCHAR(10) NULL,
    coeficiente         DECIMAL(10,4) NULL,
    m2_unidad_funcional DECIMAL(10,2) NULL,
    bauleras            INT NULL,
    cochera             INT NULL,
    m2_baulera          DECIMAL(10,2) NULL,
    m2_cochera          DECIMAL(10,2) NULL,
    FOREIGN KEY (id_consorcio) REFERENCES dbo.Consorcio(id_consorcio)
);
GO

--------------------------------------------------------------------------------
-- 2️⃣ CREACIÓN DEL ESQUEMA IMPORTACION (si no existe)
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Importacion')
    EXEC('CREATE SCHEMA Importacion');
GO

--------------------------------------------------------------------------------
-- 3️⃣ STORED PROCEDURE: Importacion.CargarUnidadFuncional
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
--------------------------------------------------------------------------------
-- 4️⃣ EJEMPLO DE EJECUCIÓN
--------------------------------------------------------------------------------

INSERT INTO dbo.Consorcio (nombre, direccion, m2_totales, vencimiento1, vencimiento2)
VALUES 
    ('Azcuenaga', NULL, NULL, NULL, NULL),
    ('Alzaga', NULL, NULL, NULL, NULL),
    ('Alberdi', NULL, NULL, NULL, NULL),
    ('Unzue', NULL, NULL, NULL, NULL),
    ('Pereyra Iraola', NULL, NULL, NULL, NULL);

-- Verificar que se insertaron
SELECT * FROM dbo.Consorcio;

-- Luego ejecutá el SP con la ruta del archivo:
EXEC Importacion.CargarUnidadFuncional
    @RutaArchivo = 'C:\Users\User\Downloads\Archivos\Archivos\UFporconsorcio.txt';