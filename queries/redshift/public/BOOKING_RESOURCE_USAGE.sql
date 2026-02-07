SELECT    
    bru.BOOKING_RESOURCE_CENTER||'br'||bru.BOOKING_RESOURCE_ID AS "RESOURCE_ID",
    bru.BOOKING_CENTER||'book'||bru.BOOKING_ID                   AS "BOOKING_ID",
    bru.STATE                                                  AS "STATE",
    bru.STARTTIME                                              AS "BOOKING_START_DATETIME",
    bru.STOPTIME                                               AS "BOOKING_STOP_DATETIME",
	bru.BOOKING_CENTER                                         AS "CENTER_ID",
    b.LAST_MODIFIED                                            AS "ETS"
FROM
    BOOKING_RESOURCE_USAGE bru
JOIN
    BOOKINGS b
ON
    b.CENTER = bru.BOOKING_CENTER
    AND b.ID = bru.BOOKING_ID 
