# sql-practice

This is the hardest one in the set, because MySQL has no MEDIAN() function. AVG, SUM, MIN, MAX, COUNT — that's the whole aggregate list. Median you build yourself.

The idea: sort all the latitudes, then grab the value sitting in the middle position.

If there are 500 rows, the median is the 250th (0-indexed) after sorting. Generally: skip count/2 rows, take the next one.

sql
SELECT ROUND(LAT_N, 4)
FROM STATION
ORDER BY LAT_N
LIMIT 1
OFFSET (SELECT COUNT(*) FROM STATION) / 2;

OFFSET is the new piece. It skips N rows before LIMIT starts counting. LIMIT 1 OFFSET 250 means "skip 250, then give me 1" — the 251st row.

The subquery computes how many to skip: half the row count.

MySQL is fussy about expressions in OFFSET, so if it rejects that, use a variable:

sql
SET @rowindex := (SELECT COUNT(*) FROM STATION) DIV 2;
SELECT ROUND(LAT_N, 4) FROM STATION ORDER BY LAT_N LIMIT 1 OFFSET @rowindex;
