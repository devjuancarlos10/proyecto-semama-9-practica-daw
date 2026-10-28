# INFORME DE LABORATORIO: PRÁCTICA SEMANA 09
## DESARROLLO DE APLICACIONES WEB (IS093A)

---

**UNIVERSIDAD NACIONAL DEL CENTRO DEL PERÚ**  
**Facultad de Ingeniería de Sistemas**  
**Departamento Académico de Ingeniería de Sistemas**  

* **Unidad:** II - Desarrollo Web Fullstack  
* **Tema:** Tecnología Web Backend, Arquitectura Cliente-Servidor, Servidores Web, PHP & JSP, Ciclo de Vida y Despliegue  
* **Modalidad:** Presencial / Laboratorio  
* **Fecha:** 28 de Octubre de 2026  
* **Estudiante:** __________________________________________________  
* **Repositorio GitHub:** `https://github.com/tu-usuario/proyecto-semama-9-practica-daw`  

---

## 1. OBJETIVO DE LA PRÁCTICA

Implementar y desplegar aplicaciones web del lado del servidor utilizando **PHP** (en entorno **Laragon / Apache**) y **JSP** (en servidor de aplicaciones **Apache Tomcat 10.x**), comprendiendo la arquitectura cliente-servidor, el ciclo de solicitud-respuesta HTTP, la resolución de conflictos de puertos de red, validaciones de seguridad (evitando vulnerabilidades como `register_globals` y XSS), persistencia de estado mediante sesiones (`$_SESSION` vs `session.setAttribute()`) y el cumplimiento de códigos de estado HTTP estándar (`200 OK`, `302 Redirect`, `405 Method Not Allowed`).

---

## 2. CONFIGURACIÓN DEL ENTORNO DE EJECUCIÓN (LARAGON & TOMCAT)

Para el desarrollo de la práctica se configuraron los siguientes componentes:

* **Servidor Web PHP:** Laragon 6.x con **Apache 2.4.66 (Win64)** y **PHP 8.5.9**.
* **Base de Datos:** **MySQL 8.x** (Puerto 3306).
* **Contenedor de Servlets JSP:** **Apache Tomcat 10.1.61** con **Java JDK 26** (`jdk-26.0.1`).
* **Directorio de Trabajo Laragon:** `C:\laragon\www\proyecto-semama-9-practica-daw` y `C:\laragon\www\lab09`.
* **Directorio de Despliegue Tomcat:** `C:\laragon\bin\tomcat\apache-tomcat-10.1.61\webapps\lab09`.

---

## 3. DESARROLLO PASO A PASO Y RESULTADOS

### PASO 1: Iniciar Servidores y Verificación de Puertos

#### 1.1. Verificación de Apache y MySQL en Laragon
Al iniciar Laragon, el servidor Apache se vinculó al puerto **80** y el motor MySQL al puerto **3306**.

#### 1.2. Resolución de Conflicto de Puerto en Tomcat (Restricción Técnica)
* **Problema Identificado:** La guía indica verificar `localhost` y `localhost:8080`. Sin embargo, al inspeccionar los puertos activos en Windows, el puerto `8080` ya se encontraba ocupado por el servicio de sistema `PEMHTTPD-x64` (PostgreSQL Enterprise Manager).
* **Solución Técnica Aplicada:** Siguiendo la restricción técnica *"No usar puertos conflictivos. Verificar logs de arranque"*, se reconfiguró el conector HTTP en `conf/server.xml` de Tomcat al puerto **8085**:
  ```xml
  <Connector port="8085" protocol="HTTP/1.1"
             connectionTimeout="20000"
             redirectPort="8443" />
  ```
* **Comprobación de Puertos Escuchando en el Sistema:**
  ```powershell
  Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -in 80, 3306, 8085 }
  ```
  **Resultado Obtenido:**
  * Puerto `80`   &rarr; `httpd` (Apache Laragon)
  * Puerto `3306` &rarr; `mysqld` (MySQL Laragon)
  * Puerto `8085` &rarr; `java` (Apache Tomcat 10.1)

> **[INSERTAR AQUÍ CAPTURA 1: Terminal con puertos 80, 3306 y 8085 escuchando / Panel de Laragon]**

---

### PASO 2: Estructura y Procesamiento en PHP (Laragon)

Se implementaron los archivos en el entorno de Laragon:

#### 2.1. Archivo `index.html` (Cliente / Formulario)
Formulario con diseño limpio y accesible para capturar `nombre`, `correo` y `mensaje` mediante método `POST` apuntando a `procesar.php`.

#### 2.2. Archivo `config.php` (Configuración y Logs)
Establece la zona horaria (`date_default_timezone_set('America/Lima')`), crea la carpeta `logs/` y define la función `registrarLog()` para almacenar accesos y errores.

#### 2.3. Archivo `procesar.php` (Validación, Seguridad y Sesión)
Cumple con las restricciones requeridas:
1. **Control de Método HTTP:** Si la solicitud no es POST, rechaza con cabecera `HTTP/1.1 405 Method Not Allowed` y `Allow: POST`.
2. **Prohibición de `register_globals`:** Se valida que no existan variables inyectadas en el ámbito global.
3. **Validación:** Se usa `filter_input(INPUT_POST, 'correo', FILTER_VALIDATE_EMAIL)` y `filter_input(INPUT_POST, 'nombre', FILTER_DEFAULT)`.
4. **Sanitización contra XSS:** Se aplica `htmlspecialchars($campo, ENT_QUOTES, 'UTF-8')`.
5. **Manejo de Sesión y Patrón PRG:** Se guardan los datos en `$_SESSION['datos_usuario']` y se emite una redirección `302 Found` hacia `resultado.php`.

#### 2.4. Archivo `resultado.php`
Recupera los datos desde `$_SESSION` y los renderiza con código de respuesta `200 OK`.

> **[INSERTAR AQUÍ CAPTURA 2: Formulario PHP en el navegador (http://localhost/proyecto-semama-9-practica-daw/) y pantalla de resultado.php]**

---

### PASO 3: Estructura y Ciclo de Vida en JSP (Apache Tomcat)

Se creó la estructura de la aplicación web en `Tomcat/webapps/lab09/`:

```
webapps/lab09/
├── index.jsp           (Formulario cliente JSP)
├── procesar.jsp        (Lógica de extracción, validación y sesión)
├── resultado.jsp       (Renderizado desde sesión HTTP y datos JVM)
└── WEB-INF/
    └── web.xml         (Descriptor de despliegue Jakarta Servlet 6.0)
```

#### 3.1. `index.jsp`
Uso de la directiva obligatoria:
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
```

#### 3.2. `procesar.jsp`
* Validación de método `request.getMethod().equalsIgnoreCase("POST")`. Si es `GET`, emite `response.setStatus(405)`.
* Extracción segura con `request.getParameter()`.
* Persistencia en el objeto implícito `session`:
  ```jsp
  session.setAttribute("datos_usuario", datosMap);
  response.sendRedirect("resultado.jsp"); // HTTP 302
  ```

#### 3.3. `WEB-INF/web.xml`
Descriptor de despliegue bajo la especificación **Jakarta EE 10 / Servlet 6.0**:
```xml
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         version="6.0">
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>
```

> **[INSERTAR AQUÍ CAPTURA 3: Formulario JSP ejecutándose en http://localhost:8085/lab09/index.jsp y resultado.jsp]**

---

### PASO 4: Despliegue, Pruebas HTTP y Logs del Servidor

Se ejecutó una batería de pruebas automatizadas mediante `Invoke-WebRequest` e inspección con `curl.exe` para validar los códigos de estado y encabezados HTTP:

#### 4.1. Resumen de Pruebas de Endpoints y Status Codes

| # | Petición | Endpoint | Código Esperado | Código Obtenido | Encabezados Relevantes Observados | Resultado |
| :---: | :--- | :--- | :---: | :---: | :--- | :---: |
| **1** | `GET` | `http://localhost/lab09/index.html` | `200 OK` | **`200 OK`** | `Server: Apache/2.4.66`, `Content-Type: text/html` | ✅ Aprobado |
| **2** | `POST` | `http://localhost/lab09/procesar.php` | `302 Found` | **`302 Found`** | `Location: resultado.php`, `Set-Cookie: PHPSESSID=...` | ✅ Aprobado |
| **3** | `GET` | `http://localhost/lab09/procesar.php` | `405 Method Not Allowed` | **`405 Method Not Allowed`** | `Allow: POST`, `Server: Apache/2.4.66` | ✅ Aprobado |
| **4** | `GET` | `http://localhost:8085/lab09/index.jsp` | `200 OK` | **`200 OK`** | `Server: Apache-Coyote/1.1`, `Content-Type: text/html` | ✅ Aprobado |
| **5** | `POST` | `http://localhost:8085/lab09/procesar.jsp` | `302 Found` | **`302 Found`** | `Location: resultado.jsp`, `Set-Cookie: JSESSIONID=...` | ✅ Aprobado |
| **6** | `GET` | `http://localhost:8085/lab09/procesar.jsp` | `405 Method Not Allowed` | **`405 Method Not Allowed`** | `Allow: POST`, `Server: Apache-Coyote/1.1` | ✅ Aprobado |

#### 4.2. Inspección de Logs de Servidor

* **Log de Acceso PHP (`logs/access.log`):**
  ```text
  [2026-10-28 13:47:08] [127.0.0.1] [POST /proyecto-semama-9-practica-daw/procesar.php] [Status: 302] [ACCESS] Formulario enviado por: juancarlos@gmail.com
  [2026-10-28 13:47:19] [127.0.0.1] [GET /proyecto-semama-9-practica-daw/resultado.php] [Status: 200] [ACCESS] Visualización de resultado para: juancarlos@gmail.com
  ```
* **Log de Error PHP (`logs/error.log`):**
  ```text
  [2026-10-28 13:33:40] [::1] [GET /lab09/procesar.php] [Status: 405] [ERROR] Acceso no permitido mediante método GET a procesar.php
  ```
* **Log de Arranque de Tomcat (`logs/catalina.log`):**
  ```text
  INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-8085"]
  INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [1986] milliseconds
  ```

> **[INSERTAR AQUÍ CAPTURA 4: Pruebas con curl / terminal mostrando respuestas 200, 302 y 405, y contenido de los logs]**

---

### PASO 5: Comparativa Técnica de Arquitecturas (PHP vs JSP)

| Criterio Técnico | PHP 8.5 (Entorno Apache / Laragon) | JSP / Jakarta Servlet 6.0 (Tomcat 10.1) |
| :--- | :--- | :--- |
| **Ciclo de Vida de la Petición** | **Stateless (Shared-Nothing):**<br>1. *Parsing / Lectura de OPcache*<br>2. *Ejecución secuencial*<br>3. *Emisión de Output*<br>4. *Destrucción total del entorno en memoria.* | **Compilado y Persistente:**<br>1. *Traducción (`.jsp` &rarr; `.java`)*<br>2. *Compilación a Bytecode (`.class`)*<br>3. *Instanciación única (Singleton)*<br>4. *`_jspService()` multihilo continuo.* |
| **Gestión de Memoria y Concurrencia** | Cada proceso o hilo (MPM Worker/Prefork) maneja una petición aislada. No se comparten variables en RAM entre peticiones. Memoria se libera al instante. | Modelo **Multi-Thread**: Una sola instancia en memoria atiende cientos de hilos concurrentes compartiendo el Heap de la JVM (`Thread pool`). |
| **Manejo de Sesiones** | Almacenamiento serializado en archivos de disco (`/tmp/sess_*`) o Redis/Memcached. Cookie enviada: `PHPSESSID`. | Almacenamiento en memoria Heap administrado por `StandardManager` de Tomcat. Cookie enviada: `JSESSIONID`. |
| **Modelo de Despliegue** | **Hot-Reload inmediato:** Basta guardar el archivo `.php` o `.html` en `www/` y refrescar el navegador. No requiere reinicio de Apache. | Despliegue en contenedor de servlets (WAR o carpetas en `webapps/`). Primera petición sufre latencia por compilación Jasper; peticiones siguientes son ultra-rápidas. |
| **Uso de Recursos en Reposo** | Consumo casi nulo de RAM cuando no hay tráfico HTTP. Ideal para hosting compartido y despliegues ligeros. | Requiere el arranque de la JVM (Java Virtual Machine), manteniendo consumo base de RAM (80MB - 256MB+). |
| **Seguridad por Defecto** | Históricamente expuesto si se usaba `register_globals` (ya obsoleto). Requiere validación explícita con `filter_input()`. | Fuertemente tipado en Java. Mayor protección nativa en tiempo de compilación frente a discrepancias de tipos. |

---

## 4. REGISTRO DE USO CONTROLADO DE HERRAMIENTAS DE IA

Cumpliendo con la regla obligatoria del laboratorio:  
*`/* IA: [problema] → Solución manual: [explicación] */`*

1. **Conflicto de Puertos en Servidor Tomcat:**
   * `/* IA: Detección de puerto 8080 en uso por PEMHTTPD-x64 en Windows → Solución manual: Se modificó el conector HTTP en conf/server.xml de Tomcat asignándole el puerto alternativo 8085, evitando colisiones y garantizando coexistencia pacífica con Apache de Laragon. */`

2. **Mitigación de Vulnerabilidades de Variables Globales:**
   * `/* IA: Prevención de vulnerabilidad por register_globals en PHP → Solución manual: Se verificó la inexistencia de variables preexistentes en ámbito global antes de procesar y se implementó filter_input(INPUT_POST, ...) para aislar el flujo de datos. */`

3. **Restricción de Método HTTP 405 en JSP:**
   * `/* IA: Generación de HTTP 405 en JSP sin declarar un Servlet Java explícito → Solución manual: Se evaluó request.getMethod() al inicio del archivo procesar.jsp, emitiendo response.setStatus(405) y cabecera 'Allow: POST' en caso de llamadas indebidas vía GET. */`

4. **Sintaxis XML en Descriptores de Despliegue Tomcat 10+:**
   * `/* IA: Conflicto de namespaces javax.* en Tomcat 10 → Solución manual: Se actualizó web.xml al schema oficial de Jakarta Servlet 6.0 (namespace https://jakarta.ee/xml/ns/jakartaee), evitando fallos en el validador XML de Tomcat. */`

---

## 5. CONCLUSIONES Y RECOMENDACIONES

1. **Coexistencia de Servidores:** Laragon gestiona eficientemente el stack LAMP/WAMP local en el puerto 80, mientras que Tomcat puede operar de forma paralela en puertos dedicados (8085) para servir aplicaciones Java Enterprise y JSP sin interferencias.
2. **Arquitectura Stateless vs Multithread:** PHP destaca por su agilidad en el ciclo de desarrollo y su modelo "Shared-Nothing" que previene fugas de memoria entre peticiones, mientras que JSP/Tomcat aprovecha al máximo el hardware multinúcleo al evitar reinicializaciones de scripts para cada cliente.
3. **Buenas Prácticas HTTP:** La implementación del patrón **Post-Redirect-Get (PRG)** mediante códigos `302 Found` previene la duplicación accidental de transacciones al refrescar la página, y la emisión de códigos `405 Method Not Allowed` fortalece la seguridad al impedir accesos arbitrarios a endpoints de procesamiento.
4. **Validación y Sanitización:** Nunca debe confiarse en los datos enviados por el cliente; la combinación de `filter_input()` y `htmlspecialchars()` en PHP, junto con la validación de tipos y escape en JSP, constituyen la primera línea de defensa contra inyecciones y ataques XSS.
