USE Com5600G15
GO

--script para ejecutar las querys del archivo de importaciones.
/*NOTA: la ruta de los archivos como los nombres de los archivos en si se han elegido arbitrariamente.
Esto puede cambiarse a gusto siempre y cuando se modifique el parametro enviado a los SP*/

--ImportarUnidadFuncional
EXECUTE Importacion.CargarUnidadFuncional @RutaArchivo = 'C:\ArchivosBDA\UF por consorcio.txt'

--JSON (Gastos por Consorcio)
EXECUTE Importacion.ImportarJSON @RutaArchivo = 'C:\ArchivosBDA\Servicios.Servicios.json'

--Importar proveedores de servicios para los consorcios
EXECUTE Importacion.ImportarConsorciosProveedores @RutaExcel = 'C:\ArchivosBDA\datos varios.xlsx'

--Importar datos de inquilinos y propietarios
EXECUTE Importacion.CargarInquilinoPropietariosDatos @RutaArchivo = 'C:\ArchivosBDA\Inquilino-propietarios-datos.csv'

--Importar datos Unidad Funcional
EXECUTE Importacion.CargarInquilinoPropietariosUF @RutaArchivo = 'C:\ArchivosBDA\Inquilino-propietarios-UF.csv'

--Importar PagosConsorcios
EXECUTE Importacion.ImportarPagos @RutaCsv = 'C:\ArchivosBDA\pagos_consorcios.csv'