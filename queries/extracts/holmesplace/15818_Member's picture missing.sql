-- The extract is extracted from Exerp on 2026-02-08
-- Active and Temp inactive only, with current subs start date, delete dups
SELECT
        p.CENTER || 'p' || p.ID AS MEMBER_ID,
		p.FULLNAME AS "Name",
		p.STATUS AS "Status",
		p.CENTER as "Club",
		S.START_DATE AS "StartDate"
		

FROM PERSONS p

LEFT JOIN
    SUBSCRIPTIONS S
ON
    P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID


WHERE 
        p.CENTER IN (:Scope)
		AND p.STATUS IN (1,3)
        AND p.PERSONTYPE != 2
		AND S.STATE IN (2,4)
		AND (p.CENTER, p.ID) NOT IN
(
        SELECT
                pea.PERSONCENTER,
                pea.PERSONID
        FROM PERSON_EXT_ATTRS pea
        WHERE
				pea.PERSONCENTER IN (:Scope)
				AND pea.NAME IN ('_eClub_Picture','_eClub_PictureFace')
                AND pea.mimevalue IS NOT NULL
)



ORDER BY MEMBER_ID