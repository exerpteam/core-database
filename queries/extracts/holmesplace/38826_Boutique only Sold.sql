SELECT
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID AS "MemberID",
	owner.FULLNAME AS "MemberName",
	CASE owner.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "Status",
    prod.NAME  AS  "Membership",
    camps.CODE  AS  "Campaign",
    ss.PRICE_PERIOD AS "Price",
        
    (
        CASE sub.STATE
            WHEN 2
            THEN 'ACTIVE'
            WHEN 3
            THEN 'ENDED'
            WHEN 4
            THEN 'FROZEN'
            WHEN 7
            THEN 'WINDOW'
            WHEN 8
            THEN 'CREATED'
            ELSE 'UNKNOWN'
        END) AS "Membership_State",
    (
        CASE sub.SUB_STATE
            WHEN 1
            THEN 'NONE'
            WHEN 2
            THEN 'AWAITING_ACTIVATION'
            WHEN 3
            THEN 'UPGRADED'
            WHEN 4
            THEN 'DOWNGRADED'
            WHEN 5
            THEN 'EXTENDED'
            WHEN 6
            THEN 'TRANSFERRED'
            WHEN 7
            THEN 'REGRETTED'
            WHEN 8
            THEN 'CANCELLED'
            WHEN 9
            THEN 'BLOCKED'
            ELSE 'UNKNOWN'
        END) AS "Membership_Substate",
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY') AS   "Startdate",
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY') AS   "Creationdate",
    email.TXTVALUE  AS "Email",
    
    TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY') AS "Join Date"
    
FROM
    SUBSCRIPTION_SALES ss
JOIN
    SUBSCRIPTIONS sub
ON
    sub.CENTER = ss.SUBSCRIPTION_CENTER
    AND sub.ID = ss.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONTYPES stype
ON
    ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
    AND ss.SUBSCRIPTION_TYPE_ID = stype.ID

                                
JOIN
    PRODUCTS prod
ON
    stype.CENTER = prod.CENTER
    AND stype.ID = prod.ID
JOIN
    PRODUCT_AND_PRODUCT_GROUP_LINK pp
ON
   prod.center = pp.PRODUCT_CENTER
   AND prod.id = pp.PRODUCT_ID
   AND pp.PRODUCT_GROUP_ID in (24016) ---Boutique
   
JOIN
    PERSONS owner
ON
    owner.CENTER = sub.OWNER_CENTER
    AND owner.ID = sub.OWNER_ID

LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    owner.center = email.PERSONCENTER
    AND owner.id = email.PERSONID
    AND email.name = '_eClub_Email'

LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    owner.center = osd.PERSONCENTER
    AND owner.id = osd.PERSONID
    AND osd.name = 'OriginalStartDate'

LEFT JOIN
    (
        SELECT
            pu.PERSON_CENTER,
            pu.PERSON_ID,
            STRING_AGG(sc.NAME, ',' ORDER BY sc.NAME) AS CODE
        FROM
            PRIVILEGE_USAGES pu
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.ID = pu.GRANT_ID
            AND pg.GRANTER_SERVICE = 'StartupCampaign'
        JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.ID = pg.GRANTER_ID
        WHERE
            pu.USE_TIME >= $$CreationFrom$$
            AND pu.USE_TIME < ($$CreationTo$$ + 24*60*60*1000)
        GROUP BY
            pu.PERSON_CENTER,
            pu.PERSON_ID ) camps
ON
    camps.PERSON_CENTER = owner.center
    AND camps.PERSON_ID = owner.ID
WHERE
    ss.type =1 -- only new sales
	AND prod.name IN ('Holmes Place Boutique')--add new boutique membershps here separated by comma
	AND sub.SUB_STATE NOT IN (8)-- not cancelled
    AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
    AND sub.CREATION_TIME >= $$CreationFrom$$
    AND sub.CREATION_TIME < ($$CreationTo$$ + 24*60*60*1000)
GROUP BY
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
	owner.STATUS,
	prod.NAME,
	ss.PRICE_PERIOD,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    email.TXTVALUE,
    osd.TXTVALUE,
    camps.CODE
	
	

ORDER BY
	prod.NAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID

