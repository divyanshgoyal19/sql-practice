# Mistakes Log

Errors made while practising, and what caused them. Re-read before each session.

---

## NULL handling

**`NOT IN` with a NULL in the subquery returns zero rows.**
`x NOT IN (1, 2, NULL)` expands to `x <> 1 AND x <> 2 AND x <> NULL`. The last comparison is UNKNOWN for every row, so nothing passes `WHERE`.
Fix: add `WHERE col IS NOT NULL` inside the subquery, or use `NOT EXISTS`, which never compares values.
Note: plain `IN` is safe. Only `NOT IN` breaks.

**`NULL = NULL` is UNKNOWN, not TRUE** — in `WHERE` and in `JOIN ... ON`. NULLs never match each other in a join.
But set operators (`UNION`, `INTERSECT`, `EXCEPT`) *do* treat two NULLs as equal for deduplication. Inconsistent, and worth remembering as an exception.

**`SUM()` over zero matched rows returns NULL, not 0.** After a `LEFT JOIN`, wrap it: `COALESCE(SUM(x), 0)`.

---

## Joins

**In an anti-join, the filter goes in `WHERE`, not `ON`.**
`LEFT JOIN t2 ON t1.id = t2.fk AND t2.id IS NULL` kills the match condition, so the LEFT JOIN keeps every left row. The `IS NULL` test must come after the join has padded with NULLs.

**Test a NOT NULL column for the anti-join.** Check the primary key (`m.emp_id`), not a nullable column (`m.manager_id`) — otherwise a genuinely NULL value gives a false match.

**Joining changes the grain.** After joining to a one-to-many table, one row is no longer one entity. Check the row count; if it grew, aggregates will double-count.

---

## Set operations

**`UNION` deduplicates the entire combined result**, not just matches across the two queries. Duplicates within a single branch are also removed.

**A row is a duplicate only if every selected column matches.** Including an `id` or timestamp defeats deduplication silently.

**Result column names come from the first `SELECT`.** `ORDER BY` must use those names.

**Columns pair by position, not name.** `SELECT name, city` unioned with `SELECT city, name` runs without error and produces garbage.

**Default to `UNION ALL`.** `UNION` pays a full sort/hash to remove duplicates. Only use it when duplicates are genuinely possible and unwanted.

**`INTERSECT` / `EXCEPT` need MySQL 8.0.31+.** Substitutes: `IN` + `DISTINCT`, and `NOT EXISTS`.

**`INTERSECT` binds tighter than `UNION` and `EXCEPT`.** Parenthesise when mixing set operators.

---

## Window functions

**Cannot filter on a window function in `WHERE` or `HAVING`** — they are evaluated after both. Wrap in a derived table or CTE and filter in the outer query.

**Adding `ORDER BY` inside `OVER()` changes the frame** to "start of partition → current row". That is what makes a running total; forgetting it gives a flat group total instead.

**The default `RANGE` frame treats ties as one unit.** Tied rows get identical running totals. Use `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` for strict row-by-row accumulation.

**`ROW_NUMBER` with ties is non-deterministic.** Add a tiebreaker column when output must be stable.

**Pick the right ranking function.** `ROW_NUMBER` for exactly-one-per-group, `RANK` when ties should skip, `DENSE_RANK` when they should not.

---

## Errors by code

**Error 1054 — Unknown column 'x' in 'field list'.** The column does not exist on that table. Either misspelled, on a different table, or wrong alias. Run `DESCRIBE tablename;` before writing queries against a table not touched recently.

---

## Habits

**A subquery like `WHERE name IN (SELECT DISTINCT name FROM same_table)` filters nothing.** Every row is trivially in its own table's list. It only ever excludes NULLs, by accident.

**Alias every computed column.** `COALESCE(SUM(quantity), 0)` with no alias produces an unreadable column header and cannot be referenced later.

**Use single quotes for string literals.** Double quotes work in MySQL's default mode but mean "identifier" in standard SQL and in Postgres/Oracle.

**MySQL's default collation is case-insensitive**, so `'bangalore'` matches `'Bangalore'`. That is a MySQL default, not a SQL guarantee — do not rely on it elsewhere.
