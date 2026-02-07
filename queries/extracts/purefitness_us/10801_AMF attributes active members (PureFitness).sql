SELECT
    "Member ID",
	"Member Name",
    "External ID",
    "Person State",
	"AMFPRICE",
	"noAMF"
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
			npe.TXTVALUE AS "noAMF",
            ppe.TXTVALUE AS "AMFPRICE"
        FROM
            PERSONS p
        LEFT JOIN
			PERSON_EXT_ATTRS npe
		ON
			npe.PERSONCENTER = p.CURRENT_PERSON_CENTER
			AND npe.PERSONID = p.CURRENT_PERSON_ID
			AND npe.NAME = 'noAMF'
        LEFT JOIN
			PERSON_EXT_ATTRS ppe
		ON
			ppe.PERSONCENTER = p.CURRENT_PERSON_CENTER
			AND ppe.PERSONID = p.CURRENT_PERSON_ID
			AND ppe.NAME = 'AMFPRICE'
        WHERE
            p.center in (:center)
            -- p.center||'p'||p.id = '535p14828' AND
            AND p.STATUS IN (1, 3)
            AND p.PERSONTYPE NOT IN (2, 3, 6)
			AND (npe.TXTVALUE NOT IN ('null','false')
                    OR ppe.TXTVALUE NOT IN ('null')
            )
        GROUP BY
            p.center,
            p.id,
            npe.TXTVALUE,
            ppe.TXTVALUE,
            p.STATUS) dat2