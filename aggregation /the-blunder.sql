-- The Blunder
-- Difference between the real average salary and one typed
-- on a keyboard with a broken 0 key.
-- Concept: REPLACE(x, '0', '') deletes zeros per row BEFORE averaging.
--          CEIL rounds up — the question says "round up", not "round".

SELECT CEIL(AVG(SALARY) - AVG(REPLACE(SALARY, '0', '')))
FROM EMPLOYEES;
