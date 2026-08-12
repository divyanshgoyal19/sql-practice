-- HackerRank | SQL | Advanced Select | Occupations
-- https://www.hackerrank.com/challenges/occupations/problem

-- Pivot: reshape long data (one row per person) into wide (one column per
-- occupation). ROW_NUMBER() with PARTITION BY invents the row position that
-- lets unrelated names share a row; MIN(CASE ...) then pulls the right name
-- into each column, and returns NULL automatically once an occupation runs out.
SELECT
    MIN(CASE WHEN Occupation = 'Doctor'    THEN Name END) AS Doctor,
    MIN(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MIN(CASE WHEN Occupation = 'Singer'    THEN Name END) AS Singer,
    MIN(CASE WHEN Occupation = 'Actor'     THEN Name END) AS Actor
FROM (
    SELECT
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
) AS ranked
GROUP BY rn;
