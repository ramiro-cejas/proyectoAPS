<?php
// Obtener los valores del formulario
$usuario = $_POST['usuario'];
$contrasena = $_POST['contrasena'];

// Incluir el archivo de usuarios de prueba
include 'usuarios_de_prueba.php';

// Función para verificar las credenciales por tipo
function verificarCredenciales($usuario, $contrasena, $usuarios) {
    foreach ($usuarios as $u) {
        if ($u['usuario'] === $usuario && $u['contrasena'] === $contrasena) {
            return true;
        }
    }
    return false;
}

// Verificar las credenciales por tipo
if (verificarCredenciales($usuario, $contrasena, $clientesDePrueba)) {
    // Credenciales de cliente válidas, puedes redirigir o realizar acciones de cliente
    echo "Inicio de sesión exitoso como cliente";
} elseif (verificarCredenciales($usuario, $contrasena, $empleadosDePrueba)) {
    // Credenciales de empleado válidas, puedes redirigir o realizar acciones de empleado
    echo "Inicio de sesión exitoso como empleado";
} elseif (verificarCredenciales($usuario, $contrasena, $adminsDePrueba)) {
    // Credenciales de administrador válidas, puedes redirigir o realizar acciones de administrador
    echo "Inicio de sesión exitoso como administrador";
} else {
    // Credenciales incorrectas, muestra un mensaje de error
    echo "Error: Usuario o contraseña incorrectos";
}
?>
