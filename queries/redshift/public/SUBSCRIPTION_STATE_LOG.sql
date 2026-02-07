SELECT
    scl.KEY                                                     AS "ID",
    scl.CENTER                                                  AS "CENTER_ID",
    scl.CENTER || 'ss' || scl.ID                                AS "SUBSCRIPTION_ID",
	CASE 
        WHEN scl.STATEID = 2 THEN 'ACTIVE'
        WHEN scl.STATEID = 3 THEN 'ENDED'
        WHEN scl.STATEID = 4 THEN 'FROZEN'
        WHEN scl.STATEID = 7 THEN 'WINDOW'
        WHEN scl.STATEID = 8 THEN 'CREATED'
        ELSE 'UNKNOWN'
	END AS "STATE",
	CASE 
		WHEN scl.SUB_STATE = 1 THEN 'NONE'
		WHEN scl.SUB_STATE = 2 THEN 'AWAITING_ACTIVATION'
		WHEN scl.SUB_STATE = 3 THEN 'UPGRADED'
		WHEN scl.SUB_STATE = 4 THEN 'DOWNGRADED'
		WHEN scl.SUB_STATE = 5 THEN 'EXTENDED'
		WHEN scl.SUB_STATE = 6 THEN 'TRANSFERRED'
		WHEN scl.SUB_STATE = 7 THEN 'REGRETTED'
		WHEN scl.SUB_STATE = 8 THEN 'CANCELLED'
		WHEN scl.SUB_STATE = 9 THEN 'BLOCKED'
		WHEN scl.SUB_STATE = 10 THEN 'CHANGED'
		ELSE 'UNKNOWN'
	END AS "SUB_STATE",
    scl.ENTRY_START_TIME                                        AS "ENTRY_START_DATETIME",
    scl.ENTRY_END_TIME                                          AS "ENTRY_END_DATETIME",    
    scl.BOOK_START_TIME                                         AS "BOOK_START_DATETIME",
    scl.BOOK_END_TIME                                           AS "BOOK_END_DATETIME",
    COALESCE(scl.ENTRY_END_TIME, scl.ENTRY_START_TIME)          AS "ETS"
FROM
    STATE_CHANGE_LOG scl
WHERE
    scl.ENTRY_TYPE = 2
