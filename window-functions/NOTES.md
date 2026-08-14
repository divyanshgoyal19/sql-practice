# Window Functions — Reference

## The core distinction

| | Rows out | Detail preserved |
|---|---|---|
| `GROUP BY` | One per group | No |
| `OVER (PARTITION BY ...)` | One per input row | Yes |

A window function computes a value **across a set of related rows** while leaving every row in the result. That is the whole idea; everything else is syntax.

## Anatomy

```sql
FUNCTION() OVER (
    PARTITION BY col   -- optional: split into groups
    ORDER BY     col   -- optional: order within the group
    ROWS/RANGE ...     -- optional: which rows the function sees
)
```

- **No `PARTITION BY`** → the whole result set is one window.
- **No `ORDER BY`** → the function sees the entire partition.
- **With `ORDER BY`** → the default frame becomes *start of partition → current row*, which is what turns `SUM` into a running total.

## Default frame — the thing that catches people

Adding `ORDER BY` silently changes the frame to:

```sql
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

`RANGE` treats **tied values as one unit**, so tied rows all receive the same running total. For strict row-by-row accumulation, write `ROWS` explicitly:

```sql
SUM(amount) OVER (ORDER BY order_date
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
```

On a unique ordering column the two agree. On a date column with repeats they do not — and that is a real bug that produces plausible-looking wrong numbers.

Moving average of the last 3 rows:

```sql
AVG(amount) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

## Execution order

```
FROM → WHERE → GROUP BY → HAVING → WINDOW FUNCTIONS → SELECT
     → DISTINCT → ORDER BY → LIMIT
```

Two consequences that explain most window-function errors:

1. **You cannot filter on a window function in `WHERE` or `HAVING`.** Wrap the query in a derived table or CTE and filter in the outer query. This is why every top-N-per-group query has two levels.
2. **Window functions run after `GROUP BY`**, so `ROW_NUMBER() OVER (ORDER BY SUM(x) DESC)` is legal — the window sees the aggregated rows, not the raw ones.

## The three ranking functions

| Values | `ROW_NUMBER` | `RANK` | `DENSE_RANK` |
|---|---|---|---|
| 100 | 1 | 1 | 1 |
| 150 | 2 | 2 | 2 |
| 150 | 3 | 2 | 2 |
| 200 | 4 | 4 | 3 |

- `ROW_NUMBER` — always sequential; ties broken arbitrarily. Use for deduplication and "exactly one per group".
- `RANK` — ties share, then skip. Competition placings.
- `DENSE_RANK` — ties share, no gaps. "Top 3 distinct values".

`ROW_NUMBER` with a tied `ORDER BY` is non-deterministic between runs. Add a tiebreaker column when the output must be stable.

## `LEAD` and `LAG`

```sql
LAG(col, offset, default)  OVER (PARTITION BY ... ORDER BY ...)
LEAD(col, offset, default) OVER (PARTITION BY ... ORDER BY ...)
```

`LAG` looks backwards, `LEAD` forwards. Boundary rows return `NULL` unless a default is supplied. Period-over-period change becomes:

```sql
amount - LAG(amount) OVER (ORDER BY month)
```

which previously required a self-join on `month = month - 1`.

## Top N per group — the pattern

```sql
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY sort_col DESC) AS rn
    FROM t
)
SELECT * FROM ranked WHERE rn <= N;
```

Learn this shape. It answers "top 3 products per category", "most recent order per customer", "highest-paid employee per department", and it is a near-certain interview question.

## Availability

Window functions require **MySQL 8.0+** (also MariaDB 10.2+). PostgreSQL, SQL Server, Oracle and SQLite 3.25+ all support them. Check with `SELECT VERSION();`.

## Common errors

| Symptom | Cause |
|---|---|
| Syntax error on `WHERE ROW_NUMBER() ...` | Window functions run after `WHERE`; use a derived table or CTE |
| Running total is flat, not accumulating | `ORDER BY` missing inside `OVER()` |
| Tied rows share a running total unexpectedly | Default `RANGE` frame; switch to `ROWS` |
| Ranks change between runs | Ties in `ORDER BY`; add a tiebreaker column |
| `NULL` instead of `0` after `LEFT JOIN` + `SUM` | Wrap in `COALESCE(SUM(x), 0)` |
