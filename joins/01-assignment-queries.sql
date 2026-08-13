-- Q1: List all customers and their orders, including customers with no orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date, o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;


-- Q2: Find orders placed by customers from the USA
SELECT c.customer_id, c.customer_name, c.country, o.order_id, o.order_date, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.country = 'USA';
