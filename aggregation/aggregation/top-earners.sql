-- Top Earners
-- Maximum total earnings (months * salary) and how many employees hit it.
-- Concept: GROUP BY an expression buckets rows by computed value.
--          COUNT(*) then counts rows within each bucket.
--          MAX() alone would give the value but not the headcount.

SELECT MONTHS * SALARY, COUNT(*)
FROM EMPLOYEE
GROUP BY MONTHS * SALARY
ORDER BY MONTHS * SALARY DESC
LIMIT 1;
