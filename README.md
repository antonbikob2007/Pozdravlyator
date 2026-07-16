
# 🎉 Поздравлятор

**Поздравлятор** — веб-приложение для ведения списка дней рождения. Держит под рукой ДР друзей, знакомых и коллег, показывает, кого поздравлять сегодня и в ближайшие дни.

Учебный проект: SPA + Web API + база данных.

[](https://github.com/antonbikob2007/Pozdravlyator)[https://img.shields.io/badge/version-1.0.0-blue](https://img.shields.io/badge/version-1.0.0-blue)  
[](https://github.com/antonbikob2007/Pozdravlyator)[https://img.shields.io/badge/.NET-9.0-purple](https://img.shields.io/badge/.NET-9.0-purple)  
[](https://github.com/antonbikob2007/Pozdravlyator)[https://img.shields.io/badge/SQLite-3.0-lightblue](https://img.shields.io/badge/SQLite-3.0-lightblue)  
[](https://github.com/antonbikob2007/Pozdravlyator)[https://img.shields.io/badge/JavaScript-ES6-yellow](https://img.shields.io/badge/JavaScript-ES6-yellow)

----------

## 📋 Функциональность

-   Список ближайших ДР на главной — сегодняшние подсвечены, рядом счётчик "через сколько дней"
    
-   Полный список — с живым поиском по имени и сортировкой по дате или имени
    
-   Добавление, редактирование, удаление записей
    
-   Фото именинника — загрузка и отображение
    
-   Год рождения необязателен — если неизвестен, возраст не показывается
    
-   Корректный расчёт ближайшего ДР — с переходом через Новый год и обработкой 29 февраля
    

----------

## 🛠️ Стек технологий

**Backend:**

-   [ASP.NET](https://asp.net/) Core 9.0 — веб-фреймворк для создания API
    
-   Entity Framework Core — ORM для работы с базой данных
    
-   SQLite — лёгкая встроенная база данных
    
-   Swagger — документация API
    

**Frontend:**

-   HTML5 — структура страниц
    
-   CSS3 — стилизация и адаптивность
    
-   JavaScript (ES6+) — клиентская логика
    
-   Fetch API — HTTP-запросы к серверу
    

----------

## 📁 Структура проекта

text

Pozdravlyator/
├── src/
│   ├── Pozdravlyator.Api/          # Web API
│   │   ├── Controllers/            # API-эндпоинты
│   │   ├── wwwroot/                # Статика (фото, фронтенд)
│   │   └── Program.cs              # Настройка приложения
│   ├── Pozdravlyator.Core/         # Бизнес-сущности и DTO
│   │   ├── Entities/               # Доменная модель
│   │   └── DTOs/                   # Объекты передачи данных
│   └── Pozdravlyator.Infrastructure/ # Работа с БД
│       └── Data/                   # DbContext и конфигурация
├── pozdravlyator.client/           # Frontend (HTML+CSS+JS)
│   ├── index.html                  # Главная страница
│   ├── style.css                   # Стили
│   └── script.js                   # Клиентская логика
└── start-pozdravlyator.bat         # Скрипт запуска

----------

## 🚀 Запуск

**Требования:**

-   .NET 9 SDK
    
-   Python 3.x (для фронтенда)
    

**Быстрый старт (Windows):**  
Запустите `start-pozdravlyator.bat` — откроются два окна с бэкендом и фронтендом.

**Backend:**

text

cd src/Pozdravlyator.Api
dotnet restore
dotnet run --urls="http://0.0.0.0:5029"

После запуска:

-   API: [http://localhost:5029](http://localhost:5029/)
    
-   Swagger: [http://localhost:5029/swagger](http://localhost:5029/swagger)
    

**Frontend:**

text

cd pozdravlyator.client
python -m http.server 3000 --bind 0.0.0.0

Фронтенд доступен по адресу [http://localhost:3000](http://localhost:3000/)

**База данных:**  
Файл `pozdravlyator.db` создаётся автоматически при первом запуске. Тестовые записи добавляются автоматически.

----------

## 📡 API Endpoints

-   `GET /api/birthdays` — получить все записи
    
-   `GET /api/birthdays/upcoming?days=7` — получить ближайшие ДР
    
-   `GET /api/birthdays/{id}` — получить запись по ID
    
-   `POST /api/birthdays` — создать запись
    
-   `PUT /api/birthdays/{id}` — обновить запись
    
-   `DELETE /api/birthdays/{id}` — удалить запись
    
-   `POST /api/birthdays/{id}/photo` — загрузить фото
    

----------

## 📝 Примеры запросов

**Создать запись:**

text

curl -X POST http://localhost:5029/api/birthdays \
 -H "Content-Type: application/json" \
 -d '{"firstName":"Иван","lastName":"Петров","birthDate":"1990-05-15"}'

**Получить ближайшие (7 дней):**

text

curl "http://localhost:5029/api/birthdays/upcoming?days=7"

**Загрузить фото:**

text

curl -X POST http://localhost:5029/api/birthdays/1/photo -F "file=@photo.jpg"

----------

## 🌐 Публичный доступ (ngrok)

Для демонстрации приложения:

text

ngrok http 5029

Полученную ссылку можно отправить другим людям.

----------

## 🧪 Тестирование

**Проверка вручную:**

-   Главная "Ближайшие" — сегодняшние ДР подсвечены, остальные отсортированы по близости
    
-   Все записи — отображаются все записи, доступны редактирование и удаление
    
-   Добавление — заполнение полей → запись появляется в списке
    
-   Редактирование — изменение данных → запись обновляется
    
-   Удаление — подтверждение → запись удаляется
    
-   29 февраля — в невисокосный год ДР считается 28-го
    

----------

## 📦 Особенности реализации

-   Инкапсуляция — вся бизнес-логика расчёта дат внутри сущности Birthday
    
-   Чистая архитектура — разделение на Core, Infrastructure и API
    
-   Валидация — проверка всех входных данных с понятными ошибками
    
-   Хранение фото — изображения в `wwwroot/uploads`, в БД хранится путь
    
-   CORS — настроен для взаимодействия с фронтендом
