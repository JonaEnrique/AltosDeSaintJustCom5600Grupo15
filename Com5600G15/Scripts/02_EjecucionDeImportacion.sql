USE Com5600G15
GO

--script para ejecutar las querys del archivo de importaciones.
/*NOTA: la ruta de los archivos como los nombres de los archivos en si se han elegido arbitrariamente.
Esto puede cambiarse a gusto siempre y cuando se modifique el parametro enviado a los SP*/


--Importar proveedores de servicios para los consorcios y consorcios
EXECUTE Importacion.ImportarConsorciosProveedores @RutaExcel = 'C:\ArchivosBDA\datos varios.xlsx'
GO

--ImportarUnidadesFuncionales
EXECUTE Importacion.CargarUnidadFuncional @RutaArchivo = 'C:\ArchivosBDA\UF por consorcio.txt'
GO

--JSON (Gastos por Consorcio)
EXECUTE Importacion.ImportarJSON @RutaArchivo = 'C:\ArchivosBDA\Servicios.Servicios.json'
GO

--Importar datos Unidad Funcional (Importar en nueva tabla, ver como poner id_consorcio en lugar del nombre)
EXECUTE Importacion.CargarInquilinoPropietariosUF @RutaArchivo = 'C:\ArchivosBDA\Inquilino-propietarios-UF.csv'

--Importar datos de inquilinos y propietarios (Corregir como pasar a la tabla en bd)
EXECUTE Importacion.CargarInquilinoPropietariosDatos @RutaArchivo = 'C:\ArchivosBDA\Inquilino-propietarios-datos.csv'

--Importar PagosConsorcios (Corregir)
EXECUTE Importacion.ImportarPagos @RutaCsv = 'C:\ArchivosBDA\pagos_consorcios.csv'