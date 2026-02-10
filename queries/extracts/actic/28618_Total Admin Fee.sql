-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-1637
SELECT c.ID AS "Clud ID", c.SHORTNAME AS "Club Name", count(*) "Members charged",
  -sum(art.AMOUNT) "Total Admin Fee"
FROM
  AR_TRANS art
JOIN
  CENTERS c
ON
  c.ID = art.CENTER
WHERE
 art.CENTER in (:Scope)
 AND art.REF_TYPE = 'INVOICE'
 AND art.AMOUNT = -99
 AND TRIM(art.TEXT) = 'Årlig administrasjonsavgift for medlemskap'
 AND art.ENTRY_TIME > :From_Date
 AND art.ENTRY_TIME <  :To_Date + 86400000
GROUP BY c.ID, c.SHORTNAME 
ORDER BY c.ID
