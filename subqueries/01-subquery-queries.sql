-- =====================================================================
-- Subqueries — practice queries
-- Run 00-schema-setup.sql first.
-- =====================================================================

USE subquery;


-- ---------------------------------------------------------------------
-- Q1. Employees working in departments located in Bangalore or Mumbai
-- ---------------------------------------------------------------------
SELECT name
FROM employees
WHERE dept_id IN (
    SELECT dept_id
    FROM departments
    WHERE location IN ('Bangalore', 'Mumbai')
);
-- Returns: Alice, Bob (Engineering/Bangalore), Eve, Frank (Finance/Mumbai)
--
-- A non-correlated subquery: the inner query runs once, produces
-- (10, 30), and the outer query filters against that list.
--
-- Note on quoting: SQL string literals use single quotes. Double quotes
-- work in MySQL's default mode but mean "identifier" in standard SQL and
-- in Postgres/Oracle. Single quotes are the portable habit.
--
-- Note on case: 'bangalore' also matches here because MySQL's default
-- collation is case-insensitive. That is a MySQL default, not a SQL rule.


-- ---------------------------------------------------------------------
-- Q2. Employees who are NOT managers — anti-join version
-- ---------------------------------------------------------------------
SELECT e.name
FROM employees e
LEFT JOIN employees m
       ON m.manager_id = e.emp_id
WHERE m.emp_id IS NULL;
-- Returns: Bob, Dave, Frank
--
-- e = the employee being tested, m = anyone reporting to them.
-- LEFT JOIN keeps e even when nobody matches, padding m's columns with
-- NULL. Those NULL rows are exactly the people nobody reports to.
--
-- TRAP: the filter must be in WHERE, not ON. Putting
-- "AND m.emp_id IS NULL" in the ON clause kills the match condition,
-- and the LEFT JOIN then keeps all 6 employees.
--
-- Test m.emp_id (the primary key, never NULL) rather than
-- m.manager_id — a genuinely NULL manager_id would give a false match.


-- ---------------------------------------------------------------------
-- Q3. Employees who are NOT managers — NOT IN version
-- ---------------------------------------------------------------------
SELECT name
FROM employees
WHERE emp_id NOT IN (
    SELECT manager_id
    FROM employees
    WHERE manager_id IS NOT NULL   -- <-- this line is load-bearing
);
-- Returns: Bob, Dave, Frank
--
-- TRAP: drop the IS NOT NULL filter and this returns ZERO rows.
-- Alice's manager_id is NULL, so the subquery yields (NULL, 1, 1, 3, 1, 5).
-- NOT IN expands to:  emp_id <> NULL AND emp_id <> 1 AND ...
-- and "emp_id <> NULL" is UNKNOWN — never TRUE — so nothing passes WHERE.
--
-- NOT EXISTS avoids the problem entirely, because EXISTS only asks
-- "did any row come back?" and never compares values:
--
--   SELECT e.name FROM employees e
--   WHERE NOT EXISTS (
--       SELECT 1 FROM employees m WHERE m.manager_id = e.emp_id
--   );
--
-- Plain IN is safe with NULLs; NOT IN is not. Worth memorising.


-- ---------------------------------------------------------------------
-- Q4. Employees earning above the company average
-- ---------------------------------------------------------------------

-- 4a. Derived table + CROSS JOIN (the version worked out in practice)
SELECT name
FROM (
    SELECT *
    FROM employees
    CROSS JOIN (SELECT AVG(salary) AS avg_salary FROM employees) AS avg_tbl
) AS final_table
WHERE salary > avg_salary;
-- Returns: Alice (90000), Carol (72000), Eve (81000)   [average = 67833.33]
--
-- The CROSS JOIN attaches the single average value to every row, making
-- it available for a row-level comparison. This works, and the pattern
-- generalises well — but here it is more machinery than the job needs.

-- 4b. Scalar subquery — the idiomatic version
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- Same result. A subquery returning exactly one row and one column is a
-- "scalar subquery" and can be used anywhere a single value is expected.
--
-- Why this works in WHERE even though AVG() cannot appear there directly:
-- the subquery is evaluated as its own complete query first, producing a
-- constant. WHERE never sees an aggregate function.
