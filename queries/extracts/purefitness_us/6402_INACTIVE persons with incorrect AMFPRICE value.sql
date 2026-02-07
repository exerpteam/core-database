SELECT
    "Member ID",
	"Member Name",
    "External ID",
    "Person State",
	"Attribute"   
FROM
    (
      SELECT DISTINCT
            p.center||'p'||p.id AS "Member ID",
            P.external_id AS "External ID",
            p.center,
            p.fullname AS "Member Name",
            CASE p.STATUS
                WHEN 0 THEN 'LEAD'
                WHEN 1 THEN 'ACTIVE'
                WHEN 2 THEN 'INACTIVE'
                WHEN 3 THEN 'TEMPORARYINACTIVE'
                WHEN 4 THEN 'TRANSFERRED'
                WHEN 5 THEN 'DUPLICATE'
                WHEN 6 THEN 'PROSPECT'
                WHEN 7 THEN 'DELETED'
                WHEN 8 THEN 'ANONYMIZED'
                WHEN 9 THEN 'CONTACT'
                ELSE 'UNKNOWN'
            END AS "Person State",
			pe.TXTVALUE AS "Attribute"
        FROM
            PERSONS p
        LEFT JOIN
			PERSON_EXT_ATTRS pe
		ON
			pe.PERSONCENTER = p.CURRENT_PERSON_CENTER
			AND pe.PERSONID = p.CURRENT_PERSON_ID
			AND pe.NAME = 'AMFPRICE'
        WHERE
            p.center in (:center)
            -- p.center||'p'||p.id = '535p14828' AND
            AND p.STATUS = 2
            AND p.PERSONTYPE NOT IN (2, 3, 6)
			AND pe.TXTVALUE NOT IN ('null','49')
        GROUP BY
            p.center,
            p.id,
            pe.TXTVALUE,
            p.STATUS) dat2