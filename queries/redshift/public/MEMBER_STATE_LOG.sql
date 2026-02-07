SELECT
    MEMBER_STATE_LOG_ID                                 AS "ID",
    PERSON_ID                                           AS "PERSON_ID",
	CASE 
		WHEN STATEID = 0 THEN 'NOTAPPLICABLE'
		WHEN STATEID = 1 THEN 'NONMEMBER'
		WHEN STATEID = 2 THEN 'MEMBER'
		WHEN STATEID = 3 THEN 'SECONDARYMEMBER'
		WHEN STATEID = 4 THEN 'EXTRA'
		WHEN STATEID = 5 THEN 'EXMEMBER'
		WHEN STATEID = 6 THEN 'LEGACYMEMBER'
		ELSE 'UNKNOWN'
	END AS "MEMBER_STATE",
    START_TIME                                          AS "FROM_DATETIME",
    CENTER                                              AS "CENTER_ID",
    ETS                                                 AS "ETS"
FROM
    (
        SELECT
            scl.KEY AS MEMBER_STATE_LOG_ID,
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
                WHEN STATEID IN (1,5,6) -- nonMember, exMember, legacyMember
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
            scl.ENTRY_TYPE = 5
            AND p.SEX != 'C')scl
	