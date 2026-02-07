SELECT
    sc.ID,
    sc.NAME,
    center.NAME club,
    area.NAME area,
    sc.STATE,
    longtodate(sc.STARTTIME) start_date,
    longtodate(sc.ENDTIME) end_date
FROM
    STARTUP_CAMPAIGN sc
LEFT JOIN CENTERS center
ON
    sc.SCOPE_TYPE = 'C'
    AND sc.SCOPE_ID = center.ID
LEFT JOIN AREAS area
ON
    sc.SCOPE_TYPE = 'A'
    AND sc.SCOPE_ID = area.ID
ORDER BY sc.STARTTIME desc
