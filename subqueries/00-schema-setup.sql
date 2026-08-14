-- =====================================================================
-- Subqueries — schema setup
-- Run this file first, then 01-subquery-queries.sql
--
-- Two tables with a self-referencing FK on employees.manager_id,
-- which is what makes the manager/non-manager questions possible.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS subquery;
USE subquery;

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location  VARCHAR(50)
);

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    name       VARCHAR(50) NOT NULL,
    dept_id    INT,
    salary     DECIMAL(10,2),
    manager_id INT,
    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)   -- self-reference
);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (10, 'Engineering', 'Bangalore'),
    (20, 'HR',          'Delhi'),
    (30, 'Finance',     'Mumbai'),
    (40, 'Marketing',   'Pune');   -- no employees: tests LEFT JOIN behaviour

INSERT INTO employees (emp_id, name, dept_id, salary, manager_id)
VALUES
    (1, 'Alice', 10, 90000, NULL),  -- NULL manager_id: the NOT IN trap
    (2, 'Bob',   10, 55000, 1),
    (3, 'Carol', 20, 72000, 1),
    (4, 'Dave',  20, 48000, 3),
    (5, 'Eve',   30, 81000, 1),
    (6, 'Frank', 30, 61000, 5);

-- Managers (appear in someone's manager_id): Alice (1), Carol (3), Eve (5)
-- Non-managers:                               Bob (2), Dave (4), Frank (6)
-- Average salary: 67833.33
