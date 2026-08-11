-- Weather Observation Station 5
-- Shortest and longest CITY names, with their lengths.
-- Concept: ORDER BY takes an expression, not just a column.
--          Second sort key breaks ties alphabetically.
--          UNION ALL stacks two single-row results.

(SELECT CITY, LENGTH(CITY)
 FROM STATION
 ORDER BY LENGTH(CITY) ASC, CITY ASC
 LIMIT 1)
UNION ALL
(SELECT CITY, LENGTH(CITY)
 FROM STATION
 ORDER BY LENGTH(CITY) DESC, CITY ASC
 LIMIT 1);
