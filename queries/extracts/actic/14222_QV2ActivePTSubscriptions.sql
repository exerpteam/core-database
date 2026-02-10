-- The extract is extracted from Exerp on 2026-02-08
--  
/*
* TOTAL PT EFT SUBSCRIPTIONS BY DATE
*/
-- TODO
-- CHECK! Skapa script
-- CHECK! Automatisera
-- CHECK! Persontyp (historisk spelar mindre roll)
-- CHECK! ålder
-- Kvalitetssäkra
-- CHECK! Active on last day
-- CHECK! lägg till monthly price, 0 idag
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1) AS previousDayDate,
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS todayLongDate,
				c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    ----------------------------------------------------------------
    cen.COUNTRY AS "COUNTRY",
    cen.EXTERNAL_ID                         AS "COST",
    cen.ID                                  AS "CENTERID",
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS "PERSONID",
    /* TODO old persontype from Transfer.
    need to look in old pids state_change_log or persons table is easier
    CASE
    WHEN scl_ptype.STATEID IS NULL
    THEN
    END PersonType,
    */
    CAST(EXTRACT('year' FROM age(p.birthdate)) AS VARCHAR)         AS "AGE",
    p.SEX                                                          AS "GENDER",
    CASE  scl_ptype.STATEID  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 
    'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS "PERSONTYPE",
    -- DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'
    -- ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS
    -- Current_PTYPE,
    /*
    CASE
    WHEN scl_ptype.STATEID = p.PERSONTYPE
    THEN 'TRUE'
    ELSE 'FALSE'
    END MATCH_PTYPE,
    */
    company.LASTNAME AS "COMPANY_NAME",
    CA.NAME          AS "AGREEMENT_NAME",
    0                AS "JOININGFEE",
    -- sub.BINDING_PRICE AS MONTHLY_PRICE, -- price at sales date, don't reflect pricechange i.e
    -- campaigns
    -- sp.PRICE AS Monthly_Price, -- is null if there is no price changes
    CASE
        WHEN sp.PRICE IS NULL
        THEN sub.BINDING_PRICE
        ELSE sp.PRICE
    END Monthly_Price,
    CASE
        WHEN sp.TYPE IS NULL
        THEN 'BINDING PRICE'
        ELSE sp.TYPE
    END Price_Type,
    -- sp.TYPE AS Price_Type,
    sub.CENTER || 'ss' || sub.ID                                                  AS SubscriptionId,
    CASE  sub.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS
    subscription_STATE,
    CASE  sub.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 
    'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS
                                                         SUBSCRIPTION_SUB_STATE,
    CASE st.ST_TYPE  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  ELSE 'UKNOWN' END AS PaymentType,
    -- TO_CHAR(longToDate(sub.CREATION_TIME), 'YYYY-MM-DD') AS Sales_Date,
    -- TO_CHAR(sub.START_DATE, 'YYYY-MM-DD')    AS start_DATE,
    -- TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD')  AS binding_END_DATE,
    -- TO_CHAR(sub.END_DATE, 'YYYY-MM-DD')    AS end_DATE,
    longToDate(sub.CREATION_TIME) AS sales_date,
    sub.START_DATE                AS start_date,
    sub.BINDING_END_DATE          AS bindning_END_DATE,
    sub.END_DATE                  AS end_date,
    -- sub.BINDING_PRICE,
    -------------------------------------------
    -- CASE
    --  WHEN ss.SUBSCRIPTION_TYPE_TYPE = 0 THEN ceil(( ss.PRICE_PERIOD /( ( ss.END_DATE -
    -- ss.START_DATE)-2) )*30) -- cash pr month
    --  WHEN ss.SUBSCRIPTION_TYPE_TYPE = 1 THEN ss.PRICE_PERIOD
    -- END   AS MonthlyPrice,
    prod.NAME     AS Product_Name,
    prod.GLOBALID AS Global_Id
FROM
    SUBSCRIPTIONS sub
JOIN PARAMS params ON params.CenterID = sub.CENTER
LEFT JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = sub.CENTER
AND sp.SUBSCRIPTION_ID = sub.ID
    -- make sure we join the price from actual date
AND sp.FROM_DATE <= params.previousDayDate -- Date,
AND (
        sp.TO_DATE IS NULL
    OR  sp.TO_DATE >= params.previousDayDate) -- Date
AND sp.CANCELLED != 1
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
AND st.ID = sub.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PRODUCTS prod
ON
    st.CENTER = prod.CENTER
AND st.ID = prod.ID
LEFT JOIN
    CENTERS cen
ON
    sub.OWNER_CENTER = cen.ID
LEFT JOIN
    PERSONS p
ON
    sub.OWNER_CENTER = p.CENTER
AND sub.OWNER_ID = p.ID
    -----------------------------------------------------------------
    -- persontype at the time choosen
    -- added by MB
LEFT JOIN
    STATE_CHANGE_LOG scl_ptype
ON
    sub.OWNER_CENTER = scl_ptype.CENTER
AND sub.OWNER_ID = scl_ptype.ID
AND scl_ptype.ENTRY_TYPE = 3
AND scl_ptype.ENTRY_START_TIME < params.todayLongDate -- Date
AND (
        scl_ptype.ENTRY_END_TIME IS NULL
    OR  scl_ptype.ENTRY_END_TIME > params.todayLongDate)
    -----------------------------------------------------------------
    -- persons linked to company and agreement at the time choosen
    -- added by MB
LEFT JOIN
    (
        SELECT
            scl_rel.CENTER,
            scl_rel.ID,
            scl_rel.ENTRY_START_TIME,
            scl_rel.ENTRY_END_TIME,
            companyAgrRel.RELATIVECENTER,
            companyAgrRel.RELATIVEID,
            companyAgrRel.RELATIVESUBID
        FROM
            STATE_CHANGE_LOG scl_rel
        INNER JOIN
            RELATIVES companyAgrRel
        ON
            scl_rel.CENTER = companyAgrRel.CENTER
        AND scl_rel.ID = companyAgrRel.ID
        AND scl_rel.SUBID = companyAgrRel.SUBID
        AND companyAgrRel.RTYPE = 3
        WHERE
            scl_rel.ENTRY_TYPE = 4
        AND scl_rel.STATEID != 3 ) compRel
ON
    compRel.CENTER = sub.OWNER_CENTER
AND compRel.ID= sub.OWNER_ID
AND compRel.ENTRY_START_TIME < params.todayLongDate -- Date
AND (
        compRel.ENTRY_END_TIME IS NULL
    OR  compRel.ENTRY_END_TIME > params.todayLongDate)
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = compRel.RELATIVECENTER
AND ca.ID = compRel.RELATIVEID
AND ca.SUBID = compRel.RELATIVESUBID
LEFT JOIN
    PERSONS company
ON
    company.CENTER = ca.CENTER
AND company.ID = ca.id
AND company.sex = 'C'
    -----------------------------------------------------------------
WHERE
    sub.OWNER_CENTER IN (:Scope)
AND sub.START_DATE <= params.previousDayDate -- Date
AND (
        sub.END_DATE IS NULL
    OR  sub.END_DATE >= params.previousDayDate) -- Date
AND sub.CREATION_TIME < params.todayLongDate -- make sure we dont include sales with start
    -- date in past
    -- AND scl_ptype.STATEID != 2 -- exclude staff
AND prod.PRIMARY_PRODUCT_GROUP_ID IN (1224,
                                      1227,
                                      1824,
                                      2224,
                                      2225,
                                      2226,
                                      6624,
                                      6625,
                                      6626,
                                      10224,
                                      10225,
                                      10226,
                                      10825,
                                      3224,
                                      3625,
                                      5224,
                                      5227)
    -- Product groups
    -- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions,
    -- 219+221 = CASH campaign subscriptions
    -- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded, 1224, 1227, 1824, 2224-2226 =
    -- Personal Training
