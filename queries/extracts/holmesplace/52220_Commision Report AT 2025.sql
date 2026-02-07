SELECT

	ss.sales_date										AS "SalesDate",
	TO_CHAR(sub.START_DATE, 'DD-MM-YYYY')       		AS  "StartDate",		
	ss.OWNER_CENTER || 'p' || ss.OWNER_ID 				AS  "Mtg.Nummer",
	CASE owner.sex
	WHEN 'M' THEN 'MALE'
	WHEN 'F' THEN 'FEMALE'
	WHEN 'C' THEN 'OTHER'
	ELSE 'OTHER'
	END  												AS  "M/F", 	   
	     
	extract(year from age(CURRENT_DATE, owner.BIRTHDATE)) AS "Age",        
	owner.zipcode										AS	"ZipCode",
	prod.NAME											AS "Membership ",
	ppg.name											AS "SubsType",
	comp.fullname   									AS	"Company",

CASE
	WHEN stype.st_type = 0 THEN stype.periodcount
	WHEN stype.st_type = 1 THEN stype.bindingperiodcount
	WHEN stype.st_type = 2 THEN stype.bindingperiodcount
END 													AS "Contract",
CASE stype.periodunit
	WHEN 0 THEN 'WEEKS'
	WHEN 1 THEN 'DAYS'
	WHEN 2 THEN 'MONTHS'
	ELSE 'OTHER'
END  													AS "Length",

	Source.TXTVALUE										AS "Source",	
    salesperson.FULLNAME 								AS  "SalesPerson",

	ss.PRICE_ADMIN_FEE  								AS  "AdminFee",
	ss.PRICE_NEW        								AS  "JoiningPrice",
	NULL 									    	AS "YES/NO StarterPack",
	
	ss.PRICE_PERIOD     							AS  "MembershipFee",
	ss.PRICE_PRORATA    								AS "ProRataAmount",
	ss.PRICE_INITIAL    								AS  "PaidUpfront",
	
    camps.CODE  										AS "Offer/Notizen",
    
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
        END) 								AS "MembershipStatus",
    
    
CASE WHEN  
TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY')< TO_CHAR(sub.START_DATE, 'DD-MM-YYYY') THEN 'YES'
ELSE 'NO'
END 												AS "Rejoiner",
cok.TXTVALUE        								AS "YES/NO Comission",
com.TXTVALUE        								AS "Contract Notes",

CASE per.fullname
WHEN 'API TEST STAFF' THEN  'OnlineSale'
ELSE 'ClubSale'
END 												AS 	"Online/Offline",
egymid.TXTVALUE										AS "Egymid"

----additional info---
-- SUM(mp.CACHED_PRODUCTPRICE) 					AS "AddonTotal",--
--TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY') AS "OSD",--
--TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')    creationdate,--
--owner.address1, home.TXTVALUE   homephone, mobile.TXTVALUE mobilephone, email.TXTVALUE  email,--
--CASE WHEN corp_doc.TXTVALUE = 'true' THEN 'OK'--
--ELSE NULL     END 							AS "corp_doc",--
--owner.birthdate 									AS "DOB",--
--createdBy.Fullname 								AS "Created by",--

    
    
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

LEFT JOIN product_group ppg
ON
	ppg.ID = prod.primary_product_group_id

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
    PERSON_EXT_ATTRS Source
ON
    owner.center = Source.PERSONCENTER
    AND owner.id = Source.PERSONID
    AND Source.name = 'SOURCES_AT'
LEFT JOIN
    PERSON_EXT_ATTRS corp_doc
ON
    owner.center = corp_doc.PERSONCENTER
    AND owner.id = corp_doc.PERSONID
    AND corp_doc.name = 'COMM_CORPORATE_DOC'

LEFT JOIN
	PERSON_EXT_ATTRS COFE
ON
	owner.center = COFE.PERSONCENTER
    AND owner.id = COFE.PERSONID
    AND COFE.name = 'CHARGECOFEEAT'

LEFT JOIN
	PERSON_EXT_ATTRS FITCHECK
ON
	owner.center = FITCHECK.PERSONCENTER
    AND owner.id = FITCHECK.PERSONID
    AND FITCHECK.name = 'FITCHECK'

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
    PERSON_EXT_ATTRS egymid
ON
    owner.center = egymid.PERSONCENTER
    AND owner.id = egymid.PERSONID
    AND egymid.name = 'EGYMIDAT'

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

LEFT JOIN CLEARINGHOUSES clh
ON
    clh.ID = pa.clearinghouse


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
		EMPLOYEES emp
ON
	emp.center = ss.employee_center
AND emp.id = ss.employee_id

LEFT JOIN
	PERSONS per
ON
	emp.PERSONCENTER = per.CENTER
	AND emp.PERSONID = per.ID
	
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

--company name---
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=owner.center
    AND comp_rel.id=owner.id
    AND comp_rel.RTYPE = 3
    AND comp_rel.STATUS < 3


LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
    AND cag.id=comp_rel.RELATIVEID
    AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
    AND comp.id=cag.id

---promo---


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
    AND sub.CREATION_TIME <= ($$CreationTo$$ + 24*60*60*1000)
	AND sub.SUB_STATE NOT IN (8) --cancelled--
	AND prod.primary_product_group_id NOT IN (1201,1601,1605,6)--free Gym Income, ptdd, ptclip--
GROUP BY
	ss.sales_date,
    salesperson.FULLNAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
    payment_ar.BALANCE,
    prod.NAME,
    stype.BINDINGPERIODCOUNT,
    ss.PRICE_NEW,
    ss.PRICE_ADMIN_FEE,
	ss.price_admin_fee_discount,
    ss.PRICE_PRORATA,
	ss.price_prorata_discount,
    ss.PRICE_INITIAL,
    ss.PRICE_PERIOD,
    pa.STATE,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    owner.address1,
    owner.zipcode,
    owner.city,
    home.TXTVALUE,
    mobile.TXTVALUE,
    email.TXTVALUE,
    corp_doc.TXTVALUE,
    COFE.TXTVALUE,
	FITCHECK.TXTVALUE,
    createdBy.Fullname,
    cok.TXTVALUE,
    com.TXTVALUE,
    osd.TXTVALUE,
	camps.CODE,
	owner.sex,
	owner.birthdate,
	comp.fullname,
	stype.st_type,
	stype.periodcount,
	stype.periodunit,
	Source.TXTVALUE,
	ppg.name,
	clh.name,
	sub.subscription_price,
	per.fullname,
	egymid.TXTVALUE
	

ORDER BY
    salesperson.FULLNAME,
    ss.OWNER_ID

