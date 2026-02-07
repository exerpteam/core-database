SELECT
    dms.ID AS "ID",
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
    END                                                                AS "PERSON_ID",
    dms.PERSON_CENTER                                                  AS "CENTER_ID",
    dms.PERSON_ID                                                      AS "HOME_CENTER_PERSON_ID",
    dms.CHANGE_DATE                                                    AS "DATE",
    dms.ENTRY_START_TIME                                               AS "ENTRY_DATETIME",
	CASE 
		WHEN dms.CHANGE = 0 THEN 'OTHER'
		WHEN dms.CHANGE = 1 THEN 'JOINER'
		WHEN dms.CHANGE = 2 THEN 'REJOINER'
		WHEN dms.CHANGE = 3 THEN 'REACTIVATED'
		WHEN dms.CHANGE = 4 THEN 'LEAVER'
		WHEN dms.CHANGE = 5 THEN 'LEAVER END OF DAY'
		WHEN dms.CHANGE = 6 THEN 'CHANGE MEMBERSHIP'
		WHEN dms.CHANGE = 7 THEN 'TRANSFER OUT'
		WHEN dms.CHANGE = 8 THEN 'TRANSFER IN'
		WHEN dms.CHANGE = 9 THEN 'TRANSFER IN AND CHANGE MEMBERSHIP'
		WHEN dms.CHANGE = 10 THEN 'MIGRATED'
		ELSE 'UNKNOWN'
	END AS "CHANGE", 
    dms.MEMBER_NUMBER_DELTA                                            AS "MEMBER_NUMBER_DELTA",
    dms.EXTRA_NUMBER_DELTA                                             AS "EXTRA_NUMBER_DELTA",
    dms.SECONDARY_MEMBER_NUMBER_DELTA                                  AS "SECONDARY_MEMBER_NUMBER_DELTA",
    dms.ENTRY_STOP_TIME                                                AS "CANCEL_DATETIME",
    COALESCE(dms.ENTRY_STOP_TIME, dms.ENTRY_START_TIME)                AS "ETS"
FROM
    DAILY_MEMBER_STATUS_CHANGES dms
JOIN
    PERSONS p
ON
    p.CENTER = dms.PERSON_CENTER
    AND p.id = dms.PERSON_ID
