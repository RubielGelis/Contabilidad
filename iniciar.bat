@echo off
setlocal
cd /d "%~dp0"

title Sistema Contable - Iniciando...
echo ============================================
echo   Sistema Contable - Compilacion e Inicio
echo ============================================
echo.

if not exist "node_modules" (
    echo [1/3] Instalando dependencias...
    call npm install
    if errorlevel 1 (
        echo.
        echo [ERROR] Fallo la instalacion de dependencias.
        pause
        exit /b 1
    )
) else (
    echo [1/3] Dependencias ya instaladas.
)

echo.
echo [2/3] Compilando el proyecto Next.js...
call npm run build
if errorlevel 1 (
    echo.
    echo [ERROR] Fallo la compilacion del proyecto.
    pause
    exit /b 1
)

echo.
echo [3/3] Iniciando servidor y abriendo navegador en http://localhost:3000 ...
start "" /b cmd /c "timeout /t 3 /nobreak >nul & start http://localhost:3000"

call npm run start
if errorlevel 1 (
    echo.
    echo [ERROR] El servidor se detuvo con errores.
    pause
    exit /b 1
)
