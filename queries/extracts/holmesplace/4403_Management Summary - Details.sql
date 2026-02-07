SELECT
    personcenter,
    personId,
    memberId,
    country,
    shortname,
    openstate opening,
    CASE
        WHEN SUM(lead_active) > 0
            AND SUM(lead_active) + ((SUM(inactive_active) + SUM(inactive_tmp)) - (SUM(active_inactive) + SUM
            (tmp_inactive))) > 0
        THEN 1
        ELSE 0
    END joiner,
    CASE
        WHEN (SUM(inactive_active) + SUM(inactive_tmp)) > 0
            AND (SUM(inactive_active) + SUM(inactive_tmp)) - SUM(lead_active) + (SUM(active_inactive) + SUM
            (tmp_inactive)) >= 0
        THEN 1
        ELSE 0
    END rejoiner,
    CASE
        WHEN (SUM(active_inactive) + SUM(tmp_inactive)) < 0
            AND (SUM(active_inactive) + SUM(tmp_inactive)) + (SUM(inactive_active) + SUM(inactive_tmp)) + SUM
            (lead_active) <= 0
        THEN -1
        ELSE 0
    END leaver,
    --            SUM(lead_active) joiners,
    --            SUM(active_inactive) + SUM(tmp_inactive) leavers,
    --            SUM(inactive_active) + SUM(inactive_tmp) rejoiners,
    SUM(transf_active)+ SUM(active_transf) transfers,
    (openstate + SUM(lead_active) + SUM(active_inactive) + SUM(tmp_inactive) + SUM(inactive_active) + SUM (inactive_tmp
    ) + SUM(transf_active ) + SUM(active_transf) - closestate) * -1 OTHER,
    closestate closing,
            :FromDate,
            :ToDate,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NOT NULL
            AND closestate > 0
        THEN -1
        ELSE 0
    END DEBTOR,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NULL
            AND closestate > 0
            AND FREESUBS.LATESTART > 0
            AND FREESUBS.FROZEN <= 0
            AND FREESUBS.COMPLIMENTARY <= 0
            AND (BIRTHDATE is null or floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) >= 16)
            AND ( FREESUBS.FREEDAYS <= 0
                OR FREESUBS.futurePriceIncrease <= 0)
        THEN -1
        ELSE 0
    END LATESTART,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NULL
            AND closestate > 0
            AND FREESUBS.LATESTART <= 0
            AND FREESUBS.FROZEN > 0
            AND FREESUBS.COMPLIMENTARY <= 0
            AND (BIRTHDATE is null or floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) >= 16)
            AND ( FREESUBS.FREEDAYS <= 0
                OR FREESUBS.futurePriceIncrease <= 0)
        THEN -1
        ELSE 0
    END FROZEN,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NULL
            AND closestate > 0
            AND FREESUBS.LATESTART <= 0
            AND FREESUBS.FROZEN <= 0
            AND FREESUBS.COMPLIMENTARY <= 0
            AND (BIRTHDATE is null or floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) >= 16)
            AND ( FREESUBS.FREEDAYS > 0
                OR FREESUBS.futurePriceIncrease > 0)
        THEN -1
        ELSE 0
    END EXTRAS,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NULL
            AND closestate > 0
            AND FREESUBS.LATESTART <= 0
            AND FREESUBS.FROZEN <= 0
            AND FREESUBS.COMPLIMENTARY > 0
            AND (BIRTHDATE is null or floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) >= 16)
            AND ( FREESUBS.FREEDAYS <= 0
                OR FREESUBS.futurePriceIncrease <= 0)
        THEN -1
        ELSE 0
    END COMPS,
    CASE
        WHEN DEBTORS.CUSTOMERCENTER IS NULL
            AND closestate > 0
            AND FREESUBS.LATESTART <= 0
            AND FREESUBS.FROZEN <= 0
            AND FREESUBS.COMPLIMENTARY <= 0
            AND BIRTHDATE is not null AND floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) < 16
            AND ( FREESUBS.FREEDAYS <= 0
                OR FREESUBS.futurePriceIncrease <= 0)
        THEN -1
        ELSE 0
    END KIDS
    --            CASE
    --                WHEN closestate > 0
    --                    AND DEBTORS.CUSTOMERCENTER IS NULL
    --                    AND NVL(FREESUBS.LATESTART, 0) < 0
    --                    AND FREESUBS.FROZEN < 0
    --                    AND FREESUBS.COMPLIMENTARY < 0
    --                    AND floor(months_between(longtodate(:ToDate + (1000*60*60*24)), BIRTHDATE) / 12) >
    -- = 16
    --                    AND FREESUBS.FREEDAYS < 0
    --                    AND FREESUBS.futurePriceIncrease < 0
    --                THEN 1
    --                ELSE 0
    --            END LIVE
    --ROUND(((SUM(active_inactive) + SUM(active_transf)) / SUM(openstate)) * 100 , 2) attrition,
    --100 + ROUND(((SUM(active_inactive) + SUM(active_transf)) / SUM(openstate)) * 100 , 2) retention,
    --ROUND((SUM(lead_active) + SUM(inactive_active)) / SUM(openstate) * 100 , 2) JOINERS,
    --ROUND(SUM(closestate)/ SUM(openstate) * 100,2 ) CLOSING
    --sum(UNBROKEN_MEM_DAYS),
    --sum(TOTAL_MEM_DAYS)
FROM
    (
        SELECT
            p.CENTER personCenter,
            p.ID personId,
            center.WEB_NAME SHORTNAME,
            center.COUNTRY,
            p.CENTER || 'p' || p.ID memberId,
            p.FIRST_ACTIVE_START_DATE,
            p.LAST_ACTIVE_START_DATE,
            p.LAST_ACTIVE_END_DATE,
            p.BIRTHDATE,
            CASE
                WHEN p.LAST_ACTIVE_END_DATE IS NULL
                THEN TRUNC(to_date('2013-10-01', 'YYYY-MM-DD') - p.LAST_ACTIVE_START_DATE) + 1
                ELSE p.MEMBERDAYS
            END UNBROKEN_MEM_DAYS,
            CASE
                WHEN p.LAST_ACTIVE_END_DATE IS NULL
                THEN TRUNC(to_date('2013-10-01', 'YYYY-MM-DD') - p.LAST_ACTIVE_START_DATE) + 1 +
                    p.ACCUMULATED_MEMBERDAYS
                ELSE p.MEMBERDAYS + p.ACCUMULATED_MEMBERDAYS
            END TOTAL_MEM_DAYS,
            CASE
                WHEN scl_open.CENTER IS NOT NULL
                    AND scl_open.BOOK_START_TIME <= :FromDate
                    AND scl_open.STATEID IN (1,3)
                THEN 1
                ELSE 0
            END openstate,
            CASE
                WHEN scl_period_from.STATEID = 0
                    AND scl_period_next.STATEID IN (1,3)
                THEN 1
                ELSE 0
            END lead_active,
            CASE
                WHEN scl_period_from.STATEID = 1
                    AND scl_period_next.STATEID = 2
                THEN -1
                ELSE 0
            END active_inactive,
            CASE
                WHEN scl_period_from.STATEID = 2
                    AND scl_period_next.STATEID = 1
                THEN 1
                ELSE 0
            END inactive_active,
            CASE
                WHEN scl_period_from.STATEID = 2
                    AND scl_period_next.STATEID = 3
                THEN 1
                ELSE 0
            END inactive_tmp,
            CASE
                WHEN scl_period_from.STATEID = 3
                    AND scl_period_next.STATEID = 2
                THEN -1
                ELSE 0
            END tmp_inactive,
            CASE
                WHEN scl_period_from.STATEID = 1
                    AND scl_period_next.STATEID = 5
                THEN -1
                ELSE 0
            END active_dupl,
            CASE
                WHEN scl_period_from.STATEID = 4
                    AND scl_period_next.STATEID = 1
                THEN 1
                ELSE 0
            END transf_active,
            CASE
                WHEN scl_period_from.STATEID = 1
                    AND scl_period_next.STATEID = 4
                THEN -1
                ELSE 0
            END active_transf,
            CASE
                WHEN scl_close.CENTER IS NOT NULL
                    AND scl_close.STATEID IN (1,3)
                THEN 1
                ELSE 0
            END closestate
            --            longtodate(scl_period_from.ENTRY_START_TIME) entryStart,
            --            longtodate(scl_period_next.ENTRY_START_TIME) entryend,
            --            longtodate(scl_period_from.BOOK_START_TIME) bookStart,
            --            longtodate(scl_period_next.BOOK_START_TIME) bookend
            --            DECODE(scl_period_from.STATEID, 0, 'lead', 1, 'active', 2, 'inactive', 3, 'temp
            -- inactive', 4,
            -- 'transferred'
            --            , 5, 'duplicate' , 7 , 'blocked', 6, 'prospect', 8, 'anonymized') periodFromState
            -- ,
            --            DECODE(scl_period_next.STATEID, 0, 'lead', 1, 'active', 2, 'inactive', 3, 'temp
            -- inactive', 4,
            -- 'transferred'
            --            , 5, 'duplicate' , 7 , 'blocked', 6, 'prospect', 8, 'anonymized') periodToState
        FROM
            PERSONS p
        JOIN
            CENTERS center
        ON
            p.CENTER = center.ID
            -- Join to get opening state of the member
        LEFT JOIN
            STATE_CHANGE_LOG scl_open
        ON
            scl_open.CENTER = p.CENTER
            AND scl_open.ID = p.ID
            AND scl_open.ENTRY_TYPE = 1
            AND scl_open.STATEID IN (1,3)
            AND scl_open.BOOK_START_TIME < :FromDate
            AND (
                scl_open.BOOK_END_TIME IS NULL
                OR scl_open.BOOK_END_TIME >= :FromDate)
            -- Join to get closing state of the member
        LEFT JOIN
            STATE_CHANGE_LOG scl_close
        ON
            p.CENTER = scl_close.CENTER
            AND p.ID = scl_close.ID
            AND scl_close.ENTRY_TYPE = 1
            AND scl_close.STATEID IN (1,3)
            AND scl_close.BOOK_START_TIME < :ToDate + (1000*60*60*24)
            AND (
                scl_close.BOOK_END_TIME IS NULL
                OR scl_close.BOOK_END_TIME >= :ToDate + (1000*60*60*24) )
            -- Join to get state changes (from) in period of the member
        LEFT JOIN
            STATE_CHANGE_LOG scl_period_from
        ON
            p.CENTER = scl_period_from.CENTER
            AND p.ID = scl_period_from.ID
            AND scl_period_from.ENTRY_TYPE = 1
            AND (
                scl_period_from.BOOK_START_TIME < :ToDate + (1000*60*60*24)
                OR scl_period_from.BOOK_END_TIME < :ToDate + (1000*60*60*24))
            AND (
                scl_period_from.BOOK_START_TIME >= :FromDate
                OR scl_period_from.BOOK_END_TIME >= :FromDate )
            -- Join to get state changes (next) in period of the member
        LEFT JOIN
            STATE_CHANGE_LOG scl_period_next
        ON
            scl_period_from.CENTER = scl_period_next.CENTER
            AND scl_period_from.ID = scl_period_next.ID
            AND scl_period_from.ENTRY_TYPE = scl_period_next.ENTRY_TYPE
            AND scl_period_next.BOOK_START_TIME < :ToDate + (1000*60*60*24)
            AND (
                scl_period_from.ENTRY_END_TIME = scl_period_next.ENTRY_START_TIME
                OR scl_period_from.ENTRY_END_TIME + 1 = scl_period_next.ENTRY_START_TIME)
        WHERE
            p.CENTER IN (:Scope)
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG persontype
                        WHERE
                            (
                                persontype.CENTER = p.CENTER
                                AND persontype.ID = p.ID
                                AND persontype.ENTRY_TYPE = 3
                                AND persontype.STATEID = 2
                                AND persontype.BOOK_START_TIME < :ToDate + (1000*60*60*24)
                                AND (
                                    persontype.BOOK_END_TIME IS NULL
                                    OR persontype.BOOK_END_TIME >= :FromDate) ))

            -- This sub query decides the member to inlude. I.e. either active in beginning or changed in
            -- period
            AND EXISTS
            (
                SELECT
                    *
                FROM
                    STATE_CHANGE_LOG scl_include
                WHERE
                    scl_include.CENTER = p.CENTER
                    AND scl_include.ID = p.ID
                    AND scl_include.ENTRY_TYPE = 1
                    AND scl_include.STATEID IN (1,3)
                    AND ((
                            scl_include.BOOK_START_TIME < :FromDate
                            AND (
                                scl_include.BOOK_END_TIME IS NULL
                                OR scl_include.BOOK_END_TIME >= :FromDate ) )
                        OR (
                            scl_include.BOOK_START_TIME >= :FromDate
                            AND scl_include.BOOK_START_TIME <= :ToDate + (1000*60*60*24) ) ))
            -- Join to get MEMBERSHIP state changes in period of the member
            -- Should always exists for the members returned above
        ORDER BY
            p.CENTER,
            p.ID,
            p.BIRTHDATE,
            longtodate(scl_period_from.BOOK_START_TIME) )
    -- Join to find overdue debt transactions on members
LEFT JOIN
    (
        SELECT DISTINCT
            CUSTOMERCENTER,
            CUSTOMERID
        FROM
            (
                SELECT
                    ar.CUSTOMERCENTER,
                    ar.CUSTOMERID,
                    ar.CENTER,
                    ar.ID,
                    art.SUBID,
                    art.AMOUNT,
                    SUM(arm.AMOUNT) settledAmount
                FROM
                    AR_TRANS art
                JOIN
                    ACCOUNT_RECEIVABLES ar
                ON
                    art.CENTER = ar.CENTER
                    AND art.ID = ar.ID
                LEFT JOIN
                    ART_MATCH arm
                ON
                    arm.ART_PAID_CENTER = art.CENTER
                    AND arm.ART_PAID_ID = art.ID
                    AND arm.ART_PAID_SUBID = art.SUBID
                    AND arm.ENTRY_TIME < :ToDate + (1000*60*60*24)
                    AND (
                        arm.CANCELLED_TIME IS NULL
                        OR arm.CANCELLED_TIME > :ToDate + (1000*60*60*24))
                WHERE
                    ar.CUSTOMERCENTER IN (:Scope)
                    AND art.AMOUNT < 0
                    AND art.COLLECTED_AMOUNT < 0
                    AND ar.AR_TYPE = 4
                    -- Only include debt more than 31 days old
                    --AND art.DUE_DATE + 31 < to_date('2013-10-01', 'YYYY-MM-DD')
                    AND art.DUE_DATE + 31 < longtodate(:ToDate + (1000*60*60*24))
                GROUP BY
                    ar.CUSTOMERCENTER,
                    ar.CUSTOMERID,
                    ar.CENTER,
                    ar.ID,
                    art.SUBID,
                    art.AMOUNT
                HAVING
                    -SUM(arm.AMOUNT) <> art.AMOUNT
                    OR SUM(arm.AMOUNT) IS NULL)) DEBTORS
ON
    DEBTORS.CUSTOMERCENTER = personCenter
    AND DEBTORS.CUSTOMERID = personId
    -- Join to find info on membership and membership periods overlapping end date of period (status)
LEFT JOIN
    (
        SELECT
            OWNER_CENTER,
            OWNER_ID,
            CASE
                WHEN SUM(latestart) > 0 and SUM(activesub) = 0 
                THEN 1
                ELSE 0
            END lateStart,
            CASE
                WHEN SUM(frozen) > 0
                THEN 1
                ELSE 0
            END frozen,
            CASE
                WHEN SUM(freedays) > 0
                THEN 1
                ELSE 0
            END freedays,
            CASE
                WHEN SUM(futurePriceIncrease) > 0 or (SUM(complimentary) > 0 and sum(futurePriceIncreaseFutureSub) > 0) 
                THEN 1
                ELSE 0
            END futurePriceIncrease,
            CASE
                WHEN MIN(complimentary) = 0  -- LC
                THEN 0
                ELSE 1
            END complimentary,
            COUNT(*)
        FROM
            (
                SELECT DISTINCT
                    SU.CENTER,
                    SU.ID,
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,
                    CASE
                        WHEN SCL1.STATEID = 8
                            AND SU.START_DATE > longtodate(:ToDate)
                        THEN 1
                        ELSE 0
                    END latestart,
                    -- LC
                    CASE
                        WHEN ACTIVE_SUBS.activesub > 0 
                        THEN 1
                        ELSE 0
                    END activesub,                    
                    -- /LC
                    CASE
                        WHEN SCL1.STATEID <> 8
                            AND SPP.SPP_TYPE IN (2,7)
                            AND SU.START_DATE < longtodate(:ToDate + (1000*60*60*24))
                        THEN 1
                        ELSE 0
                    END frozen,
                    CASE
                        WHEN SPP.SPP_TYPE IN (3)
                            AND SU.START_DATE < longtodate(:ToDate + (1000*60*60*24))
                        THEN 1
                        ELSE 0
                    END freeDays,
                    CASE
                        WHEN SPP.SPP_TYPE NOT IN (2,7,3)
                            AND SUM(SP.PRICE) > 0
                            -- LC: we exclude subscriptions where there is a price update from the 1st of month following the start date and start date after the first
                            AND (SU.START_DATE <= longtodate(:FromDate) or min(sp.FROM_DATE) > last_day(SU.START_DATE) + 1)

                            AND SU.START_DATE < longtodate(:ToDate + (1000*60*60*24))
                        THEN 1
                        ELSE 0
                    END futurePriceIncrease,
                    CASE
                        WHEN SUM(SP.PRICE) > 0
                            AND (SCL1.STATEID = 8)
--                            AND (SU.START_DATE >= longtodate(${ToDate}$ + (1000*60*60*24)))
                        THEN 1
                        ELSE 0
                    END futurePriceIncreaseFutureSub,

                    CASE
                        WHEN SPP.SUBSCRIPTION_PRICE = 0
                            AND SPP.SPP_TYPE NOT IN (2,7,3)
                            AND SU.START_DATE < longtodate(:ToDate + (1000*60*60*24))
                            AND (SUM(SP.PRICE) <= 0
                                OR SUM(SP.PRICE) IS NULL)
                        THEN 1
                        ELSE 0
                    END complimentary
                FROM
                    SUBSCRIPTIONS SU
                INNER JOIN
                    SUBSCRIPTIONTYPES ST
                ON
                    (
                        SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
                INNER JOIN
                    STATE_CHANGE_LOG SCL1
                ON
                    (
                        SCL1.CENTER = SU.CENTER
                        AND SCL1.ID = SU.ID
                        AND SCL1.ENTRY_TYPE = 2
                        AND SCL1.STATEID IN (2,
                                             4,8)
                        AND SCL1.BOOK_START_TIME < :ToDate + (1000*60*60*24)
                        AND (
                            SCL1.BOOK_END_TIME IS NULL
                            OR SCL1.BOOK_END_TIME >= :ToDate )
                        AND SCL1.ENTRY_START_TIME < :ToDate + (1000*60*60*24) )
                LEFT JOIN
                    SUBSCRIPTIONPERIODPARTS SPP
                ON
                    (
                        SPP.CENTER = SU.CENTER
                        AND SPP.ID = SU.ID
                        AND SPP.FROM_DATE <= longtodate(:ToDate)
                        AND SPP.TO_DATE >= longtodate(:ToDate)
                        AND SPP.SPP_STATE = 1
                        AND SPP.ENTRY_TIME <= :ToDate + (6*60*60*1000) )
                LEFT JOIN
                    SUBSCRIPTION_PRICE SP
                ON
                    (
                        SP.SUBSCRIPTION_CENTER = SU.CENTER
                        AND SP.SUBSCRIPTION_ID = SU.ID
                        AND SP.FROM_DATE >= longtodate(:ToDate)
                        AND SP.PRICE > 0 
--                      AND SP.CANCELLED = 0
)
				-- LC
                LEFT JOIN
                    (
                        SELECT
                            SU_ACT.OWNER_CENTER,
                            SU_ACT.OWNER_ID,
                            CASE
                                WHEN SUM(SU_ACT.id) > 0
                                THEN 1
                                ELSE 0
                            END activesub
                        FROM
                            SUBSCRIPTIONS SU_ACT
                        INNER JOIN
                            SUBSCRIPTIONTYPES ST_ACT
                        ON
                            (
                                SU_ACT.SUBSCRIPTIONTYPE_CENTER = ST_ACT.CENTER
                            AND SU_ACT.SUBSCRIPTIONTYPE_ID = ST_ACT.ID )
                        INNER JOIN
                            STATE_CHANGE_LOG SCL1_ACT
                        ON
                            (
                                SCL1_ACT.CENTER = SU_ACT.CENTER
                            AND SCL1_ACT.ID = SU_ACT.ID
                            AND SCL1_ACT.ENTRY_TYPE = 2
                            AND SCL1_ACT.STATEID IN (2,
                                                     4,8)
                            AND SCL1_ACT.BOOK_START_TIME < :ToDate + (1000*60*60*24)
                            AND (
                                    SCL1_ACT.BOOK_END_TIME IS NULL
                                OR  SCL1_ACT.BOOK_END_TIME >= :ToDate )
                            AND SCL1_ACT.ENTRY_START_TIME < :ToDate + (1000*60*60*24) )
                        WHERE
                            (
                                SU_ACT.CENTER IN (:Scope)
                            AND SCL1_ACT.STATEID IN (2,4) )
                        GROUP BY
                            SU_ACT.OWNER_CENTER,
                            SU_ACT.OWNER_ID) ACTIVE_SUBS
                ON
                    ACTIVE_SUBS.OWNER_CENTER = SU.OWNER_CENTER
                AND ACTIVE_SUBS.OWNER_ID = SU.OWNER_ID				
				-- LC


                WHERE
                    (
                        SU.CENTER IN (:Scope)
                        AND (
                            SPP.SUBSCRIPTION_PRICE = 0
                                    OR (
                                        SPP.CENTER IS NULL
                                        AND SCL1.STATEID IN (8))

                            OR (
                                SPP.SUBSCRIPTION_PRICE <> 0
                                AND SPP.SPP_TYPE IN (2,7)))
                        AND ST.ST_TYPE IN (0,1)
                        AND ST.IS_ADDON_SUBSCRIPTION = 0)
                GROUP BY
                    SU.CENTER,
                    SU.ID,
                    SU.START_DATE,
                    SU.OWNER_CENTER,
                    SU.OWNER_ID,
                    SPP.CENTER,
                    SPP.SUBSCRIPTION_PRICE,
                    SPP.SPP_TYPE,
                    SCL1.STATEID,
					ACTIVE_SUBS.ACTIVESUB)
        GROUP BY
            OWNER_CENTER,
            OWNER_ID) FREESUBS
ON
    FREESUBS.OWNER_CENTER = personcenter
    AND FREESUBS.OWNER_ID = personid
GROUP BY
    personcenter,
    personid,
    BIRTHDATE,
    DEBTORS.CUSTOMERCENTER,
    FREESUBS.LATESTART,
    FREESUBS.FROZEN,
    FREESUBS.FREEDAYS,
    FREESUBS.futurePriceIncrease,
    FREESUBS.COMPLIMENTARY,
    memberId,
    country,
    shortname,
    --UNBROKEN_MEM_DAYS,
    --TOTAL_MEM_DAYS,
    openstate,
    closestate
    --HAVING
    --    openstate + SUM(lead_active) + SUM(active_inactive) + SUM(tmp_inactive) + SUM(inactive_active) +
    -- SUM
    -- (inactive_tmp)
    --    + SUM(transf_active)+ SUM (active_transf ) - closestate = 0
ORDER BY
    country,
    personcenter,
    personId
