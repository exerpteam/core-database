/**
* Creator: Exerp
* Purpose: List sold memberships for a given period.
* Result is summarized by Club and Type.
*/
SELECT
    clubname,
    sub_set.mytype AS type,
    MEMBERSHIP,
    price,
    COUNT(*) count,
    COUNT(*) * price total,
    replace('' || SUM(sponsored), '.', ',') sponsored,
    replace('' || SUM(invoiced), '.', ',') invoiced,
    CASE
        WHEN sub_set.mytype = 'Cash'
        THEN REPLACE('' || (COUNT(*) * price) - SUM(sponsored) - SUM(invoiced), '.', ',')
        ELSE '0'
    END netAmount
FROM
    (
        SELECT
            club.SHORTNAME clubname,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
			CASE
        		WHEN per.PERSONTYPE IS NOT NULL THEN 
				CASE per.PERSONTYPE  
					WHEN 0 THEN 'PRIVATE'  
					WHEN 1 THEN 'STUDENT'  
					WHEN 2 THEN 'STAFF'  
					WHEN 3 THEN 'FRIEND'  
					WHEN 4 THEN 'CORPORATE'  
					WHEN 5 THEN 'ONEMANCORPORATE'  
					WHEN 6 THEN  'FAMILY'  
					WHEN 7 THEN 'SENIOR'  
					WHEN 8 THEN 'GUEST' 
					ELSE 'UNKNOWN' 
				END
        		ELSE NULL
    		END AS PERSONTYPE,			
            TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') creationTime,
            prod.NAME MEMBERSHIP,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN 'Cash'
                WHEN subType.ST_TYPE = 1
                THEN 'EFT'
                ELSE 'Unknown'
            END mytype,
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
		--AND longtodate(sub.CREATION_TIME) >= :FromDate
    	--AND longtodate(sub.CREATION_TIME) < :ToDate + 1
		AND sub.CREATION_TIME >= :FromDate
		AND sub.CREATION_TIME < :ToDate + (24 * 60 * 60 * 1000)
        AND per.PERSONTYPE <> 2
		AND sub.sub_state <> 8
        ORDER BY
            clubname, subType.ST_TYPE, prod.name, sub.SUBSCRIPTION_PRICE DESC
    )sub_set
GROUP BY
    clubname,
    sub_set.mytype,
    MEMBERSHIP,
    price
ORDER BY
    clubname, sub_set.mytype, membership, price DESC