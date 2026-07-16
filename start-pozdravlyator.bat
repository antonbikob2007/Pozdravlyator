@echo off
chcp 65001 > nul

:: Проверяем наличие ngrok
where ngrok > nul 2>&1
if errorlevel 1 (
    echo ========================================
    echo  НЕ НАЙДЕН NGROK
    echo ========================================
    echo.
    echo  Локальный доступ:
    echo  http://localhost:5029
    echo.
    echo  Для публичного доступа нужно установить ngrok:
    echo.
    echo  1. Скачай: https://ngrok.com/download
    echo  2. Распакуй ngrok.exe в папку проекта
    echo  3. Зарегистрируйся на ngrok.com
    echo  4. Получи токен в личном кабинете
    echo  5. Выполни: ngrok config add-authtoken ТВОЙ_ТОКЕН
    echo.
    echo  После этого запусти скрипт снова
    echo ========================================
    pause
    exit
)

:: Получаем IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
set IP=%IP: =%
set IP=%IP:IPv4-адрес. . . . . . . . . . . =%

:: Копируем фронтенд
if not exist "src\Pozdravlyator.Api\wwwroot\index.html" (
    xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\ > nul 2>&1
)

:: Разрешаем порт
netsh advfirewall firewall add rule name="Pozdravlyator 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

:: Запускаем сервер
start "Сервер" cmd /k "cd /d D:\Progeckt\Pozdravlyator\src\Pozdravlyator.Api && dotnet run --urls="http://0.0.0.0:5029""

timeout /t 5 /nobreak > nul

:: Запускаем ngrok
start "Ngrok" cmd /k "ngrok http 5029"

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
echo  Не закрывай окна. Для остановки Ctrl+C
echo ========================================
pause