-- This is the version from 2026-02-05
--  
SELECT distinct
    p.CENTER||'p'||p.ID MemberID,
	    floor(months_between(current_timestamp, p.BIRTHDATE) / 12) age,
    p.SEX,
	CASE P.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 
        'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 
        'CORPORATE' WHEN 5 THEN 'ONE MAN CORPORATE' WHEN 6 THEN 
        'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' ELSE 
        'UNKNOWN' END AS PERSONTYPE,
    sa.START_DATE,
	sa.END_DATE,
	current_timestamp as Run_time,
    CASE
        WHEN scl2.STATEID IN (1,3,4)
            OR scl3.CENTER IS NOT NULL 
        THEN 'true'
        WHEN scl2.STATEID IN (2,0)
            OR scl2.STATEID IS NULL
        THEN 'false'
    END AS "existing Member",
	 CASE
        WHEN sa.USE_INDIVIDUAL_PRICE = 1
        THEN sa.INDIVIDUAL_PRICE_PER_UNIT
        ELSE mpr.CACHED_PRODUCTPRICE
    END AS Price,
    sa.EMPLOYEE_CREATOR_CENTER
FROM
    PERSONS op
JOIN
    PERSONS p
ON
    op.CURRENT_PERSON_CENTER = p.CENTER
    AND op.CURRENT_PERSON_ID = p.ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
    AND mpr.GLOBALID like 'ALL_IN%'
LEFT JOIN
    (
        SELECT
            scl.CENTER,
            scl.id,
            MAX(scl.ENTRY_START_TIME) ENTRY_START_TIME
        FROM
            STATE_CHANGE_LOG scl
        JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = scl.CENTER
            AND s.OWNER_ID = scl.ID
            AND s.STATE IN (2,4)
        JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = s.CENTER
            AND sa.SUBSCRIPTION_ID = s.ID
            
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
            AND mpr.GLOBALID = 'ALL_IN'
        WHERE
            scl.ENTRY_TYPE = 1
            AND scl.ENTRY_START_TIME<=dateToLong(TO_CHAR(sa.START_DATE-14, 'YYYY-MM-dd HH24:MI'))
        GROUP BY
            scl.CENTER,
            scl.ID) scl
ON
    scl.CENTER = p.CENTER
    AND scl.id = p.ID
LEFT JOIN
    STATE_CHANGE_LOG scl2
ON
    scl2.CENTER = p.CENTER
    AND scl2.id = p.ID
    AND scl2.ENTRY_TYPE = 1
    AND scl2.ENTRY_START_TIME = scl.ENTRY_START_TIME
LEFT JOIN
    STATE_CHANGE_LOG scl3
ON
    scl3.CENTER = p.CENTER
    AND scl3.id = p.ID
    AND scl3.ENTRY_TYPE = 1
    AND scl3.ENTRY_START_TIME BETWEEN s.CREATION_TIME-1000*60*60*14 AND s.CREATION_TIME
    AND scl3.STATEID = 4
WHERE
    p.STATUS IN (1,3) and p.CENTER in ($$scope$$)
 AND (
        sa.end_date IS NULL
        OR sa.end_date >= to_date(TO_CHAR(current_timestamp,'yyyy-mm-dd'),'yyyy-mm-dd') )
    AND sa.CANCELLED = 0