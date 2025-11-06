/*
    ---------------------------------------------------------------------
    -Fecha: 21/11/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Perez
    - Cristian Vergara
    -Script: PRUEBAS Stored Procedures de modificacion de tablas
    ---------------------------------------------------------------------
*/
USE Com5600G15
GO

-------<<<<<<<TABLA CONSORCIO>>>>>>>-------

-- INSERCION EXITOSA
DECLARE @id1 INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Las Palmeras',
    @direccion = 'Av. Corrientes 1234',
    @cant_unidades_funcionales = 24,
    @m2_totales = 1500.50,
    @vencimiento1 = '2025-01-10',
    @vencimiento2 = '2025-01-10 23:59:59',
    @id_consorcio = @id1 OUTPUT;

-- INSERCION EXITOSA DE SEGUNDO CONSORCIO (necesario para la prueba de nombre duplicado)
DECLARE @id2 INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Torre Norte',
    @direccion = 'Av. Santa Fe 5678',
    @cant_unidades_funcionales = 30,
    @m2_totales = 2000.00,
    @vencimiento1 = '2025-02-15',
    @vencimiento2 = '2025-02-15 23:59:59',
    @id_consorcio = @id2 OUTPUT;

-- ERROR: NOMBRE YA EXISTE
DECLARE @id_error1 INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Las Palmeras',
    @direccion = 'Otra Direccion 123',
    @cant_unidades_funcionales = 10,
    @m2_totales = 500.00,
    @vencimiento1 = '2025-04-01',
    @vencimiento2 = '2025-04-01 23:59:59',
    @id_consorcio = @id_error1 OUTPUT;

-- ERROR: CANTIDAD UNIDADES FUNCIONALES <= 0
DECLARE @id_error2 INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Invalido 1',
    @direccion = 'Direccion Test',
    @cant_unidades_funcionales = 0,
    @m2_totales = 500.00,
    @vencimiento1 = '2025-05-01',
    @vencimiento2 = '2025-05-01 23:59:59',
    @id_consorcio = @id_error2 OUTPUT;

-- ERROR: M2 TOTALES <= 0
DECLARE @id_error3 INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Invalido 2',
    @direccion = 'Direccion Test',
    @cant_unidades_funcionales = 10,
    @m2_totales = -100.00,
    @vencimiento1 = '2025-06-01',
    @vencimiento2 = '2025-06-01 23:59:59',
    @id_consorcio = @id_error3 OUTPUT;

-- MODIFICAR CONSORCIO

-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarConsorcio 
    @id_consorcio = 1,
    @nombre = 'Consorcio Las Palmeras Renovado',
    @direccion = 'Av. Corrientes 1234 - Piso 2',
    @cant_unidades_funcionales = 28,
    @m2_totales = 1800.00,
    @vencimiento1 = '2025-01-20',
    @vencimiento2 = '2025-01-20 23:59:59';

-- ERROR: ID INVALIDO
EXEC Consorcio.ModificarConsorcio 
    @id_consorcio = 99999,
    @nombre = 'Consorcio Inexistente',
    @direccion = 'Direccion 123',
    @cant_unidades_funcionales = 10,
    @m2_totales = 500.00,
    @vencimiento1 = '2025-07-01',
    @vencimiento2 = '2025-07-01 23:59:59';

-- ERROR: NOMBRE YA EXISTE EN OTRO CONSORCIO
EXEC Consorcio.ModificarConsorcio 
    @id_consorcio = 1,
    @nombre = 'Consorcio Torre Norte',
    @direccion = 'Direccion Nueva',
    @cant_unidades_funcionales = 20,
    @m2_totales = 1000.00,
    @vencimiento1 = '2025-08-01',
    @vencimiento2 = '2025-08-01 23:59:59';

-- ELIMINAR CONSORCIO

-- ERROR: ID INVALIDO
EXEC Consorcio.EliminarConsorcio @id_consorcio = 99999;

-- MOSTRAR TABLA CONSORCIO
SELECT * FROM Consorcio.Consorcio;
GO
