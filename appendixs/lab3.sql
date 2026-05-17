-- ============================================================================
-- Файл: lab3.sql
-- Мета: Закріплення практичних навичок складних SQL-запитів (Варіант 21)
-- ============================================================================

-- ==========================================
-- РОЗДІЛ 1: Логічні оператори (AND, OR, NOT)
-- ==========================================

-- 1. Вибірка пацієнтів жіночої статі, які народилися після 1990 року (AND)
SELECT * FROM patients 
WHERE gender = 'Female' AND birth_date > '1990-01-01';

-- 2. Вибірка тестів, які коштують більше 300 грн АБО містять слово "крові" у назві (OR)
SELECT test_name, price FROM tests 
WHERE price > 300 OR test_name ILIKE '%крові%';

-- 3. Вибірка всіх замовлень, які були створені БЕЗ направлення лікаря (NOT / IS NULL)
SELECT order_id, order_date, total_amount FROM orders 
WHERE doctor_id IS NULL;

-- 4. Пацієнти, чий номер телефону починається на '+38050' або '+38067', але це не чоловіки (Логічна комбінація)
SELECT first_name, last_name, phone FROM patients
WHERE (phone LIKE '+38050%' OR phone LIKE '+38067%') AND NOT gender = 'Male';

-- ==========================================
-- РОЗДІЛ 2: Агрегатні функції
-- ==========================================

-- 5. Загальна кількість зареєстрованих тестів у каталозі (COUNT)
SELECT COUNT(test_id) AS total_tests_available FROM tests;

-- 6. Загальна сума грошей, отримана за всі замовлення (SUM)
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- 7. Середня вартість одного лабораторного дослідження (AVG)
SELECT ROUND(AVG(price), 2) AS average_test_price FROM tests;

-- 8. Мінімальна та максимальна вартість замовлення (MIN, MAX)
SELECT MIN(total_amount) AS min_order, MAX(total_amount) AS max_order FROM orders;

-- 9. Підрахунок кількості пацієнтів за статтю (COUNT + GROUP BY)
SELECT gender, COUNT(patient_id) AS patients_count 
FROM patients GROUP BY gender;

-- ==========================================
-- РОЗДІЛ 3: Усі типи JOIN
-- ==========================================

-- 10. INNER JOIN: Отримати список замовлень разом з іменами пацієнтів
SELECT o.order_id, p.first_name, p.last_name, o.order_date
FROM orders o
INNER JOIN patients p ON o.patient_id = p.patient_id;

-- 11. LEFT JOIN: Всі лікарі та їхні направлення (навіть якщо лікар ще нікого не направляв)
SELECT d.full_name, o.order_id, o.order_date
FROM doctors d
LEFT JOIN orders o ON d.doctor_id = o.doctor_id;

-- 12. RIGHT JOIN: Всі замовлення з прив'язкою до лікарів (включаючи замовлення без лікарів)
SELECT o.order_id, d.full_name, d.specialization
FROM doctors d
RIGHT JOIN orders o ON d.doctor_id = o.doctor_id;

-- 13. FULL OUTER JOIN: Об'єднання всіх пацієнтів та всіх замовлень для пошуку аномалій (пацієнтів без замовлень)
SELECT p.first_name, p.last_name, o.order_id
FROM patients p
FULL OUTER JOIN orders o ON p.patient_id = o.patient_id;

-- 14. CROSS JOIN: Створення матриці "Кожен пацієнт з кожним тестом" (для генерації можливих комбінацій послуг)
SELECT p.last_name, t.test_name 
FROM patients p
CROSS JOIN tests t;

-- 15. SELF JOIN: Знайти пацієнтів, які народилися в один рік
SELECT p1.last_name AS patient_1, p2.last_name AS patient_2, EXTRACT(YEAR FROM p1.birth_date) AS birth_year
FROM patients p1
JOIN patients p2 ON EXTRACT(YEAR FROM p1.birth_date) = EXTRACT(YEAR FROM p2.birth_date) AND p1.patient_id < p2.patient_id;

-- 16. Multiple JOINs: Повний маршрут — Пацієнт, Лікар, Замовлення, Назва тесту, Результат
SELECT p.last_name AS patient, d.full_name AS doctor, t.test_name, od.result_value
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN patients p ON o.patient_id = p.patient_id
LEFT JOIN doctors d ON o.doctor_id = d.doctor_id
JOIN tests t ON od.test_id = t.test_id;

-- ==========================================
-- РОЗДІЛ 4: Підзапити (Subqueries)
-- ==========================================

-- 17. Subquery у WHERE: Пацієнти, чия загальна сума замовлення більша за середній чек
SELECT patient_id, order_date, total_amount FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- 18. IN: Імена пацієнтів, які здавали 'Тиреотропний гормон (ТТГ)'
SELECT first_name, last_name FROM patients
WHERE patient_id IN (
    SELECT o.patient_id FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN tests t ON od.test_id = t.test_id
    WHERE t.test_name = 'Тиреотропний гормон (ТТГ)'
);

-- 19. NOT IN: Тести, які ще жодного разу не замовляли
SELECT test_name FROM tests
WHERE test_id NOT IN (SELECT DISTINCT test_id FROM order_details);

-- 20. EXISTS: Лікарі, які направили хоча б одного пацієнта
SELECT full_name FROM doctors d
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.doctor_id = d.doctor_id
);

-- 21. NOT EXISTS: Пацієнти, які ще не мають жодного замовлення
SELECT first_name, last_name FROM patients p
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.patient_id = p.patient_id
);

-- 22. Subquery у FROM: Розрахунок середньої кількості тестів у одному замовленні
SELECT ROUND(AVG(test_count), 2) AS avg_tests_per_order
FROM (
    SELECT order_id, COUNT(test_id) AS test_count 
    FROM order_details 
    GROUP BY order_id
) AS order_stats;

-- ==========================================
-- РОЗДІЛ 5: Операції над множинами
-- ==========================================

-- 23. UNION: Єдиний довідник імен (Пацієнти + Лікарі) з позначкою ролі
SELECT first_name || ' ' || last_name AS person_name, 'Patient' AS role FROM patients
UNION
SELECT full_name, 'Doctor' FROM doctors;

-- 24. UNION ALL: Список усіх ID пацієнтів і ID лікарів з таблиці замовлень (включно з дублями)
SELECT patient_id AS involved_person_id FROM orders
UNION ALL
SELECT doctor_id FROM orders WHERE doctor_id IS NOT NULL;

-- 25. INTERSECT: Пацієнти, які обслуговувались і лікарем 1, і лікарем 2 (гіпотетичний перетин)
SELECT patient_id FROM orders WHERE doctor_id = 1
INTERSECT
SELECT patient_id FROM orders WHERE doctor_id = 2;

-- 26. EXCEPT (MINUS): Всі ID тестів мінус ті, що вже були виконані (аналог запиту 19)
SELECT test_id FROM tests
EXCEPT
SELECT test_id FROM order_details;

-- 27. UNION з умовами: Сегментація тестів за ціновою категорією
SELECT test_name, 'Premium' AS category FROM tests WHERE price > 300
UNION
SELECT test_name, 'Standard' AS category FROM tests WHERE price <= 300;

-- 28. EXCEPT: Пацієнти, які робили замовлення, АЛЕ в їхніх замовленнях немає статусу 'Pending'
SELECT o.patient_id FROM orders o
EXCEPT
SELECT o.patient_id FROM orders o 
JOIN order_details od ON o.order_id = od.order_id WHERE od.status = 'Pending';

-- ==========================================
-- РОЗДІЛ 6: Common Table Expressions (CTE)
-- ==========================================

-- 29. Простий CTE: Список виконаних аналізів
WITH CompletedTests AS (
    SELECT order_id, test_id, result_value 
    FROM order_details WHERE status = 'Completed'
)
SELECT * FROM CompletedTests;

-- 30. CTE з агрегацією: Топ найпопулярніших аналізів
WITH TestCounts AS (
    SELECT test_id, COUNT(*) AS usage_count
    FROM order_details GROUP BY test_id
)
SELECT t.test_name, tc.usage_count
FROM tests t JOIN TestCounts tc ON t.test_id = tc.test_id
ORDER BY usage_count DESC;

-- 31. CTE: Аналіз віку пацієнтів на момент створення їхнього першого замовлення
WITH FirstOrder AS (
    SELECT patient_id, MIN(order_date) AS first_date FROM orders GROUP BY patient_id
)
SELECT p.last_name, EXTRACT(YEAR FROM AGE(fo.first_date, p.birth_date)) AS age_at_first_order
FROM patients p JOIN FirstOrder fo ON p.patient_id = fo.patient_id;

-- 32. Multiple CTEs: Зведення загального доходу та кількості тестів
WITH TotalRev AS (SELECT SUM(total_amount) AS rev FROM orders),
     TotalTests AS (SELECT COUNT(*) AS cnt FROM order_details)
SELECT TotalRev.rev, TotalTests.cnt FROM TotalRev, TotalTests;

-- 33. Рекурсивний CTE: Генерація послідовності дат для звіту за останній тиждень (приклад)
WITH RECURSIVE DateSeries AS (
    SELECT CAST('2026-05-01' AS DATE) AS report_date
    UNION ALL
    SELECT report_date + INTERVAL '1 day'
    FROM DateSeries WHERE report_date < '2026-05-15'
)
SELECT ds.report_date, COUNT(o.order_id) AS orders_count
FROM DateSeries ds
LEFT JOIN orders o ON DATE(o.order_date) = ds.report_date
GROUP BY ds.report_date ORDER BY ds.report_date;

-- ==========================================
-- РОЗДІЛ 7: Віконні функції (Window Functions)
-- ==========================================

-- 34. ROW_NUMBER(): Нумерація замовлень для кожного пацієнта хронологічно
SELECT order_id, patient_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY order_date) as patient_order_seq
FROM orders;

-- 35. RANK(): Рейтинг тестів за ціною (1 - найдорожчий)
SELECT test_name, price,
       RANK() OVER (ORDER BY price DESC) as price_rank
FROM tests;

-- 36. DENSE_RANK(): Рейтинг пацієнтів за сумою витрачених коштів (без розривів у нумерації)
SELECT patient_id, total_amount,
       DENSE_RANK() OVER (ORDER BY total_amount DESC) as spend_rank
FROM orders;

-- 37. SUM() OVER(): Накопичувальна сума замовлень по датах
SELECT order_id, order_date, total_amount,
       SUM(total_amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- 38. AVG() OVER(PARTITION): Порівняння ціни конкретного тесту в замовленні з середнім чеком пацієнта
SELECT o.patient_id, o.order_id, o.total_amount,
       ROUND(AVG(o.total_amount) OVER (PARTITION BY o.patient_id), 2) AS avg_patient_spend
FROM orders o;

-- 39. LEAD(): Визначення суми наступного замовлення пацієнта (для аналізу динаміки витрат)
SELECT patient_id, order_date, total_amount,
       LEAD(total_amount) OVER (PARTITION BY patient_id ORDER BY order_date) AS next_order_amount
FROM orders;

-- 40. LAG(): Визначення часу, що минув з моменту попереднього замовлення пацієнта
SELECT patient_id, order_id, order_date,
       LAG(order_date) OVER (PARTITION BY patient_id ORDER BY order_date) AS previous_order_date,
       AGE(order_date, LAG(order_date) OVER (PARTITION BY patient_id ORDER BY order_date)) AS time_since_last_order
FROM orders;