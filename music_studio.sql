/* Скрипт для створення БД "Music Studio".
  Автор: Mikhail Melik-Kazarian
  СУБД: PostgreSQL
*/

-- 1. Створюємо таблиці (DDL)
-- Використовуємо IF EXISTS для уникнення помилок при повторному запуску
DROP TABLE IF EXISTS tracks;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artists;

CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY, -- SERIAL створює ID автоматично
    name VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    artist_id INTEGER REFERENCES artists(artist_id) ON DELETE CASCADE, -- Скорочений запис зовнішнього ключа
    title VARCHAR(100) NOT NULL,
    release_year INTEGER CHECK (release_year > 1900) -- Перевірка даних
);

CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    album_id INTEGER REFERENCES albums(album_id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    duration INTERVAL -- Специфічний тип Postgres
);

-- 2. Заповнюємо даними (DML)
-- Зверніть увагу: ми НЕ вказуємо id, бо SERIAL робить це сам
INSERT INTO artists (name, genre, country) VALUES 
    ('The Weeknd', 'R&B', 'Canada'),
    ('Queen', 'Rock', 'UK');

-- Для надійності можна використати підзапит для отримання ID (просунутий метод),
-- але для лаби можна просто вказати цифри: 1, 2...
INSERT INTO albums (artist_id, title, release_year) VALUES 
    (1, 'After Hours', 2020),
    (2, 'A Night at the Opera', 1975);

INSERT INTO tracks (album_id, title, duration) VALUES 
    (1, 'Blinding Lights', '3 minutes 20 seconds'),
    (2, 'Bohemian Rhapsody', '00:05:55'); -- Альтернативний формат часу

-- 3. Перевірка (Вибірка)
SELECT * FROM tracks;