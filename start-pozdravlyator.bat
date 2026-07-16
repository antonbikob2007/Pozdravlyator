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
    echo Downloading .NET 9.0 SDK...
    echo.
    
    :: Скачиваем .NET 9.0 SDK
    powershell -Command "Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/7d02d9a1-11c3-487b-a3e6-3d8d40cedda4/d75d4997878b4a9a5664c837f01e96ee/dotnet-sdk-9.0.100-win-x64.exe' -OutFile '%TEMP%\dotnet-sdk-9.0.100-win-x64.exe'"
    
    if exist "%TEMP%\dotnet-sdk-9.0.100-win-x64.exe" (
        echo [OK] Downloaded successfully
        echo.
        echo Installing .NET 9.0 SDK...
        echo Please follow the installation wizard
        echo.
        start /wait "" "%TEMP%\dotnet-sdk-9.0.100-win-x64.exe" /quiet /norestart
        echo.
        echo [OK] Installation complete
        echo.
    ) else (
        echo [ERROR] Failed to download .NET SDK
        echo Please download manually: https://dotnet.microsoft.com/download/dotnet/9.0
        pause
        exit /b
    )
)

:: Проверяем версию
for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VER=%%i
echo [OK] .NET version: %DOTNET_VER%

echo %DOTNET_VER% | findstr "9." > nul
if errorlevel 1 (
    echo [WARNING] .NET 9.0 is recommended
    echo You have: %DOTNET_VER%
    echo.
    echo Download .NET 9.0: https://dotnet.microsoft.com/download/dotnet/9.0
    echo Press any key to continue anyway...
    pause > nul
)

:: =============================================
:: 2. ПРОВЕРКА NGROK
:: =============================================

where ngrok > nul 2>&1
if errorlevel 1 (
    echo [WARN] ngrok not found - installing...
    echo.
    echo Downloading ngrok...
    powershell -Command "Invoke-WebRequest -Uri 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip' -OutFile '%TEMP%\ngrok.zip'"
    
    if exist "%TEMP%\ngrok.zip" (
        echo [OK] Downloaded successfully
        echo Installing ngrok to current folder...
        powershell -Command "Expand-Archive -Path '%TEMP%\ngrok.zip' -DestinationPath '%~dp0' -Force"
        echo [OK] ngrok installed
        echo.
    ) else (
        echo [ERROR] Failed to download ngrok
        echo Please download manually: https://ngrok.com/download
        echo.
    )
)

:: =============================================
:: 3. ЗАПУСК СЕРВЕРА
:: =============================================

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

echo Waiting 10 seconds...
timeout /t 10 /nobreak > nul

:: =============================================
:: 4. ЗАПУСК NGROK
:: =============================================

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
    echo To enable public access, install ngrok manually
    echo 1. Download: https://ngrok.com/download
    echo 2. Register: https://ngrok.com
    echo 3. Get token from dashboard
    echo 4. Run: ngrok config add-authtoken YOUR_TOKEN
    echo 5. Run: ngrok http 5029
    echo.
    pause
    exit /b
)

echo Starting ngrok...
start "Ngrok" cmd /k "ngrok http 5029"

timeout /t 3 /nobreak > nul

:: Получаем ссылку
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