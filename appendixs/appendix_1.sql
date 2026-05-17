-- 1. Створення користувацького типу даних ENUM
CREATE TYPE test_status_enum AS ENUM ('Pending', 'Processing', 'Completed', 'Cancelled');

-- 2. Адаптація існуючої таблиці order_details
ALTER TABLE order_details DROP COLUMN IF EXISTS status;
ALTER TABLE order_details ADD COLUMN status test_status_enum DEFAULT 'Pending';