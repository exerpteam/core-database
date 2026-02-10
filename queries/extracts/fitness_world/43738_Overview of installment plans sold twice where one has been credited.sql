-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3457

SELECT DISTINCT ar_total.center||'p'||ar_total.id as MemberID, ar_total.fullname, ar_total."Total_ART" AS Correction, ar_total.entry_date AS Entry_Date, cl.Text AS Description FROM
(SELECT 
  TO_CHAR(longtodate(art.ENTRY_TIME),'YYYY-MM-DD') as entry_date,
  p.FULLNAME,
  p.id,
  p.center,
  art.id as acc_id,
  art.center as acc_center,
  sum(art.AMOUNT) as "Total_ART"
FROM
  AR_TRANS art
 JOIN
  ACCOUNT_RECEIVABLES ar
ON
  ar.CENTER = art.CENTER 
  AND ar.ID = art.ID 
  AND ar.AR_TYPE = 6
JOIN
  PERSONS p
ON    
  p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID 
WHERE 
  art.ENTRY_TIME >= $$From_Date$$
GROUP BY TO_CHAR(longtodate(art.ENTRY_TIME),'YYYY-MM-DD'), p.id,p.center, art.id, art.center, p.fullname
HAVING sum(art.AMOUNT) < 0
) ar_total
JOIN 
  AR_TRANS art2
ON
  art2.STATUS in ('NEW','OPEN') 
--  AND ar_total.entry_date = TO_CHAR(longtodate(art2.ENTRY_TIME),'YYYY-MM-DD')
  AND art2.CENTER = ar_total.acc_center
  AND art2.ID = ar_total.acc_id
JOIN
  credit_note_lines_mt cl
ON
  cl.person_center = ar_total.center
  AND cl.person_id = ar_total.id
  AND cl.TOTAL_AMOUNT = -ar_total."Total_ART"


