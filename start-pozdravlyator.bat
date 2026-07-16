@echo off
chcp 65001 > nul
title Поздравлятор - Запуск (Radmin VPN)

echo ================================================
echo        🎉 ПОЗДРАВЛЯТОР - ЗАПУСК
echo ================================================
echo.

:: Получаем Radmin IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "26.254"') do set RADMIN_IP=%%a
set RADMIN_IP=%RADMIN_IP: =%

if "%RADMIN_IP%"=="" (
    echo ⚠️  Radmin IP не найден, используем локальный
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set IP=%%a
    set IP=%IP: =%
    set IP=%IP:IPv4-адрес. . . . . . . . . . . =%
) else (
    set IP=%RADMIN_IP%
)

echo 📡 Radmin IP: %IP%
echo.

:: Разрешаем порты
netsh advfirewall firewall add rule name="Pozdravlyator 3000" dir=in action=allow protocol=TCP localport=3000 > nul 2>&1
netsh advfirewall firewall add rule name="Pozdravlyator 5029" dir=in action=allow protocol=TCP localport=5029 > nul 2>&1

:: Запускаем Backend
echo 🚀 Запуск Backend (API)...
start "Поздравлятор - Backend" cmd /k "cd /d D:\Progeckt\Pozdravlyator\src\Pozdravlyator.Api && dotnet run --urls="http://0.0.0.0:5029""

timeout /t 5 /nobreak > nul

:: Запускаем Frontend
echo 🚀 Запуск Frontend...
start "Поздравлятор - Frontend" cmd /k "cd /d D:\Progeckt\Pozdravlyator\pozdravlyator.client && py -m http.server 3000 --bind 0.0.0.0"

echo.
echo ================================================
echo        ✅ ПРИЛОЖЕНИЕ ЗАПУЩЕНО!
echo ================================================
echo.
echo 🌐 Открой в браузере:
echo    http://%IP%:3000
echo.
echo 📋 Swagger:
echo    http://%IP%:5029/swagger
echo.
echo 📤 Отправь другу ссылку:
echo    http://%IP%:3000
echo.
echo ⚠️  Друг должен быть в твоей сети Radmin!
echo.
echo ================================================
pause