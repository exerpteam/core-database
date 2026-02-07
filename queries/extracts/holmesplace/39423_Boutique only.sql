SELECT
	c.Shortname						AS "Club",
    p.CENTER ||'p'|| p.ID           AS "Member ID",
    p.FULLNAME                      AS "Fullname",
	email.TXTVALUE					AS "email",
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
        END) AS "Status",
    sub.start_date                  AS "Subsciption Startdate",
	sub.end_date					AS "Subcription Endate",
	prod.name						AS "Subscription Name"
FROM 
    PERSONS p 

LEFT JOIN
    CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center = email.PERSONCENTER
    AND p.id = email.PERSONID
    AND email.name = '_eClub_Email'

LEFT JOIN 
    SUBSCRIPTIONS sub 
ON 
    p.CENTER = sub.OWNER_CENTER
    AND p.ID = sub.OWNER_ID
JOIN 
    SUBSCRIPTION_SALES ss 
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

WHERE 
    sub.STATE IN (2,4,8)--active, frozen and created memberships
    AND prod.name IN ('Holmes Place Boutique')--add new boutique membershps here separated by comma
	AND p.CENTER IN ($$Scope$$)