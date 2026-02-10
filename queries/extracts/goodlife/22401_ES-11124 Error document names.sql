-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3967
SELECT
   je.*,
   substring(name FROM 0 FOR 100) AS NEW_NAME,
   CASE
       WHEN je.big_text IS NOT NULL
       THEN CAST(je.name||' ' AS BYTEA)||je.big_text
       ELSE CAST(je.name AS BYTEA)
   END AS NEW_BIG_TEXT
FROM
   goodlife.journalentries je
WHERE
   LENGTH(je.name) > 100