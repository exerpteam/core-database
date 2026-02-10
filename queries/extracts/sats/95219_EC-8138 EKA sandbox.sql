-- The extract is extracted from Exerp on 2026-02-08
-- Active members with debt without debt step
        SELECT
            c.name                AS homecenter,
            p.center ||'p'|| p.id AS member_id,
            p.fullname,
            CASE p.STATUS
                WHEN 0
                THEN 'LEAD'
                WHEN 1
                THEN 'ACTIVE'
                WHEN 2
                THEN 'INACTIVE'
                WHEN 3
                THEN 'TEMPORARYINACTIVE'
                WHEN 4
                THEN 'TRANSFERRED'
                WHEN 5
                THEN 'DUPLICATE'
                WHEN 6
                THEN 'PROSPECT'
                WHEN 7
                THEN 'DELETED'
                WHEN 8
                THEN 'ANONYMIZED'
                WHEN 9
                THEN 'CONTACT'
                ELSE 'Undefined'
            END AS PERSON_STATUS,
            CASE p.sex
                WHEN 'C'
                THEN 'COMPANY'
                ELSE 'PERSON'
            END AS "type",
            cc.startdate,
            cc.amount,
            CAST(xpath('//cashCollectionSettings/systemPropertyName/text()', CAST(convert_from
            (cc.settings, 'UTF-8') AS XML)) AS VARCHAR) AS setting_value
        FROM
            persons p
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            cashcollectioncases cc
        ON
            cc.personcenter = p.center
        AND cc.personid = p.id
        WHERE
            cc.closed = 'false'
        AND cc.currentstep_type = -1
        AND cc.missingpayment = 'true'
        AND p.status IN (1,3)
        AND cc.nextstep_type IS NULL
		AND p.center IN (:scope)