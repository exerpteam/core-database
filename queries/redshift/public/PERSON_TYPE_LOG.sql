SELECT
    scl.KEY AS "ID",
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
    END                                                  AS "PERSON_ID",
	CASE 
		WHEN scl.STATEID = 0 THEN 'PRIVATE'
		WHEN scl.STATEID = 1 THEN 'STUDENT'
		WHEN scl.STATEID = 2 THEN 'STAFF'
		WHEN scl.STATEID = 3 THEN 'FRIEND'
		WHEN scl.STATEID = 4 THEN 'CORPORATE'
		WHEN scl.STATEID = 5 THEN 'ONEMANCORPORATE'
		WHEN scl.STATEID = 6 THEN 'FAMILY'
		WHEN scl.STATEID = 7 THEN 'SENIOR'
		WHEN scl.STATEID = 8 THEN 'GUEST'
		WHEN scl.STATEID = 9 THEN 'CHILD'
		WHEN scl.STATEID = 10 THEN 'EXTERNAL_STAFF'
		ELSE 'UNKNOWN'
	END AS "PERSON_TYPE",
    scl.ENTRY_START_TIME                                     "FROM_DATETIME",
    scl.CENTER           AS                                           "CENTER_ID",
    scl.ENTRY_START_TIME AS                                           "ETS"
FROM
    STATE_CHANGE_LOG scl
JOIN
    PERSONS p
ON
    p.center = scl.center
    AND p.id = scl.id
WHERE
    scl.ENTRY_TYPE = 3
    AND p.SEX != 'C'
