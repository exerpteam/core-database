SELECT
    b.CENTER || 'book' || b.ID             AS "ID",
    b.NAME                               AS "NAME",
    b.CENTER                             AS "CENTER_ID",
    b.ACTIVITY                           AS "ACTIVITY_ID",
    cg.NAME                              AS "COLOR",
    b.STARTTIME                          AS "START_DATETIME",
    b.STOPTIME                           AS "STOP_DATETIME",
    b.CREATION_TIME                      AS "CREATION_DATETIME",
    b.STATE                              AS "STATE",
    b.CLASS_CAPACITY        AS "CLASS_CAPACITY",
    b.WAITING_LIST_CAPACITY AS "WAITING_LIST_CAPACITY",
    b.CANCELATION_TIME                   AS "CANCEL_DATETIME",
    CASE
        WHEN b.CANCELATION_TIME IS NOT NULL
        THEN B.CANCELLATION_REASON
        ELSE NULL
    END              AS "CANCEL_REASON",
    b.CLASS_CAPACITY AS "MAX_CAPACITY_OVERRIDE",
    CASE
        WHEN b.MAIN_BOOKING_CENTER IS NULL
        THEN b.CENTER || 'book' || b.ID
        ELSE b.MAIN_BOOKING_CENTER||'book'||b.MAIN_BOOKING_ID
    END                                                    AS "MAIN_BOOKING_ID",
    b.DESCRIPTION                                          AS "DESCRIPTION",
    b.COMENT                                               AS "COMMENT",
    CAST(CAST (b.ONE_OFF_CANCELLATION AS INT) AS SMALLINT) AS "SINGLE_CANCELLATION",
    COALESCE(CAST(CAST (b.min_age_strict AS INT) AS SMALLINT) ,0) AS "STRICT_AGE_LIMIT",
    CASE WHEN b.min_age >= 24 THEN b.min_age / 12
	     ELSE b.min_age
    END AS "MINIMUM_AGE",
    CASE WHEN b.max_age >= 24 THEN b.max_age / 12
	     ELSE b.max_age
    END AS "MAXIMUM_AGE",
	CASE WHEN b.min_age >= 24 THEN 'YEARS'
         WHEN b.min_age <  24 THEN 'MONTHS'
    END AS "MINIMUM_AGE_UNIT",
	CASE WHEN b.max_age >= 24 THEN 'YEARS'
         WHEN b.max_age <  24 THEN 'MONTHS'
    END AS "MAXIMUM_AGE_UNIT",
    CASE WHEN b.min_age >= 24 THEN (b.min_age / 12) || ' - ' 
                             ELSE CASE WHEN b.max_age >= 24 THEN b.min_age || ' months - ' ELSE  b.min_age || ' - ' END
    END 
    ||
    CASE WHEN b.max_age >= 24 THEN (b.max_age / 12) || ' years' 
                             ELSE b.max_age || ' months'
    END 				AS "AGE_TEXT",
    CASE
        WHEN a.activity_type IN (9,
                                 11)
        THEN b.BOOKING_PROGRAM_ID
        ELSE NULL
    END                       AS "BOOKING_PROGRAM_ID",
    b.STREAMING_ID            AS "STREAM_ID",
    b.ADDITIONAL_INFO         AS "ADDITIONAL_INFO",
    b.LAST_MODIFIED           AS "ETS",    
    CASE
        WHEN (creator.CENTER != creator.TRANSFERS_CURRENT_PRS_CENTER
                OR creator.id != creator.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = creator.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = creator.TRANSFERS_CURRENT_PRS_ID)
        ELSE creator.EXTERNAL_ID
    END                AS "CREATOR_PERSON_ID"    
FROM
    BOOKINGS b
JOIN
    CENTERS c
ON
    c.ID = b.CENTER
JOIN
    ACTIVITY a
ON
    a.ID = b.ACTIVITY
LEFT JOIN
    COLOUR_GROUPS cg
ON
    b.COLOUR_GROUP_ID = cg.ID
    AND b.COLOUR_GROUP_ID IS NOT NULL
LEFT JOIN
    PERSONS creator
ON
    creator.center = b.creator_center
    AND creator.id = b.creator_id    
