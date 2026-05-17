-- 1. Вибірка всіх даних із певної таблиці
SELECT * FROM tests;

-- 2. Вибірка з умовою (WHERE): Скільки записів відповідає певній умові? (Пацієнти жіночої статі)
SELECT * FROM patients 
WHERE gender = 'Female';

-- 3. Сортування (ORDER BY): Тести від найдорожчого до найдешевшого
SELECT test_name, price 
FROM tests 
ORDER BY price DESC;

-- 4. Які унікальні значення є в певному стовпці? (Унікальні статуси аналізів)
SELECT DISTINCT status 
FROM order_details;

-- 5. Які максимальні та мінімальні значення певного параметра? (Ціна тесту)
SELECT 
    MAX(price) AS max_price, 
    MIN(price) AS min_price 
FROM tests;

-- 6. Яка загальна сума всіх транзакцій? (Сума всіх замовлень)
SELECT SUM(total_amount) AS total_revenue 
FROM orders;

-- 7. Групування (GROUP BY + HAVING): Лікарі, які виписали більше 1 направлення
SELECT doctor_id, COUNT(order_id) AS total_orders
FROM orders
WHERE doctor_id IS NOT NULL
GROUP BY doctor_id
HAVING COUNT(order_id) > 1;

-- 8. Об'єднання таблиць (JOIN): Отримання повної інформації про результати пацієнта
SELECT 
    p.first_name, 
    p.last_name, 
    t.test_name, 
    od.result_value, 
    od.status
FROM patients p
JOIN orders o ON p.patient_id = o.patient_id
JOIN order_details od ON o.order_id = od.order_id
JOIN tests t ON od.test_id = t.test_id
WHERE p.patient_id = 1;

-- 9. Яка середня кількість замовлень на клієнта? (Агрегатні функції та підзапити)
SELECT AVG(order_count) AS avg_orders_per_patient
FROM (
    SELECT patient_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY patient_id
) AS subquery;