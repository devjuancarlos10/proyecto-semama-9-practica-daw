<?php
/**
 * Archivo: procesar.php
 * Procesamiento de formulario con validacion, sanitizacion y manejo de sesiones.
 * 
 * IA: Validacion segura sin register_globals y control de metodo HTTP
 *  -> Solucion manual: Se valida que la solicitud sea POST emitiendo HTTP 405 en caso contrario, 
 *     y se extraen los campos mediante filter_input() y htmlspecialchars() para evitar XSS.
 */

require_once __DIR__ . '/config.php';

// Validar que el método sea POST (HTTP 405 Method Not Allowed)
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    echo "<h2 style='font-family: sans-serif; color: #dc2626;'>405 - Método no permitido</h2>";
    echo "<p style='font-family: sans-serif;'>Este formulario solo acepta envíos mediante método POST.</p>";
    echo "<p><a href='index.html' style='font-family: sans-serif;'>Volver al formulario</a></p>";
    exit;
}

// Proteger contra register_globals
if (isset($nombre) || isset($correo) || isset($mensaje)) {
    http_response_code(403);
    die("Acceso no autorizado.");
}

// Obtener y validar datos usando filter_input
$nombre = filter_input(INPUT_POST, 'nombre', FILTER_DEFAULT);
$correo = filter_input(INPUT_POST, 'correo', FILTER_VALIDATE_EMAIL);
$mensaje = filter_input(INPUT_POST, 'mensaje', FILTER_DEFAULT);

$errores = [];

if (empty($nombre) || strlen(trim($nombre)) < 2) {
    $errores[] = "Por favor ingrese un nombre válido.";
}

if (!$correo) {
    $errores[] = "El correo electrónico no es válido.";
}

if (empty($mensaje)) {
    $errores[] = "El mensaje no puede estar vacío.";
}

if (!empty($errores)) {
    http_response_code(400);
    echo "<div style='font-family: sans-serif; max-width: 480px; margin: 40px auto; padding: 20px; border: 1px solid #f87171; border-radius: 8px; background: #fef2f2;'>";
    echo "<h3 style='color: #b91c1c;'>Error en los datos ingresados:</h3><ul>";
    foreach ($errores as $error) {
        echo "<li style='color: #7f1d1d;'>" . htmlspecialchars($error, ENT_QUOTES, 'UTF-8') . "</li>";
    }
    echo "</ul><br><a href='index.html'>Volver a intentar</a></div>";
    exit;
}

// Sanitizar con htmlspecialchars
$datos = [
    'nombre' => htmlspecialchars(trim($nombre), ENT_QUOTES, 'UTF-8'),
    'correo' => htmlspecialchars(trim($correo), ENT_QUOTES, 'UTF-8'),
    'mensaje' => htmlspecialchars(trim($mensaje), ENT_QUOTES, 'UTF-8'),
    'fecha' => date('d/m/Y H:i:s')
];

// Guardar en sesión
session_start();
$_SESSION['datos_usuario'] = $datos;

// Registrar en log
registrarLog('ACCESS', "Formulario enviado por: {$datos['correo']}", 302);

// Redireccionar con HTTP 302 (patrón Post-Redirect-Get)
header('Location: resultado.php', true, 302);
exit;
