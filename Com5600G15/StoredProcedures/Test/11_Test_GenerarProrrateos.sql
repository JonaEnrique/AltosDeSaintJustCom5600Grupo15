USE Com5600G15
GO
/*
    ---------------------------------------------------------------------
    -Fecha: 27/10/2025
    -Grupo: 15
    -Materia: Bases de Datos Aplicada
    - Integrantes:
    - Jonathan Enrique
    - Ariel De Brito
    - Franco Perez
    - Cristian Vergara
    Consigna: ejecutar sp de generar prorrateo
    ---------------------------------------------------------------------
*/

--Ejecucion del sp de Calcular Prorrateo

EXEC Reporte.calcularProrrateo 

--Ver tabla prorrateo
SELECT * FROM Pago.Prorrateo