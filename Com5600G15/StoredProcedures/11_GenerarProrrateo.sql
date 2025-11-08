CREATE OR ALTER FUNCTION Consorcio.sumaOrdinarios(
    @idUnidad INT,
    @fecha DATE
)
RETURNS DECIMAL(30,2)
AS
BEGIN
    DECLARE @total DECIMAL(30,2);
    DECLARE @ultimo_prorrateo DATE;
	DECLARE @idConsorcio INT;
	DECLARE @coeficiente DECIMAL(4,1);

	SELECT 
		@idConsorcio=c.id_consorcio, 
		@coeficiente = u.coeficiente
	FROM Consorcio.Consorcio c
	INNER JOIN Consorcio.UnidadFuncional u ON u.id_consorcio=c.id_consorcio
	where u.id_unidad=@idUnidad;

    
    SELECT @ultimo_prorrateo = MAX(fecha)
    FROM Pago.Prorrateo
    WHERE fecha <= @fecha;

	IF @ultimo_prorrateo IS NULL
	BEGIN
		-- No hay prorrateo previo
		SELECT @total = SUM(importe)
		FROM Pago.GastoOrdinario
		WHERE id_consorcio = @idConsorcio;
	END
	ELSE
	BEGIN
		-- sumar expensas desde el ultimo prorrateo
		SELECT @total = SUM(importe)
		FROM Pago.GastoOrdinario
		WHERE id_consorcio = @idConsorcio
		  AND fecha > @ultimo_prorrateo;
	END

    RETURN ISNULL(@total, 0) * @coeficiente;
END;
GO

CREATE OR ALTER FUNCTION Consorcio.sumaExtraordinarios(
    @idUnidad INT,
    @fecha DATE
)
RETURNS DECIMAL(30,2)
AS
BEGIN
    DECLARE @total DECIMAL(30,2);
    DECLARE @ultimo_prorrateo DATE;
	DECLARE @idConsorcio INT;
	DECLARE @coeficiente DECIMAL(4,1);

	SELECT 
		@idConsorcio=c.id_consorcio,
		@coeficiente = u.coeficiente
	FROM Consorcio.Consorcio c
	INNER JOIN Consorcio.UnidadFuncional u ON u.id_consorcio=c.id_consorcio
	where u.id_unidad=@idUnidad;

    
    SELECT @ultimo_prorrateo = MAX(fecha)
    FROM Pago.Prorrateo
    WHERE fecha <= @fecha;

	IF @ultimo_prorrateo IS NULL
	BEGIN
		-- No hay prorrateo previo
		SELECT @total = SUM(importe)
		FROM Pago.GastoExtraordinario
		WHERE id_consorcio = @idConsorcio;
	END
	ELSE
	BEGIN
		-- sumar expensas desde el ultimo prorrateo
		SELECT @total = SUM(importe)
		FROM Pago.GastoExtraordinario
		WHERE id_consorcio = @idConsorcio
		  AND fecha > @ultimo_prorrateo;
	END
	


    RETURN ISNULL(@total, 0) * @coeficiente;
END;
GO




CREATE OR ALTER FUNCTION Consorcio.unidadPersona(
    @idUnidad INT
)
RETURNS VARCHAR(100)
AS
BEGIN

    DECLARE @nombre VARCHAR(49);
	DECLARE @apellido VARCHAR(50);
	DECLARE @nombre_completo VARCHAR(100);

    SELECT TOP 1
		@nombre=p.nombre, 
		@apellido=p.apellido
    FROM Consorcio.UnidadFuncional u
	INNER JOIN Consorcio.PersonaUnidad pu ON u.id_unidad=pu.id_unidad
	INNER JOIN Consorcio.Persona p ON pu.dni=p.dni
	WHERE u.id_unidad=@idUnidad
	ORDER BY p.apellido, p.nombre;

	SET @nombre_completo = CONCAT(@nombre, ' ', @apellido);
	
	RETURN @nombre_completo;
END;
GO

CREATE OR ALTER FUNCTION Consorcio.bauleraUnidad(
    @idUnidad INT,
	@fecha DATE
)
RETURNS  DECIMAL(30,2)
AS
BEGIN
	--gasto_baulera = expensas_ordinarias * (m2_baulera / (m2_unidad + m2_baulera + m2_cochera))
    DECLARE @gasto_baulera DECIMAL(30,2);
	DECLARE @m2_cochera DECIMAL(30,2);
	DECLARE @m2_baulera DECIMAL(30,2);
	DECLARE @m2_unidad DECIMAL(30,2);

	SELECT 
		@m2_cochera = u.m2_cochera,
		@m2_baulera = u.m2_baulera,
		@m2_unidad = u.m2_unidad
	FROM Consorcio.UnidadFuncional u
	WHERE u.id_unidad=@idUnidad;
	
	SET @gasto_baulera = Consorcio.sumaOrdinarios(@idUnidad,@fecha) 
							* (@m2_baulera/(@m2_baulera+@m2_cochera+@m2_unidad));

	RETURN @gasto_baulera
END;
GO

CREATE OR ALTER FUNCTION Consorcio.cocheraUnidad(
    @idUnidad INT,
	@fecha DATE
)
RETURNS DECIMAL(30,2)
AS
BEGIN
	--gasto_cochera = expensas_ordinarias * (m2_cochera / (m2_unidad + m2_baulera + m2_cochera))
    DECLARE @gasto_cochera DECIMAL(30,2);
	DECLARE @m2_cochera DECIMAL(30,2);
	DECLARE @m2_baulera DECIMAL(30,2);
	DECLARE @m2_unidad DECIMAL(30,2);

	SELECT 
		@m2_cochera = u.m2_cochera,
		@m2_baulera = u.m2_baulera,
		@m2_unidad = u.m2_unidad
	FROM Consorcio.UnidadFuncional u
	WHERE u.id_unidad=@idUnidad;
	
	SET @gasto_cochera = Consorcio.sumaOrdinarios(@idUnidad,@fecha) 
							* (@m2_cochera/(@m2_baulera+@m2_cochera+@m2_unidad));

	RETURN @gasto_cochera
END;
GO

CREATE OR ALTER FUNCTION Consorcio.pagosRecibidos(
    @idUnidad INT
)
RETURNS DECIMAL(30,2)
AS
BEGIN
    DECLARE @pagos_recibidos DECIMAL(30,2);
    DECLARE @ultimo_prorrateo DATE;
	DECLARE @fecha DATE = GETDATE();
    
    SELECT @ultimo_prorrateo = MAX(p.fecha)
    FROM Pago.Prorrateo p
    WHERE p.fecha <= @fecha
	AND p.id_unidad = @idUnidad;

	IF @ultimo_prorrateo IS NULL
	BEGIN
		--no hay prorrateo previo sumar todo
		SELECT @pagos_recibidos = SUM(p.importe)
		FROM Pago.PagoAsociado p
		WHERE P.id_unidad = @idUnidad;
	END
	ELSE
	BEGIN
		-- sumar pagos desde el ultimo prorrateo
		SELECT @pagos_recibidos = SUM(p.importe)
		FROM Pago.PagoAsociado p
		WHERE fecha > @ultimo_prorrateo
		AND p.id_unidad = @idUnidad;
	END

	RETURN ISNULL(@pagos_recibidos, 0);
END;
GO

CREATE OR ALTER PROCEDURE Reporte.actualizarInteresesPorVencimiento
    @fecha DATE,
    @vencimiento INT  -- 1 = primer vencimiento (2%), 2 = segundo vencimiento (5%)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tasa DECIMAL(5,2);

    -- Definir la tasa según el vencimiento
    IF @vencimiento = 1
        SET @tasa = 0.02;  -- 2% primer vencimiento
    ELSE IF @vencimiento = 2
        SET @tasa = 0.05;  -- 5% segundo vencimiento
    ELSE
        RAISERROR('Vencimiento inválido. Solo 1 o 2.', 16, 1);

    -- Actualizar solo los prorrateos de la fecha indicada con deuda pendiente
    UPDATE Pago.Prorrateo
    SET 
        intereses = deudas * @tasa,
        total_a_pagar = deudas + (deudas * @tasa)
    WHERE fecha = @fecha
      AND deudas > 0;
END;
GO



CREATE OR ALTER PROCEDURE Reporte.calcularProrrateo
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @fecha_actual DATE = GETDATE();
		WITH Calculados AS (
		SELECT 
			u.id_unidad,
			u.coeficiente,
			u.piso,
			u.departamento,
			ISNULL((SELECT TOP 1 total_a_pagar - pagos_recibidos
                    FROM Pago.Prorrateo p
                    WHERE p.id_unidad = u.id_unidad
                    ORDER BY fecha DESC), 0) AS saldoAnterior,
			Consorcio.unidadPersona(u.id_unidad) AS propietario,
			Consorcio.cocheraUnidad(u.id_unidad,@fecha_actual) AS precio_cochera,
			Consorcio.bauleraUnidad(u.id_unidad,@fecha_actual) AS precio_baulera,
			Consorcio.pagosRecibidos(u.id_unidad) AS pagos_recibidos,
			Consorcio.sumaOrdinarios(u.id_unidad, @fecha_actual) AS ordinarios,
			Consorcio.sumaExtraordinarios(u.id_unidad, @fecha_actual) AS extraordinarios
		FROM Consorcio.UnidadFuncional u
	)
	INSERT INTO Pago.Prorrateo (
		id_unidad, fecha, porcentaje_m2, piso, depto,
		nombre_propietario, precio_cocheras, precio_bauleras,
		saldo_anterior_abonado, pagos_recibidos, deudas, intereses,
		expensas_ordinarias, expensas_extraordinarias, total_a_pagar
	)
	SELECT
		id_unidad,
		@fecha_actual,
		coeficiente,
		piso,
		departamento,
		propietario,
		precio_cochera,
		precio_baulera,
		c.saldoAnterior AS saldo_anterior_abonado, 
		pagos_recibidos,
		c.saldoAnterior + c.ordinarios + c.extraordinarios - c.pagos_recibidos AS deudas,
		0 AS intereses,
		ordinarios,
		extraordinarios,
		c.saldoAnterior + c.ordinarios + c.extraordinarios - c.pagos_recibidos AS total_a_pagar
	FROM Calculados c;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

