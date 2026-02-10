-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.SHORTNAME AS ClubName,
    p.FULLNAME,
    DECODE(pcl.NEW_VALUE, 'true', 'Opt-in', 'false', 'Opt-out') AS Accecpt_Email,
    longtodate(MAXENTRY.ENTRYTIME)                              AS ChangeTime
FROM
    HP.TASKS ta
JOIN
    HP.PERSONS p
ON
    p.CENTER = ta.PERSON_CENTER
    AND p.ID = ta.PERSON_ID
JOIN
    (
        SELECT
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID,
            MAX(pcl1.ENTRY_TIME) AS ENTRYTIME
        FROM
            HP.PERSON_CHANGE_LOGS pcl1
        WHERE
            pcl1.CHANGE_ATTRIBUTE = 'ALLOWED_CHANNEL_EMAIL'
            AND pcl1.EMPLOYEE_CENTER = 100
            AND pcl1.EMPLOYEE_ID = 4207
        GROUP BY
            pcl1.PERSON_CENTER,
            pcl1.PERSON_ID) MAXENTRY
ON
    MAXENTRY.PERSON_CENTER = p.CENTER
    AND MAXENTRY.PERSON_ID = p.ID
JOIN
    HP.PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = MAXENTRY.PERSON_CENTER
    AND pcl.PERSON_ID = MAXENTRY.PERSON_ID
    AND pcl.ENTRY_TIME = MAXENTRY.ENTRYTIME
    AND pcl.CHANGE_ATTRIBUTE = 'ALLOWED_CHANNEL_EMAIL'
JOIN
    HP.CENTERS cen
ON
    cen.ID = p.CENTER

Where ta.PERSON_CENTER in (:scope)    
    