-- Three ways to find customers with no orders.
-- Two work. One silently fails.

-- 1. LEFT JOIN + IS NULL
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
-- returns 3 rows: Charlie, Eve, Frank

-- 2. NOT EXISTS
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
-- returns 3 rows

-- 3. NOT IN — returns 0 rows
SELECT customer_id, customer_name
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders);
-- Order 106 has a NULL customer_id, so the subquery returns (1,2,4,NULL).
-- NOT IN expands to: id <> 1 AND id <> 2 AND id <> 4 AND id <> NULL
-- That last comparison is UNKNOWN for every row, so nothing passes WHERE.
-- Fix: add WHERE customer_id IS NOT NULL inside the subquery.
