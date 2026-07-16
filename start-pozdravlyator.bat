@echo off
chcp 65001 > nul

echo ========================================
echo  ПОЗДРАВЛЯТОР - ЗАПУСК
echo ========================================
echo.

:: Проверяем .NET
where dotnet > nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] .NET SDK не найден!
    echo Скачай: https://dotnet.microsoft.com/download
    echo.
    echo Нажми любую клавишу для выхода...
    pause > nul
    exit /b
)
echo [OK] .NET найден

:: Проверяем ngrok
where ngrok > nul 2>&1
if errorlevel 1 (
    echo [ВНИМАНИЕ] ngrok не найден
    echo Публичный доступ не будет работать
    echo Скачай: https://ngrok.com/download
    echo.
)

:: Получаем IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%
set IP=%IP:IPv4-address. . . . . . . . . . . =%

echo [OK] IP: %IP%
echo.

:: Копируем фронтенд
if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    echo Копирование файлов фронтенда...
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
    echo [OK] Файлы скопированы
)
echo.

:: Разрешаем порт
netsh advfirewall firewall add rule name="Поздравлятор 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

:: Запускаем сервер
echo Запуск сервера...
start "Сервер" cmd /k "cd /d src\Pozdravlyator.Api && dotnet run --urls="http://0.0.0.0:5029""

:: Ждем 5 секунд
echo Ожидание запуска сервера...
timeout /t 5 /nobreak > nul

:: Проверяем ngrok еще раз
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
    echo Нажми любую клавишу для выхода...
    pause > nul
    exit /b
)

:: Запускаем ngrok
echo Запуск ngrok...
start "Ngrok" cmd /k "ngrok http 5029"

:: Ждем 3 секунды
timeout /t 3 /nobreak > nul

:: Получаем ссылку
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
echo Не закрывай окна с сервером и ngrok!
echo Для остановки нажми Ctrl+C в каждом окне
echo.
echo Нажми любую клавишу для выхода...
pause > nul