-- =====================================================================
-- Window functions — basics
-- Run 00-schema-sales.sql first.
--
-- The one idea underneath everything here:
--   GROUP BY  collapses rows into one row per group.
--   OVER()    keeps every row and attaches a group-level value to it.
-- =====================================================================

USE windows;


-- ---------------------------------------------------------------------
-- 1. OVER() with an empty window — the whole table is one group
-- ---------------------------------------------------------------------
SELECT *,
       SUM(sale_amount) OVER () AS total_all_sales
FROM Sales;
-- Every row keeps its own data AND gets the grand total alongside it.
-- Empty parentheses = "the window is every row in the result set".


-- ---------------------------------------------------------------------
-- 2. The contrast: GROUP BY collapses, OVER() does not
-- ---------------------------------------------------------------------
SELECT department, SUM(sale_amount) AS dept_total
FROM Sales
GROUP BY department;
-- 2 rows out. The individual sales are gone.

SELECT *,
       SUM(sale_amount) OVER (PARTITION BY department) AS dept_total
FROM Sales;
-- 9 rows out. Each row keeps its detail and gains its department total.
--
-- PARTITION BY is the window equivalent of GROUP BY: it splits rows into
-- groups, and the function is computed independently within each group.
-- Rows never leave the result.


-- ---------------------------------------------------------------------
-- 3. The other aggregates work the same way
-- ---------------------------------------------------------------------
SELECT *, COUNT(sale_amount) OVER (PARTITION BY department) AS dept_count FROM Sales;
SELECT *, MIN(sale_amount)   OVER (PARTITION BY department) AS dept_min   FROM Sales;
SELECT *, MAX(sale_amount)   OVER (PARTITION BY department) AS dept_max   FROM Sales;
-- Any aggregate function can be used as a window function.
-- This is what makes "compare each row to its group" a one-line query.


-- ---------------------------------------------------------------------
-- 4. Adding ORDER BY inside OVER() turns a total into a RUNNING total
-- ---------------------------------------------------------------------
SELECT *,
       SUM(sale_amount) OVER (ORDER BY employee_id) AS running_total
FROM Sales;
-- 100, 300, 450, 750, 1150, 1400, ...  — accumulating down the rows.
--
-- This is the single most surprising thing about window functions:
-- adding ORDER BY changes the DEFAULT FRAME from "all rows in the
-- partition" to "from the start of the partition up to the current row".
--
-- The default frame written out in full:
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--
-- CAUTION with RANGE: it groups tied values together, so tied rows all
-- get the same running total. For a strict row-by-row accumulation, be
-- explicit:
--   SUM(sale_amount) OVER (ORDER BY employee_id
--                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
-- Here employee_id is unique, so both give the same answer — but on a
-- date column with repeats, they differ.

SELECT *,
       MAX(sale_amount) OVER (ORDER BY employee_id) AS running_max
FROM Sales;
-- "Best sale so far" — the running-frame idea applied to MAX.


-- ---------------------------------------------------------------------
-- 5. PARTITION BY + ORDER BY together — running total that resets
-- ---------------------------------------------------------------------
SELECT *,
       SUM(sale_amount) OVER (PARTITION BY department ORDER BY employee_id)
           AS dept_running_total
FROM Sales;
-- The accumulation restarts at each new department. PARTITION BY sets
-- the boundaries; ORDER BY sets the direction of travel inside them.


-- ---------------------------------------------------------------------
-- 6. Ranking functions — and why there are three of them
-- ---------------------------------------------------------------------
SELECT *,
       ROW_NUMBER() OVER (ORDER BY sale_amount) AS row_num,
       DENSE_RANK() OVER (ORDER BY sale_amount) AS dense_rnk,
       RANK()       OVER (ORDER BY sale_amount) AS rnk
FROM Sales;
-- The difference only shows up on ties (150, 150 and 300, 300 and 400, 400):
--
--   sale_amount | ROW_NUMBER | RANK | DENSE_RANK
--   ------------|------------|------|------------
--   100         | 1          | 1    | 1
--   150         | 2          | 2    | 2
--   150         | 3          | 2    | 2
--   200         | 4          | 4    | 3
--   250         | 5          | 5    | 4
--   ...
--
-- ROW_NUMBER  — always 1,2,3,... Ties broken arbitrarily. Use when you
--               need exactly one row per group (deduplication, top-1).
-- RANK        — ties share a rank, then it SKIPS. Use for competition
--               placings, where two silvers means no bronze.
-- DENSE_RANK  — ties share a rank, no gaps. Use for "top 3 distinct
--               salary bands", where you care about values not rows.
--
-- ROW_NUMBER is non-deterministic across runs when the ORDER BY has ties.
-- Add a tiebreaker column if the output must be stable.


-- ---------------------------------------------------------------------
-- 7. Ranking within each partition
-- ---------------------------------------------------------------------
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY sale_amount)
           AS rank_in_dept
FROM Sales;
-- Numbering restarts at 1 for each department. This is the foundation of
-- every "top N per group" query — see 03-window-practice.sql.


-- ---------------------------------------------------------------------
-- 8. LEAD and LAG — reaching into neighbouring rows
-- ---------------------------------------------------------------------
SELECT *, LEAD(sale_amount) OVER (ORDER BY employee_id) AS next_sale     FROM Sales;
SELECT *, LAG(sale_amount)  OVER (ORDER BY employee_id) AS previous_sale FROM Sales;
-- LAG looks backwards, LEAD looks forwards. The first LAG and the last
-- LEAD are NULL — there is no neighbour there.
--
-- Optional args: LAG(col, offset, default)
--   LAG(sale_amount, 1, 0) returns 0 instead of NULL at the boundary.

SELECT *,
       LAG(sale_amount) OVER (PARTITION BY department ORDER BY employee_id)
           AS prev_sale_in_dept
FROM Sales;
-- Now each department gets its own NULL at its own first row.
--
-- Why LAG matters for analyst work: month-over-month change is
--   sale_amount - LAG(sale_amount) OVER (ORDER BY month)
-- which used to require an awkward self-join on month = month - 1.
