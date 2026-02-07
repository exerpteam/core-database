SELECT DISTINCT
    np.EXTERNAL_ID                                                             AS "EXTERNALID",
    su.center||'ss'||su.id                                                     AS "SUBSCRIPTIONID",
    su.START_DATE                                                              AS "STARTDATE",
    su.END_DATE                                                                AS "ENDDATE",
    su.SUBSCRIPTIONTYPE_CENTER || 'prod' || su.SUBSCRIPTIONTYPE_ID             AS "PRODUCTID",	
    TO_CHAR(NVL(SPP.SUBSCRIPTION_PRICE, NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE))) AS "CURRENTPRICE",
    TO_CHAR(NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE))                              AS "NORMALPRICE",
    TO_CHAR(longtodate(su.CREATION_TIME) , 'YYYY-MM-DD')                       AS "MEMBERSIGNUPDATE",
    il.TOTAL_AMOUNT                                                            AS "PRICEJFEE",
    CASE
        WHEN il.TOTAL_AMOUNT < il.PRODUCT_NORMAL_PRICE
        THEN 1
        ELSE 0
    END                                                                        AS "DISCOUNTEDJFEE",
    DECODE(NVL(ss.PRICE_ADMIN_FEE,0),0,0,1)                                    AS "PAIDCHARITYDONATION", 
    DECODE (su.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS "STATE",
    DECODE (su.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS "SUBSTATE",
    DECODE(sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID,'ss',null,sc.NEW_SUBSCRIPTION_CENTER||'ss'||sc.NEW_SUBSCRIPTION_ID) AS "NEWSUBSCRIPTIONID",
    TO_CHAR(longtodatetz(su.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "LASTMODIFIEDDATE"		
FROM
    PUREGYM.PERSONS p
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
LEFT JOIN
    PUREGYM.SUBSCRIPTIONPERIODPARTS SPP
ON
    (
        SPP.CENTER = SU.CENTER
        AND SPP.ID = SU.ID
        AND SPP.FROM_DATE <= greatest(trunc(sysdate), su.start_date)
        AND (
            SPP.TO_DATE IS NULL
            OR SPP.TO_DATE >= greatest(trunc(sysdate), su.start_date) )
        AND SPP.SPP_STATE = 1
        AND SPP.ENTRY_TIME < exerpro.datetolong(to_char(trunc(sysdate+1), 'YYYY-MM-DD HH24:MI')) )
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE SP
ON
    (
        SP.SUBSCRIPTION_CENTER = SU.CENTER
        AND SP.SUBSCRIPTION_ID = SU.ID
        AND sp.CANCELLED = 0
        AND SP.FROM_DATE <= greatest(trunc(sysdate), su.start_date)
        AND (
            SP.TO_DATE IS NULL
            OR SP.TO_DATE >= greatest(trunc(sysdate), su.start_date) ) )	
LEFT JOIN
    PUREGYM.SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = su.CENTER
    AND sc.OLD_SUBSCRIPTION_ID = su.id
    AND sc.NEW_SUBSCRIPTION_CENTER IS NOT NULL
    AND TRUNC(sysdate) between trunc(sc.EFFECT_DATE) and TRUNC(NVL(exerpro.longtodate(sc.CANCEL_TIME), sysdate+1))
LEFT JOIN
    PUREGYM.INVOICELINES il
ON
    il.center = su.INVOICELINE_CENTER
    AND il.id = su.INVOICELINE_ID
    AND il.SUBID = su.INVOICELINE_SUBID
LEFT JOIN
    PUREGYM.SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = su.CENTER
    AND ss.SUBSCRIPTION_ID = su.ID
WHERE
    p.CENTER IN($$scope$$)
    AND su.LAST_MODIFIED >= $$fromdate$$
    AND su.LAST_MODIFIED < $$todate$$ + (86400 * 1000)   