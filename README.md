Поздравлятор — веб-приложение для ведения списка дней рождения с напоминаниями. Держит под рукой ДР друзей, знакомых и коллег, показывает, кого поздравлять сегодня и в ближайшие дни.
Учебный проект: SPA + Web API + база данных.
https://img.shields.io/badge/version-1.0.0-blue
https://img.shields.io/badge/ASP.NET_Core-9.0-purple
https://img.shields.io/badge/SQLite-3.0-lightblue
https://img.shields.io/badge/JavaScript-ES6-yellow

Возможности
• Список ближайших ДР на главной — сегодняшние подсвечены, рядом счётчик "через сколько дней".
• Полный список — с живым поиском по имени и сортировкой по дате или имени.
• Добавление, редактирование, удаление записей.
• Фото именинника — загрузка и отображение.
• Год рождения необязателен — если неизвестен, возраст просто не показывается.
• Корректный расчёт ближайшего ДР — с переходом через Новый год и обработкой 29 февраля (в невисокосный год поздравляем 28-го).

Стек
КомпонентТехнологииBackendASP.NET Core Web API (.NET 9)ДанныеEF Core + SQLite, миграции через dotnet efFrontendHTML5 + CSS3 + JavaScript (ES6+)Документация APISwagger
Структура проекта
text
Pozdravlyator/
├── src/
│   ├── Pozdravlyator.Api/          # Web API, доменная модель, EF Core
│   │   ├── Controllers/            # API-эндпоинты
│   │   ├── wwwroot/                # Статика (фронтенд и фото)
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
Доменная модель плоская: сущность Birthday и методы расчёта возраста и дней до ДР, вынесенные непосредственно в класс сущности. Вся календарная логика собрана внутри Birthday:
• GetAge() — вычисление возраста на текущую дату
• GetDaysUntilNextBirthday() — количество дней до ближайшего ДР
• IsBirthdayToday() — проверка, сегодня ли ДР
Запросы "сегодня / ближайшие" и проекция в DTO выполняются в контроллере.

Запуск
Требования
• .NET 9 SDK
• Python 3.x (для фронтенда, опционально)
Быстрый старт (Windows)
Запустите start-pozdravlyator.bat — откроются два окна с бэкендом и фронтендом.
Backend (вручную)
bash
cd src/Pozdravlyator.Api
dotnet restore
dotnet build
dotnet run --urls="http://0.0.0.0:5029"
После запуска API доступно по адресу http://localhost:5029, Swagger — по адресу /swagger.
Frontend (через Python)
bash
cd pozdravlyator.client
python -m http.server 3000 --bind 0.0.0.0
Фронтенд доступен по адресу http://localhost:3000.
Frontend (через Backend — для публичного доступа)
bash
xcopy /E /I /Y pozdravlyator.client\* src\Pozdravlyator.Api\wwwroot\
После этого фронтенд доступен по адресу http://localhost:5029.
База данных
Файл pozdravlyator.db создаётся автоматически при первом запуске. Тестовые записи добавляются автоматически при пустой базе.
После изменения модели создаётся новая миграция:
bash
dotnet ef migrations add ИмяМиграции --project src/Pozdravlyator.Api
dotnet ef database update --project src/Pozdravlyator.Api

API
Эндпоинты
МетодURLОписаниеGET/api/birthdaysПолучить все записиGET/api/birthdays/upcoming?days=7Получить ближайшие ДРGET/api/birthdays/{id}Получить запись по IDPOST/api/birthdaysСоздать записьPUT/api/birthdays/{id}Обновить записьDELETE/api/birthdays/{id}Удалить записьPOST/api/birthdays/{id}/photoЗагрузить фотоПримеры запросов
Создать запись:
bash
curl -X POST http://localhost:5029/api/birthdays \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Иван","lastName":"Петров","birthDate":"1990-05-15"}'
Получить ближайшие (7 дней):
bash
curl "http://localhost:5029/api/birthdays/upcoming?days=7"
Загрузить фото:
bash
curl -X POST http://localhost:5029/api/birthdays/1/photo -F "file=@photo.jpg"
Валидация: невалидные данные возвращают ошибку 400 с пояснением.

Тестирование
Сценарии для ручной проверки
СценарийОжидаемый результатГлавная "Ближайшие"Сегодняшние ДР подсвечены меткой "🎉 Сегодня!", остальные отсортированы по близостиВсе записиОтображаются все записи, доступен переход к редактированию и удалениюДобавлениеЗаполнение полей (имя, фамилия, дата рождения, год, контакты, фото) → запись появляется в спискеРедактированиеИзменение данных → запись обновляетсяУдалениеПодтверждение → запись удаляетсяГраничные даты29 февраля в невисокосный год → ДР считается 28-го; 31 декабря → корректный переход на следующий годСегодняшний ДРСчётчик показывает 0, отображается метка "сегодня"
Публичный доступ (через ngrok)
Для демонстрации приложения друзьям и коллегам:
bash
ngrok http 5029
Полученную ссылку отправьте другим людям — они смогут открыть приложение.

Особенности реализации
• Инкапсуляция — вся бизнес-логика расчёта дат находится внутри сущности Birthday
• Чистая архитектура — разделение на Core (сущности и DTO), Infrastructure (DbContext) и API (контроллеры)
• Валидация — на сервере проверяются все входные данные с понятными сообщениями об ошибках
• Хранение фото — изображения сохраняются в wwwroot/uploads, в БД хранится путь
• CORS — настроен для взаимодействия с фронтендом
• Dependency Injection — все зависимости регистрируются через DI-контейнер

