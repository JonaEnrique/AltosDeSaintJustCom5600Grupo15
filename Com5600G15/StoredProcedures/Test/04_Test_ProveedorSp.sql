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

-------<<<<<<<TABLA PROVEEDOR>>>>>>>-------

-- PREPARACION: Crear consorcio para las pruebas
DECLARE @id_consorcio_test INT;
EXEC Consorcio.CrearConsorcio 
    @nombre = 'Consorcio Test Proveedor',
    @direccion = 'Calle Proveedor 456',
    @cant_unidades_funcionales = 15,
    @m2_totales = 1500.00,
    @vencimiento1 = '2025-02-10',
    @vencimiento2 = '2025-02-10 23:59:59',
    @id_consorcio = @id_consorcio_test OUTPUT;
GO

-- INSERCION EXITOSA
DECLARE @id_prov1 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Electricidad SA',
    @cuenta = '0123456789',
    @tipo = 'Servicios',
    @id_proveedor = @id_prov1 OUTPUT;
GO

DECLARE @id_prov2 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Plomeria Rodriguez',
    @cuenta = '9876543210',
    @tipo = 'Mantenimiento',
    @id_proveedor = @id_prov2 OUTPUT;
GO

DECLARE @id_prov3 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Limpieza Total',
    @id_proveedor = @id_prov3 OUTPUT;
GO

-- ERROR: CONSORCIO INEXISTENTE
DECLARE @id_prov_error1 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 99999,
    @nombre_proveedor = 'Proveedor Test',
    @id_proveedor = @id_prov_error1 OUTPUT;
GO

-- ERROR: PROVEEDOR DUPLICADO EN MISMO CONSORCIO
DECLARE @id_prov_error2 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = 'Electricidad SA',
    @cuenta = '1111111111',
    @tipo = 'Servicios',
    @id_proveedor = @id_prov_error2 OUTPUT;
GO

-- ERROR: NOMBRE VACIO
DECLARE @id_prov_error3 INT;
EXEC Consorcio.CrearProveedor
    @id_consorcio = 1,
    @nombre_proveedor = '   ',
    @cuenta = '2222222222',
    @tipo = 'Varios',
    @id_proveedor = @id_prov_error3 OUTPUT;
GO

-- MODIFICAR PROVEEDOR
-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarProveedor
    @id_proveedor = 1,
    @nombre_proveedor = 'Electricidad SA Modificado',
    @cuenta = '0123456789-MOD',
    @tipo = 'Servicios Generales';
GO

-- ERROR: ID INVALIDO
EXEC Consorcio.ModificarProveedor
    @id_proveedor = 99999,
    @nombre_proveedor = 'Proveedor Inexistente',
    @cuenta = '0000000000',
    @tipo = 'Ninguno';
GO

-- ERROR: NOMBRE YA EXISTE EN OTRO PROVEEDOR
EXEC Consorcio.ModificarProveedor
    @id_proveedor = 1,
    @nombre_proveedor = 'Plomeria Rodriguez',
    @cuenta = '0123456789',
    @tipo = 'Servicios';
GO

-- ERROR: NOMBRE VACIO
EXEC Consorcio.ModificarProveedor
    @id_proveedor = 1,
    @nombre_proveedor = '   ',
    @cuenta = '0123456789',
    @tipo = 'Servicios';
GO

-- ELIMINAR PROVEEDOR
-- ERROR: ID INVALIDO
EXEC Consorcio.EliminarProveedor @id_proveedor = 99999;
GO

-- ELIMINACION EXITOSA (SIN RELACIONES)
EXEC Consorcio.EliminarProveedor @id_proveedor = 3;
GO

-- MOSTRAR TABLA PROVEEDOR
SELECT * FROM Consorcio.Proveedor;
GO
