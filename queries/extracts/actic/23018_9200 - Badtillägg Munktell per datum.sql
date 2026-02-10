-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Mikael Ahlberg
* ServiceTicket: N/A
* Purpose: List subscriptions with addon for bath in Eskilstuna.
*
*/
SELECT
    e.IDENTITY  AS "CARDNO",
    1           AS CARDSTATUS,
    p.FIRSTNAME AS "Name",
    p.LASTNAME  AS "LastName",
	s.center,
	'' as saSubstart,
	s.START_DATE as Substart,
	s.END_DATE as subend,
	--sa.END_DATE as enddate,
	'' as enddate,
	cast(:check_date as date) AS MEMBERBASEDATE,
	p.CENTER||'p'||p.ID AS MEMBERID,
	pr.NAME/*,
	CASE
		WHEN LOWER(pr.NAME) LIKE '%region%' THEN 'JA'
		
		WHEN LOWER(pr.NAME) LIKE '%max%' THEN 'JA'
		WHEN LOWER(pr.NAME) LIKE '%personalmedlemskap%' THEN 'JA'

		WHEN (
				LOWER(pr.NAME) LIKE '%single site%' 
				OR LOWER(pr.NAME) LIKE '%autogiro%' 
				OR LOWER(pr.NAME) LIKE '%benify%'  
				OR LOWER(pr.NAME) LIKE 'web%'
			)  
			AND s.CENTER = 200 THEN 'JA'
		ELSE 'NEJ'
	END*/


FROM
    persons p
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.center
	AND s.OWNER_ID = p.id
JOIN
    ENTITYIDENTIFIERS e
ON
    p.CENTER = e.REF_CENTER
	AND p.ID = e.REF_ID
	AND e.ENTITYSTATUS = 1
	AND e.IDMETHOD = 1
LEFT JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
	AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
	s.START_DATE <= $$check_date$$
	AND (s.END_DATE > $$check_date$$ OR  s.END_DATE IS NULL)
	AND s.SUB_STATE !=8
	--AND s.CENTER IN (189,200,184) 
	AND (
		(
--			s.CENTER IN (200) 
			s.CENTER IN (189,200,184) -- Use this  for max-access during the summer.
			AND
			(	
				LOWER(pr.NAME) LIKE '%single site%' 
				OR LOWER(pr.NAME) LIKE '%autogiro%' 
				OR LOWER(pr.NAME) LIKE '%benify%'
				OR LOWER(pr.NAME) LIKE 'web%'
				OR LOWER(pr.NAME) LIKE '%personal%'
			)
		)
		OR
		(
			s.CENTER IN (189,200,184) 
			AND 
			(LOWER(pr.NAME) LIKE '%region%' OR LOWER(pr.NAME) LIKE '%personal%')
		)
		OR
		(
			(LOWER(pr.NAME) LIKE '%max%' OR LOWER(pr.NAME) LIKE '%personal%')
		)
	)
ORDER BY
    s.START_DATE
