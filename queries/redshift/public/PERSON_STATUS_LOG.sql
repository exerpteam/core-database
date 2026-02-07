SELECT
    PERSON_STATUS_LOG_ID                         AS "ID",
    PERSON_ID                                    AS "PERSON_ID",
	CASE 
		WHEN STATEID = 0 THEN 'LEAD'
		WHEN STATEID = 1 THEN 'ACTIVE'
		WHEN STATEID = 2 THEN 'INACTIVE'
		WHEN STATEID = 3 THEN 'TEMPORARYINACTIVE'
		WHEN STATEID = 4 THEN 'TRANSFERED'
		WHEN STATEID = 5 THEN 'DUPLICATE'
		WHEN STATEID = 6 THEN 'PROSPECT'
		WHEN STATEID = 7 THEN 'DELETED'
		WHEN STATEID = 8 THEN 'ANONYMIZED'
		WHEN STATEID = 9 THEN 'CONTACT'
		ELSE 'UNKNOWN'
	END AS "PERSON_STATUS",     
    START_TIME                                   AS "FROM_DATETIME",
    CENTER                                       AS "CENTER_ID",
    ETS                                          AS "ETS"
FROM
    (
        SELECT
            scl.KEY AS PERSON_STATUS_LOG_ID,
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
            END AS PERSON_ID,
            STATEID,
            scl.center AS CENTER,
            CASE
                WHEN STATEID IN (2) -- inactive
                THEN scl.BOOK_START_TIME
                ELSE scl.ENTRY_START_TIME
            END                  AS START_TIME,
            scl.ENTRY_START_TIME AS ETS
        FROM
            STATE_CHANGE_LOG scl
        JOIN
            PERSONS p
        ON
            p.center = scl.center
            AND p.id = scl.id
        WHERE
            scl.ENTRY_TYPE = 1
            AND p.SEX != 'C')scl
			