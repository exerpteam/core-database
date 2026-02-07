-- This is the version from 2026-02-05
--  
SELECT
        SU.CENTER,
        cen.SHORTNAME,
        su.center || 'ss' || su.id as SubscriptionId,
        su.owner_center || 'p' || su.owner_id as PersonId,
		pr.name,
		su.start_date,

        sum(case when ST.ST_TYPE = 1 and SCL1.STATEID = 2 then 1 else 0 end) as ActiveEFTCount,
        sum(case when ST.ST_TYPE = 0 and SCL1.STATEID = 2 then 1 else 0 end) as ActiveCashCount,
        sum(case when SCL1.STATEID = 2 and SCL1.STATEID = 2 then 1 else 0 end) as ActiveCount,
        sum(case when SCL1.STATEID = 4 then 1 else 0 end) as Frozen,
        count(*) as Total
,
        round(AVG(EXTRACT(DAY FROM (longtodate(:at_date + 86400000) - su.START_DATE)))) - 1 as AverageMembershipDays,
        round(AVG(freeze_length.Duration)) as AverageFreezeDays

,
        round(AVG(EXTRACT(DAY FROM (longtodate(:at_date + 86400000) - su.START_DATE)))) 
        - round(AVG(freeze_length.Duration)) - 1 as AvgMembershipDaysWithoutFreeze
       
         

FROM
    SUBSCRIPTIONS SU
JOIN centers cen on su.center = cen.id

INNER JOIN
    SUBSCRIPTIONTYPES ST
ON
    (
        SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
INNER JOIN
    PRODUCTS PR
ON
    (
        ST.CENTER = PR.CENTER
    AND ST.ID = PR.ID)
INNER JOIN
    STATE_CHANGE_LOG SCL1
ON
    (
        SCL1.CENTER = SU.CENTER
    AND SCL1.ID = SU.ID
    AND SCL1.ENTRY_TYPE = 2)
LEFT JOIN
    STATE_CHANGE_LOG SCL2
ON
    (
        SU.OWNER_CENTER = SCL2.CENTER
    AND SU.OWNER_ID = SCL2.ID
    AND SCL2.ENTRY_TYPE = 3
    AND SCL2.BOOK_START_TIME < :at_date + 86400000
    AND (
            SCL2.BOOK_END_TIME IS NULL
        OR  SCL2.BOOK_END_TIME >= :at_date + 86400000))

LEFT JOIN
    (
        SELECT
            sub.center,
            sub.id,
            scl_d .stateid
            --scl_d.*, longtodate(scl_d.BOOK_START_TIME), longtodate(scl_d.BOOK_END_TIME),
            --         longtodate(scl_d.ENTRY_START_TIME), longtodate(scl_d.ENTRY_END_TIME)
            --,        least(nvl(scl_d.BOOK_END_TIME, :at_date + 86400000), :at_date + 86400000)
            --,        longtodate(least(nvl(scl_d.BOOK_END_TIME, :at_date + 86400000), :at_date + 86400000))
            --,        sum(least(nvl(scl_d.BOOK_END_TIME, :at_date + 86400000), :at_date + 86400000) -
            --         scl_d.BOOK_START_TIME) as TotalTimeInStatus
            ,
            SUM(ROUND((least(NVL(scl_d.BOOK_END_TIME, :at_date + 86400000), :at_date + 86400000) -
            scl_d.BOOK_START_TIME) / (86400*1000))) AS Duration
        FROM
            STATE_CHANGE_LOG scl_d
        JOIN
            SUBSCRIPTIONS sub
        ON
            sub.center = scl_d.center
        AND sub.id = scl_d.id
        AND scl_d.ENTRY_TYPE = 2
        WHERE
            scl_d.BOOK_START_TIME < :at_date + 86400000

        AND (
                scl_d.BOOK_END_TIME IS NULL
            OR  scl_d.BOOK_END_TIME > scl_d.BOOK_START_TIME)
        GROUP BY
            sub.center,
            sub.id,
            scl_d.stateid ) freeze_length
ON
    freeze_length.center = su.center
AND freeze_length.id = su.id
AND freeze_length.stateid = 4
WHERE
    (
        SU.CENTER in (:scope) AND 
        
    SCL1.ENTRY_TYPE = 2
    AND SCL1.STATEID IN (2,
                         4)
    AND SCL1.BOOK_START_TIME < :at_date + 86400000
    AND (
            SCL1.BOOK_END_TIME IS NULL
        OR  SCL1.BOOK_END_TIME >= :at_date + 86400000)
    AND SCL1.ENTRY_START_TIME < :at_date + 86400000
    AND SCL2.STATEID IN (0,
                         7,
                         8,
                         5,
                         3,
                         4,
                         1,
                         9,
                         6)
    AND EXISTS
        (
            SELECT
                PAPGL.PRODUCT_GROUP_ID AS PAPGL_PRODUCT_GROUP_ID
            FROM
                PRODUCT_AND_PRODUCT_GROUP_LINK PAPGL
            WHERE
                (
                    PR.CENTER = PAPGL.PRODUCT_CENTER
                AND PR.ID = PAPGL.PRODUCT_ID
                AND PAPGL.PRODUCT_GROUP_ID IN (6,
                                               7)))) 
group by su.center, su.id, cen.SHORTNAME, su.owner_center
, su.owner_id,pr.name, su.start_date

order by su.owner_center, su.owner_id, su.id
                                               
                                               
              