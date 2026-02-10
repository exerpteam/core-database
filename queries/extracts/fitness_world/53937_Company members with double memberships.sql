-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8785
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize  */
            $$FromDate$$                                                                           AS FROM_DATE,
            $$ToDate$$+1                                                                         AS TO_DATE,
            datetolongTZ(TO_CHAR(TRUNC($$FromDate$$), 'YYYY-MM-DD HH24:MI'),'Europe/Copenhagen')   AS FROM_DATE_LONG,
            datetolongTZ(TO_CHAR(TRUNC($$ToDate$$+1), 'YYYY-MM-DD HH24:MI'),'Europe/Copenhagen') AS TO_DATE_LONG
        FROM
            DUAL
    )
    ,
    ELIGIBLE AS
    (
        SELECT DISTINCT
            s.OWNER_CENTER,
            s.OWNER_ID,
            s.CENTER,
            s.ID
        FROM
            (
                SELECT DISTINCT
                    p.CENTER,
                    p.ID
                FROM
                    PERSONS p
                CROSS JOIN
                    PARAMS
                JOIN
                    STATE_CHANGE_LOG scl
                ON
                    p.CENTER = scl.CENTER
                    AND p.ID = scl.ID
                    AND scl.ENTRY_TYPE = 3
                    AND scl.STATEID = 4
                WHERE
                    p.CENTER IN ($$Scope$$)
                    AND ( (
                            scl.ENTRY_START_TIME < PARAMS.TO_DATE_LONG
                            AND scl.ENTRY_END_TIME > PARAMS.FROM_DATE_LONG)
                        OR (
                            scl.ENTRY_START_TIME < PARAMS.TO_DATE_LONG
                            AND scl.ENTRY_END_TIME IS NULL) ) ) corp
        CROSS JOIN
            PARAMS
        JOIN
            SUBSCRIPTIONS s
        ON
            corp.CENTER = s.OWNER_CENTER
            AND corp.ID = s.OWNER_ID
        JOIN
            STATE_CHANGE_LOG scls
        ON
            scls.CENTER = s.CENTER
            AND scls.ID = s.ID
            AND scls.ENTRY_TYPE = 2
            AND scls.STATEID IN (2,4)
        WHERE
            ( (
                    scls.ENTRY_START_TIME < PARAMS.TO_DATE_LONG
                    AND scls.ENTRY_END_TIME > PARAMS.FROM_DATE_LONG)
                OR (
                    scls.ENTRY_START_TIME < PARAMS.TO_DATE_LONG
                    AND scls.ENTRY_END_TIME IS NULL) )
    )
    ,
    ELIGIBLE_ROW AS
    (
        SELECT
            e.*,
            ROW_NUMBER() OVER (ORDER BY e.OWNER_CENTER,e.OWNER_ID) AS ROW_NUMBER
        FROM
            ELIGIBLE e
    )
    ,
    V_SUB AS
    (
        SELECT
            e1.OWNER_CENTER,
            e1.OWNER_ID,
            e1.OWNER_CENTER || 'p' || e1.OWNER_ID AS MemberID,
            e1.CENTER                             AS Sub1Center,
            e1.id                                 AS Sub1Id,
            e2.CENTER                             AS Sub2Center,
            e2.id                                 AS Sub2Id,
            e1.CENTER || 'ss' || e1.ID            AS SubscriptionId1,
            e2.CENTER || 'ss' || e2.ID            AS SubscriptionId2,
            s1.START_DATE                         AS sub1_startdate,
            s1.END_DATE                           AS sub1_enddate,
            s2.START_DATE                         AS sub2_startdate,
            s2.END_DATE                           AS sub2_enddate,
            s1.subscription_price                 AS sub1_price,
            s2.subscription_price                 AS sub2_price,
            CASE
                WHEN s1.START_DATE >= s2.START_DATE
                THEN s1.START_DATE
                ELSE s2.START_DATE
            END AS periodStart ,
            CASE
                WHEN s1.END_DATE >= s2.END_DATE
                THEN s2.END_DATE
                ELSE s1.END_DATE
            END AS periodEnd
        FROM
            ELIGIBLE_ROW e1
        JOIN
            ELIGIBLE_ROW e2
        ON
            e1.OWNER_CENTER = e2.OWNER_CENTER
            AND e1.OWNER_ID = e2.OWNER_ID
        JOIN
            SUBSCRIPTIONS s1
        ON
            s1.CENTER = e1.CENTER
            AND s1.ID = e1.ID
        JOIN
            SUBSCRIPTIONS s2
        ON
            s2.CENTER = e2.CENTER
            AND s2.ID = e2.ID
        WHERE
            e1.ROW_NUMBER != e2.ROW_NUMBER
            AND e1.ROW_NUMBER < e2.ROW_NUMBER --- TO NOT GET DUPLICATES
            AND ( (
                    s1.END_DATE IS NULL
                    AND s2.END_DATE IS NULL)
                OR (
                    s1.END_DATE IS NULL
                    AND s2.END_DATE IS NOT NULL
                    AND s2.END_DATE > s1.START_DATE)
                OR (
                    s2.END_DATE IS NULL
                    AND s1.END_DATE IS NOT NULL
                    AND s1.END_DATE > s2.START_DATE)
                OR (
                    s1.END_DATE IS NOT NULL
                    AND s2.END_DATE IS NOT NULL
                    AND s1.START_DATE < s2.END_DATE
                    AND s1.END_DATE > s2.START_DATE)
                OR (
                    s2.END_DATE IS NOT NULL
                    AND s1.END_DATE IS NOT NULL
                    AND s2.START_DATE < s1.END_DATE
                    AND s2.END_DATE > s1.START_DATE) )
    )
    ,
    v_sub_period_part AS
    (
        SELECT
            s.periodStart                                                                                           AS overlapPeriodStart,
            s.periodEnd                                                                                             AS overlapPeriodEnd,
            (s.periodEnd-s.periodStart)+1                                                                           AS overlapdaysInTotal,
            (spp1.to_date-spp1.from_date)+1                                                                         AS numberOfDays,
            NVL(ROUND((spp1.subscription_price+NVL(spp1.addons_price, 0))/((spp1.to_date-spp1.from_date)+1), 2), 0) AS dailyPrice,
            (LEAST(spp1.to_date, s.periodEnd) - GREATEST(spp1.from_date, s.periodStart)) +1                         AS overlapdays,
            spp1.from_date,
            spp1.to_date,
            spp1.subscription_price,
            spp1.addons_price,
            spp1.center,
            spp1.id
        FROM
            V_SUB s
        JOIN
            SUBSCRIPTIONPERIODPARTS spp1
        ON
            ((
                    s.Sub1Center = spp1.CENTER
                    AND s.Sub1ID = spp1.ID
                    AND spp1.from_date <= s.periodEnd
                    AND spp1.to_date >= s.periodStart)
                OR (
                    s.Sub2Center = spp1.CENTER
                    AND s.Sub2ID = spp1.ID
                    AND spp1.from_date <= s.periodEnd
                    AND spp1.to_date >= s.periodStart))
            AND SPP1.SPP_STATE = 1
    )
    --SELECT     *  FROM     v_sub_period_part;
    ,
    v_sub_period_part_price AS
    (
        SELECT
            center                                AS subcenter,
            id                                    AS subid,
            ROUND(SUM(dailyPrice*overlapdays), 2) AS overlapPrice
        FROM
            v_sub_period_part
        GROUP BY
            center,
            id
    )
    --SELECT     * FROM     v_sub_period_part_price;
    ,
    v_overlap_sub AS
    (
        SELECT
            sub.OWNER_CENTER,
            sub.OWNER_ID,
            sub.MemberID,
            sub.periodStart AS overlapPeriodStart,
            sub.periodEnd   AS overlapPeriodEnd,
            subpart.overlapPrice,
            subpart.subcenter,
            subpart.subid
        FROM
            V_SUB sub
        JOIN
            v_sub_period_part_price subpart
        ON
            (
                subpart.subcenter = sub.Sub1Center
                AND subpart.subid = sub.Sub1Id )
            OR (
                subpart.subcenter = sub.Sub2Center
                AND subpart.subid = sub.Sub2Id )
    )
    ,
    v_sub_mem AS
    (
        SELECT
            sub.MemberID AS PersonId,
            comp.fullname ,
            prod.name AS productName,
            sub.overlapPeriodStart,
            sub.overlapPeriodEnd,
            sub.overlapPrice,
            sub.subcenter,
            sub.subid
        FROM
            v_overlap_sub sub
        JOIN
            RELATIVES r
        ON
            sub.OWNER_CENTER = r.CENTER
            AND sub.OWNER_ID = r.ID
            AND r.RTYPE = 3
            AND r.STATUS < 2
        JOIN
            PERSONS comp
        ON
            comp.CENTER = r.RELATIVECENTER
            AND comp.ID = r.RELATIVEID
        JOIN
            subscriptions s
        ON
            s.center = sub.subcenter
            AND s.id = sub.subid
        JOIN
            products prod
        ON
            prod.center = s.subscriptiontype_center
            AND prod.id = s.subscriptiontype_id
    )
    ,
    v_pivot AS
    (
        SELECT
            sub.* ,
            LEAD(sub.productName,0) OVER (PARTITION BY PersonId, overlapPeriodStart, overlapPeriodEnd ORDER BY PersonId)  AS productName1 ,
            LEAD(sub.overlapPrice,0) OVER (PARTITION BY PersonId, overlapPeriodStart, overlapPeriodEnd ORDER BY PersonId) AS price1 ,
            LEAD(sub.productName,1) OVER (PARTITION BY PersonId, overlapPeriodStart, overlapPeriodEnd ORDER BY PersonId)  AS productName2 ,
            LEAD(sub.overlapPrice,1) OVER (PARTITION BY PersonId, overlapPeriodStart, overlapPeriodEnd ORDER BY PersonId) AS price2 ,
            ROW_NUMBER() OVER (PARTITION BY PersonId, overlapPeriodStart, overlapPeriodEnd ORDER BY PersonId)             AS ADDONSEQ
        FROM
            v_sub_mem sub
    )
SELECT
    PersonId                                  AS "Member Id",
    fullname                                  AS "Companay Name",
    productName1                              AS "Membership 1 Name",
    productName2                              AS "Membership 2 Name",
    TO_CHAR(overlapPeriodStart, 'YYYY-MM-DD') AS "From Date Double Subscription" ,
    TO_CHAR(overlapPeriodEnd, 'YYYY-MM-DD')   AS "To Date Double Subscription" ,
    price1                                    AS "Sub 1 invoice in double period",
    price2                                    AS "Sub 2 invoice in double period"
FROM
    v_pivot
WHERE
    ADDONSEQ=1