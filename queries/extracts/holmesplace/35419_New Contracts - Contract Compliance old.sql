SELECT
    (
        CASE sub.CENTER
            WHEN 47
            THEN 'BFD'
            WHEN 2
            THEN 'BMS'
            WHEN 55
            THEN 'POP'
            WHEN 45
            THEN 'GMT'
            WHEN 14
            THEN 'HAM'
            WHEN 30
            THEN 'KOE'
            WHEN 24
            THEN 'LBK'
            WHEN 48
            THEN 'NWT'
            WHEN 49
            THEN 'OSK'
            WHEN 9 
            THEN 'PPL'
            WHEN 89
            THEN 'SST'
            WHEN 13
            THEN 'AMG'
            WHEN 157
            THEN 'ESS'
            WHEN 156
            THEN 'OBK'
            WHEN 100
			THEN 'HPDE'
			ELSE 'UNKNOWN'
        END)                                                        AS "Club",
    salesperson.FULLNAME                                            AS "Sales Staff",
    ss.OWNER_CENTER ||  'p' || ss.OWNER_ID                          AS "Member ID",
    owner.FULLNAME                                                  AS "Fullname",
    prod.NAME                                                       AS "Membership",
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
        END)                                                        AS "Membership State",
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY')                           AS "Start Date",
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')            AS "Creation Date",
    TO_CHAR(TO_DATE(osd.TXTVALUE, 'YYYY-MM-DD'),'DD-MM-YYYY')       AS "Original Start date",
    cok.TXTVALUE                                                    AS "Contract Compliant",
    StarterPack.TXTVALUE					                        AS "Starter Pack",
	ADDONS.TXTVALUE						                            AS "Add-ons",
	MembershipFEE.TXTVALUE				                            AS "Membership Fee",
	ContractDocumentation.TXTVALUE				                    AS "Contract Documentation",
	CampaignCodeUsed.TXTVALUE                                       AS "Campaign Code Used",
    com.TXTVALUE                                                    AS "Contract Comment",
    company.TXTVALUE                                                AS "Company"
FROM
    subscription_sales ss
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
    PERSON_EXT_ATTRS StarterPack
ON
    owner.center = StarterPack.PERSONCENTER
    AND owner.id = StarterPack.PERSONID
    AND StarterPack.name = 'StarterPack'
LEFT JOIN
    PERSON_EXT_ATTRS ADDONS
ON
    owner.center = ADDONS.PERSONCENTER
    AND owner.id = ADDONS.PERSONID
    AND ADDONS.name = 'ADDONS'
LEFT JOIN
    PERSON_EXT_ATTRS CampaignCodeUsed
ON
    owner.center = CampaignCodeUsed.PERSONCENTER
    AND owner.id = CampaignCodeUsed.PERSONID
    AND CampaignCodeUsed.name = 'CampaignCodeUsed'
LEFT JOIN
    PERSON_EXT_ATTRS MembershipFee
ON
    owner.center = MembershipFee.PERSONCENTER
    AND owner.id = MembershipFee.PERSONID
    AND MembershipFee.name = 'MembershipFee'
LEFT JOIN
    PERSON_EXT_ATTRS ContractDocumentation
ON
    owner.center = ContractDocumentation.PERSONCENTER
    AND owner.id = ContractDocumentation.PERSONID
    AND ContractDocumentation.name = 'ContractDocumentation'
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
    AND sub.CREATOR_CENTER || 'emp' || sub.CREATOR_ID <> 100 || 'emp' || 2001
    AND prod.primary_product_group_id <> 1201
    AND prod.primary_product_group_id <> 2802
    AND prod.primary_product_group_id <> 6 
    AND sub.STATE <> 3
    AND sub.STATE <> 7 
    AND sub.SUB_STATE <> 8 
GROUP BY
    sub.Center,
    salesperson.FULLNAME,
    sub.CREATOR_CENTER,
    sub.CREATOR_ID,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
    payment_ar.BALANCE,
    prod.NAME,
    prod.primary_product_group_id,
    stype.BINDINGPERIODCOUNT,
    ss.PRICE_NEW,
    ss.PRICE_ADMIN_FEE,
    ss.PRICE_PRORATA,
    ss.PRICE_INITIAL,
    ss.PRICE_PERIOD,
    pa.STATE,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    passport.TXTVALUE,
    corp_doc.TXTVALUE,
    health.TXTVALUE,
    createdBy.Fullname,
    cok.TXTVALUE,
	StarterPack.TXTVALUE,
	ADDONS.TXTVALUE,
	CampaignCodeUsed.TXTVALUE,
	MembershipFee.TXTVALUE,
	ContractDocumentation.TXTVALUE,
    com.TXTVALUE,
    company.TXTVALUE,
    osd.TXTVALUE,
    camps.CODE
ORDER BY
    salesperson.FULLNAME,
    ss.OWNER_ID

