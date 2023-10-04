const mysql = require('mysql');

// Configura la conexión a tu base de datos MySQL
const connection = mysql.createConnection({
    host: 'localhost',  // Cambia a la dirección de tu servidor MySQL
    user: 'administrador', // Cambia a tu nombre de usuario de MySQL
    password: 'administrador', // Cambia a tu contraseña de MySQL
    database: 'seguros' // Cambia al nombre de tu base de datos
});

// Función para registrar un nuevo cliente
function registrarCliente(
    nombre,
    apellido,
    fechaNacimiento,
    genero,
    direccion,
    provincia,
    pais,
    codigoPostal,
    telefono,
    email,
    aclaraciones,
    callback
) {
    // Conectar a la base de datos
    connection.connect((err) => {
        if (err) {
            return callback(err, null);
        }

        // Llamar al procedimiento almacenado para registrar un nuevo cliente
        connection.query(
            'CALL RegistrarNuevoCliente(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @username, @password)',
            [
                nombre,
                apellido,
                fechaNacimiento,
                genero,
                direccion,
                provincia,
                pais,
                codigoPostal,
                telefono,
                email,
                aclaraciones
            ],
            (err, results) => {
                if (err) {
                    connection.end(); // Cerrar la conexión en caso de error
                    return callback(err, null);
                }

                // Obtener los resultados de las variables de salida
                connection.query(
                    'SELECT @username AS NuevoUsername, @password AS NuevaContraseña',
                    (err, results) => {
                        connection.end(); // Cerrar la conexión después de obtener los resultados
                        if (err) {
                            return callback(err, null);
                        }
                        const nuevoUsername = results[0].NuevoUsername;
                        const nuevaContraseña = results[0].NuevaContraseña;
                        callback(null, { nuevoUsername, nuevaContraseña });
                    }
                );
            }
        );
    });
}