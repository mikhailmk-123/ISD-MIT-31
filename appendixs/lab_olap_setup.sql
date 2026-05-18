-- ============================================================
-- Лабораторна робота: OLAP-аналіз продажів у PostgreSQL + Excel
-- ============================================================

-- 1. Створення таблиць вимірів (dimension tables)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS regions (
    id SERIAL PRIMARY KEY,
    region_name VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

-- 2. Створення фактової таблиці (fact table)
CREATE TABLE IF NOT EXISTS sales (
    id SERIAL PRIMARY KEY,
    sale_date DATE,
    product_id INT,
    region_id INT,
    customer_id INT,
    quantity INT,
    revenue NUMERIC(10,2)
);

-- 3. Зв'язки між таблицями
ALTER TABLE sales DROP CONSTRAINT IF EXISTS fk_sales_product;
ALTER TABLE sales DROP CONSTRAINT IF EXISTS fk_sales_region;
ALTER TABLE sales DROP CONSTRAINT IF EXISTS fk_sales_customer;

ALTER TABLE sales ADD CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES products(id);
ALTER TABLE sales ADD CONSTRAINT fk_sales_region FOREIGN KEY (region_id) REFERENCES regions(id);
ALTER TABLE sales ADD CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

-- 4. Наповнення таблиць вимірів
INSERT INTO products (product_name, category) VALUES
('Laptop', 'Electronics'),
('Phone', 'Electronics'),
('Table', 'Furniture'),
('Chair', 'Furniture'),
('Headphones', 'Electronics'),
('Desk Lamp', 'Furniture'),
('Monitor', 'Electronics'),
('Keyboard', 'Electronics'),
('Bookshelf', 'Furniture'),
('Sofa', 'Furniture');

INSERT INTO regions (region_name, country) VALUES
('Kyiv', 'Ukraine'),
('Lviv', 'Ukraine'),
('Warsaw', 'Poland'),
('Krakow', 'Poland'),
('Odesa', 'Ukraine'),
('Kharkiv', 'Ukraine'),
('Berlin', 'Germany'),
('Prague', 'Czech Republic');

INSERT INTO customers (customer_name, segment) VALUES
('Company A', 'B2B'),
('Customer B', 'B2C'),
('TechCorp', 'B2B'),
('HomeUser1', 'B2C'),
('OfficePlus', 'B2B'),
('Student X', 'B2C'),
('StartupHub', 'B2B'),
('Family Y', 'B2C'),
('RetailMax', 'B2B'),
('Individual Z', 'B2C');

-- 5. Генерація 100 записів у таблицю sales
INSERT INTO sales (sale_date, product_id, region_id, customer_id, quantity, revenue)
SELECT
    DATE '2023-01-01' + (random() * 730)::INT AS sale_date,
    (random() * 9 + 1)::INT AS product_id,
    (random() * 7 + 1)::INT AS region_id,
    (random() * 9 + 1)::INT AS customer_id,
    (random() * 20 + 1)::INT AS quantity,
    ROUND((random() * 5000 + 50)::NUMERIC, 2) AS revenue
FROM generate_series(1, 100);

-- 6. Створення OLAP представлення (view)
CREATE OR REPLACE VIEW orders_summary AS
SELECT
    DATE_PART('year', sale_date)::INT AS year,
    DATE_PART('month', sale_date)::INT AS month,
    p.category,
    r.region_name,
    c.segment,
    SUM(s.revenue) AS total_revenue,
    SUM(s.quantity) AS total_quantity,
    COUNT(*) AS num_sales
FROM sales s
JOIN products p ON s.product_id = p.id
JOIN regions r ON s.region_id = r.id
JOIN customers c ON s.customer_id = c.id
GROUP BY year, month, p.category, r.region_name, c.segment;

-- 7. Додаткове представлення з кварталами (для drill-down)
CREATE OR REPLACE VIEW orders_by_quarter AS
SELECT
    DATE_PART('year', sale_date)::INT AS year,
    'Q' || DATE_PART('quarter', sale_date)::INT AS quarter,
    DATE_PART('month', sale_date)::INT AS month,
    p.category,
    r.region_name,
    r.country,
    c.segment,
    SUM(s.revenue) AS total_revenue,
    SUM(s.quantity) AS total_quantity
FROM sales s
JOIN products p ON s.product_id = p.id
JOIN regions r ON s.region_id = r.id
JOIN customers c ON s.customer_id = c.id
GROUP BY year, quarter, month, p.category, r.region_name, r.country, c.segment;

-- Перевірка даних
SELECT 'products' AS table_name, COUNT(*) AS rows FROM products
UNION ALL
SELECT 'regions', COUNT(*) FROM regions
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'sales', COUNT(*) FROM sales;
