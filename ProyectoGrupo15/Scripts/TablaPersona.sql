USE "COM5600_G15"
CREATE TABLE Persona (
	dni CHAR(8) PRIMARY KEY,
	nombre VARCHAR(15),
	apellido VARCHAR(15),
	mail VARCHAR(30),
	telefono INT,
	tipo_cuenta CHECK tipo_cuenta in ('CVU','CBU'),
	codigo_cuenta INT
)