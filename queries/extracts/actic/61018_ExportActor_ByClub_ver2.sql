WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS cutDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    e.IDENTITY  AS "CARDNO",
    1           AS CARDSTATUS,
    p.FIRSTNAME AS "Name",
    p.LASTNAME  AS "LastName",
	p.CENTER ||'p'||p.ID

FROM
    persons p
JOIN	
	PARAMS params ON params.CenterID = p.CENTER
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.center
	AND s.OWNER_ID = p.id

FULL JOIN
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
	s.START_DATE <= LONGTODATE(params.cutDate)
	AND (s.END_DATE > LONGTODATE(params.cutDate) OR  s.END_DATE IS NULL)
	AND s.SUB_STATE NOT IN(8,9)
	AND (
		(
			s.CENTER IN (:center_array) -- Use this  for max-access during the summer.
			AND
			(	
				LOWER(pr.NAME) LIKE '%single site%' 
				OR LOWER(pr.NAME) LIKE '%junior%'  
				OR LOWER(pr.NAME) LIKE '%ungdom%' 
				OR LOWER(pr.NAME) LIKE '%autogiro%' 
				OR LOWER(pr.NAME) LIKE '%benify%'
				OR LOWER(pr.NAME) LIKE 'web%'
				OR LOWER(pr.NAME) LIKE 'personal%'
				OR LOWER(pr.NAME) LIKE '1 månads träning%'
				OR LOWER(pr.NAME) LIKE '%benifex%'
				OR LOWER(pr.NAME) LIKE '%myactic%'
				OR LOWER(pr.NAME) LIKE '%sponsor%'
			)
		)
		OR
		(
			s.CENTER IN (:center_array) 
			AND 
				(LOWER(pr.NAME) LIKE '%region%'
				OR LOWER(pr.NAME) LIKE '%personal%'
)
		)
		OR
		(
			(LOWER(pr.NAME) LIKE '%max%'
			OR
			LOWER(pr.NAME) LIKE '%personal%')
		)
	)
ORDER BY
    s.START_DATE
