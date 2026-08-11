-- Weather Observation Station 11
-- Cities that do NOT start with a vowel OR do NOT end with one.
-- Concept: NOT (A AND B) is the same as NOT A OR NOT B.
--          The connector in the question decides AND vs OR — read it carefully.

SELECT DISTINCT CITY
FROM STATION
WHERE LEFT(CITY, 1) NOT IN ('a','e','i','o','u')
   OR RIGHT(CITY, 1) NOT IN ('a','e','i','o','u');
