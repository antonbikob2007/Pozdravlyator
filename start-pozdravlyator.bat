@echo off
cd /d "%~dp0"

echo ========================================
echo  POZDRAVLYATOR - START
echo ========================================
echo.

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found
    echo Download: https://dotnet.microsoft.com/download
    pause
    exit /b
)

where ngrok > nul 2>&1
if errorlevel 1 (
    echo [WARN] ngrok not found
    echo Public access will not work
    echo Download: https://ngrok.com/download
    echo.
)

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Copying frontend files...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Files copied
)
echo.

netsh advfirewall firewall add rule name="Pozdravlyator 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

echo Starting server...
start "Server" cmd /k "cd /d "%~dp0src\Pozdravlyator.Api" && dotnet run --urls="http://0.0.0.0:5029""

echo Waiting 5 seconds...
timeout /t 5 /nobreak > nul

where ngrok > nul 2>&1
if errorlevel 1 (
    echo.
    echo ========================================
    echo  LOCAL ACCESS ONLY
    echo ========================================
    echo  http://localhost:5029
    echo  http://%IP%:5029
    echo  http://%IP%:5029/swagger
    echo ========================================
    echo.
    echo To enable public access:
    echo 1. Install ngrok: https://ngrok.com/download
    echo 2. Register at ngrok.com
    echo 3. Get token from dashboard
    echo 4. Run: ngrok config add-authtoken YOUR_TOKEN
    echo 5. Run: ngrok http 5029
    echo.
    pause
    exit /b
)

echo Starting ngrok...
start "Ngrok" cmd /k "ngrok http 5029"

echo Waiting 3 seconds...
timeout /t 3 /nobreak > nul

for /f "tokens=*" %%a in ('curl -s http://127.0.0.1:4040/api/tunnels ^| findstr "public_url"') do set NGROK_LINE=%%a
set NGROK_URL=%NGROK_LINE:*"public_url":"=%
set NGROK_URL=%NGROK_URL:"%,}=%

echo.
echo ========================================
echo  SERVER STARTED
echo ========================================
echo  Local:       http://localhost:5029
echo  Local:       http://%IP%:5029
echo  Swagger:     http://localhost:5029/swagger
echo  Public:      %NGROK_URL%
echo ========================================
echo.
echo Keep windows open. Press Ctrl+C to stop
pause