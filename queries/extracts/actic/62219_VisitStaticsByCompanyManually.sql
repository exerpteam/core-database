-- The extract is extracted from Exerp on 2026-02-08
-- List checkins by members related to a companyagreement.
Should be emailed scheduled to partner.
/**
* List checkins by members related to a companyagreement.
* Should be emailed scheduled to partner.
*/
SELECT
    ca.CENTER||'p'||ca.ID AS CompanyId,
    c.LASTNAME            AS company,
    ca.NAME               AS agreement,
	visitCenter.NAME	  AS VisitCenter,
    p.CENTER||'p'||p.ID   AS Customer,
    p.FIRSTNAME           AS FirstName,
    p.LASTNAME            AS LastName,
	TO_CHAR(TO_TIMESTAMP(cil.CHECKIN_TIME / 1000), 'YYYY-MM-DD HH24:MI') AS CheckinTime
FROM COMPANYAGREEMENTS ca
JOIN PERSONS c
  ON ca.CENTER = c.CENTER
 AND ca.ID     = c.ID
JOIN RELATIVES rel
  ON rel.RELATIVECENTER = ca.CENTER
 AND rel.RELATIVEID     = ca.ID
 AND rel.RELATIVESUBID  = ca.SUBID
 AND rel.RTYPE          = 3
JOIN PERSONS p
  ON rel.CENTER = p.CENTER
 AND rel.ID     = p.ID
JOIN CHECKINS cil
  ON cil.PERSON_CENTER = p.CENTER
 AND cil.PERSON_ID     = p.ID
JOIN CENTERS visitCenter ON
	cil.CHECKIN_CENTER = visitCenter.ID
WHERE
    c.SEX = 'C'
AND (ca.CENTER||'p'||ca.ID) IN (:companies)
AND cil.CHECKIN_TIME BETWEEN :FromDate AND :ToDate
AND rel.STATUS < 3
AND p.CENTER IN (:scope)
GROUP BY
    ca.CENTER, 
	ca.ID, 
	ca.CENTER||'p'||ca.ID,
    c.LASTNAME, 
	ca.NAME,
    p.CENTER||'p'||p.ID, 
	p.CENTER,
	p.FIRSTNAME, 
	p.LASTNAME,
	p.ID,
	cil.CHECKIN_TIME,
	visitCenter.NAME
ORDER BY
	cil.CHECKIN_TIME
    
