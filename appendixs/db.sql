-- Створення бази даних
CREATE DATABASE medlab_db;

-- ПРИМІТКА: Підключіться до бази medlab_db перед виконанням наступних команд

-- Створення користувачів (ролей)
CREATE ROLE lab_admin WITH LOGIN PASSWORD 'AdminPass_2026' SUPERUSER;
CREATE ROLE lab_moderator WITH LOGIN PASSWORD 'ModPass_2026';
CREATE ROLE lab_user WITH LOGIN PASSWORD 'UserPass_2026';

-- Надання базових прав доступу до схеми
GRANT USAGE ON SCHEMA public TO lab_moderator, lab_user;

-- Права для модератора (читання та запис)
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO lab_moderator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lab_moderator;

-- Права для звичайного користувача (тільки читання)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lab_user;