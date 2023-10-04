CREATE DATABASE IF NOT EXISTS `seguros`;
USE `seguros`;

-- Crear tabla de clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(10),
    direccion VARCHAR(255) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    codigo_postal VARCHAR(20),
    telefono VARCHAR(20),
    email VARCHAR(255) NOT NULL,
    aclaraciones TEXT
    -- Otros campos relacionados con los clientes
);

-- Crear tabla de empleados
CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    cargo VARCHAR(255) NOT NULL,
    numero_identificacion VARCHAR(20) NOT NULL
    -- Otros campos relacionados con los empleados
);

-- Crear tabla de planes
CREATE TABLE planes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    cobertura VARCHAR(255) NOT NULL,
    costo DECIMAL(10, 2) NOT NULL
    -- Otros campos relacionados con los planes
);

-- Crear tabla de transacciones (registro de solicitudes de beneficios, por ejemplo)
CREATE TABLE solicitudes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    plan_id INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (plan_id) REFERENCES planes(id)
);

-- Crear tabla de cuentas de clientes
CREATE TABLE cuentas_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_sha2 VARCHAR(64) NOT NULL,  -- Almacena la contraseña cifrada con SHA-2
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Crear tabla de cuentas de empleados
CREATE TABLE cuentas_empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_sha2 VARCHAR(64) NOT NULL,  -- Almacena la contraseña cifrada con SHA-2
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);


DELIMITER //

-- Procedimiento para registrar nuevo cliente
CREATE PROCEDURE RegistrarNuevoCliente(
    IN p_nombre VARCHAR(255),
    IN p_apellido VARCHAR(255),
    IN p_fecha_nacimiento DATE,
    IN p_genero VARCHAR(10),
    IN p_direccion VARCHAR(255),
    IN p_provincia VARCHAR(50),
    IN p_pais VARCHAR(50),
    IN p_codigo_postal VARCHAR(20),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(255),
    IN p_aclaraciones TEXT,
    IN p_empleado_username VARCHAR(50),  -- Usuario del empleado
    IN p_empleado_password VARCHAR(255),  -- Contraseña del empleado
    OUT p_username VARCHAR(50),
    OUT p_password CHAR(64),  -- Almacena el hash SHA-2 de la contraseña del cliente
    OUT p_empleado_valido INT,  -- Variable de salida para verificar la existencia y autenticación del empleado
    OUT p_cliente_existente INT  -- Variable de salida para verificar si el cliente ya existe
)
BEGIN
    -- Verificar si el empleado existe y las credenciales son válidas
    SELECT COUNT(*) INTO p_empleado_valido
    FROM cuentas_empleados
    WHERE username = p_empleado_username AND password_sha2 = SHA2(p_empleado_password, 256);
    
    -- Si el empleado existe y las credenciales son válidas, proceder con la verificación del cliente
    IF p_empleado_valido = 1 THEN
        -- Verificar si el cliente ya existe (basado en nombre, apellido y fecha de nacimiento)
        SELECT COUNT(*) INTO p_cliente_existente
        FROM clientes
        WHERE nombre = p_nombre AND apellido = p_apellido AND fecha_nacimiento = p_fecha_nacimiento;
        
        -- Si el cliente no existe, proceder con el registro del cliente
        IF p_cliente_existente = 0 THEN
            -- Generar un nombre de usuario (puedes personalizar la lógica según tus necesidades)
            SET p_username = CONCAT(LEFT(p_nombre, 1), LEFT(p_apellido, 4), YEAR(p_fecha_nacimiento));

            SET p_password = SUBSTRING(MD5(RAND()), 1, 8);

            SET p_password = SHA2(p_password, 256);

            -- Insertar el nuevo cliente en la tabla de clientes
            INSERT INTO clientes (nombre, apellido, fecha_nacimiento, genero, direccion, provincia, pais, codigo_postal, telefono, email, aclaraciones)
            VALUES (p_nombre, p_apellido, p_fecha_nacimiento, p_genero, p_direccion, p_provincia, p_pais, p_codigo_postal, p_telefono, p_email, p_aclaraciones);

            -- Obtener el ID del nuevo cliente
            SET @cliente_id = LAST_INSERT_ID();

            -- Insertar la cuenta del cliente en la tabla de cuentas_clientes con la contraseña cifrada en SHA-2
            INSERT INTO cuentas_clientes (cliente_id, username, password_sha2)
            VALUES (@cliente_id, p_username, p_password);
        END IF;
    END IF;
    
END //
DELIMITER ;


DELIMITER //
-- Procedimiento para registrar nuevo empleado
CREATE PROCEDURE RegistrarNuevoEmpleado(
    IN p_nombre VARCHAR(255),
    IN p_cargo VARCHAR(255),
    IN p_numero_identificacion VARCHAR(20),
    OUT p_username VARCHAR(50),
    OUT p_password CHAR(64)  -- Almacenará el hash SHA-2 de la contraseña
)
BEGIN
    -- Verificar si el número de identificación del empleado ya existe
    DECLARE contador INT;
    SET contador = 0;
    SELECT COUNT(*) INTO contador FROM empleados WHERE numero_identificacion = p_numero_identificacion;
    
    -- Si el número de identificación no existe, proceder con el registro del empleado
    IF contador = 0 THEN
        -- Generar un nombre de usuario (puedes personalizar la lógica según tus necesidades)
        SET p_username = CONCAT(LEFT(p_nombre, 1), LEFT(p_cargo, 4), p_numero_identificacion);

        SET p_password = SUBSTRING(MD5(RAND()), 1, 8);
        -- Generar una contraseña aleatoria (puedes personalizar la generación)
        SET p_password = SHA2(p_password, 256);

        -- Insertar el nuevo empleado en la tabla de empleados
        INSERT INTO empleados (nombre, cargo, numero_identificacion)
        VALUES (p_nombre, p_cargo, p_numero_identificacion);

        -- Obtener el ID del nuevo empleado
        SET @empleado_id = LAST_INSERT_ID();

        -- Insertar la cuenta del empleado en la tabla de cuentas_empleados con la contraseña cifrada en SHA-2
        INSERT INTO cuentas_empleados (empleado_id, username, password_sha2)
        VALUES (@empleado_id, p_username, p_password);
    END IF;
END //
DELIMITER ;

DELIMITER //
-- Procedimiento para registrar o actualizar un plan
CREATE PROCEDURE RegistrarOActualizarPlan(
    IN p_nombre VARCHAR(255),
    IN p_cobertura VARCHAR(255),
    IN p_costo DECIMAL(10, 2),
    OUT p_resultado INT
)
BEGIN
    DECLARE plan_id INT;
    
    -- Buscar si ya existe un plan con el mismo nombre
    SELECT id INTO plan_id
    FROM planes
    WHERE nombre = p_nombre;
    
    -- Si el plan con ese nombre ya existe, actualizarlo y establecer el resultado a 2
    IF plan_id IS NOT NULL THEN
        UPDATE planes
        SET cobertura = p_cobertura, costo = p_costo
        WHERE id = plan_id;
        SET p_resultado = 2;
    ELSE
        -- Si no existe, insertar un nuevo plan y establecer el resultado a 1
        INSERT INTO planes (nombre, cobertura, costo)
        VALUES (p_nombre, p_cobertura, p_costo);
        SET p_resultado = 1;
    END IF;
    
    -- Si no se pudo realizar ninguna acción, establecer el resultado a 0
    IF p_resultado IS NULL THEN
        SET p_resultado = 0;
    END IF;
END //
DELIMITER ;

DELIMITER //
-- Procedimiento para gestionar solicitudes
CREATE PROCEDURE GestionarSolicitud(
    IN p_cliente_id INT,
    IN p_plan_id INT,
    OUT p_resultado INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- En caso de error, establecer el resultado a 0
        SET p_resultado = 0;
    END;
    
    -- Intentar insertar la solicitud en la tabla de solicitudes
    INSERT INTO solicitudes (cliente_id, plan_id)
    VALUES (p_cliente_id, p_plan_id);
    
    -- Si la inserción fue exitosa, establecer el resultado a 1
    SET p_resultado = 1;
END //
DELIMITER ;
