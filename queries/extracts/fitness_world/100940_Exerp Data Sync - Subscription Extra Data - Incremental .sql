-- This is the version from 2026-02-05
--  
WITH
    params AS materialized
    (
        SELECT
            datetolongC(TO_CHAR(CURRENT_DATE-5, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS FROMDATE,
            datetolongC(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS TODATE
    )
    ,
    subs AS
    (
        SELECT
            su.center,
            su.id ,
            su.owner_center,
            su.owner_id,
            su.state ,
            su.LAST_MODIFIED ,
            su.creation_time,
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID,
            np.external_id,
            su.end_date,
            SUM ( frz.END_DATE +1 - frz.START_DATE ) over (partition BY su.owner_center,
            su.owner_id)                                                           AS freeze_sums,
            MAX ( frz.START_DATE) over (partition BY su.owner_center, su.owner_id) AS
                                                                                LastFreezeStartDate,
            MAX ( frz.END_DATE) over (partition BY su.owner_center, su.owner_id)    AS LatestFreeze,
            MAX ( frz.LAST_MODIFIED) over (partition BY su.owner_center, su.owner_id) AS
            Freeze_Last_Modified
        FROM
            SUBSCRIPTIONS su
        JOIN
            persons p
        ON
            su.OWNER_CENTER = p.CENTER
        AND su.OWNER_ID = p.ID
        JOIN
            PERSONS np
        ON
            np.CENTER = p.CURRENT_PERSON_CENTER
        AND np.id = p.CURRENT_PERSON_ID
        LEFT JOIN
            SUBSCRIPTION_FREEZE_PERIOD frz
        ON
            frz.SUBSCRIPTION_CENTER = su.CENTER
        AND frz.SUBSCRIPTION_ID = su.ID
        AND frz.STATE = 'ACTIVE'
        WHERE
            su.owner_center IN (:scope)
        AND su.CREATION_TIME <dateToLong(TO_CHAR(CURRENT_DATE, 'YYYY-MM-dd HH24:MI'))
/*        AND su.center = 172
AND su.id IN(235641 ,
             235822)*/
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pg.ID = ppgl.PRODUCT_GROUP_ID
                WHERE
                    pg.EXCLUDE_FROM_MEMBER_COUNT = True
                AND ppgl.product_center = su.SUBSCRIPTIONTYPE_CENTER
                AND ppgl.product_id = su.SUBSCRIPTIONTYPE_ID)
    )
    --    select * from subs;
    ,
    boltons AS
    (
        SELECT
            su.*,
            COUNT(DISTINCT sa.id)    AS boltons,
            MAX ( sa.CREATION_TIME ) AS Boltons_Last_Created
        FROM
            subs AS su
        LEFT JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = su.CENTER
        AND sa.SUBSCRIPTION_ID = su.ID
        AND sa.CANCELLED = 0
        GROUP BY
            su.center,
            su.id ,
            su.owner_center,
            su.owner_id,
            su.state ,
            su.freeze_sums,
            su.LastFreezeStartDate,
            su.LatestFreeze,
            su.Freeze_Last_Modified,
            su.LAST_MODIFIED,
            su.creation_time,
            su.CURRENT_PERSON_CENTER,
            su.CURRENT_PERSON_ID,
            su.external_id,
            su.end_date
    )
    ,
    subs_bolton_frz AS
    (
        SELECT
            sa.*
        FROM
            params,
            boltons sa
        WHERE
            state = 2
        OR  (sa.Boltons_Last_Created >= PARAMS.FROMDATE
            AND sa.Boltons_Last_Created < PARAMS.TODATE)
        OR  ( sa.Freeze_Last_Modified >= PARAMS.FROMDATE
            AND sa.Freeze_Last_Modified < PARAMS.TODATE)
    )
    ,
    subs_prs AS
    (
        SELECT
            su.*,
            COUNT( distinct
                CASE
                    WHEN pr.CENTER IS NULL
                    THEN NULL
                    ELSE (pr.CENTER,pr.id,pr.SUBID)
                END ) AS num
        FROM
            subs_bolton_frz su
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = su.OWNER_CENTER
        AND ar.CUSTOMERID = su.OWNER_ID
        AND ar.AR_TYPE = 4
        LEFT JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
        AND pr.ID = ar.ID
        AND pr.STATE IN (3,4)
        AND pr.ENTRY_TIME > su.CREATION_TIME
        AND ( to_timestamp(pr.ENTRY_TIME/1000)::DATE < su.END_DATE
            OR  su.END_DATE IS NULL)
        GROUP BY
            su.center,
            su.id ,
            su.owner_center,
            su.owner_id,
            su.state ,
            su.freeze_sums,
            su.LastFreezeStartDate,
            su.LatestFreeze,
            su.Freeze_Last_Modified,
            su.LAST_MODIFIED,
            su.creation_time,
            su.boltons,
            su.boltons_last_created,
            su.CURRENT_PERSON_CENTER,
            su.CURRENT_PERSON_ID,
            su.external_id,
            su.end_date
    )
   
 --   select * from subs_prs;
SELECT DISTINCT
    EXTERNAL_ID                               AS "EXTERNALID",
    center||'ss'||id                          AS "SUBSCRIPTIONID",
    TO_CHAR(LastFreezeStartDate,'YYYY-MM-DD') AS "LASTFROZENSTARTDATE",
    TO_CHAR(LatestFreeze,'YYYY-MM-DD')        AS "LASTFROZENDAY",
    freeze_sums                                      AS "ACCUMULATEDFREEZEDAYS",
    CASE
        WHEN COALESCE(IOS_TIME,ANDROID_TIME) IS NOT NULL
        THEN 1
        ELSE 0
    END AS "APPUSER",
    CASE
        WHEN IOS_TIME IS NOT NULL
        THEN 1
        ELSE 0
    END AS "REGISTEREDIOS",
    CASE
        WHEN ANDROID_TIME IS NOT NULL
        THEN 1
        ELSE 0
    END             AS "REGISTEREDANDROID",
    COALESCE(num,0) AS "SUCCESSFULDDPAYMENTS",
    CASE COALESCE(boltons,0)
        WHEN 0
        THEN 0
        ELSE 1
    END                 AS "BOLTONS",
    COALESCE(ref_num,0) AS "COUNTOFREFERRALSMADE",
    (
        CASE
            WHEN (LAST_MODIFIED IS NULL
                AND Freeze_Last_Modified IS NULL
                AND Boltons_Last_Created IS NULL)
            THEN NULL
            ELSE TO_CHAR(longtodatetz(GREATEST(LAST_MODIFIED, Freeze_Last_Modified,
                Boltons_Last_Created),'Europe/Zurich'),'YYYY-MM-DD HH24:MI:SS')
        END) AS "LASTMODIFIEDDATE"
FROM
    (
        SELECT
            su.*,
            COUNT(DISTINCT
            CASE
                WHEN op.CENTER IS NULL
                THEN NULL
                ELSE (op.CENTER,op.ID)
            END) AS ref_num,
            MAX(
                CASE
                    WHEN pdt.PLATFORM = 'IOS'
                    THEN pdt.REGISTER_DATE_TIME
                    ELSE NULL
                END ) AS IOS_TIME,
            MAX(
                CASE
                    WHEN pdt.PLATFORM = 'ANDROID'
                    THEN pdt.REGISTER_DATE_TIME
                    ELSE NULL
                END ) AS ANDROID_TIME
        FROM
            subs_prs su
        LEFT JOIN
            PERSONS p
        ON
            p.CURRENT_PERSON_CENTER = su.CURRENT_PERSON_CENTER
        AND p.CURRENT_PERSON_ID = su.CURRENT_PERSON_ID
        LEFT JOIN
            RELATIVES r
        ON
            r.RELATIVECENTER = p.CENTER
        AND r.RELATIVEID = p.ID
        AND r.RTYPE = 13
        AND r.STATUS = 1
        LEFT JOIN
            PERSONS op
        ON
            op.CENTER = r.CENTER
        AND op.id = r.ID
        AND op.STATUS != 7
        LEFT JOIN
            PUSH_DEVICE_TOKENS pdt
        ON
            pdt.ENVIRONMENT = 'PROD'
        AND pdt.PERSON_CENTER = su.owner_center
        AND pdt.PERSON_ID = su.owner_id
        GROUP BY
            su.center,
            su.id ,
            su.owner_center,
            su.owner_id,
            su.state ,
            su.freeze_sums,
            su.LastFreezeStartDate,
            su.LatestFreeze,
            su.Freeze_Last_Modified,
            su.LAST_MODIFIED,
            su.creation_time,
            su.boltons,
            su.boltons_last_created,
            su.CURRENT_PERSON_CENTER,
            su.CURRENT_PERSON_ID,
            su.num,
            su.external_id,
            su.end_date) t