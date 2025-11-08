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

        select * from #TmpUnidadFuncional;
        -- Insertar los datos nuevos en UnidadFuncional
		INSERT INTO Consorcio.UnidadFuncional (
			id_consorcio,
			piso,
			departamento,
			coeficiente,
			m2_unidad,
			m2_baulera,
			m2_cochera
		)
		SELECT 
			c.id_consorcio,
			LTRIM(RTRIM(t.Piso)),
			LTRIM(RTRIM(t.Departamento)),
			TRY_CAST(REPLACE(t.Coeficiente, ',', '.') AS DECIMAL(4,1)),
			TRY_CAST(t.m2_unidad_funcional AS DECIMAL(10,2)),  -- from the file
			TRY_CAST(t.m2_baulera AS DECIMAL(10,2)),
			TRY_CAST(t.m2_cochera AS DECIMAL(10,2))
		FROM #TmpUnidadFuncional t
		INNER JOIN Consorcio.Consorcio c
			ON c.nombre = LTRIM(RTRIM(t.NombreConsorcio))
		WHERE NOT EXISTS (
			SELECT 1 
			FROM Consorcio.UnidadFuncional u
			WHERE u.id_consorcio = c.id_consorcio
			  AND u.piso = LTRIM(RTRIM(t.Piso))
			  AND u.departamento = LTRIM(RTRIM(t.Departamento))
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

CREATE OR ALTER FUNCTION dbo.NormalizarNumero (@num NVARCHAR(50))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @limpio NVARCHAR(50) = @num;

    IF @limpio LIKE '%,%' AND @limpio LIKE '%.%' AND CHARINDEX(',', @limpio) < CHARINDEX('.', @limpio)
	BEGIN
        -- estilo US: 22,648.59 -> eliminar ','
        SET @limpio = REPLACE(@limpio, ',', '');
	END
    ELSE IF @limpio LIKE '%.%' AND @limpio LIKE '%,%' AND CHARINDEX('.', @limpio) < CHARINDEX(',', @limpio)
	BEGIN
        -- estilo EU: 33.706,04 -> eliminar '.' y reemplazar ',' con '.'
        SET @limpio = REPLACE(@limpio, '.', '');
        SET @limpio = REPLACE(@limpio, ',', '.');
	END
    ELSE IF @limpio LIKE '%,%' AND CHARINDEX(',', @limpio) = LEN(@limpio)-2
	BEGIN
        -- por las dudas: 9.613,50 -> reemplazar ',' con '.'
        SET @limpio = REPLACE(@limpio, ',', '.');
	END
    ELSE
	BEGIN
        SET @limpio = REPLACE(@limpio, ',', ''); -- fallback
	END

    RETURN TRY_CAST(@limpio AS DECIMAL(10,2));
END;
GO



IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'Seq_Factura')
    CREATE SEQUENCE Seq_Factura
        START WITH 1
        INCREMENT BY 1;
GO

CREATE OR ALTER PROCEDURE Importacion.ImportarJSON 
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaArchivo IS NULL OR LTRIM(RTRIM(@RutaArchivo)) = ''
        BEGIN
            RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
            RETURN;
        END

	
    CREATE TABLE #TempServicios (
        id NVARCHAR(50),
        nombre_consorcio NVARCHAR(100),
        mes NVARCHAR(20),
        bancarios DECIMAL(10,2),
        limpieza DECIMAL(10,2),
        administracion DECIMAL(10,2),
        seguros DECIMAL(10,2),
        gastos_generales DECIMAL(10,2),
        servicios_agua DECIMAL(10,2),
        servicio_luz DECIMAL(10,2)
    );
	
	DECLARE @sql NVARCHAR(MAX);
	SET @sql = 
	N'
	DECLARE @json NVARCHAR(MAX);
	SELECT @json = BulkColumn
	FROM OPENROWSET(BULK '''+ @RutaArchivo +N''' , SINGLE_CLOB) AS j;

	INSERT INTO #TempServicios
	SELECT 
		id,
		nombre_consorcio,
		mes,
		dbo.NormalizarNumero(seguros) AS seguros,
		dbo.NormalizarNumero(limpieza) AS limpieza,
		dbo.NormalizarNumero(administracion) AS administracion,
		dbo.NormalizarNumero(bancarios) AS bancarios,
		dbo.NormalizarNumero(gastos_generales) AS gastos_generales,
		dbo.NormalizarNumero(servicios_agua) AS servicios_agua,
		dbo.NormalizarNumero(servicio_luz) AS servicio_luz
	FROM OPENJSON(@json)
	WITH (
		id NVARCHAR(50) ''$._id."$oid"'',
		nombre_consorcio NVARCHAR(200) ''$."Nombre del consorcio"'',
		mes NVARCHAR(20) ''$.Mes'',
		bancarios NVARCHAR(20) ''$.BANCARIOS'',
		limpieza NVARCHAR(20) ''$.LIMPIEZA'',
		administracion NVARCHAR(20) ''$.ADMINISTRACION'',
		seguros NVARCHAR(20) ''$.SEGUROS'',
		gastos_generales NVARCHAR(20) ''$."GASTOS GENERALES"'',
		servicios_agua NVARCHAR(20) ''$."SERVICIOS PUBLICOS-Agua"'',
		servicio_luz NVARCHAR(20) ''$."SERVICIOS PUBLICOS-Luz"''
	);';
	EXEC sp_executesql @sql ;

	DELETE #TempServicios 
	WHERE nombre_consorcio IS NULL;

	DECLARE @TipoGastoMap TABLE (
    json_tipo NVARCHAR(50),
    prov_tipo NVARCHAR(50)
	);

	INSERT INTO @TipoGastoMap VALUES
		('BANCARIOS', 'GASTOS BANCARIOS'),
		('LIMPIEZA', 'LIMPIEZA'),
		('ADMINISTRACION', 'ADMINISTRACION'),
		('SEGUROS', 'SEGUROS'),
		('GASTOS GENERALES', 'GASTOS GENERALES'),
		('SERVICIOS AGUA', 'AGUA'),
		('SERVICIOS LUZ', 'LUZ');

	INSERT INTO Pago.GastoOrdinario
	(
	id_consorcio,
	tipo_gasto,
	fecha,
	nro_factura,
	importe,
	id_proveedor,
	descripcion
	)
	SELECT 
	c.id_consorcio,
	m.json_tipo AS tipo_gasto,
	DATEFROMPARTS(YEAR(GETDATE()), 
		CASE gs.mes
			WHEN 'enero' THEN 1
			WHEN 'febrero' THEN 2
			WHEN 'marzo' THEN 3
			WHEN 'abril' THEN 4
			WHEN 'mayo' THEN 5
			WHEN 'junio' THEN 6
			WHEN 'julio' THEN 7
			WHEN 'agosto' THEN 8
			WHEN 'septiembre' THEN 9
			WHEN 'octubre' THEN 10
			WHEN 'noviembre' THEN 11
			WHEN 'diciembre' THEN 12
			ELSE 1
		END, 1) AS fecha,
	NEXT VALUE FOR Seq_Factura,
	gs.importe,
	p.id_proveedor,   -- quedará NULL si no hay proveedor
	NULL AS descripcion
	FROM
	(
	SELECT nombre_consorcio, 'BANCARIOS' AS tipo_gasto, bancarios AS importe, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'LIMPIEZA', limpieza, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'ADMINISTRACION', administracion, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'SEGUROS', seguros, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'GASTOS GENERALES', gastos_generales, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'SERVICIOS AGUA', servicios_agua, mes FROM #TempServicios
	UNION ALL
	SELECT nombre_consorcio, 'SERVICIOS LUZ', servicio_luz, mes FROM #TempServicios
	) gs
	INNER JOIN @TipoGastoMap m ON gs.tipo_gasto = m.json_tipo
	INNER JOIN Consorcio.Consorcio c 
	ON LOWER(LTRIM(RTRIM(gs.nombre_consorcio))) = LOWER(LTRIM(RTRIM(c.nombre)))
	LEFT JOIN Consorcio.Proveedor p 
	ON p.id_consorcio = c.id_consorcio 
	AND LOWER(LTRIM(RTRIM(p.tipo))) = LOWER(LTRIM(RTRIM(m.prov_tipo)))
	WHERE gs.importe>0;

END;
GO

--------------------------------------------------------------------------------
--STORED PROCEDURE: Importacion.ImportarConsorciosProveedores
--------------------------------------------------------------------------------
IF OBJECT_ID('Importacion.ImportarConsorciosProveedores', 'P') IS NOT NULL
    DROP PROCEDURE Importacion.ImportarConsorciosProveedores;
GO

CREATE PROCEDURE Importacion.ImportarConsorciosProveedores
    @RutaExcel NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
	IF @RutaExcel IS NULL OR LTRIM(RTRIM(@RutaExcel)) = ''
    BEGIN
        RAISERROR('La ruta del excel no puede estar vacía', 16, 1);
        RETURN;
    END
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
				TRY_CAST(LTRIM(RTRIM(F2)) AS NVARCHAR(200)) AS F2,
				TRY_CAST(LTRIM(RTRIM(F3)) AS NVARCHAR(200)) AS F3,
				TRY_CAST(LTRIM(RTRIM(F4)) AS INT) AS F4,
				TRY_CAST(LTRIM(RTRIM(F5)) AS DECIMAL(10,2)) AS F5
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.16.0'',
				''Excel 12.0 Xml;HDR=NO;Database=' + @RutaExcel +N''',
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
				''Excel 12.0 Xml;HDR=NO;Database=' + @RutaExcel +N''',
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
		INNER JOIN Consorcio.Consorcio C
			ON C.nombre = P.nombre_consorcio;  -- JOIN en el nombre del consorcio

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		-- Declaramos e informamos el error
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		THROW;  
	END CATCH;

	--Volvemos a la configuracion original
	EXEC sp_configure 'Ad Hoc Distributed Queries', @prevAdHoc;
	EXEC sp_configure 'show advanced options', @prevShowAdvanced;
	RECONFIGURE;
END;
GO
--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.CargarInquilinoPropietariosDatos
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarInquilinoPropietariosDatos
    @RutaArchivo NVARCHAR(4000)
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
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpInquilinoPropietariosDatos') IS NOT NULL
            DROP TABLE #TmpInquilinoPropietariosDatos;

        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarInquilinoPropietariosDatos: %s', 16, 1, @ErrorMensaje);
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.CargarInquilinoPropietariosUF
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.CargarInquilinoPropietariosUF
    @RutaArchivo NVARCHAR(4000)
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

        UPDATE #TmpInquilinoPropietariosUF
        SET CVU_CBU = LTRIM(RTRIM(CVU_CBU)),
            NombreConsorcio = LTRIM(RTRIM(NombreConsorcio)),
            nroUnidadFuncional = LTRIM(RTRIM(nroUnidadFuncional)),
            piso = LTRIM(RTRIM(piso)),
            departamento = LTRIM(RTRIM(departamento));

        DECLARE @FilasImportadas INT;
        SELECT @FilasImportadas = COUNT(*) FROM #TmpInquilinoPropietariosUF;
        PRINT 'Importación completada (UF): ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados en #TmpInquilinoPropietariosUF.';
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpInquilinoPropietariosUF') IS NOT NULL
            DROP TABLE #TmpInquilinoPropietariosUF;

        DECLARE @ErrorMensaje NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('error en Importacion.CargarInquilinoPropietariosUF: %s', 16, 1, @ErrorMensaje);
	END CATCH
END;
GO
--------------------------------------------------------------------------------
-- STORED PROCEDURE: Importacion.ImportarPagos
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Importacion.ImportarPagos
    @RutaCsv NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RutaCsv IS NULL OR LTRIM(RTRIM(@RutaCsv)) = ''
    BEGIN
        RAISERROR('La ruta del archivo no puede estar vacía', 16, 1);
        RETURN;
    END

    BEGIN TRY

        DECLARE @sql NVARCHAR(1000);
		CREATE TABLE #TmpPago (
			id			   VARCHAR(40),
            fecha          VARCHAR(15),
			cvu_cbu        VARCHAR(25),
			importe        VARCHAR(40)
        );

		SET @sql=N'BULK INSERT #TmpPago
		FROM ''' + @RutaCsv +N'''
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''\n''
		);';

		EXEC sp_executesql @sql;

		SELECT t.id AS idPagosInvalidos
		FROM #TmpPago t
		WHERE (NULLIF(LTRIM(RTRIM(importe)), '''') IS NULL)
			OR (NULLIF(LTRIM(RTRIM(fecha)), '''') IS NULL)
			OR (TRY_CAST(importe AS DECIMAL(10,2)) < 0) 
			OR TRY_CAST(fecha AS DATE) IS NULL;

		--eliminando tuplas invalidas de pago
		DELETE FROM #TmpPago
		WHERE 
			(NULLIF(LTRIM(RTRIM(importe)), '''') IS NULL)
			OR (NULLIF(LTRIM(RTRIM(fecha)), '''') IS NULL)
			OR (TRY_CAST(importe AS DECIMAL(10,2)) < 0) 
			OR TRY_CAST(fecha AS DATE) IS NULL;

		
			
		INSERT INTO Pago.PagoAsociado (fecha,cvu_cbu,importe)
		SELECT 
			TRY_CAST(t.fecha AS DATE),
			LTRIM(RTRIM(t.cvu_cbu)),
			TRY_CAST(t.importe AS DECIMAL(10,2))
		FROM #TmpPago t;

		WITH pagoPersona AS (
		SELECT 
			a.cvu_cbu,
			u.id_unidad 
		FROM Pago.PagoAsociado a
		INNER JOIN Consorcio.Persona p ON a.cvu_cbu=p.cvu_cbu
		INNER JOIN Consorcio.PersonaUnidad u ON u.dni=p.dni
		)
		UPDATE p
		SET p.id_unidad = c.id_unidad
		FROM Pago.PagoAsociado p
		INNER JOIN pagoPersona c ON c.cvu_cbu=p.cvu_cbu;

        DECLARE @FilasImportadas INT;
        SELECT @FilasImportadas = COUNT(*) FROM #TmpPago;

        PRINT 'Importación completada (datos): ' + CAST(@FilasImportadas AS NVARCHAR(10)) + ' registros insertados en PagoAsociado.';
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TmpPago') IS NOT NULL
            DROP TABLE #TmpPago;

        THROW;
    END CATCH
END;
GO