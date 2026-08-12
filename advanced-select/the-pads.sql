-- HackerRank | SQL | Advanced Select | The PADS
-- https://www.hackerrank.com/challenges/the-pads/problem

-- Result set 1: name with profession initial in parentheses, alphabetical.
-- CONCAT collapses four pieces into a single output column; the parentheses
-- are passed as literal strings since CONCAT inserts no separators itself.
SELECT CONCAT(Name, '(', LEFT(Occupation, 1), ')')
FROM OCCUPATIONS
ORDER BY Name;

-- Result set 2: count sentence per occupation.
-- GROUP BY collapses rows into one bucket per occupation; COUNT(*) counts
-- rows within each bucket. Two-level ORDER BY: count ascending, with
-- occupation name as the alphabetical tiebreak.
SELECT CONCAT('There are a total of ', COUNT(*), ' ', LOWER(Occupation), 's.')
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY COUNT(*) ASC, Occupation ASC;
