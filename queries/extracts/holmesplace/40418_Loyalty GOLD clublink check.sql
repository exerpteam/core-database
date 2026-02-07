SELECT
	per.EXTERNAL_ID,
	s.CENTER ||'ss'|| s.ID AS SubID,
    s.OWNER_CENTER || 'p' ||s.OWNER_ID AS MemNo,
    per.FIRSTNAME || ' ' || per.LASTNAME AS name,
    addons.name                             addonName,
    addons.start_date                       addonStartDate,
    addons.end_date                         addonEndDate,
    addons.addonPrice,
    p.NAME               MainSubscription,
    p.PRICE              MainNormalPrice,
    s.SUBSCRIPTION_PRICE MainMemberprice,
    s.START_DATE         MainStart,
	s.END_DATE				MainEnd,
	CASE s.STATE
        WHEN 2
        THEN 'active'
        WHEN 3
        THEN 'ended'
        WHEN 4
        THEN 'frozen'
        WHEN 7
        THEN 'window'
        WHEN 8
        THEN 'created'
        ELSE 'UNKNOWN'
    END AS SubsState,
    peaLOYALTYDE.TXTVALUE AS "LOYALTY",
	peaLOYALTYDEREG.TXTVALUE AS "LOYALTYREG",
	peaLOYALTYDEADDON.TXTVALUE AS "LOYALTYDEADDON",
    peaOSD.TXTVALUE AS  "ORIGINAL_START_DATE",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "MEMBER_YEARS"

    
    
FROM
    SUBSCRIPTIONS s
JOIN
    PRODUCTS p
ON
    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND p.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
JOIN
    PERSONS per
ON
    per.CENTER = s.OWNER_CENTER
    AND per.id = s.OWNER_ID
JOIN
    PERSON_EXT_ATTRS peaLOYALTYDE
 ON
    per.center = peaLOYALTYDE.PERSONCENTER
    AND per.id = peaLOYALTYDE.PERSONID
    AND peaLOYALTYDE.name = 'LOYALTYDE'

LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEREG
 ON
    per.center = peaLOYALTYDEREG.PERSONCENTER
    AND per.id = peaLOYALTYDEREG.PERSONID
    AND peaLOYALTYDEREG.name = 'LOYALTYDEREG'

LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEADDON
 ON
    per.center = peaLOYALTYDEADDON.PERSONCENTER
    AND per.id = peaLOYALTYDEADDON.PERSONID
    AND peaLOYALTYDEADDON.name = 'LOYALTYDEADDON'


LEFT JOIN
    PERSON_EXT_ATTRS peaOSD
 ON
    per.center = peaOSD.PERSONCENTER
    AND per.id = peaOSD.PERSONID
    AND peaOSD.name = 'OriginalStartDate'



LEFT JOIN
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            mp.CACHED_PRODUCTNAME AS name,
            addons.START_DATE,
            addons.END_DATE,
            CASE addons.USE_INDIVIDUAL_PRICE
                WHEN 0
                THEN pr.PRICE
                WHEN 1
                THEN addons.INDIVIDUAL_PRICE_PER_UNIT
            END AS addonPrice
        FROM
            SUBSCRIPTION_ADDON addons
        JOIN
            MASTERPRODUCTREGISTER mp
        ON
            mp.ID = addons.ADDON_PRODUCT_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            mp.PRIMARY_PRODUCT_GROUP_ID = pg.ID
			AND pg.ID IN (8416)--CLUBLINK
			
        JOIN
            SUBSCRIPTIONS s
        ON
            addons.SUBSCRIPTION_CENTER = s.CENTER
            AND addons.SUBSCRIPTION_ID = s.ID
        JOIN
            PRODUCTS pr
        ON
            pr.center = s.center
            AND pr.GLOBALID = mp.GLOBALID
        JOIN
            PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            s.OWNER_CENTER IN($$Scope$$)
			
			AND per.PERSONTYPE <> 2--NOT STAFF

    	--Filter out members under 12
    	AND age(per.birthdate) > interval '12 year'
		AND pg.ID IN (8416)--clublink Loyalty is 23616
	     AND addons.CANCELLED = 0           
          

        UNION ALL
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            p.NAME,
            s.START_DATE,
            S.END_DATE,
            s.SUBSCRIPTION_PRICE addonPrice
        FROM
            SUBSCRIPTIONS s
        JOIN
            PRODUCTS p
        ON
            p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND p.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            PRODUCT_GROUP pg
        ON
            p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN
            PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        WHERE
            s.OWNER_CENTER IN($$Scope$$)
            AND pg.ID IN (8416)--clublink
						
             ) addons
ON
    addons.owner_center = per.center
    AND addons.owner_id = per.id
WHERE
    s.OWNER_CENTER IN ( $$Scope$$)
	AND per.PERSONTYPE <> 2--NOT STAFF
	AND per.STATUS IN (1,3)--ACTIVE TEMP INACTIVE
	AND s.state IN (2,4,8) -- active frozen created
		AND pg.ID NOT IN (2802,1605,19815,1601,6) --coaching ptbydd gym income pt clipcards
	AND (peaLOYALTYDE.TXTVALUE like 'Gold%%')
	
    

