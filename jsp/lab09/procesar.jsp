<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%--
  Archivo: procesar.jsp
  Procesamiento de formulario en JSP con validación y sesión en Tomcat.
  
  /* IA: Restricción de método HTTP 405 y persistencia en sesión
     → Solución manual: response.setStatus(405) si no es POST, y session.setAttribute() */
--%>
<%
    // Validar método POST
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        response.setHeader("Allow", "POST");
        out.println("<h2 style='font-family: sans-serif; color: #dc2626;'>405 - Método no permitido</h2>");
        out.println("<p style='font-family: sans-serif;'>Este formulario solo acepta envíos mediante método POST.</p>");
        out.println("<p><a href='index.jsp' style='font-family: sans-serif;'>Volver al formulario</a></p>");
        return;
    }

    request.setCharacterEncoding("UTF-8");
    String nombre = request.getParameter("nombre");
    String correo = request.getParameter("correo");
    String mensaje = request.getParameter("mensaje");

    List<String> errores = new ArrayList<>();

    if (nombre == null || nombre.trim().length() < 2) {
        errores.add("Por favor ingrese un nombre válido.");
    }
    if (correo == null || !correo.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")) {
        errores.add("El correo electrónico no es válido.");
    }
    if (mensaje == null || mensaje.trim().isEmpty()) {
        errores.add("El mensaje no puede estar vacío.");
    }

    if (!errores.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.println("<div style='font-family: sans-serif; max-width: 480px; margin: 40px auto; padding: 20px; border: 1px solid #f87171; border-radius: 8px; background: #fef2f2;'>");
        out.println("<h3 style='color: #b91c1c;'>Error en los datos ingresados:</h3><ul>");
        for (String err : errores) {
            out.println("<li style='color: #7f1d1d;'>" + err + "</li>");
        }
        out.println("</ul><br><a href='index.jsp'>Volver a intentar</a></div>");
        return;
    }

    // Sanitizar valores
    String nombreSan = nombre.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String correoSan = correo.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    String mensajeSan = mensaje.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");

    Map<String, String> datos = new HashMap<>();
    datos.put("nombre", nombreSan);
    datos.put("correo", correoSan);
    datos.put("mensaje", mensajeSan);
    datos.put("fecha", new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));

    session.setAttribute("datos_usuario", datos);

    // Redirección con HTTP 302
    response.sendRedirect("resultado.jsp");
%>
