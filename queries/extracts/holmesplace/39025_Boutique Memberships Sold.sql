SELECT
    salesperson.FULLNAME AS "SalesPerson",
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID AS "MemberID",
	owner.FULLNAME AS "MemberName",
	CASE p.STATUS
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
    SUM(mp.CACHED_PRODUCTPRICE) AS "addonTotal",
    
    (
        CASE sub.STATE
            WHEN 2
            THEN 'active'
            WHEN 3
            THEN 'ended'
            WHEN 4
            THEN 'frozen'
            WHEN 7
            THEN 'ended recently'
            WHEN 8
            THEN 'created (future)'
            ELSE 'unknown'
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
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY') AS   "Creationdate",
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY') AS   "Startdate",
    TO_CHAR(sub.END_DATE, 'DD-MM-YYYY')  AS "Subcription Endate",
   email.TXTVALUE  AS "Email",    
    home.TXTVALUE AS  "Homephone",
    mobile.TXTVALUE AS "Mobilephone",
       
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
     PRODUCT_GROUP pg
ON
    primary_product_group_id = pg.id
    
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
    PERSON_EXT_ATTRS osd
ON
    owner.center = osd.PERSONCENTER
    AND owner.id = osd.PERSONID
    AND osd.name = 'OriginalStartDate'

LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = owner.center
    AND payment_ar.CUSTOMERID = owner.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
    AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
    AND paymentaccount.ACTIVE_AGR_ID = pa.id
    AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    PERSON_EXT_ATTRS pa_sales
ON
    pa_sales.PERSONCENTER = ss.OWNER_CENTER
    AND pa_sales.PERSONID = ss.OWNER_ID
    AND pa_sales.NAME = 'Sales_Staff'
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

----add company name

LEFT JOIN
PERSONS p
ON
    p.CENTER = sub.OWNER_CENTER
    AND p.ID = sub.OWNER_ID
LEFT JOIN
    RELATIVES rca
ON
    rca.CENTER = sub.OWNER_CENTER ----Member of the company agreement
    AND rca.ID = sub.OWNER_ID
    AND rca.RTYPE = 3
    AND rca.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rca.RELATIVECENTER
    AND ca.id = rca.RELATIVEID
    AND ca.SUBID = rca.RELATIVESUBID

LEFT JOIN
  PERSONS comp
ON
    comp.center = rca.RELATIVECENTER
    AND comp.id = rca.RELATIVEID




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
	AND pp.PRODUCT_GROUP_ID in (24016)--Boutique
	AND sub.STATE NOT IN (3,7)--Not ended or window
	AND sub.SUB_STATE NOT IN (8)--not cancelled
    AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
    AND sub.CREATION_TIME >= $$CreationFrom$$
    AND sub.CREATION_TIME < ($$CreationTo$$ + 24*60*60*1000)
GROUP BY
    salesperson.FULLNAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
	p.STATUS,
	prod.NAME,
	ss.PRICE_PERIOD,
    sub.STATE,
    sub.SUB_STATE,
   TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
   TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
   TO_CHAR(sub.END_DATE, 'DD-MM-YYYY'),
    email.TXTVALUE,
    home.TXTVALUE,
    mobile.TXTVALUE,
    osd.TXTVALUE,
    camps.CODE,
	mp.CACHED_PRODUCTPRICE
	

ORDER BY
	prod.NAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID

