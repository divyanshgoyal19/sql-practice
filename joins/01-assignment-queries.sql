-- Q1: List all customers and their orders, including customers with no orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date, o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;


-- Q2: Find orders placed by customers from the USA
SELECT c.customer_id, c.customer_name, c.country, o.order_id, o.order_date, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.country = 'USA';



-- Q3: Get a list of all customers and products, even if they aren't related
SELECT c.customer_id,
       c.customer_name,
       p.product_id,
       p.product_name
FROM customers c
CROSS JOIN products p;
-- 24 rows — every customer paired with every product (Cartesian product).
-- No ON clause: a cross join has no matching condition.


-- Q4: List all employees and their manager names
SELECT e.emp_id,
       e.name         AS employee_name,
       m.name         AS manager_name,
       e.department
FROM employees e
LEFT JOIN employees m
       ON e.manager_id = m.emp_id;
-- 5 rows. Self join: the same table aliased twice, e for the employee
-- and m for the manager that e.manager_id points to.
-- LEFT JOIN is required — John and Anna have manager_id = NULL, and
-- NULL = m.emp_id is UNKNOWN, so an INNER JOIN would drop them.


-- Q5: List all orders and include customer names, even if the customer is unknown
SELECT o.order_id,
       o.order_date,
       o.amount,
       c.customer_id,
       c.customer_name
FROM customers c
RIGHT JOIN orders o
        ON c.customer_id = o.customer_id;
-- 6 rows — every order, including order 106 whose customer_id is NULL.
-- Order 106 comes back with customer_id and customer_name as NULL,
-- meaning "no matching customer found".
-- Equivalent and more conventional: FROM orders o LEFT JOIN customers c ...


-- Q6: Find customers who placed at least one order
SELECT DISTINCT c.customer_id,
       c.customer_name
FROM customers c
INNER JOIN orders o
        ON c.customer_id = o.customer_id;
-- 3 rows: Alice, Bob, Diana.
-- DISTINCT is needed because the join produces one row per ORDER —
-- Alice and Diana have two orders each, so they appear twice before DISTINCT.

-- Same result using EXISTS — no DISTINCT needed, since EXISTS filters
-- rather than joining, so customer rows are never duplicated.
SELECT c.customer_id,
       c.customer_name
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.customer_id);


-- Q7: Show all customers who haven't ordered any products
SELECT c.customer_id,
       c.customer_name
FROM customers c
LEFT JOIN orders o
       ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
-- 3 rows: Charlie, Eve, Frank.
-- The LEFT JOIN keeps all 6 customers (8 rows once Alice and Diana are
-- doubled by their second order). Filtering on o.customer_id IS NULL then
-- keeps only the customers that found no match.
-- IS NULL must be in WHERE, not ON — in ON it becomes part of the join
-- condition and all 8 rows come back.
-- Filter on the join key, not on a column like o.amount that could
-- legitimately be NULL in a real order.
-- See 03-null-traps.sql for why the NOT IN version of this fails.


-- Q8: List products and the total quantity ordered, including products never ordered
SELECT p.product_id,
       p.product_name,
       p.category,
       COALESCE(SUM(oi.quantity), 0) AS total_quantity
FROM products p
LEFT JOIN order_items oi
       ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category;
-- LEFT JOIN so never-ordered products survive; an INNER JOIN would drop them.
-- SUM, not COUNT — the question asks for total quantity, and one order_items
-- row can carry a quantity of 3. COUNT would say 1.
-- COALESCE turns the NULL from SUM(NULL) into 0 for never-ordered products.
-- Related trap: after a LEFT JOIN, COUNT(*) returns 1 for an unmatched row
-- because the NULL-padded row still exists. Always count a column from the
-- right-hand table: COUNT(oi.product_id) correctly returns 0.


-- Q9: Show pairs of employees who belong to the same department
SELECT e1.emp_id   AS emp_1_id,
       e1.name     AS employee_1,
       e2.emp_id   AS emp_2_id,
       e2.name     AS employee_2,
       e1.department
FROM employees e1
JOIN employees e2
  ON e1.department = e2.department
 AND e1.emp_id < e2.emp_id;
-- 2 rows: John-Jane (Sales), Mike-Emily (IT). Anna is alone in HR, so no pair.
-- The < condition does two jobs: nothing is less than itself, so self-pairs
-- (John-John) are excluded; and of the two mirror rows (John-Jane, Jane-John)
-- only one survives.
-- The assignment hint suggests e1.emp_id != e2.emp_id instead. That returns
-- 4 rows — each pair twice, once in each order. DISTINCT cannot fix that,
-- because (John, Jane) and (Jane, John) are different rows.
-- Compare on emp_id rather than name: two employees could share a name.


-- Q10: List customer-product pairs for every order placed
SELECT c.customer_name,
       p.product_name,
       o.order_id,
       oi.quantity
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id;
-- 5 rows. orders and products share no column, so order_items is the bridge —
-- it holds both order_id and product_id.
-- Join order matters: products cannot be joined before order_items is in
-- scope, because oi.product_id would not exist yet.
-- Order 106 is absent: it has a NULL customer_id and no order_items rows,
-- so the inner joins drop it.
