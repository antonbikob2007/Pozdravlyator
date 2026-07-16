@echo off
cd /d "%~dp0"

echo ========================================
echo  POZDRAVLYATOR - START
echo ========================================
echo.
echo Current folder: %CD%
echo.

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found!
    echo Download: https://dotnet.microsoft.com/download
    pause
    exit /b
)

for /f "tokens=*" %%i in ('dotnet --version') do echo [OK] .NET version: %%i

if not exist "src\Pozdravlyator.Api\Pozdravlyator.Api.csproj" (
    echo [ERROR] Project file not found!
    echo Expected: src\Pozdravlyator.Api\Pozdravlyator.Api.csproj
    echo Current folder: %CD%
    pause
    exit /b
)

echo [OK] Project found
echo.

if not exist "src\Pozdravlyator.Api\wwwroot" (
    echo Creating wwwroot folder...
    mkdir src\Pozdravlyator.Api\wwwroot
)

if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Copying frontend files...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
)

echo Building and starting server...
echo.

:: Запускаем сервер в новом окне
start "Server" cmd /k "cd /d "%~dp0src\Pozdravlyator.Api" && echo Starting server... && dotnet run --urls="http://0.0.0.0:5029""

echo Waiting 10 seconds for server to start...
timeout /t 10 /nobreak > nul

:: Проверяем, запущен ли сервер
netstat -ano | findstr :5029 > nul
if errorlevel 1 (
    echo [WARNING] Server may not be running on port 5029
    echo Check the Server window for errors
) else (
    echo [OK] Server is running on port 5029
)

echo.
echo ========================================
echo  TO ACCESS:
echo ========================================
echo  Local: http://localhost:5029
echo.
echo  If localhost doesnt work, try:
echo  http://127.0.0.1:5029
echo.
echo  Check Server window for errors
echo ========================================
echo.
echo Press any key to open in browser...
pause > nul

start http://localhost:5029

echo.
echo ========================================
echo  Keep this window open
echo  Close it when you want to stop
echo ========================================
pause