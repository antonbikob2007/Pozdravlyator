@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo ========================================
echo  ПОЗДРАВЛЯТОР - ЗАПУСК
echo ========================================
echo.

:: =============================================
:: 1. ПРОВЕРКА .NET SDK
:: =============================================

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] .NET SDK не найден!
    echo.
    echo Открываем страницу для скачивания...
    start https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo Скачай и установи .NET 8.0 SDK
    echo После установки перезагрузи компьютер
    echo.
    pause
    exit /b
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VER=%%i
echo [OK] .NET SDK: %DOTNET_VER%
echo.

:: =============================================
:: 2. ПРОВЕРКА ASP.NET CORE RUNTIME 8.0
:: =============================================

echo Проверка ASP.NET Core Runtime 8.0...

:: Сохраняем список установленных runtime в файл
dotnet --list-runtimes > "%TEMP%\runtimes.txt"

:: Ищем точное совпадение с 8.0
findstr /C:"Microsoft.AspNetCore.App 8." "%TEMP%\runtimes.txt" > nul
if errorlevel 1 (
    echo.
    echo [ОШИБКА] ASP.NET Core Runtime 8.0 не найден!
    echo.
    echo Установленные runtime:
    type "%TEMP%\runtimes.txt"
    echo.
    echo Открываем страницу для скачивания...
    start https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo Скачай и установи ASP.NET Core Runtime 8.0
    echo После установки перезагрузи компьютер
    echo.
    del "%TEMP%\runtimes.txt"
    pause
    exit /b
)

del "%TEMP%\runtimes.txt"
echo [OK] ASP.NET Core Runtime 8.0 найден
echo.

:: =============================================
:: 3. ЗАПУСК СЕРВЕРА
:: =============================================

:: Проверка проекта
if not exist "src\Pozdravlyator.Api\Pozdravlyator.Api.csproj" (
    echo [ОШИБКА] Проект не найден!
    pause
    exit /b
)

:: Копирование фронтенда
if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Копирование файлов...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Файлы скопированы
)
echo.

:: Проверка ngrok
set USE_NGROK=N
where ngrok > nul 2>&1
if errorlevel 1 (
    echo [ВНИМАНИЕ] ngrok не найден
    echo Публичный доступ не будет работать
    echo.
    echo Скачать ngrok: https://ngrok.com/download
    echo.
) else (
    echo [OK] ngrok найден
    echo.
    echo Использовать ngrok для публичного доступа? (Y/N)
    choice /C YN /N /M "Ваш выбор: "
    if not errorlevel 2 set USE_NGROK=Y
)
echo.

:: Получаем IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

:: Запуск сервера
echo Запуск сервера...
start "Server" cmd /k "cd /d "%~dp0src\Pozdravlyator.Api" && dotnet run --urls="http://0.0.0.0:5029""

timeout /t 8 /nobreak > nul

:: Запуск ngrok
if "%USE_NGROK%"=="Y" (
    echo Запуск ngrok...
    start "Ngrok" cmd /k "ngrok http 5029"
    timeout /t 3 /nobreak > nul

    for /f "tokens=*" %%a in ('curl -s http://127.0.0.1:4040/api/tunnels ^| findstr "public_url"') do set NGROK_LINE=%%a
    set NGROK_URL=%NGROK_LINE:*"public_url":"=%
    set NGROK_URL=%NGROK_URL:"%,}=%
)

echo.
echo ========================================
echo  СЕРВЕР ЗАПУЩЕН
echo ========================================
echo  Локально:    http://localhost:5029
echo  Локально:    http://%IP%:5029
echo  Swagger:     http://localhost:5029/swagger
if "%USE_NGROK%"=="Y" echo  Публичная:   %NGROK_URL%
echo ========================================
echo.
echo Не закрывай окна. Для остановки Ctrl+C
pause