SELECT
            club.SHORTNAME clubname,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
			DECODE ( per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') creationTime,
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
                THEN  sub.SUBSCRIPTION_PRICE 
                ELSE -1
            END price,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL_SPONSORED
                ELSE 0
            END sponsored,
            CASE
                WHEN ar.AR_TYPE = 4 and subType.ST_TYPE = 0
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
        WHERE
    	sub.center IN ( :ChosenScope )
	AND longtodate(sub.CREATION_TIME) >= :FromDate
    	AND longtodate(sub.CREATION_TIME) < :ToDate + 1
        AND per.PERSONTYPE <> 2
		AND sub.sub_state <> 8
        ORDER BY
            clubname, subType.ST_TYPE, prod.name, sub.SUBSCRIPTION_PRICE DESC