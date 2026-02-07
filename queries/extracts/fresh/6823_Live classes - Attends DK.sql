SELECT
    att.center                              AS Center,
    att.PERSON_CENTER ||'p' ||att.person_id AS MemberId,
    TO_CHAR(longtodate(att.START_TIME), 'HH24.MI.SS')   AS ATTEND_TIME,
    TO_CHAR(longtodate(att.START_TIME), 'DD.MM.YYYY')   AS ATTEND_DATE,
    CASE
        WHEN pu.DEDUCTION_KEY IS NOT NULL
        THEN 1
        ELSE 0
    END AS ServiceProductDeducted
FROM
    ATTENDS att
JOIN BOOKING_RESOURCES br
ON
    br.center = att.BOOKING_RESOURCE_CENTER
AND br.id = att.BOOKING_RESOURCE_ID
JOIN PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = att.center
AND pu.TARGET_SERVICE = 'Attend'
AND pu.TARGET_ID = att.id
WHERE
    br.ATTEND_PRIVILEGE_ID = 3
AND att.state = 'ACTIVE'
AND att.center IN (:scope)
AND att.START_TIME >= :from_date
AND att.START_TIME < (:to_date + (24*3600*1000 -1 )) 