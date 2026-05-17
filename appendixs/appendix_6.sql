-- 1. Перевірка роботи тригера логування (INSERT та UPDATE)
INSERT INTO order_details (order_id, test_id, result_value, status) VALUES (1, 3, NULL, 'Pending');
UPDATE order_details SET status = 'Processing' WHERE detail_id = (SELECT MAX(detail_id) FROM order_details);
SELECT * FROM order_details_log ORDER BY changed_at DESC;

-- 2. Перевірка тригера автоматичного оновлення суми
SELECT order_id, total_amount FROM orders WHERE order_id = 3;
INSERT INTO order_details (order_id, test_id, status) VALUES (3, 4, 'Pending');
SELECT order_id, total_amount FROM orders WHERE order_id = 3;

-- 3. Перевірка роботи користувацької функції
SELECT 
    patient_id, 
    first_name, 
    last_name, 
    get_patient_status(patient_id) AS loyalty_status
FROM patients;