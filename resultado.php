<?php
/**
 * Archivo: resultado.php
 * Muestra los datos almacenados en sesión tras la redirección.
 */

require_once __DIR__ . '/config.php';
session_start();

if (!isset($_SESSION['datos_usuario'])) {
    header('Location: index.html');
    exit;
}

$datos = $_SESSION['datos_usuario'];
registrarLog('ACCESS', "Visualización de resultado para: {$datos['correo']}", 200);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Datos Recibidos</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
        }

        body {
            background-color: #f4f6f9;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            max-width: 480px;
            width: 100%;
            padding: 32px;
        }

        .success-badge {
            display: inline-block;
            background: #dcfce7;
            color: #166534;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 16px;
        }

        h2 {
            font-size: 22px;
            margin-bottom: 20px;
            color: #1e293b;
        }

        .info-row {
            border-bottom: 1px solid #f1f5f9;
            padding: 12px 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .label {
            font-size: 13px;
            color: #64748b;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.03em;
        }

        .value {
            font-size: 15px;
            color: #0f172a;
            word-break: break-word;
        }

        .btn {
            display: block;
            text-align: center;
            margin-top: 24px;
            background-color: #2563eb;
            color: #ffffff;
            text-decoration: none;
            padding: 12px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 6px;
            transition: background-color 0.2s;
        }

        .btn:hover {
            background-color: #1d4ed8;
        }
    </style>
</head>
<body>

    <div class="card">
        <span class="success-badge">✓ Formulario Procesado con Éxito</span>
        <h2>Detalles de la Información</h2>

        <div class="info-row">
            <span class="label">Nombre</span>
            <span class="value"><?= $datos['nombre'] ?></span>
        </div>

        <div class="info-row">
            <span class="label">Correo Electrónico</span>
            <span class="value"><?= $datos['correo'] ?></span>
        </div>

        <div class="info-row">
            <span class="label">Mensaje</span>
            <span class="value"><?= nl2br($datos['mensaje']) ?></span>
        </div>

        <div class="info-row">
            <span class="label">Fecha y Hora de Envío</span>
            <span class="value"><?= $datos['fecha'] ?></span>
        </div>

        <a href="index.html" class="btn">Volver al Formulario</a>
    </div>

</body>
</html>
