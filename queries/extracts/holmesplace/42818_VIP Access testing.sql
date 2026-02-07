SELECT
    createdBy.Fullname AS "Created by",
    salesperson.FULLNAME "SALES STAFF",
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID person_id,
	owner.STATUS,
    owner.FULLNAME,
    prod.NAME          MEMBERSHIP,
    stype.BINDINGPERIODCOUNT,
    prod.EXTERNAL_ID,
    camps.CODE                  Campaign,
    
        
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY')                   startdate,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')    creationdate,
    
    mobile.TXTVALUE mobilephone,
    email.TXTVALUE  email,
    
    TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY') AS "Original Start date"
    

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
    PERSONS owner
ON
    owner.CENTER = sub.OWNER_CENTER
    AND owner.ID = sub.OWNER_ID

LEFT JOIN
    SUBSCRIPTION_ADDON addon
ON
    sub.CENTER = addon.SUBSCRIPTION_CENTER
    AND sub.ID = addon.SUBSCRIPTION_ID
    AND addon.CANCELLED = 0
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    addon.ADDON_PRODUCT_ID = mp.ID
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    owner.center = home.PERSONCENTER
    AND owner.id = home.PERSONID
    AND home.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    owner.center = mobile.PERSONCENTER
    AND owner.id = mobile.PERSONID
    AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    owner.center = email.PERSONCENTER
    AND owner.id = email.PERSONID
    AND email.name = '_eClub_Email'

LEFT JOIN
    PERSON_EXT_ATTRS cok
ON
    owner.center = cok.PERSONCENTER
    AND owner.id = cok.PERSONID
    AND cok.name = 'ContractOK'
LEFT JOIN
    PERSON_EXT_ATTRS reason
ON
    owner.center = reason.PERSONCENTER
    AND owner.id = reason.PERSONID
    AND reason.name = 'ContractReason'
LEFT JOIN
    PERSON_EXT_ATTRS com
ON
    owner.center = com.PERSONCENTER
    AND owner.id = com.PERSONID
    AND com.name = 'ContractCom'

LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    owner.center = osd.PERSONCENTER
    AND owner.id = osd.PERSONID
    AND osd.name = 'OriginalStartDate'


LEFT JOIN
    PERSON_EXT_ATTRS salesoffer
ON
    owner.center = salesoffer.PERSONCENTER
    AND owner.id = salesoffer.PERSONID
    AND salesoffer.name = 'SalesOffer'

LEFT JOIN
    PERSON_EXT_ATTRS pa_sales
ON
    pa_sales.PERSONCENTER = ss.OWNER_CENTER
    AND pa_sales.PERSONID = ss.OWNER_ID
    AND pa_sales.NAME = 'Sales_Staff'

LEFT JOIN
    PERSON_EXT_ATTRS source
ON
   source.PERSONCENTER = ss.OWNER_CENTER
    AND source.PERSONID = ss.OWNER_ID
    AND source.NAME = 'SOURCES_DE'
LEFT JOIN
    PERSONS salesperson
ON
    pa_sales.TXTVALUE = salesperson.CENTER||'p'||salesperson.id

LEFT JOIN
    RELATIVES r
ON
    r.CENTER = ss.OWNER_CENTER
    AND r.ID = ss.OWNER_ID
    AND r.RTYPE = 8
    AND r.STATUS < 2
LEFT JOIN
    PERSONS createdBy
ON
    r.RELATIVECENTER = createdBy.CENTER
    AND r.RELATIVEID = createdBy.ID



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
    AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
    AND sub.CREATION_TIME >= $$CreationFrom$$
    AND sub.CREATION_TIME < ($$CreationTo$$ + 24*60*60*1000)
AND camps.CODE IN ('February 2 x 50% + 12 Months - 49€ JF,February 2 x 50% + 12 Months - 49€ JF')
GROUP BY
    salesperson.FULLNAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
	 prod.NAME,
    stype.BINDINGPERIODCOUNT,
	prod.EXTERNAL_ID,
    ss.PRICE_NEW,
    ss.PRICE_ADMIN_FEE,
    ss.PRICE_PRORATA,
    ss.PRICE_INITIAL,
    ss.PRICE_PERIOD,
	sub.center,
	sub.ID,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    
    mobile.TXTVALUE,
    email.TXTVALUE,
    
    createdBy.Fullname,
    cok.TXTVALUE,
	reason.TXTVALUE,
    com.TXTVALUE,
    
	osd.TXTVALUE,
    
	salesoffer.TXTVALUE,
	source.TXTVALUE,
    camps.CODE,
	
	
	owner.STATUS

ORDER BY
    salesperson.FULLNAME,
    ss.OWNER_ID

