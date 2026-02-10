-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    any_club_in_scope AS
    (
        SELECT id 
          FROM centers 
         WHERE id IN (:scope)
           AND rownum = 1
    )
    , params AS
    (
        SELECT
             
            /*+ materialize  */
            1 AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(sysdate)+1, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT DISTINCT
    np.EXTERNAL_ID                                      AS "EXTERNALID",
    su.center||'ss'||su.id                              AS "SUBSCRIPTIONID",
    TO_CHAR(FrzPerMem.LastFreezeStartDate,'YYYY-MM-DD') AS "LASTFROZENSTARTDATE",	
    TO_CHAR(FrzPerMem.LatestFreeze,'YYYY-MM-DD')        AS "LASTFROZENDAY",
    FrzPerMem.sums                                      AS "ACCUMULATEDFREEZEDAYS",	
    NVL2(NVL(app.IOS_TIME,app.ANDROID_TIME),1,0)        AS "APPUSER",
    NVL2(app.IOS_TIME,1,0)                              AS "REGISTEREDIOS",
    NVL2(app.ANDROID_TIME,1,0)                          AS "REGISTEREDANDROID",		
    NVL(suc_dd.num,0)                                   AS "SUCCESSFULDDPAYMENTS",
    DECODE(NVL(sa.boltons,0),0,0,1)                     AS "BOLTONS",
    NVL(refs.num,0)                                     AS "COUNTOFREFERRALSMADE",
    (CASE 
        WHEN (su.LAST_MODIFIED IS NULL AND FrzPerMem.Freeze_Last_Modified IS NULL AND sa.Boltons_Last_Created IS NULL) THEN
                NULL
        ELSE
                TO_CHAR(longtodatetz(GREATEST(su.LAST_MODIFIED, FrzPerMem.Freeze_Last_Modified, sa.Boltons_Last_Created),'Europe/London'),'YYYY-MM-DD HH24:MI:SS')
     END) AS "LASTMODIFIEDDATE"	
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
            PUREGYM.SUBSCRIPTIONS s
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
                    PUREGYM.SUBSCRIPTION_FREEZE_PERIOD sfp
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
        SELECT *
        FROM
        (
            SELECT
                PERSON_CENTER,
                PERSON_ID,
                PLATFORM,
                REGISTER_DATE_TIME
            FROM
                PUREGYM.PUSH_DEVICE_TOKENS
            WHERE ENVIRONMENT = 'PROD'
        )
        PIVOT
        (
            MAX(REGISTER_DATE_TIME)
            FOR PLATFORM IN ('IOS' as IOS_TIME, 'ANDROID' as ANDROID_TIME)
        )
    ) app
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
    (
        SELECT
            sa.SUBSCRIPTION_CENTER,
            sa.SUBSCRIPTION_ID,
            COUNT(1) AS boltons,
            MAX ( CREATION_TIME ) AS Boltons_Last_Created
        FROM
            PUREGYM.SUBSCRIPTION_ADDON sa
        WHERE sa.CANCELLED = 0
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
CROSS JOIN PARAMS
WHERE
    p.CENTER IN(:scope)
    and p.STATUS in (1,3)
    AND su.CREATION_TIME <dateToLong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'))
    AND su.STATE IN (2,4,8)
    AND (su.STATE = 2
         OR (FrzPerMem.Freeze_Last_Modified >= PARAMS.FROMDATE AND FrzPerMem.Freeze_Last_Modified < PARAMS.TODATE)
         OR (sa.Boltons_Last_Created >= PARAMS.FROMDATE AND sa.Boltons_Last_Created < PARAMS.TODATE)
        )