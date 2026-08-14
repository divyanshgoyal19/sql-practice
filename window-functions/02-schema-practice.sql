-- =====================================================================
-- Window functions — applied practice schema
-- Run this file, then 03-window-practice.sql
--
-- Five related tables with deliberate gaps: a customer with no orders,
-- an order with a NULL customer_id, a product never ordered. Those gaps
-- are the point — they are what make LEFT JOIN and COALESCE necessary.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS window_practice;
USE window_practice;

CREATE TABLE customers (
    customer_id   INT,
    customer_name VARCHAR(100),
    country       VARCHAR(50)
);

INSERT INTO customers VALUES (1, 'Alice',   'USA');
INSERT INTO customers VALUES (2, 'Bob',     'India');
INSERT INTO customers VALUES (3, 'Charlie', 'USA');      -- no orders
INSERT INTO customers VALUES (4, 'Diana',   'Germany');
INSERT INTO customers VALUES (5, 'Eve',     'France');   -- no orders
INSERT INTO customers VALUES (6, 'Frank',   'Mexico');   -- no orders

CREATE TABLE orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE,
    amount      DECIMAL(10,2)
);

INSERT INTO orders VALUES (101, 1,    '2025-06-29', 250.50);
INSERT INTO orders VALUES (102, 1,    '2025-06-19', 130.00);
INSERT INTO orders VALUES (103, 2,    '2025-06-09',  99.99);
INSERT INTO orders VALUES (104, 4,    '2025-05-30', 540.00);
INSERT INTO orders VALUES (105, 4,    '2025-05-20', 180.50);
INSERT INTO orders VALUES (106, NULL, '2025-05-10', 300.00);  -- orphan order

CREATE TABLE products (
    product_id   INT,
    product_name VARCHAR(100),
    category     VARCHAR(50)
);

INSERT INTO products VALUES (201, 'Phone',   'Electronics');
INSERT INTO products VALUES (202, 'Laptop',  'Electronics');
INSERT INTO products VALUES (203, 'Tablet',  'Electronics');
INSERT INTO products VALUES (204, 'Charger', 'Accessories');

CREATE TABLE order_items (
    order_id   INT,
    product_id INT,
    quantity   INT
);

INSERT INTO order_items VALUES (101, 201, 1);
INSERT INTO order_items VALUES (101, 202, 2);
INSERT INTO order_items VALUES (102, 204, 1);
INSERT INTO order_items VALUES (104, 201, 3);
INSERT INTO order_items VALUES (105, 203, 1);

CREATE TABLE employees (
    emp_id     INT,
    name       VARCHAR(100),
    manager_id INT,
    department VARCHAR(50)
);

INSERT INTO employees VALUES (1, 'John',  NULL, 'Sales');
INSERT INTO employees VALUES (2, 'Jane',  1,    'Sales');
INSERT INTO employees VALUES (3, 'Mike',  1,    'IT');
INSERT INTO employees VALUES (4, 'Emily', 2,    'IT');
INSERT INTO employees VALUES (5, 'Anna',  NULL, 'HR');
