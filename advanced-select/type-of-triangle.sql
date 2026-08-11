-- Type of Triangle
-- Classify each row as Equilateral / Isosceles / Scalene / Not A Triangle.
-- Concept: CASE checks conditions top-down and stops at the first match.
--          Order matters:
--            1. Validity first — 1,1,5 has two equal sides but isn't a triangle
--            2. Equilateral before Isosceles — 3 equal sides also satisfies "2 equal"
--            3. ELSE catches Scalene by elimination

SELECT
    CASE
        WHEN A + B <= C OR A + C <= B OR B + C <= A THEN 'Not A Triangle'
        WHEN A = B AND B = C THEN 'Equilateral'
        WHEN A = B OR B = C OR A = C THEN 'Isosceles'
        ELSE 'Scalene'
    END
FROM TRIANGLES;
