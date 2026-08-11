-- Weather Observation Station 20 — median of LAT_N
-- Concept: MySQL has no MEDIAN(). Built from the definition instead:
--          the value with as many values below it as above it.
--          This is a CORRELATED subquery — the inner queries reference
--          S.LAT_N from the outer row, so they re-run for every row.
-- Note: LIMIT 1 OFFSET (subquery) does NOT work — MySQL requires a
--       literal integer in OFFSET.

SELECT ROUND(S.LAT_N, 4)
FROM STATION S
WHERE (SELECT COUNT(*) FROM STATION WHERE LAT_N < S.LAT_N)
    = (SELECT COUNT(*) FROM STATION WHERE LAT_N > S.LAT_N);
