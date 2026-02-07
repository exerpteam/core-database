SELECT
    p.CENTER || 'pa' || p.ID                AS "ID",
    p.BOOKING_CENTER || 'book' || p.BOOKING_ID AS "BOOKING_ID",
    p.CENTER                                 AS "CENTER_ID",
    CASE
        WHEN (per.CENTER != per.TRANSFERS_CURRENT_PRS_CENTER
            OR  per.id != per.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = per.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = per.TRANSFERS_CURRENT_PRS_ID)
        ELSE per.EXTERNAL_ID
    END                                                                  AS "PERSON_ID",
    p.CREATION_TIME                                                          AS "CREATION_DATETIME",
    CASE
        WHEN (create_per.CENTER != create_per.TRANSFERS_CURRENT_PRS_CENTER
            OR  create_per.id != create_per.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = create_per.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = create_per.TRANSFERS_CURRENT_PRS_ID)
        ELSE create_per.EXTERNAL_ID
    END                                                                  AS "CREATION_PERSON_ID",
    p.STATE                                                                       AS "STATE",
	CASE 
		WHEN p.USER_INTERFACE_TYPE = 0 THEN 'OTHER'
		WHEN p.USER_INTERFACE_TYPE = 1 THEN 'CLIENT'
		WHEN p.USER_INTERFACE_TYPE = 2 THEN 'WEB'
		WHEN p.USER_INTERFACE_TYPE = 3 THEN 'KIOSK'
		WHEN p.USER_INTERFACE_TYPE = 4 THEN 'SCRIPT'
		WHEN p.USER_INTERFACE_TYPE = 5 THEN 'API'
		WHEN p.USER_INTERFACE_TYPE = 6 THEN 'MOBILE_API'
		WHEN p.USER_INTERFACE_TYPE = 7 THEN 'MOBILE_API_STAFF'		
		ELSE 'UNKNOWN'
	END AS "USER_INTERFACE_TYPE", 
    p.SHOWUP_TIME                                                             AS "SHOW_UP_DATETIME",
	CASE 
		WHEN p.SHOWUP_INTERFACE_TYPE = 0 THEN 'OTHER'
		WHEN p.SHOWUP_INTERFACE_TYPE = 1 THEN 'CLIENT'
		WHEN p.SHOWUP_INTERFACE_TYPE = 2 THEN 'WEB'
		WHEN p.SHOWUP_INTERFACE_TYPE = 3 THEN 'KIOSK'
		WHEN p.SHOWUP_INTERFACE_TYPE = 4 THEN 'SCRIPT'
		WHEN p.SHOWUP_INTERFACE_TYPE = 5 THEN 'API'
		WHEN p.SHOWUP_INTERFACE_TYPE = 6 THEN 'MOBILE_API'
		WHEN p.SHOWUP_INTERFACE_TYPE = 7 THEN 'MOBILE_API_STAFF'	
		ELSE 'UNKNOWN'
	END AS "SHOW_UP_INTERFACE_TYPE", 	
    CAST(CAST (p.SHOWUP_USING_CARD AS INT) AS SMALLINT)                      AS "SHOWUP_USING_CARD",
    p.CANCELATION_TIME                                                         AS "CANCEL_DATETIME",
	CASE 
		WHEN p.CANCELATION_INTERFACE_TYPE = 0 THEN 'OTHER'
		WHEN p.CANCELATION_INTERFACE_TYPE = 1 THEN 'CLIENT'
		WHEN p.CANCELATION_INTERFACE_TYPE = 2 THEN 'WEB'
		WHEN p.CANCELATION_INTERFACE_TYPE = 3 THEN 'KIOSK'
		WHEN p.CANCELATION_INTERFACE_TYPE = 4 THEN 'SCRIPT'
		WHEN p.CANCELATION_INTERFACE_TYPE = 5 THEN 'API'
		WHEN p.CANCELATION_INTERFACE_TYPE = 6 THEN 'MOBILE_API'
		WHEN p.CANCELATION_INTERFACE_TYPE = 7 THEN 'MOBILE_API_STAFF'
		ELSE 'UNKNOWN'
	END AS "CANCEL_INTERFACE_TYPE",  
    p.CANCELATION_REASON                              AS "CANCEL_REASON",
        CASE
        WHEN (cancel_per.CENTER != cancel_per.TRANSFERS_CURRENT_PRS_CENTER
            OR  cancel_per.id != cancel_per.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = cancel_per.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = cancel_per.TRANSFERS_CURRENT_PRS_ID)
        ELSE cancel_per.EXTERNAL_ID
    END                                                                  AS "CANCEL_PERSON_ID",
    CAST(CAST (case when p.ON_WAITING_LIST = 1 or p.MOVED_UP_TIME > 0 then 1 else 0 end AS INT) AS SMALLINT) AS "WAS_ON_WAITING_LIST",
    p.MOVED_UP_TIME                                   AS "SEAT_OBTAINED_DATETIME",
    p.participation_number                            AS "PARTICIPANT_NUMBER",
    p.LAST_MODIFIED                                   AS "ETS",
    bs.ref                                            AS "SEAT_ID",
    p.SEAT_STATE                                      AS "SEAT_STATE"
FROM
    PARTICIPATIONS p
LEFT JOIN
    persons per
ON
    per.CENTER = p.PARTICIPANT_CENTER
AND per.ID = p.PARTICIPANT_ID
LEFT JOIN
    persons create_per
ON
    create_per.CENTER = p.creation_by_center
AND create_per.ID = p.creation_by_id
LEFT JOIN
    persons cancel_per
ON
    cancel_per.CENTER = p.cancelation_by_center
AND cancel_per.ID = p.cancelation_by_id
LEFT JOIN   
    BOOKING_SEATS bs
ON
    bs.ID = p.seat_id	