SELECT
    createdBy.Fullname AS "Created by",
    salesperson.FULLNAME "SALES STAFF",
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID person_id,

	owner.STATUS,
    owner.FULLNAME,
    payment_ar.BALANCE ACCOUNT_BALANCE,
	sub.center || 'ss' || sub.id    AS  "SubId",
    prod.NAME          MEMBERSHIP,
	sub.binding_end_date AS "BindingEnd",
    stype.BINDINGPERIODCOUNT,
    prod.EXTERNAL_ID,
    camps.CODE                  Campaign,
    ss.PRICE_NEW                JOINING,
    ss.PRICE_ADMIN_FEE          adminFee,
    ss.PRICE_PRORATA            PRORATA,
    ss.PRICE_INITIAL            INITIALP,
    ss.PRICE_PERIOD             periodPrice,
    SUM(mp.CACHED_PRODUCTPRICE) addonTotal,
    (
        CASE pa.STATE
            WHEN 1
            THEN 'CREATED'
            WHEN 2
            THEN 'SENT'
            WHEN 3
            THEN 'FAILED'
            WHEN 4
            THEN 'OK'
            WHEN 5
            THEN 'ENDED BY BANK'
            WHEN 6
            THEN 'ENDED BY CLEARING HOUSE'
            WHEN 7
            THEN 'ENDED BY DEBITOR'
            WHEN 8
            THEN 'CANCELLED'
            WHEN 9
            THEN 'END REQUEST SENT'
            WHEN 10
            THEN 'ENDED BY CREDITOR'
            WHEN 11
            THEN 'NO AGREEMENT'
            WHEN 12
            THEN 'DEPRECATED'
            WHEN 13
            THEN 'NOT NEEDED'
            WHEN 14
            THEN 'INCOMPLETE'
            WHEN 15
            THEN 'TRANSFERRED'
            ELSE 'NONE'
        END) AS DDM_STATE,
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
        END) AS MEM_STATE,
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
        END)                                             AS MEM_SUBSTATE ,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY')                   startdate,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')    creationdate,
    owner.address1,
    owner.address2,
    owner.zipcode,
    owner.city,
    home.TXTVALUE   homephone,
    mobile.TXTVALUE mobilephone,
    email.TXTVALUE  email,
    CASE
        WHEN passport.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END passport,
    CASE
        WHEN corp_doc.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END corp_doc,
    CASE
        WHEN health.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END  health,
    TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY') AS "Original Start date",
    cok.TXTVALUE          AS "Contract OK",
	reason.TXTVALUE    AS "Contract Reason",
    com.TXTVALUE          AS "Contract Com",
    company.TXTVALUE       AS "Company",
	referredby.TXTVALUE		AS "ReferredBy",
	salesoffer.TXTVALUE		AS "Real Sales Offer",
	source.TXTVALUE		AS "Source",
	BS.TXTVALUE AS "Charge BS",
	TOW.TXTVALUE AS "Tow Fee",
	comp.FULLNAME  AS "Company Name",
	ss.type AS "SS Type"

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
    PERSON_EXT_ATTRS passport
ON
    owner.center = passport.PERSONCENTER
    AND owner.id = passport.PERSONID
    AND passport.name = 'COMM_PASSPORT'
LEFT JOIN
    PERSON_EXT_ATTRS corp_doc
ON
    owner.center = corp_doc.PERSONCENTER
    AND owner.id = corp_doc.PERSONID
    AND corp_doc.name = 'COMM_CORPORATE_DOC'
LEFT JOIN
    PERSON_EXT_ATTRS health
ON
    owner.center = health.PERSONCENTER
    AND owner.id = health.PERSONID
    AND health.name = 'COMM_HEALTH_QUESTIONNAIRE'
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
    PERSON_EXT_ATTRS company
ON
    owner.center = company.PERSONCENTER
    AND owner.id = company.PERSONID
    AND company.name = 'COMPANY'
LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    owner.center = osd.PERSONCENTER
    AND owner.id = osd.PERSONID
    AND osd.name = 'OriginalStartDate'
LEFT JOIN
    PERSON_EXT_ATTRS BS
ON
    owner.center = BS.PERSONCENTER
    AND owner.id = BS.PERSONID
    AND BS.name = 'CHARGEBODYSCANFEE'
LEFT JOIN
    PERSON_EXT_ATTRS TOW
ON
    owner.center = TOW.PERSONCENTER
    AND owner.id = TOW.PERSONID
    AND TOW.name = 'CHARGETOWDE'

LEFT JOIN
    PERSON_EXT_ATTRS referredby
ON
    owner.center = referredby.PERSONCENTER
    AND owner.id = referredby.PERSONID
    AND referredby.name = 'REFERREDBY'
LEFT JOIN
    PERSON_EXT_ATTRS salesoffer
ON
    owner.center = salesoffer.PERSONCENTER
    AND owner.id = salesoffer.PERSONID
    AND salesoffer.name = 'SalesOffer'
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
    ss.type IN (1,2,3,4,5) -- 1 is new sales
    AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
    AND sub.CREATION_TIME >= $$CreationFrom$$
    AND sub.CREATION_TIME < ($$CreationTo$$ + 24*60*60*1000)
GROUP BY
    salesperson.FULLNAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
	payment_ar.BALANCE,
    prod.NAME,
	stype.BINDINGPERIODCOUNT,
	sub.binding_end_date,
	prod.EXTERNAL_ID,
    ss.PRICE_NEW,
    ss.PRICE_ADMIN_FEE,
    ss.PRICE_PRORATA,
    ss.PRICE_INITIAL,
    ss.PRICE_PERIOD,
	sub.center,
	sub.ID,
    pa.STATE,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    owner.address1,
    owner.address2,
    owner.zipcode,
    owner.city,
    home.TXTVALUE,
    mobile.TXTVALUE,
    email.TXTVALUE,
    passport.TXTVALUE,
    corp_doc.TXTVALUE,
    health.TXTVALUE,
    createdBy.Fullname,
    cok.TXTVALUE,
	reason.TXTVALUE,
    com.TXTVALUE,
    company.TXTVALUE,
	osd.TXTVALUE,
    referredby.TXTVALUE,
	salesoffer.TXTVALUE,
	source.TXTVALUE,
    camps.CODE,
	BS.TXTVALUE,
	TOW.TXTVALUE,
	comp.FULLNAME,
	owner.STATUS,
	ss.type

ORDER BY
    salesperson.FULLNAME,
    ss.OWNER_ID

