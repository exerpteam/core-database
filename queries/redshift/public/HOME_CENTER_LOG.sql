SELECT
    pcl.id AS "ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS            "PERSON_ID",
    pcl.person_center "HOME_CENTER_ID",
    entry_time        AS     "FROM_DATETIME",
    pcl.person_center AS     "CENTER_ID",
    entry_time        AS     "ETS"
FROM
    person_change_logs pcl
JOIN
    PERSONS p
ON
    p.center = pcl.person_center
    AND p.id = pcl.person_id
WHERE
    pcl.PREVIOUS_ENTRY_ID IS NULL
    AND pcl.change_attribute = 'CREATION_DATE'
	AND p.SEX <> 'C'
