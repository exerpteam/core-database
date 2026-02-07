SELECT DISTINCT
    att.CENTER||'att'||att.ID                                AS "ATTEND_ID",
    p2.center||'p'||p2.id as                                              CUSTOMER_ID,
    att.CENTER                                                  ATTEND_CENTER_ID,
    TO_CHAR(longtodate(att.START_TIME),'YYYY-MM-DD HH24:MI')    ATTEND_TIMESTAMP,
    CASE
        WHEN SUBSTR(brg.NAME, -1)=' '
        THEN SUBSTR(brg.NAME,1,LENGTH(brg.NAME)-1)
        ELSE brg.NAME
    END AS Resource_Group
FROM
    PULSE.ATTENDS att
JOIN
    PULSE.PERSONS p
ON
    p.CENTER = att.PERSON_CENTER
    AND p.ID = att.PERSON_ID
JOIN
    PULSE.PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
JOIN
    PULSE.BOOKING_RESOURCE_CONFIGS brc
ON
    brc.BOOKING_RESOURCE_CENTER = att.BOOKING_RESOURCE_CENTER
    AND brc.BOOKING_RESOURCE_ID = att.BOOKING_RESOURCE_ID
JOIN
    PULSE.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = brc.GROUP_ID
WHERE
    att.START_TIME BETWEEN datetolong(TO_CHAR(TRUNC(SYSDATE -7), 'YYYY-MM-DD HH24:MI')) AND datetolong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD HH24:MI')) and att.center in ($$scope$$)