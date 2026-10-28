<?php
/**
 * Archivo: config.php
 * Configuracion global del entorno y logging.
 * 
 * IA: Deteccion de zona horaria y manejo de logs
 *  -> Solucion manual: date_default_timezone_set('America/Lima') para sincronizar logs locales
 *     y registro de eventos de acceso/error en carpeta dedicada.
 */

date_default_timezone_set('America/Lima');

define('APP_NAME', 'Sistema Web');
define('APP_ENV', 'development');
define('LOG_DIR', __DIR__ . '/logs');

if (!is_dir(LOG_DIR)) {
    mkdir(LOG_DIR, 0755, true);
}

ini_set('display_errors', '1');
error_reporting(E_ALL);
ini_set('log_errors', '1');
ini_set('error_log', LOG_DIR . '/error.log');

function registrarLog($tipo, $mensaje, $statusCode = null) {
    $fecha = date('Y-m-d H:i:s');
    $ip = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    $metodo = $_SERVER['REQUEST_METHOD'] ?? 'CLI';
    $uri = $_SERVER['REQUEST_URI'] ?? '/';
    $statusText = $statusCode ? " [Status: $statusCode]" : "";
    
    $linea = "[$fecha] [$ip] [$metodo $uri]$statusText [$tipo] $mensaje" . PHP_EOL;
    $archivo = ($tipo === 'ERROR') ? LOG_DIR . '/error.log' : LOG_DIR . '/access.log';
    file_put_contents($archivo, $linea, FILE_APPEND | LOCK_EX);
}
