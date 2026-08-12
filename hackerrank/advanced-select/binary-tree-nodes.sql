-- HackerRank | SQL | Advanced Select | Binary Tree Nodes
-- https://www.hackerrank.com/challenges/binary-search-tree-1/problem

-- Self-referencing table: a node has children exactly when its value appears
-- in the parent column. CASE branches are ordered deliberately — Root must be
-- tested first, since the root also has children. The WHERE inside the
-- subquery strips NULLs, which would otherwise make IN return NULL, not false.
SELECT N,
       CASE WHEN P IS NULL THEN 'Root'
            WHEN N IN (SELECT P FROM BST WHERE P IS NOT NULL) THEN 'Inner'
            ELSE 'Leaf'
       END
FROM BST
ORDER BY N;
