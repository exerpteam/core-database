SELECT
    /* Integer */
    p.CENTER "Club",
    /* bigint */
    pruRef.TXTVALUE "EntityNumber",
    /* varchar(20) */
    p.EXTERNAL_ID "ExerpMemberID",
    /* varchar(20) */
    con.OLDENTITYID "LegacyMemberID",
    CASE
        WHEN invl.TOTAL_AMOUNT > s.BINDING_PRICE
        THEN
            /* The initial payment spans > one month */
            ROUND(invl.TOTAL_AMOUNT - (s.BINDING_PRICE),2)
        ELSE invl.TOTAL_AMOUNT
    END AS ProRata1,
    CASE
        WHEN invl.TOTAL_AMOUNT > s.BINDING_PRICE
        THEN
            /* The initial payment spans > one month */
            s.BINDING_PRICE
        ELSE 0
    END AS ProRata2,
    s.BINDING_PRICE "Amount",
    p.FIRST_ACTIVE_START_DATE "JoinDate",
    s.START_DATE "ContractStart",
    s.BINDING_END_DATE "EarliestEnd",
    NVL(ss.PRICE_NEW,0) + NVL(ss.PRICE_ADMIN_FEE,0) "ActivateFee",
    ROUND((1 - (DECODE(prod.PRICE,0,1,prod.PRICE) / DECODE(s.BINDING_PRICE,0,1,s.BINDING_PRICE)))*100,2) "Discount",
    '?' "PlanType",
    '?' "AuthCode",
    '?' "ErrorCode",
    '?' "ErrorDescription",
    '?' "EmployerName",
    '?' "EmployerNo",
    '?' "DataProtect",
    '?' "TandCagree",
    '?' "DateVABilled"
FROM
    SUBSCRIPTIONS s
JOIN SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.CENTER
    AND ss.SUBSCRIPTION_ID = s.ID
JOIN SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
    AND spp.SPP_TYPE = 8
    AND spp.SPP_STATE= 1
LEFT JOIN SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
LEFT JOIN INVOICELINES invl
ON
    invl.CENTER = link.INVOICELINE_CENTER
    AND invl.ID = link.INVOICELINE_ID
    AND invl.SUBID = link.INVOICELINE_SUBID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN PERSONS oldP
ON
    oldP.CENTER = s.OWNER_CENTER
    AND oldP.ID = s.OWNER_ID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
JOIN PERSONS allOld
ON
    allOld.CURRENT_PERSON_CENTER = p.CENTER
    AND allOld.CURRENT_PERSON_ID = p.ID
    /* Might be that I can use old person id ext att for this */
LEFT JOIN CONVERTER_ENTITY_STATE con
ON
    con.NEWENTITYCENTER = allOld.CENTER
    AND con.NEWENTITYID = allOld.ID
    AND con.WRITERNAME = 'ClubLeadPersonWriter'
LEFT JOIN PERSON_EXT_ATTRS pruRef
ON
    pruRef.PERSONCENTER = p.CENTER
    AND pruRef.PERSONID = p.ID
    AND pruRef.NAME = 'NEEDS TO BE REPLACE'
WHERE
    s.CREATION_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(sysdate-1,'DD'),'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC(sysdate,'DD'),'YYYY-MM-dd HH24:MI'))
    /*s.CREATION_TIME BETWEEN 1407967200000 AND 1408053600000*/
