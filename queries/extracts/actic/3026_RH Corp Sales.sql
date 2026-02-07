SELECT
    COUNT(test.clubname) cnt ,
    test.clubname,
    test.member_id,
	test.firstname,
    test.lastname,
    test.company,
    test.persontype,
    test.creationtime,
	test.membership,
	test.type,
	test.price,
	test.sponsored,
	test.invoiced
FROM
    (
        SELECT
            club.NAME clubname,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
            company.LASTNAME company,
            DECODE ( per.PERSONTYPE,4,'CORPORATE') AS PERSONTYPE,
            TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD')
creationTime,
            prod.NAME MEMBERSHIP,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN 'Cash'
                WHEN subType.ST_TYPE = 1
                THEN 'EFT'
                ELSE 'Unknown'
            END type,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL
                WHEN subType.ST_TYPE = 1
                THEN sub.SUBSCRIPTION_PRICE
                ELSE -1
            END price,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL_SPONSORED
                ELSE 0
            END sponsored,
            CASE
                WHEN ar.AR_TYPE = 4
                    AND subType.ST_TYPE = 0
                THEN -art.AMOUNT
                ELSE 0
            END invoiced
        FROM
            subscriptions sub
        LEFT JOIN AR_TRANS art
        ON
            art.REF_CENTER = sub.INVOICELINE_CENTER
            AND art.REF_ID = sub.INVOICELINE_ID
            AND art.REF_TYPE = 'INVOICE'
        LEFT JOIN ACCOUNT_RECEIVABLES ar
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
        LEFT JOIN SUBSCRIPTION_SALES sales
        ON
            sales.SUBSCRIPTION_CENTER = sub.CENTER
            AND sales.SUBSCRIPTION_ID = sub.ID
        LEFT JOIN SUBSCRIPTIONTYPES subType
        ON
            subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCTS prod
        ON
            subType.CENTER = prod.CENTER
            AND subType.ID = prod.ID
        JOIN persons per
        ON
            sub.OWNER_CENTER = per.CENTER
            AND sub.OWNER_ID = per.ID
        JOIN CENTERS club
        ON
            per.center = club.ID
        LEFT JOIN relatives r
        ON
            per.id = r.id
            AND per.center = r.center
        LEFT JOIN COMPANYAGREEMENTS agr
        ON
            r.relativecenter = agr.center
            AND r.relativeid = agr.id
            AND r.relativesubid = agr.subid
        LEFT JOIN persons company
        ON
            agr.center = company.center
            AND agr.id = company.id
        WHERE
         /* company agreement relations */
	    r.rtype = 3
    	AND sub.center IN ( :ChosenScope )
	AND longtodate(sub.CREATION_TIME) >= :FromDate
    	AND longtodate(sub.CREATION_TIME) < :ToDate + 1
		AND sub.sub_state <> 8
		AND per.PERSONTYPE=4
        ORDER BY
            clubname,
            subType.ST_TYPE,
            prod.name,
            sub.SUBSCRIPTION_PRICE DESC
    )
    test
GROUP BY
    test.clubname,
    test.member_id,
	test.firstname,
    test.lastname,
    test.company,
    test.persontype,
    test.creationtime,
	test.membership,
	test.type,
	test.price,
	test.sponsored,
	test.invoiced