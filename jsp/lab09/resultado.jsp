<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%--
  Archivo: resultado.jsp
  Vista de resultados en JSP tras redirección.
--%>
<%
    @SuppressWarnings("unchecked")
    Map<String, String> datos = (Map<String, String>) session.getAttribute("datos_usuario");
    if (datos == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Datos Recibidos (JSP)</title>
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
            background-color: #ea580c;
            color: #ffffff;
            text-decoration: none;
            padding: 12px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 6px;
            transition: background-color 0.2s;
        }

        .btn:hover {
            background-color: #c2410c;
        }
    </style>
</head>
<body>

    <div class="card">
        <span class="success-badge">✓ Formulario JSP Procesado con Éxito</span>
        <h2>Detalles de la Información</h2>

        <div class="info-row">
            <span class="label">Nombre</span>
            <span class="value"><%= datos.get("nombre") %></span>
        </div>

        <div class="info-row">
            <span class="label">Correo Electrónico</span>
            <span class="value"><%= datos.get("correo") %></span>
        </div>

        <div class="info-row">
            <span class="label">Mensaje</span>
            <span class="value"><%= datos.get("mensaje").replace("\n", "<br>") %></span>
        </div>

        <div class="info-row">
            <span class="label">Fecha y Hora de Envío</span>
            <span class="value"><%= datos.get("fecha") %></span>
        </div>

        <a href="index.jsp" class="btn">Volver al Formulario</a>
    </div>

</body>
</html>
