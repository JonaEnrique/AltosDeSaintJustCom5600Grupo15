USE Com5600G15;

GO

CREATE TABLE Proveedor (
	id_proveedor INT PRIMARY KEY IDENTITY(1,1),
	id_consorcio INT NOT NULL,
	nombre_proveedor VARCHAR(50) NOT NULL,
	cuenta VARCHAR(50),
	tipo VARCHAR(50),
	CONSTRAINT fk_consorcio_proveedor FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
);

GO

CREATE TABLE GastoOrdinario (
	id_gasto INT PRIMARY KEY IDENTITY(1,1), 
	id_consorcio INT NOT NULL,
	tipo_gasto VARCHAR(60),
	fecha DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
	importe DECIMAL(10,2) NOT NULL,
	nro_factura INT NOT NULL,
	id_proveedor INT NOT NULL,
	descripcion VARCHAR(60),
	CONSTRAINT fk_gastoOrdinario_consorcio FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio),
	CONSTRAINT fk_gastoOrdinario_proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

GO

CREATE TABLE EstadoFinanciero (
	id_estado INT PRIMARY KEY IDENTITY(1,1),
	id_consorcio INT NOT NULL,
	fecha DATE CHECK (YEAR(fecha) > 1958 AND YEAR(fecha) <= YEAR(SYSDATETIME())),
	saldo_anterior DECIMAL(10,2),
	ingreso_en_termino DECIMAL(10,2),
	ingreso_adeudado DECIMAL(10,2), 
	ingreso_adelantado DECIMAL(10,2),
	egresos_mes DECIMAL(10,2),
	saldo_cierre DECIMAL(10,2),
	CONSTRAINT fk_estadoFinanciero_consorcio FOREIGN KEY (id_consorcio) REFERENCES Consorcio(id_consorcio)
);

