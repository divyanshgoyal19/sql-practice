# Join types and NULL behaviour

Table A: 1, 2, 2, 3, NULL, NULL
Table B: 2, 3, 4, NULL

Joining on A.ID = B.ID:

| Join type  | Rows |
|------------|------|
| INNER      | 3    |
| LEFT       | 6    |
| RIGHT      | 5    |
| FULL OUTER | 8    |

Key rule: NULL = NULL is UNKNOWN, not TRUE.
A's NULLs never match B's NULL in any join type.

Duplicates multiply: A has two 2s, B has one 2, so that value
produces 2 rows.

Check: LEFT (6) + RIGHT (5) - INNER (3) = FULL OUTER (8)

MySQL has no FULL OUTER JOIN. Emulate with:
LEFT JOIN ... UNION ALL ... RIGHT JOIN ... WHERE A.ID IS NULL
Must be UNION ALL — plain UNION removes duplicate rows and gives 5 instead of 8.
