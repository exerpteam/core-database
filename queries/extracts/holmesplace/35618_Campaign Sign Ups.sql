SELECT DISTINCT
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID                       AS "Member ID",
    owner.FULLNAME                                              AS "Full Name",
    prod.NAME                                                   AS "Membership",
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY')        AS "Creation Date",
    sc.NAME                                                     AS "Campaign Name"
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
JOIN
    PRIVILEGE_USAGES pu
ON
    pu.PERSON_ID = ss.OWNER_ID
JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
AND cc.CAMPAIGN_TYPE = 'STARTUP'
JOIN
    HP.STARTUP_CAMPAIGN sc
ON
    sc.ID = cc.CAMPAIGN_ID
WHERE
    cc.CODE = (:CampaignCode) 
    AND pu.PERSON_CENTER IN (:Scope)
    AND sub.CREATION_TIME >= $$CreationFrom$$
    AND prod.primary_product_group_id <> 1201
    AND prod.primary_product_group_id <> 2802
    AND prod.primary_product_group_id <> 6 