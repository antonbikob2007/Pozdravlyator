@echo off
cd /d "%~dp0"

echo ========================================
echo  POZDRAVLYATOR - START
echo ========================================
echo.

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found!
    echo.
    echo Opening download page...
    start https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo Download and install .NET 8.0 SDK
    echo Restart your computer after installation
    echo.
    pause
    exit /b
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VER=%%i
echo [OK] .NET SDK: %DOTNET_VER%
echo.

echo Checking ASP.NET Core Runtime 8.0...

dotnet --list-runtimes > "%TEMP%\runtimes.txt"
findstr /C:"Microsoft.AspNetCore.App 8." "%TEMP%\runtimes.txt" > nul

if errorlevel 1 (
    echo.
    echo [ERROR] ASP.NET Core Runtime 8.0 not found!
    echo.
    echo Installed runtimes:
    type "%TEMP%\runtimes.txt"
    echo.
    echo Opening download page...
    start https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo Download and install ASP.NET Core Runtime 8.0
    echo Restart your computer after installation
    echo.
    del "%TEMP%\runtimes.txt"
    pause
    exit /b
)

del "%TEMP%\runtimes.txt"
echo [OK] ASP.NET Core Runtime 8.0 found
echo.

if not exist "src\Pozdravlyator.Api\Pozdravlyator.Api.csproj" (
    echo [ERROR] Project not found!
    pause
    exit /b
)

if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Copying frontend files...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Files copied
)
echo.

set USE_NGROK=N
where ngrok > nul 2>&1
if errorlevel 1 (
    echo [WARN] ngrok not found
    echo Public access will not work
    echo.
    echo Download ngrok: https://ngrok.com/download
    echo.
) else (
    echo [OK] ngrok found
    echo.
    echo Use ngrok for public access? (Y/N)
    choice /C YN /N /M "Your choice: "
    if not errorlevel 2 set USE_NGROK=Y
)
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

echo Starting server...
start "Server" cmd /k "cd /d "%~dp0src\Pozdravlyator.Api" && dotnet run --urls="http://0.0.0.0:5029""

timeout /t 8 /nobreak > nul

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
if "%USE_NGROK%"=="Y" echo  Public:      %NGROK_URL%
echo ========================================
echo.
echo Keep windows open. Press Ctrl+C to stop
pause