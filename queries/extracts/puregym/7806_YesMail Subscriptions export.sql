/*WITH
params AS
(
SELECT
--  TRUNC(SYSDATE-2 ,'DDD')                                                        p_date,
datetolongTZ(TO_CHAR(SYSDATE+1 ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
FROM
dual
)*/
SELECT DISTINCT
    np.EXTERNAL_ID         AS "External ID",
    su.center||'ss'||su.id AS "Subscription ID",
    su.START_DATE,
    su.END_DATE,
    pr.NAME                           AS "subscription name",
    NVL(suc_dd.num,0)                 AS "successful DD payments",
    DECODE(sa.CANCELLED,0,'Yes','No') AS "Boltons",
    il.TOTAL_AMOUNT                   AS "Price Jfee",
    CASE
        WHEN il.TOTAL_AMOUNT < il.PRODUCT_NORMAL_PRICE
        THEN 'Yes'
        ELSE 'No'
    END                                                                                                                                                                      AS "Discounted JFee",
    NVL(refs.num,0)                                                                                                                                                          AS "Count of referrals made",
    DECODE(ss.PRICE_ADMIN_FEE,NULL,'no',0,'No','yes')                                                                                                                        AS "Paid Charity donation",
    DECODE (su.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                                  AS STATE,
    DECODE (su.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS SUB_STATE,
    DECODE(sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID,'ss',null,sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID) as NEW_SUBSCRIPTION_ID
FROM
    PUREGYM.PERSONS p
    /* Check-ins */
JOIN
    PUREGYM.PERSONS np
ON
    np.CENTER = p.CURRENT_PERSON_CENTER
    AND np.id = p.CURRENT_PERSON_ID
JOIN
    PUREGYM.SUBSCRIPTIONS su
ON
    su.OWNER_CENTER = p.CENTER
    AND su.OWNER_ID = p.ID
JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    st.CENTER = su.SUBSCRIPTIONTYPE_CENTER
    AND st.id = su.SUBSCRIPTIONTYPE_ID
    AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = su.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = su.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PUREGYM.SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = su.CENTER
    AND sc.OLD_SUBSCRIPTION_ID = su.id
    AND sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
LEFT JOIN
    (
        SELECT
            s.center,
            s.id,
            COUNT(DISTINCT pr.CENTER||'pr'||pr.id||'sub'||pr.SUBID) AS num
        FROM
            PUREGYM.PERSONS p
        JOIN
            PUREGYM.SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
        JOIN
            PUREGYM.ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.center
            AND ar.CUSTOMERID = p.id
            AND ar.AR_TYPE = 4
        JOIN
            PUREGYM.PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
            AND pr.ID = ar.ID
            AND pr.STATE IN (3,4)
            AND pr.ENTRY_TIME > s.CREATION_TIME
            AND (
                longtodate(pr.ENTRY_TIME) < s.END_DATE
                OR s.END_DATE IS NULL)
        GROUP BY
            s.center,
            s.id ) suc_dd
ON
    su.CENTER = suc_dd.center
    AND su.ID = suc_dd.ID
LEFT JOIN
    PUREGYM.SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = su.CENTER
    AND sa.SUBSCRIPTION_ID = su.ID
LEFT JOIN
    PUREGYM.INVOICELINES il
ON
    il.center = su.INVOICELINE_CENTER
    AND il.id = su.INVOICELINE_ID
    AND il.SUBID = su.INVOICELINE_SUBID
LEFT JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER             CENTER,
            p.CURRENT_PERSON_ID                 ID,
            COUNT(DISTINCT r.CENTER||'p'||r.ID) num
        FROM
            PUREGYM.PERSONS p
        JOIN
            PUREGYM.RELATIVES r
        ON
            r.RELATIVECENTER = p.CENTER
            AND r.RELATIVEID = p.ID
            AND r.RTYPE = 13
            AND r.STATUS = 1
        JOIN
            PUREGYM.PERSONS op
        ON
            op.CENTER = r.CENTER
            AND op.id = r.ID
            AND op.STATUS NOT IN (7)
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) refs
ON
    refs.CENTER = np.CENTER
    AND refs.ID = np.ID
LEFT JOIN
    PUREGYM.SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = su.CENTER
    AND ss.SUBSCRIPTION_ID = su.ID
WHERE
    /*SCL1.BOOK_START_TIME < params.p_start_next_day
    AND (
    SCL1.BOOK_END_TIME IS NULL
    OR SCL1.BOOK_END_TIME >= params.p_start_next_day )
    AND SCL1.ENTRY_START_TIME < params.p_start_next_day*/
    p.CENTER IN($$scope$$)
    AND su.STATE !=5
    AND su.CREATION_TIME <dateToLong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'))