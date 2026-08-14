-- =====================================================================
-- Window functions — applied practice
-- Run 02-schema-practice.sql first.
--
-- These are the patterns that actually show up in analyst interviews:
-- top-N-per-group, ranking aggregates, running totals, and comparing a
-- row against a group-level value.
-- =====================================================================

USE window_practice;


-- ---------------------------------------------------------------------
-- Q1. Number products alphabetically within each category
-- ---------------------------------------------------------------------
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY product_name)
           AS seq_in_category
FROM products;
-- Electronics: Laptop 1, Phone 2, Tablet 3.  Accessories: Charger 1.
-- The plainest use of PARTITION BY — numbering restarts per group.


-- ---------------------------------------------------------------------
-- Q2. Top 2 orders by amount for each customer
-- ---------------------------------------------------------------------
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY amount DESC)
               AS rnk
    FROM orders
    WHERE customer_id IS NOT NULL
) AS ranked
WHERE rnk <= 2;
--
-- THE key pattern to memorise. Two steps, and they cannot be merged:
--   1. Inner query assigns a rank per group.
--   2. Outer query filters on that rank.
--
-- Why the derived table is unavoidable: window functions are evaluated
-- AFTER WHERE. Writing "WHERE ROW_NUMBER() OVER (...) <= 2" is a syntax
-- error, because WHERE runs before the window function exists.
--
-- Execution order:
--   FROM -> WHERE -> GROUP BY -> HAVING -> WINDOW FUNCTIONS -> SELECT
--   -> DISTINCT -> ORDER BY -> LIMIT
--
-- A CTE reads better than a derived table and does the same thing:
--   WITH ranked AS (SELECT ..., ROW_NUMBER() OVER (...) AS rnk FROM orders)
--   SELECT * FROM ranked WHERE rnk <= 2;
--
-- Order 106 is excluded by the WHERE — a NULL customer_id would form its
-- own partition, which is not a real customer.


-- ---------------------------------------------------------------------
-- Q3. Number all orders chronologically
-- ---------------------------------------------------------------------
SELECT *,
       ROW_NUMBER() OVER (ORDER BY order_date ASC) AS order_seq
FROM orders;
-- No PARTITION BY: the whole table is one window.


-- ---------------------------------------------------------------------
-- Q4. The highest-quantity line item within each order
-- ---------------------------------------------------------------------
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY quantity DESC)
               AS seq
    FROM order_items
) AS ranked
WHERE seq = 1;
-- Same two-step pattern as Q2, with N = 1.
--
-- ROW_NUMBER (not RANK) is correct here: it guarantees exactly one row
-- per order even when two line items tie on quantity. RANK would return
-- both tied rows and break the "one per order" guarantee.
-- This is also the standard deduplication idiom.


-- ---------------------------------------------------------------------
-- Q5. Products ranked by total quantity sold (including unsold products)
-- ---------------------------------------------------------------------
SELECT p.product_id,
       p.product_name,
       COALESCE(SUM(oi.quantity), 0) AS total_qty,
       ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(oi.quantity), 0) DESC,
                                   p.product_name) AS rnk
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name;
--
-- Three things worth noticing:
--
-- 1. LEFT JOIN keeps Tablet-with-no-sales... actually keeps Laptop and
--    every unsold product. An INNER JOIN would silently drop them, and
--    "rank all products" means all of them.
--
-- 2. COALESCE turns the NULL that SUM() returns over zero matched rows
--    into 0. Without it, unsold products show NULL, which sorts oddly
--    and reads as "unknown" rather than "none".
--
-- 3. The window function operates on the AGGREGATED result. Window
--    functions run after GROUP BY, so SUM() inside OVER()'s ORDER BY is
--    legal and refers to the group's total. This surprises people, and
--    it is exactly why the execution order in Q2 is worth knowing.
--
-- The second ORDER BY key (product_name) is a tiebreaker, making the
-- output deterministic when two products sold the same quantity.


-- ---------------------------------------------------------------------
-- Q6. Customers ranked by total order value (including customers with none)
-- ---------------------------------------------------------------------
SELECT c.customer_id,
       c.customer_name,
       COALESCE(SUM(o.amount), 0) AS total_spend,
       ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(o.amount), 0) DESC,
                                   c.customer_name) AS rnk
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;
-- Same shape as Q5. Charlie, Eve and Frank appear with 0 rather than
-- vanishing. Order 106 (NULL customer_id) matches nobody and is excluded
-- by the join, which is the correct outcome here.


-- ---------------------------------------------------------------------
-- Q7. Running total of spend per customer, in date order
-- ---------------------------------------------------------------------
SELECT customer_id,
       order_date,
       amount,
       SUM(amount) OVER (PARTITION BY customer_id ORDER BY order_date)
           AS running_spend
FROM orders
WHERE customer_id IS NOT NULL;
-- Accumulates within each customer and resets at the next one.
-- The classic "cumulative revenue" chart, in one clause.


-- ---------------------------------------------------------------------
-- Q8. Orders above the overall average order value
-- ---------------------------------------------------------------------
SELECT order_id, amount
FROM (
    SELECT *,
           AVG(amount) OVER () AS global_avg
    FROM orders
) AS with_avg
WHERE amount > global_avg;
-- Average across all 6 orders = 250.16. Returns orders 101 and 104.
--
-- Same derived-table requirement as Q2: the window value cannot be
-- referenced in the WHERE of the query that computes it.
--
-- A scalar subquery does this in one level:
--   SELECT order_id, amount FROM orders
--   WHERE amount > (SELECT AVG(amount) FROM orders);
--
-- The window version earns its keep when you want the average alongside
-- each row, or a PER-GROUP average:
--   AVG(amount) OVER (PARTITION BY customer_id)
-- gives "above this customer's own average", which a scalar subquery
-- cannot do without becoming correlated and slower.
