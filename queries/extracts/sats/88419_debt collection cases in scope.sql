SELECT
    t1.homecenter,
    t1.member_id,
    t1.fullname,
    t1.person_status,
    t1.type,
    t1.startdate,
    t1.amount,
    CASE t1.setting_value
        WHEN '{CASHCOLLECTION_COMP_EFT_PAY_INBIND}'
        THEN 'Company EFT in binding'
        WHEN '{CASHCOLLECTION_COMP_INV_PAY_INBIND}'
        THEN 'Company Invoice in binding'
        WHEN '{CASHCOLLECTION_PERS_CREDIT_CARD_PAY_INBIND}'
        THEN 'Person Credit card in binding'
		WHEN '{CASHCOLLECTION_PERS_EFT_PAY_OUTBIND}'
		THEN 'Person EFT outside binding'
		WHEN '{CASHCOLLECTION_PERS_INV_PAY_OUTBIND}'
		THEN 'Person Invoice Outside binding'
        ELSE 'UNKNOWN'
    END AS Debt_settings
FROM
    (
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
        and cc.cashcollectionservice = '830'
        WHERE
            cc.closed = 'false'
        --AND cc.currentstep_type = -1
        AND cc.missingpayment = 'true'
        AND p.status NOT IN (4,5,7,8)
        --AND cc.nextstep_type IS NULL
		AND p.center IN (:scope)) t1