# sql-practice

SQL practice as I work toward data analyst roles.
Solutions from HackerRank and LeetCode, plus assignment work,
with notes on the concept behind each query.

## Structure
- `basic-select/` — filtering, sorting, string functions
- `aggregation/` — COUNT, SUM, AVG, GROUP BY
- `advanced-select/` — CASE WHEN, subqueries
- `hackerrank/` — HackerRank SQL track solutions
- `leetcode/` — LeetCode SQL 50 solutions
- `joins/` — inner, left, right, cross and self joins across five
  related tables; anti-joins, aggregation over joins, and NULL
  comparison behaviour
- `subqueries/` — IN, scalar and derived-table subqueries; anti-joins;
  NULL traps with NOT IN
- `window-functions/` — OVER/PARTITION BY, running totals,
  ROW_NUMBER/RANK/DENSE_RANK, LEAD/LAG, top-N-per-group
- `mistakes.md` — running log of errors made and what caused them

## Concepts covered
- Sorting by expressions, tie-breaking with a second key
- Aggregates vs row-level queries
- Correlated subqueries
- Join types and how each handles duplicates and NULLs
- Anti-joins: LEFT JOIN + IS NULL vs NOT EXISTS vs NOT IN
- Why NULL = NULL is UNKNOWN, and what breaks because of it
- Set operations: UNION vs UNION ALL, INTERSECT, EXCEPT
- SQL logical execution order, and why it explains most errors
- Window functions vs GROUP BY: aggregating without collapsing rows
- Window frames — why ORDER BY inside OVER() creates a running total
- Top-N-per-group with ROW_NUMBER and a derived table
