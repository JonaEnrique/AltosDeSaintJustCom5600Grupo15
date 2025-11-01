
IF OBJECT_ID('dbo.IsAlpha', 'FN') IS NOT NULL
    DROP FUNCTION dbo.IsAlpha;
GO

CREATE FUNCTION dbo.IsAlpha (@inputString NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;

    IF @inputString LIKE '%[^a-zA-Z]%'
        SET @result = 0;
    ELSE
        SET @result = 1;

    RETURN @result;
END;

GO

IF OBJECT_ID('dbo.ImportConsorciosProveedores', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ImportConsorciosProveedores;
GO

CREATE PROCEDURE dbo.ImportConsorciosProveedores
    @ExcelPath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Enable Ad Hoc Queries if not already
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
    RECONFIGURE;

    -- Temporary staging tables
    CREATE TABLE #TempConsorcios (
        F1 NVARCHAR(100),  -- nombre
        F2 NVARCHAR(200),  -- direccion
        F3 INT,            -- cant_uf
        F4 DECIMAL(10,2)   -- m2_totales
    );

    CREATE TABLE #TempProveedores (
        F1 NVARCHAR(50),   -- tipo
        F2 NVARCHAR(50),   -- nombre_proveedor
        F3 NVARCHAR(50),   -- cuenta
        F4 NVARCHAR(100)   -- nombre consorcio (to resolve id_consorcio)
    );

    -- Import Consorcios
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'INSERT INTO #TempConsorcios
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
                 ''Excel 12.0 Xml;HDR=YES;Database=' + @ExcelPath + ''',
                 ''SELECT * FROM [Consorcios$]'')';
    EXEC sp_executesql @SQL;

    -- Import Proveedores
    SET @SQL = N'INSERT INTO #TempProveedores
                 SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
                 ''Excel 12.0 Xml;HDR=NO;Database=' + @ExcelPath + ''',
                 ''SELECT * FROM [Proveedores$]'')';
    EXEC sp_executesql @SQL;

    -- Insert into Consorcio
    INSERT INTO Consorcio(nombre, direccion, cant_uf, m2_totales)
    SELECT F1, F2, F3, F4
    FROM #TempConsorcios
    WHERE dbo.IsAlpha(F1) = 1; -- optional validation

    -- Insert into Proveedor, mapping consorcio name to id_consorcio
    INSERT INTO Proveedor(tipo, nombre_proveedor, cuenta, id_consorcio)
    SELECT P.F1, P.F2, P.F3, C.id_consorcio
    FROM #TempProveedores P
    INNER JOIN Consorcio C ON C.nombre = P.F4
    WHERE dbo.IsAlpha(P.F2) = 1; -- optional validation
END;
GO