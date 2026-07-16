@echo off
chcp 1251 > nul

echo ========================================
echo  ПОЗДРАВЛЯТОР - ЗАПУСК
echo ========================================
echo.

where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] .NET SDK не найден
    echo Скачай: https://dotnet.microsoft.com/download
    pause
    exit /b
)
echo [OK] .NET найден

where ngrok > nul 2>&1
if errorlevel 1 (
    echo [ВНИМАНИЕ] ngrok не найден
    echo Публичный доступ не будет работать
    echo Скачай: https://ngrok.com/download
    echo.
)

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Копирование файлов фронтенда...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Файлы скопированы
)
echo.

netsh advfirewall firewall add rule name="Pozdravlyator 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

echo Запуск сервера...
start "Server" cmd /k "cd /d src\Pozdravlyator.Api && dotnet run --urls="http://0.0.0.0:5029""

echo Ожидание 5 секунд...
timeout /t 5 /nobreak > nul

where ngrok > nul 2>&1
if errorlevel 1 (
    echo.
    echo ========================================
    echo  ТОЛЬКО ЛОКАЛЬНЫЙ ДОСТУП
    echo ========================================
    echo  http://localhost:5029
    echo  http://%IP%:5029
    echo  http://%IP%:5029/swagger
    echo ========================================
    echo.
    echo Чтобы открыть доступ из интернета:
    echo 1. Установи ngrok: https://ngrok.com/download
    echo 2. Зарегистрируйся на ngrok.com
    echo 3. Получи токен в личном кабинете
    echo 4. Выполни: ngrok config add-authtoken ТВОЙ_ТОКЕН
    echo 5. Запусти: ngrok http 5029
    echo.
    pause
    exit /b
)

echo Запуск ngrok...
start "Ngrok" cmd /k "ngrok http 5029"

echo Ожидание 3 секунды...
timeout /t 3 /nobreak > nul

for /f "tokens=*" %%a in ('curl -s http://127.0.0.1:4040/api/tunnels ^| findstr "public_url"') do set NGROK_LINE=%%a
set NGROK_URL=%NGROK_LINE:*"public_url":"=%
set NGROK_URL=%NGROK_URL:"%,}=%

echo.
echo ========================================
echo  СЕРВЕР ЗАПУЩЕН
echo ========================================
echo  Локально:    http://localhost:5029
echo  Локально:    http://%IP%:5029
echo  Swagger:     http://localhost:5029/swagger
echo  Публичная:   %NGROK_URL%
echo ========================================
echo.
echo Не закрывай окна с сервером и ngrok
echo Для остановки нажми Ctrl+C в каждом окне
echo.
pause