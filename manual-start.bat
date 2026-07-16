@echo off
cd /d "%~dp0"
echo Starting server...
echo.
cd src\Pozdravlyator.Api
dotnet run --urls="http://0.0.0.0:5029"
pause