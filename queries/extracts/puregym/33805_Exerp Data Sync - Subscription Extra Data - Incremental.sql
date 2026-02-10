-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            datetolongC(TO_CHAR(CURRENT_DATE-5, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS FROMDATE,
            datetolongC(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS TODATE
    )
    ,
    V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER AS center,
            ppgl.PRODUCT_ID     AS id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
SELECT DISTINCT
    np.EXTERNAL_ID                                      AS "EXTERNALID",
     su.center||'ss'||su.id                              AS "SUBSCRIPTIONID",
     TO_CHAR(FrzPerMem.LastFreezeStartDate,'YYYY-MM-DD') AS "LASTFROZENSTARTDATE",
     TO_CHAR(FrzPerMem.LatestFreeze,'YYYY-MM-DD')        AS "LASTFROZENDAY",
     FrzPerMem.sums                                      AS "ACCUMULATEDFREEZEDAYS",
     CASE WHEN COALESCE(app.IOS_TIME,app.ANDROID_TIME) IS NOT NULL THEN 1 ELSE 0 END        AS "APPUSER",
     CASE WHEN app.IOS_TIME IS NOT NULL THEN 1 ELSE 0 END                              AS "REGISTEREDIOS",
     CASE WHEN app.ANDROID_TIME IS NOT NULL THEN 1 ELSE 0 END                          AS "REGISTEREDANDROID",
     COALESCE(suc_dd.num,0)                                   AS "SUCCESSFULDDPAYMENTS",
     CASE COALESCE(sa.boltons,0) WHEN 0 THEN 0 ELSE 1 END                     AS "BOLTONS",
     COALESCE(refs.num,0)                                     AS "COUNTOFREFERRALSMADE",
     (CASE
         WHEN (su.LAST_MODIFIED IS NULL AND FrzPerMem.Freeze_Last_Modified IS NULL AND sa.Boltons_Last_Created IS NULL) THEN
                 NULL
         ELSE
                    TO_CHAR(longtodatetz(GREATEST(su.LAST_MODIFIED, FrzPerMem.Freeze_Last_Modified, sa.Boltons_Last_Created),'Europe/London'),'YYYY-MM-DD HH24:MI:SS')
      END) AS "LASTMODIFIEDDATE"

FROM
    PERSONS p
JOIN
    PERSONS np
ON
    np.CENTER = p.CURRENT_PERSON_CENTER
AND np.id = p.CURRENT_PERSON_ID
JOIN
    SUBSCRIPTIONS su
ON
    su.OWNER_CENTER = p.CENTER
AND su.OWNER_ID = p.ID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = su.SUBSCRIPTIONTYPE_CENTER
AND st.id = su.SUBSCRIPTIONTYPE_ID
AND (
        ST.CENTER, ST.ID) NOT IN
    (
        SELECT
            center,
            id
        FROM
            V_EXCLUDED_SUBSCRIPTIONS)
CROSS JOIN
    PARAMS
LEFT JOIN
    /*this finds the supbscriptions the member has and sums their freeze sums*/
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            SUM(frz.freeze)               AS sums,
            MAX(frz.LastFreezeStartDate)  AS LastFreezeStartDate,
            MAX(frz.Lastfreeze)           AS LatestFreeze,
            MAX(frz.Freeze_Last_Modified) AS Freeze_Last_Modified
        FROM
            SUBSCRIPTIONS s
        JOIN
            (
                SELECT
                    sfp.SUBSCRIPTION_ID,
                    sfp.SUBSCRIPTION_CENTER,
                    SUM ( sfp.END_DATE +1 - sfp.START_DATE ) AS freeze,
                    MAX ( sfp.START_DATE)                    AS LastFreezeStartDate,
                    MAX ( sfp.END_DATE)                      AS Lastfreeze,
                    MAX ( LAST_MODIFIED)                     AS Freeze_Last_Modified
                FROM
                    SUBSCRIPTION_FREEZE_PERIOD sfp
                WHERE
                    sfp.STATE = 'ACTIVE'
                GROUP BY
                    sfp.SUBSCRIPTION_ID,
                    sfp.SUBSCRIPTION_CENTER ) frz
        ON
            frz.SUBSCRIPTION_CENTER = s.CENTER
        AND frz.SUBSCRIPTION_ID = s.ID
        GROUP BY
            s.OWNER_CENTER,
            s.OWNER_ID ) FrzPerMem
ON
    p.ID = FrzPerMem.OWNER_ID
AND p.CENTER = FrzPerMem.OWNER_CENTER
LEFT JOIN
    (
        SELECT
            t.PERSON_CENTER,
            t.PERSON_ID,
            MAX(
                CASE
                    WHEN t.PLATFORM = 'IOS'
                    THEN t.REGISTER_DATE_TIME
                    ELSE NULL
                END ) AS IOS_TIME,
            MAX(
                CASE
                    WHEN t.PLATFORM = 'ANDROID'
                    THEN t.REGISTER_DATE_TIME
                    ELSE NULL
                END ) AS ANDROID_TIME
        FROM
            (
                SELECT
                    PERSON_CENTER,
                    PERSON_ID,
                    PLATFORM,
                    REGISTER_DATE_TIME
                FROM
                    PUSH_DEVICE_TOKENS
                WHERE
                    ENVIRONMENT = 'PROD' ) t
        GROUP BY
            t.PERSON_CENTER,
            t.PERSON_ID ) app
ON
    app.PERSON_CENTER = p.CENTER
AND app.PERSON_ID = p.ID
LEFT JOIN
    (
        SELECT
            s.center,
            s.id,
            COUNT(DISTINCT pr.CENTER||'pr'||pr.id||'sub'||pr.SUBID) AS num
        FROM
            SUBSCRIPTIONS s
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER =  s.OWNER_CENTER
        AND ar.CUSTOMERID = s.OWNER_ID
        AND ar.AR_TYPE = 4
        JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
        AND pr.ID = ar.ID
        AND pr.STATE IN (3,4)
        AND pr.ENTRY_TIME > s.CREATION_TIME
        AND (
               to_timestamp(pr.ENTRY_TIME/1000)::date < s.END_DATE
            OR  s.END_DATE IS NULL)
           
        GROUP BY
            s.center,
            s.id ) suc_dd
ON
    su.CENTER = suc_dd.center
AND su.ID = suc_dd.ID
LEFT JOIN
    (
        SELECT
            sa.SUBSCRIPTION_CENTER,
            sa.SUBSCRIPTION_ID,
            COUNT(1)              AS boltons,
            MAX ( CREATION_TIME ) AS Boltons_Last_Created
        FROM
            SUBSCRIPTION_ADDON sa
        WHERE
            sa.CANCELLED = 0
        GROUP BY
            sa.SUBSCRIPTION_CENTER,
            sa.SUBSCRIPTION_ID ) sa
ON
    sa.SUBSCRIPTION_CENTER = su.CENTER
AND sa.SUBSCRIPTION_ID = su.ID
LEFT JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER             CENTER,
            p.CURRENT_PERSON_ID                 ID,
            COUNT(DISTINCT r.CENTER||'p'||r.ID) num
        FROM
            PERSONS p
        JOIN
            RELATIVES r
        ON
            r.RELATIVECENTER = p.CENTER
        AND r.RELATIVEID = p.ID
        AND r.RTYPE = 13
        AND r.STATUS = 1
        JOIN
            PERSONS op
        ON
            op.CENTER = r.CENTER
        AND op.id = r.ID
        AND op.STATUS != 7
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) refs
ON
    refs.CENTER = np.CENTER
AND refs.ID = np.ID

WHERE
    p.CENTER IN (:scope)
AND su.CREATION_TIME <dateToLong(TO_CHAR(CURRENT_DATE, 'YYYY-MM-dd HH24:MI'))
AND (
        su.STATE = 2
    OR  (
            FrzPerMem.Freeze_Last_Modified >= PARAMS.FROMDATE
        AND FrzPerMem.Freeze_Last_Modified < PARAMS.TODATE)
    OR  (
            sa.Boltons_Last_Created >= PARAMS.FROMDATE
        AND sa.Boltons_Last_Created < PARAMS.TODATE) )