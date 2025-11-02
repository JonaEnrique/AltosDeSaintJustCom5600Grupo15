/*
    ---------------------------------------------------------------------
    -Fecha: 02/11/2025
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
-------<<<<<<<TABLA PERSONA>>>>>>>-------
-- INSERCION EXITOSA
EXEC Consorcio.CrearPersona
    @dni = 12345678,
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @mail = 'juan.perez@mail.com',
    @telefono = '1123456789',
    @cbu_cvu = '0000003100010000000001';
GO

EXEC Consorcio.CrearPersona
    @dni = 23456789,
    @nombre = 'María',
    @apellido = 'González',
    @mail = 'maria.gonzalez@mail.com',
    @telefono = '1145678901',
    @cbu_cvu = '0000003100010000000002';
GO

EXEC Consorcio.CrearPersona
    @dni = 34567890,
    @nombre = 'Carlos',
    @apellido = 'López',
    @mail = 'carlos.lopez@mail.com',
    @telefono = '1156789012';
GO

-- ERROR: DNI YA EXISTE
EXEC Consorcio.CrearPersona
    @dni = 12345678,
    @nombre = 'Pedro',
    @apellido = 'Martínez',
    @mail = 'pedro.martinez@mail.com',
    @telefono = '1167890123',
    @cbu_cvu = '0000003100010000000003';
GO

-- ERROR: EMAIL INVALIDO (FALTA @)
EXEC Consorcio.CrearPersona
    @dni = 45678901,
    @nombre = 'Ana',
    @apellido = 'Rodríguez',
    @mail = 'ana.rodriguezmail.com',
    @telefono = '1178901234',
    @cbu_cvu = '0000003100010000000004';
GO

-- ERROR: EMAIL INVALIDO (FALTA .)
EXEC Consorcio.CrearPersona
    @dni = 56789012,
    @nombre = 'Laura',
    @apellido = 'Fernández',
    @mail = 'laura.fernandez@mailcom',
    @telefono = '1189012345',
    @cbu_cvu = '0000003100010000000005';
GO

-- ERROR: CBU/CVU DUPLICADO
EXEC Consorcio.CrearPersona
    @dni = 67890123,
    @nombre = 'Diego',
    @apellido = 'Sánchez',
    @mail = 'diego.sanchez@mail.com',
    @telefono = '1190123456',
    @cbu_cvu = '0000003100010000000001';
GO

-- ERROR: DNI <= 0
EXEC Consorcio.CrearPersona
    @dni = -12345,
    @nombre = 'Roberto',
    @apellido = 'Torres',
    @mail = 'roberto.torres@mail.com',
    @telefono = '1101234567',
    @cbu_cvu = '0000003100010000000006';
GO

-- MODIFICAR PERSONA
-- MODIFICACION EXITOSA
EXEC Consorcio.ModificarPersona
    @dni = 12345678,
    @nombre = 'Juan Carlos',
    @apellido = 'Pérez García',
    @mail = 'juanc.perez@mail.com',
    @telefono = '1199887766',
    @cbu_cvu = '0000003100010000000001';
GO

-- ERROR: DNI NO EXISTE
EXEC Consorcio.ModificarPersona
    @dni = 99999999,
    @nombre = 'Inexistente',
    @apellido = 'Persona',
    @mail = 'inexistente@mail.com',
    @telefono = '1122334455',
    @cbu_cvu = '0000003100010000000099';
GO

-- ERROR: CBU/CVU DUPLICADO CON OTRA PERSONA
EXEC Consorcio.ModificarPersona
    @dni = 12345678,
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @mail = 'juan.perez@mail.com',
    @telefono = '1123456789',
    @cbu_cvu = '0000003100010000000002';
GO

-- ERROR: EMAIL INVALIDO
EXEC Consorcio.ModificarPersona
    @dni = 12345678,
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @mail = 'emailinvalido',
    @telefono = '1123456789',
    @cbu_cvu = '0000003100010000000001';
GO

-- ELIMINAR PERSONA
-- ERROR: DNI NO EXISTE
EXEC Consorcio.EliminarPersona @dni = 99999999;
GO

-- ELIMINACION EXITOSA (SIN RELACIONES)
EXEC Consorcio.EliminarPersona @dni = 34567890;
GO

-- MOSTRAR TABLA PERSONA
SELECT * FROM Consorcio.Persona;
GO
