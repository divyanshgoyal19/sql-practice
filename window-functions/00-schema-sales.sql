-- =====================================================================
-- Window functions — Sales schema
-- Run this file first, then 01-window-basics.sql
--
-- A single flat table is enough to learn window functions. No joins get
-- in the way of seeing what OVER() actually does.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS windows;
USE windows;

CREATE TABLE Sales (
    employee_id INT,
    department  VARCHAR(1),
    sale_amount INT,
    sale_date   DATE
);

INSERT INTO Sales (employee_id, department, sale_amount, sale_date)
VALUES
    (1, 'A', 100, '2024-01-01'),
    (2, 'A', 200, '2024-01-01'),
    (3, 'A', 150, '2024-01-02'),
    (4, 'B', 300, '2024-01-01'),
    (5, 'B', 400, '2024-01-02'),
    (6, 'B', 250, '2024-01-03');

-- Added partway through to create ties in sale_amount, which is what
-- makes ROW_NUMBER / RANK / DENSE_RANK behave differently from each other.
INSERT INTO Sales (employee_id, department, sale_amount, sale_date)
VALUES
    (7, 'A', 150, '2024-01-03'),   -- ties with employee 3
    (8, 'B', 300, '2024-01-04'),   -- ties with employee 4
    (9, 'B', 400, '2024-01-05');   -- ties with employee 5

-- 9 rows total. Department A: 4 rows. Department B: 5 rows.
