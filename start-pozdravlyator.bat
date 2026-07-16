@echo off
chcp 65001 > nul

:: Проверяем наличие ngrok
where ngrok > nul 2>&1
if errorlevel 1 (
    echo ngrok не найден
    echo Скачай: https://ngrok.com/download
    echo.
    echo Инструкция:
    echo 1. Зарегистрируйся на ngrok.com
    echo 2. Получи токен в личном кабинете
    echo 3. Выполни: ngrok config add-authtoken ТВОЙ_ТОКЕН
    pause
    exit
)

:: Закрываем старый ngrok
taskkill /f /im ngrok.exe > nul 2>&1

:: Запускаем ngrok
echo Запуск ngrok...
start "Ngrok" cmd /c "ngrok http 5029"

timeout /t 3 /nobreak > nul

:: Получаем ссылку
for /f "tokens=*" %%a in ('curl -s http://127.0.0.1:4040/api/tunnels ^| findstr "public_url"') do set NGROK_LINE=%%a
set NGROK_URL=%NGROK_LINE:*"public_url":"=%
set NGROK_URL=%NGROK_URL:"%,}=%

echo.
echo ========================================
echo  ПУБЛИЧНАЯ ССЫЛКА
echo ========================================
echo  %NGROK_URL%
echo ========================================
echo  Не закрывай окно. Для остановки Ctrl+C
echo ========================================
pause