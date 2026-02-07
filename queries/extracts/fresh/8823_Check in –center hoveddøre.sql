SELECT
    up.NAME,
    to_char(longToDate(upu.TIME),'yyyy-MM-dd HH24:MI')TIME,
    upu.PERSON_CENTER,
    upu.PERSON_ID
FROM
    USAGE_POINTS up
JOIN USAGE_POINT_RESOURCES upr
ON
    upr.USAGE_POINT_CENTER = up.CENTER
    AND upr.USAGE_POINT_ID = up.ID
JOIN USAGE_POINT_USAGES upu
ON
    upu.ACTION_CENTER = upr.CENTER
    AND upu.ACTION_ID = upr.ID
WHERE
    up.NAME IN ('Dør Vesterbrogade','Dør Matthæusgade')
    and upu.TIME between :longDateTimeFrom and :longDateTimeTO