-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    /*+ NO_BIND_AWARE */
    centre.SHORTNAME AS club,
    TO_CHAR(sub.start_date, 'DD-MM-YYYY') AS start_date,
     CASE
        WHEN soldbyOverride.CENTER IS NOT NULL
             AND (soldbyOverride.CENTER <> salesperson.CENTER
                  OR soldbyOverride.ID <> salesperson.ID)
        THEN soldbyOverride.FULLNAME
		WHEN salesperson.FULLNAME = 'VA Api' THEN 'Online Join'
        ELSE salesperson.FULLNAME
    END AS sales_person,
	CASE 
        WHEN soldbyOverride.CENTER IS NOT NULL 
             AND (soldbyOverride.CENTER <> salesperson.CENTER
                  OR soldbyOverride.ID <> salesperson.ID)		  
        THEN salesperson.FULLNAME
        ELSE NULL 
    END AS orig_sales_person,
    TO_CHAR(longtodateC(sub.CREATION_TIME, sub.center), 'DD-MM-YYYY') AS date_joined,
    TO_CHAR(longtodateC(sub.CREATION_TIME, sub.center), 'HH24:MI') AS time_joined,
    owner.CENTER || 'p' || owner.ID AS member_id,
    owner.External_ID,
    owner.FULLNAME AS member_name,
    prod.NAME AS MEMBERSHIP
FROM
    SUBSCRIPTION_SALES ss
JOIN
    SUBSCRIPTIONS sub ON sub.CENTER = ss.SUBSCRIPTION_CENTER AND sub.ID = ss.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONTYPES stype ON ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
JOIN
    PRODUCTS prod ON stype.CENTER = prod.CENTER AND stype.ID = prod.ID
JOIN 
    PERSONS owner ON owner.CENTER = sub.OWNER_CENTER AND owner.ID = sub.OWNER_ID
JOIN 
    CENTERS centre ON owner.CENTER = centre.ID
JOIN
    STATE_CHANGE_LOG SCL1 ON SCL1.CENTER = sub.CENTER AND SCL1.ID = sub.ID AND SCL1.ENTRY_TYPE = 2
                         AND SCL1.STATEID IN (2, 4, 8)
                         AND SCL1.ENTRY_START_TIME >= EXTRACT(EPOCH FROM (CURRENT_DATE::TIMESTAMP AT TIME ZONE 'Australia/Sydney')) * 1000
                         AND (
                             SCL1.ENTRY_END_TIME IS NULL 
                             OR SCL1.ENTRY_END_TIME < EXTRACT(EPOCH FROM ((CURRENT_DATE::TIMESTAMP + INTERVAL '1 day') AT TIME ZONE 'Australia/Sydney')) * 1000
                         )
LEFT JOIN 
    SUBSCRIPTION_ADDON addon ON sub.CENTER = addon.SUBSCRIPTION_CENTER AND sub.ID = addon.SUBSCRIPTION_ID AND addon.CANCELLED = 0
LEFT JOIN 
    MASTERPRODUCTREGISTER mp ON addon.ADDON_PRODUCT_ID = mp.ID
LEFT JOIN 
    PERSON_EXT_ATTRS home ON owner.center = home.PERSONCENTER AND owner.id = home.PERSONID AND home.name = '_eClub_PhoneHome'
LEFT JOIN 
    PERSON_EXT_ATTRS mobile ON owner.center = mobile.PERSONCENTER AND owner.id = mobile.PERSONID AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN 
    PERSON_EXT_ATTRS email ON owner.center = email.PERSONCENTER AND owner.id = email.PERSONID AND email.name = '_eClub_Email'
LEFT JOIN 
    EMPLOYEES emp ON ss.EMPLOYEE_CENTER = emp.CENTER AND ss.EMPLOYEE_ID = emp.ID
LEFT JOIN 
    PERSONS salesperson ON salesperson.CENTER = emp.PERSONCENTER AND salesperson.ID = emp.PERSONID
LEFT JOIN 
    PERSON_EXT_ATTRS salesPersonOverrideExt ON owner.center = salesPersonOverrideExt.PERSONCENTER AND owner.id = salesPersonOverrideExt.PERSONID AND salesPersonOverrideExt.name = 'MC'
LEFT JOIN 
    PERSONS salesPersonOverride ON salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID = salesPersonOverrideExt.TXTVALUE
LEFT JOIN 
	PERSON_EXT_ATTRS soldby on owner.center = soldby.PERSONCENTER and owner.id = soldby.PERSONID and soldby.name = 'SoldBy' 
LEFT JOIN 
	PERSONS soldbyOverride  on soldbyOverride.center || 'p' ||  soldbyOverride.ID = soldby.TXTVALUE
WHERE
    ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
    AND sub.CREATION_TIME >= EXTRACT(EPOCH FROM (CURRENT_DATE::TIMESTAMP AT TIME ZONE 'Australia/Sydney')) * 1000
    AND sub.CREATION_TIME < EXTRACT(EPOCH FROM ((CURRENT_DATE::TIMESTAMP + INTERVAL '1 day') AT TIME ZONE 'Australia/Sydney')) * 1000
	AND prod.name not in ('Toddlz','Club V 3-12','Club V 13-15')
    AND ss.SUBSCRIPTION_CENTER != '999'
    AND NOT EXISTS (
        SELECT *
        FROM SUBSCRIPTIONS oldsub
        JOIN PERSONS oldPerson ON oldSub.OWNER_CENTER = oldPerson.CENTER AND oldSub.OWNER_ID = oldPerson.ID
        JOIN PRODUCTS oldsubprod ON oldsubprod.CENTER = oldsub.subscriptiontype_center AND oldsubprod.ID = oldsub.subscriptiontype_id AND oldsubprod.name NOT IN ('Free Adult Guest', 'Paying Adult Guest','Trial Membership', 'Guest', 'Guest Pass Subscription','Online Membership', 'Vitality Online','Free Trial','Hyrox Training','Invite A Friend')
        WHERE oldPerson.CURRENT_PERSON_CENTER = owner.center 
            AND oldPerson.CURRENT_PERSON_ID = owner.ID
            AND (oldSub.CENTER <> sub.CENTER OR oldSub.ID <> sub.ID)
            AND oldSub.END_DATE + 30 > longtodateC(sub.CREATION_TIME, sub.CENTER)
            AND (oldSub.STATE != 5 AND NOT (oldSub.STATE = 3 AND oldSub.SUB_STATE = 8))
    )
    AND NOT EXISTS (
        SELECT *
        FROM STATE_CHANGE_LOG SCLCHECK
        WHERE SCLCHECK.CENTER = sub.CENTER 
              AND SCLCHECK.ID = sub.ID
              AND SCLCHECK.ENTRY_TYPE = 2 
              AND SCLCHECK.STATEID IN (2, 3, 4, 8)
              AND SCLCHECK.SUB_STATE IN (3, 4, 5, 6, 7, 8)
              AND SCL1.ENTRY_START_TIME >= EXTRACT(EPOCH FROM (CURRENT_DATE::TIMESTAMP AT TIME ZONE 'Australia/Sydney')) * 1000
              AND SCL1.ENTRY_START_TIME < EXTRACT(EPOCH FROM ((CURRENT_DATE::TIMESTAMP + INTERVAL '1 day') AT TIME ZONE 'Australia/Sydney')) * 1000
    )
    AND EXISTS (
        SELECT *
        FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
        WHERE pgl.PRODUCT_CENTER = prod.CENTER 
              AND pgl.PRODUCT_ID = prod.ID 
              AND pgl.PRODUCT_GROUP_ID = 203
    )
GROUP BY
    sub.start_date,
    centre.SHORTNAME,
    salesperson.FULLNAME,
    salesperson.CENTER,
    salesperson.ID,
    salesPersonOverride.FULLNAME,
    salesPersonOverride.CENTER,
    salesPersonOverride.ID,
    sub.CREATION_TIME,
    owner.CENTER,
    owner.ID,
    owner.External_ID,
    owner.FULLNAME,
    prod.NAME,
	soldby.txtvalue,
    sub.CENTER,
	soldbyOverride.CENTER,
	soldbyOverride.ID,
	soldbyOverride.FULLNAME
ORDER BY
    sub.CREATION_TIME,
    salesperson.FULLNAME;