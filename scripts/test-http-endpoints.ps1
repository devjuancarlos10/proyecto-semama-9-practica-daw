# ==============================================================================
# Universidad Nacional del Centro del Perú
# Facultad de Ingeniería de Sistemas
# Asignatura: Desarrollo de Aplicaciones Web (IS093A)
# Práctica Semana 09: Suite de Pruebas Automatizadas de Endpoints HTTP (Paso 4)
# ==============================================================================

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "   UNCP - PRUEBA DE PROTOCOLO HTTP, STATUS CODES Y HEADERS" -ForegroundColor White
Write-Host "   Arquitectura Cliente-Servidor: PHP (Laragon) vs JSP (Tomcat 10)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

$tests = @(
    @{
        Name = "1. [PHP] Formulario Inicial (GET index.html)"
        Url = "http://localhost/lab09/index.html"
        Method = "GET"
        Body = $null
        ExpectedStatus = 200
        Tech = "Apache 2.4 / Laragon"
    },
    @{
        Name = "2. [PHP] Envío Válido de Formulario (POST procesar.php)"
        Url = "http://localhost/lab09/procesar.php"
        Method = "POST"
        Body = "nombre=Carlos+UNCP&correo=carlos@uncp.edu.pe&rol=Estudiante&experiencia=2&mensaje=Prueba+Automatizada"
        ExpectedStatus = 302
        Tech = "PHP 8.5 (PRG Pattern)"
    },
    @{
        Name = "3. [PHP] Intento de Acceso No Permitido (GET procesar.php)"
        Url = "http://localhost/lab09/procesar.php"
        Method = "GET"
        Body = $null
        ExpectedStatus = 405
        Tech = "PHP 8.5 (filter_input & method check)"
    },
    @{
        Name = "4. [JSP] Formulario Inicial (GET index.jsp)"
        Url = "http://localhost:8085/lab09/index.jsp"
        Method = "GET"
        Body = $null
        ExpectedStatus = 200
        Tech = "Tomcat 10.1 (Jasper Compiler)"
    },
    @{
        Name = "5. [JSP] Envío Válido de Formulario (POST procesar.jsp)"
        Url = "http://localhost:8085/lab09/procesar.jsp"
        Method = "POST"
        Body = "nombre=Maria+Sistemas&correo=msistemas@uncp.edu.pe&rol=Java+Enterprise+(Jakarta+EE)&nivel=9&mensaje=Tomcat+Multithread+Test"
        ExpectedStatus = 302
        Tech = "JSP / Jakarta Servlet 6.0"
    },
    @{
        Name = "6. [JSP] Intento de Acceso No Permitido (GET procesar.jsp)"
        Url = "http://localhost:8085/lab09/procesar.jsp"
        Method = "GET"
        Body = $null
        ExpectedStatus = 405
        Tech = "Tomcat 10.1 (request.getMethod())"
    }
)

foreach ($t in $tests) {
    Write-Host "Ejecutando: $($t.Name)" -ForegroundColor DarkGray
    Write-Host "URL: $($t.Url) [$($t.Method)]" -ForegroundColor Gray
    
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        if ($t.Method -eq "POST") {
            $resp = Invoke-WebRequest -Uri $t.Url -Method Post -Body $t.Body -ContentType "application/x-www-form-urlencoded" -MaximumRedirection 0 -ErrorAction SilentlyContinue
        } else {
            $resp = Invoke-WebRequest -Uri $t.Url -Method Get -MaximumRedirection 0 -ErrorAction SilentlyContinue
        }
        $statusCode = $resp.StatusCode
        $headers = $resp.Headers
    } catch {
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $headers = $_.Exception.Response.Headers
        } else {
            $statusCode = 0
            $headers = @{}
        }
    }
    $sw.Stop()

    $isMatch = ($statusCode -eq $t.ExpectedStatus)
    $statusColor = if ($isMatch) { "Green" } else { "Red" }
    $statusTag = if ($isMatch) { "[PASS]" } else { "[FAIL]" }

    Write-Host "  $statusTag Status HTTP: $statusCode (Esperado: $($t.ExpectedStatus)) - Latencia: $($sw.ElapsedMilliseconds) ms" -ForegroundColor $statusColor
    
    # Inspección de Headers Relevantes (Paso 4)
    if ($headers["Server"]) { Write-Host "    Header Server      : $($headers["Server"])" -ForegroundColor DarkCyan }
    if ($headers["Location"]) { Write-Host "    Header Location    : $($headers["Location"]) (Redirección 302)" -ForegroundColor Yellow }
    if ($headers["Allow"]) { Write-Host "    Header Allow       : $($headers["Allow"]) (Permitidos para 405)" -ForegroundColor Magenta }
    if ($headers["Set-Cookie"]) { Write-Host "    Header Set-Cookie  : $($headers["Set-Cookie"])" -ForegroundColor Blue }
    Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Validación completada. Todos los casos de prueba de la Guía Semana 09 ejecutados." -ForegroundColor Green
