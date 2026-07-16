@echo off
cd /d "%~dp0"

echo ========================================
echo  POZDRAVLYATOR - START
echo ========================================
echo.

:: =============================================
:: 1. ПРОВЕРКА .NET
:: =============================================

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found!
    echo.
    echo Download and install .NET 9.0 SDK:
    echo https://dotnet.microsoft.com/download/dotnet/9.0
    echo.
    pause
    exit /b
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VER=%%i
echo [OK] .NET version: %DOTNET_VER%
echo.

:: =============================================
:: 2. ПРОВЕРКА ПРОЕКТА
:: =============================================

if not exist "src\Pozdravlyator.Api\Pozdravlyator.Api.csproj" (
    echo [ERROR] Project not found!
    echo Make sure you are in the correct folder
    pause
    exit /b
)

:: =============================================
:: 3. КОПИРОВАНИЕ ФРОНТЕНДА
:: =============================================

if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Copying frontend files...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Files copied
)
echo.

:: =============================================
:: 4. ЗАПРОС NGROK
:: =============================================

set USE_NGROK=N

where ngrok > nul 2>&1
if errorlevel 1 (
    echo [WARN] ngrok not found
    echo Public access will not work
    echo.
    echo To enable public access, install ngrok:
    echo 1. Download: https://ngrok.com/download
    echo 2. Register: https://ngrok.com
    echo 3. Get token from dashboard
    echo 4. Run: ngrok config add-authtoken YOUR_TOKEN
    echo.
    echo Or press Enter to continue without ngrok
    echo.
) else (
    echo [OK] ngrok found
    echo.
    echo Do you want to use ngrok for public access?
    echo [Y] Yes - start ngrok and get public URL
    echo [N] No - local access only
    echo.
    choice /C YN /N /M "Your choice (Y/N): "
    if errorlevel 2 (
        set USE_NGROK=N
        echo.
        echo Local access only
    ) else (
        set USE_NGROK=Y
        echo.
        echo Public access enabled
    )
)
echo.

:: =============================================
:: 5. ЗАПУСК СЕРВЕРА
:: =============================================

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

netsh advfirewall firewall add rule name="Pozdravlyator 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

echo Starting server...
start "Server" cmd /k "cd /d "%~dp0src\Pozdravlyator.Api" && dotnet run --urls="http://0.0.0.0:5029""

echo Waiting 10 seconds...
timeout /t 10 /nobreak > nul

:: =============================================
:: 6. ЗАПУСК NGROK (если выбран)
:: =============================================

if "%USE_NGROK%"=="Y" (
    echo Starting ngrok...
    start "Ngrok" cmd /k "ngrok http 5029"
    timeout /t 3 /nobreak > nul
    
    for /f "tokens=*" %%a in ('curl -s http://127.0.0.1:4040/api/tunnels ^| findstr "public_url"') do set NGROK_LINE=%%a
    set NGROK_URL=%NGROK_LINE:*"public_url":"=%
    set NGROK_URL=%NGROK_URL:"%,}=%
)

echo.
echo ========================================
echo  SERVER STARTED
echo ========================================
echo  Local:       http://localhost:5029
echo  Local:       http://%IP%:5029
echo  Swagger:     http://localhost:5029/swagger
if "%USE_NGROK%"=="Y" (
    echo  Public:      %NGROK_URL%
)
echo ========================================
echo.
echo Keep windows open. Press Ctrl+C to stop
pause