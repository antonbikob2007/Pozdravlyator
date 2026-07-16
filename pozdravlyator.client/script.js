// Конфигурация API
const API_URL = window.location.origin + '/api';

// Текущая страница
let currentPage = 'home';
let editingId = null;

// ============ НАВИГАЦИЯ ============
function navigateTo(page, id) {
    currentPage = page;
    editingId = id || null;
    
    // Обновляем активную ссылку
    document.querySelectorAll('nav a').forEach(a => a.classList.remove('active'));
    const links = document.querySelectorAll('nav a');
    const pageMap = { home: 0, list: 1, add: 2 };
    if (links[pageMap[page]]) links[pageMap[page]].classList.add('active');
    
    // Загружаем контент
    switch(page) {
        case 'home': loadHome(); break;
        case 'list': loadList(); break;
        case 'add': loadForm(); break;
        case 'edit': loadForm(editingId); break;
    }
}

// ============ ГЛАВНАЯ СТРАНИЦА ============
async function loadHome() {
    const content = document.getElementById('content');
    content.innerHTML = `<div class="loading">Загрузка...</div>`;
    
    try {
        const response = await fetch(`${API_URL}/birthdays/upcoming?days=7`);
        if (!response.ok) throw new Error('Ошибка загрузки');
        const birthdays = await response.json();
        
        const today = birthdays.filter(b => b.isToday);
        const upcoming = birthdays.filter(b => !b.isToday && b.daysUntilBirthday >= 0);
        
        content.innerHTML = `
            <h2>🎂 Сегодня празднуют</h2>
            ${today.length > 0 ? renderCards(today) : '<p style="color:#6c757d;">Сегодня никто не празднует 🎈</p>'}
            
            <h2 style="margin-top: 40px;">📅 Ближайшие ДР (7 дней)</h2>
            ${upcoming.length > 0 ? renderCards(upcoming) : '<p style="color:#6c757d;">Нет ближайших ДР</p>'}
        `;
    } catch (error) {
        content.innerHTML = `<p style="color:red;">Ошибка: ${error.message}</p>`;
    }
}

// ============ СПИСОК ВСЕХ ДР ============
async function loadList() {
    const content = document.getElementById('content');
    content.innerHTML = `<div class="loading">Загрузка...</div>`;
    
    try {
        const response = await fetch(`${API_URL}/birthdays`);
        if (!response.ok) throw new Error('Ошибка загрузки');
        const birthdays = await response.json();
        
        content.innerHTML = `
            <h2>📋 Все дни рождения</h2>
            <p style="color:#6c757d; margin-bottom:10px;">Всего: ${birthdays.length} записей</p>
            ${birthdays.length > 0 ? renderCards(birthdays) : '<p style="color:#6c757d;">Список пуст</p>'}
        `;
    } catch (error) {
        content.innerHTML = `<p style="color:red;">Ошибка: ${error.message}</p>`;
    }
}

// ============ ОТРИСОВКА КАРТОЧЕК ============
function renderCards(birthdays) {
    return `<div class="card-grid">${birthdays.map(b => `
        <div class="birthday-card" onclick="showPhoto('${b.photoPath || ''}')">
            ${b.photoPath ? 
                `<img class="photo" src="${API_URL.replace('/api','')}${b.photoPath}" alt="${b.fullName}" />` :
                `<div class="photo-placeholder">👤</div>`
            }
            <div class="info">
                <h3>${b.fullName}</h3>
                <div class="birthdate">${formatDate(b.birthDate)} ${b.yearOfBirth ? `(${b.age} лет)` : ''}</div>
                ${b.isToday ? '<span class="badge badge-today">🎉 Сегодня!</span>' : ''}
                ${b.daysUntilBirthday > 0 && b.daysUntilBirthday <= 7 ? `<span class="badge badge-upcoming">Через ${b.daysUntilBirthday} дн.</span>` : ''}
                ${b.daysUntilBirthday > 7 ? `<span class="badge badge-past">Через ${b.daysUntilBirthday} дн.</span>` : ''}
            </div>
            <div class="actions">
                <button class="btn-edit" onclick="event.stopPropagation(); navigateTo('edit', ${b.id})">✏️ Редактировать</button>
                <button class="btn-delete" onclick="event.stopPropagation(); deleteBirthday(${b.id})">🗑️ Удалить</button>
            </div>
        </div>
    `).join('')}</div>`;
}

// ============ ФОРМА ДОБАВЛЕНИЯ/РЕДАКТИРОВАНИЯ ============
async function loadForm(id) {
    const content = document.getElementById('content');
    const isEdit = !!id;
    let data = null;
    
    if (isEdit) {
        try {
            const response = await fetch(`${API_URL}/birthdays/${id}`);
            if (!response.ok) throw new Error('Запись не найдена');
            data = await response.json();
        } catch (error) {
            content.innerHTML = `<p style="color:red;">Ошибка: ${error.message}</p>`;
            return;
        }
    }
    
    content.innerHTML = `
        <div class="form-container">
            <h2>${isEdit ? '✏️ Редактирование' : '➕ Добавление'} записи</h2>
            <form id="birthdayForm" onsubmit="saveBirthday(event)">
                <input type="hidden" id="birthdayId" value="${id || ''}" />
                
                <div class="form-group">
                    <label>Имя *</label>
                    <input type="text" id="firstName" required value="${data?.firstName || ''}" />
                </div>
                
                <div class="form-group">
                    <label>Фамилия *</label>
                    <input type="text" id="lastName" required value="${data?.lastName || ''}" />
                </div>
                
                <div class="form-group">
                    <label>Дата рождения *</label>
                    <input type="date" id="birthDate" required value="${data?.birthDate?.split('T')[0] || ''}" />
                </div>
                
                <div class="form-group">
                    <label>Год рождения (опционально)</label>
                    <input type="number" id="yearOfBirth" min="1900" max="${new Date().getFullYear()}" value="${data?.yearOfBirth || ''}" />
                </div>
                
                <div class="form-group">
                    <label>Телефон</label>
                    <input type="text" id="phone" value="${data?.phone || ''}" />
                </div>
                
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" id="email" value="${data?.email || ''}" />
                </div>
                
                ${isEdit && data?.photoPath ? `
                    <div class="form-group">
                        <label>Текущее фото</label>
                        <div style="margin-top:5px;">
                            <img src="${API_URL.replace('/api','')}${data.photoPath}" style="max-height:150px; border-radius:10px;" />
                        </div>
                    </div>
                ` : ''}
                
                <div class="form-group">
                    <label>Фото</label>
                    <input type="file" id="photo" accept=".jpg,.jpeg,.png,.gif" />
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="navigateTo('home')">Отмена</button>
                    <button type="submit" class="btn-submit">${isEdit ? '💾 Сохранить' : '➕ Добавить'}</button>
                </div>
            </form>
        </div>
    `;
}

// ============ СОХРАНЕНИЕ ЗАПИСИ ============
async function saveBirthday(event) {
    event.preventDefault();
    
    const id = document.getElementById('birthdayId').value;
    const isEdit = !!id;
    
    const data = {
        firstName: document.getElementById('firstName').value.trim(),
        lastName: document.getElementById('lastName').value.trim(),
        birthDate: document.getElementById('birthDate').value,
        yearOfBirth: parseInt(document.getElementById('yearOfBirth').value) || null,
        phone: document.getElementById('phone').value.trim() || null,
        email: document.getElementById('email').value.trim() || null
    };
    
    if (!data.firstName || !data.lastName || !data.birthDate) {
        alert('Пожалуйста, заполните все обязательные поля');
        return;
    }
    
    try {
        let response;
        let result;
        
        if (isEdit) {
            response = await fetch(`${API_URL}/birthdays/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error('Ошибка обновления');
            result = await response.json();
        } else {
            response = await fetch(`${API_URL}/birthdays`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Ошибка создания');
            }
            result = await response.json();
        }
        
        // Загрузка фото если есть
        const photoFile = document.getElementById('photo').files[0];
        if (photoFile) {
            const formData = new FormData();
            formData.append('file', photoFile);
            
            const photoResponse = await fetch(`${API_URL}/birthdays/${result.id || id}/photo`, {
                method: 'POST',
                body: formData
            });
            
            if (!photoResponse.ok) {
                console.warn('Фото не загружено');
            }
        }
        
        alert(isEdit ? '✅ Запись обновлена!' : '✅ Запись добавлена!');
        navigateTo('home');
    } catch (error) {
        alert('❌ Ошибка: ' + error.message);
    }
}

// ============ УДАЛЕНИЕ ============
async function deleteBirthday(id) {
    if (!confirm('Вы уверены, что хотите удалить эту запись?')) return;
    
    try {
        const response = await fetch(`${API_URL}/birthdays/${id}`, {
            method: 'DELETE'
        });
        if (!response.ok) throw new Error('Ошибка удаления');
        
        alert('✅ Запись удалена');
        navigateTo(currentPage);
    } catch (error) {
        alert('❌ Ошибка: ' + error.message);
    }
}

// ============ ПОКАЗ ФОТО В МОДАЛЬНОМ ОКНЕ ============
function showPhoto(photoPath) {
    if (!photoPath) {
        alert('Фото отсутствует');
        return;
    }
    
    const modal = document.getElementById('photoModal');
    const img = document.getElementById('modalImage');
    img.src = API_URL.replace('/api','') + photoPath;
    modal.style.display = 'flex';
}

function closeModal() {
    document.getElementById('photoModal').style.display = 'none';
}

// Закрытие модального окна по клику вне изображения
document.getElementById('photoModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal();
});

// ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('ru-RU', { day: '2-digit', month: 'long' });
}

// ============ ЗАГРУЗКА ПРИ СТАРТЕ ============
document.addEventListener('DOMContentLoaded', () => {
    navigateTo('home');
});