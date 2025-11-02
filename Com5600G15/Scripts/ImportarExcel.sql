
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
		INSERT INTO Consorcio(nombre, direccion, cant_unidades_funcionales, m2_totales, vencimiento1, vencimiento2)
		SELECT T.nombre_consorcio, T.direccion, T.cant_unidades_funcionales, T.m2_totales, GETDATE(), GETDATE()
		FROM #TempConsorcios T;

		-- Insertar en tabla Proveedor dela BD, mapeando Consorcio
		INSERT INTO Proveedor(id_consorcio, nombre_proveedor, cuenta, tipo)
		SELECT C.id_consorcio, P.nombre_proveedor, P.cuenta, P.tipo
		FROM #TempProveedores P
		INNER JOIN Consorcio C
			ON C.nombre = P.nombre_consorcio;  -- JOIN en el nombre del consorcio

		COMMIT TRANSACTION;
		
		--Volvemos a la onfiguracion original
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