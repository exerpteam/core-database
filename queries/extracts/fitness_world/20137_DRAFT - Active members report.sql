-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    personId,
    country,
    center,
    shortname,
    openstate opening,
    SUM(lead_active) joiners,
    SUM(active_inactive) leavers,
    SUM(tmp_inactive) leavers_tmp,
    SUM(inactive_active) rejoiners,
    SUM(inactive_tmp) rejoiners_tmp,
    SUM(transf_active)+ SUM(active_transf) transfers,
    closestate closing,
    openstate + SUM(lead_active) + SUM(active_inactive) + SUM(inactive_active) + SUM(inactive_tmp) + SUM(transf_active) + SUM(active_transf) - closestate errors
FROM
    (
        SELECT DISTINCT
            p.CENTER,
            center.WEB_NAME SHORTNAME,
            center.COUNTRY,
            p.ID ,
            p.CENTER || 'p' || p.ID personId,
            p.FIRST_ACTIVE_START_DATE,
            p.LAST_ACTIVE_START_DATE,
            p.LAST_ACTIVE_END_DATE,
            CASE
                WHEN p.LAST_ACTIVE_END_DATE IS NULL
                THEN TRUNC(TO_DATE('2013-08-01', 'YYYY-MM-DD') - p.LAST_ACTIVE_START_DATE) + 1
                ELSE p.MEMBERDAYS
            END UNBROKEN_MEM_DAYS,
            CASE
                WHEN p.LAST_ACTIVE_END_DATE IS NULL
                THEN TRUNC(TO_DATE('2013-08-01', 'YYYY-MM-DD') - p.LAST_ACTIVE_START_DATE) + 1 + p.ACCUMULATED_MEMBERDAYS
                ELSE p.MEMBERDAYS + p.ACCUMULATED_MEMBERDAYS
            END TOTAL_MEM_DAYS,
            CASE
                WHEN scl_open.CENTER IS NOT NULL
                    AND scl_open.ENTRY_START_TIME <= :longDate1
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
                THEN 1
                ELSE 0
            END active_dupl,
            CASE
                WHEN scl_period_from.STATEID = 4
                    AND scl_period_next.STATEID = 1
                THEN 0
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
        FROM
            FW.PERSONS p
        JOIN FW.CENTERS center
        ON
            p.CENTER = center.ID
        LEFT JOIN FW.STATE_CHANGE_LOG scl_open
        ON
            scl_open.CENTER = p.CENTER
            AND scl_open.ID = p.ID
            AND scl_open.ENTRY_TYPE = 1
            AND
            (
                (
                    scl_open.ENTRY_START_TIME <= :longDate1
                    AND
                    (
                        scl_open.ENTRY_END_TIME IS NULL
                        OR scl_open.ENTRY_END_TIME >= :longDate1
                    )
                    AND scl_open.STATEID IN (1,3)
                )
            )
        LEFT JOIN FW.STATE_CHANGE_LOG scl_close
        ON
            p.CENTER = scl_close.CENTER
            AND p.ID = scl_close.ID
            AND scl_close.ENTRY_TYPE = 1
            AND scl_close.ENTRY_START_TIME <= :longDate2
            AND
            (
                scl_close.ENTRY_END_TIME IS NULL
                OR scl_close.ENTRY_END_TIME >= :longDate2
            )
            AND scl_close.STATEID IN (1,3)
        LEFT JOIN FW.STATE_CHANGE_LOG scl_period_from
        ON
            p.CENTER = scl_period_from.CENTER
            AND p.ID = scl_period_from.ID
            AND scl_period_from.ENTRY_TYPE = 1
            AND
            (
                scl_period_from.ENTRY_START_TIME <= :longDate2
                OR scl_period_from.ENTRY_END_TIME <= :longDate2
            )
            AND
            (
                scl_period_from.ENTRY_START_TIME >= :longDate1
                OR scl_period_from.ENTRY_END_TIME >= :longDate1
            )
        LEFT JOIN FW.STATE_CHANGE_LOG scl_period_next
        ON
            scl_period_from.CENTER = scl_period_next.CENTER
            AND scl_period_from.ID = scl_period_next.ID
            AND scl_period_from.ENTRY_TYPE = scl_period_next.ENTRY_TYPE
            AND scl_period_next.ENTRY_START_TIME <= :longDate2
            AND
            (
                scl_period_from.ENTRY_END_TIME = scl_period_next.ENTRY_START_TIME
                OR scl_period_from.ENTRY_END_TIME + 1 = scl_period_next.ENTRY_START_TIME
            )
        WHERE
            p.CENTER in (:scope)

            AND EXISTS
            (
                SELECT
                    *
                FROM
                    FW.STATE_CHANGE_LOG scl_include
                WHERE
                    scl_include.CENTER = p.CENTER
                    AND scl_include.ID = p.ID
                    AND scl_include.ENTRY_TYPE = 1
                    AND
                    (
                        (
                            scl_include.ENTRY_START_TIME <= :longDate1
                            AND
                            (
                                scl_include.ENTRY_END_TIME IS NULL
                                OR scl_include.ENTRY_END_TIME >= :longDate1
                            )
                            AND scl_include.STATEID IN (1,3)
                        )
                        OR
                        (
                            scl_include.ENTRY_START_TIME >= :longDate1
                            AND scl_include.ENTRY_START_TIME <= :longDate2
                        )
                    )
            )
        ORDER BY
            p.CENTER,
            p.ID,
            longtodate(scl_period_from.ENTRY_START_TIME)
    )
GROUP BY
    personid,
    country,
    center,
    shortname,
    openstate,
    closestate
HAVING
    openstate + SUM(lead_active) + SUM(active_inactive) + SUM(tmp_inactive) + SUM(inactive_active) + SUM(inactive_tmp) + SUM(transf_active)+ SUM (active_transf ) - closestate = 0
ORDER BY
    country,
    center