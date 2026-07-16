@echo off
cd /d "%~dp0"

echo ========================================
echo  DIAGNOSTIC
echo ========================================
echo.
echo 1. Current folder:
echo %CD%
echo.

echo 2. Checking for project:
if exist "src\Pozdravlyator.Api\Pozdravlyator.Api.csproj" (
    echo [OK] Project found
) else (
    echo [ERROR] Project NOT found!
)

echo.

echo 3. Checking .NET:
where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET not found
) else (
    for /f "tokens=*" %%i in ('dotnet --version') do echo [OK] .NET version: %%i
)

echo.

echo 4. Checking ngrok:
where ngrok > nul 2>&1
if errorlevel 1 (
    echo [WARN] ngrok not found
) else (
    echo [OK] ngrok found
)

echo.

echo 5. Checking port 5029:
netstat -ano | findstr :5029 > nul
if errorlevel 1 (
    echo [INFO] Port 5029 is free
) else (
    echo [WARNING] Port 5029 is in use
    netstat -ano | findstr :5029
)

echo.

echo ========================================
echo  DIAGNOSTIC COMPLETE
echo ========================================
echo.
echo If you see [ERROR], fix it first.
echo If all [OK], run start-pozdravlyator.bat
echo.
pause