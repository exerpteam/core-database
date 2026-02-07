SELECT
    book.CENTER || 'book' || book.ID "BOOKINGPRODUCTID",
    'N/A' "LowLevelName",
    book.NAME "GeneralName",
    ag.NAME "GroupName",
    book.CENTER "SiteID",
    br.NAME "StudioName",
    'EXERP' "SourceSystem",
    '?' "ExtRef"
FROM
    BOOKINGS book
JOIN ACTIVITY act
ON
    act.ID = book.ACTIVITY
JOIN ACTIVITY_GROUP ag
ON
    ag.ID = act.ACTIVITY_GROUP_ID
LEFT JOIN BOOKING_RESOURCE_USAGE bru
ON
    bru.BOOKING_CENTER = book.CENTER
    AND bru.BOOKING_ID = book.ID
LEFT JOIN BOOKING_RESOURCES br
ON
    br.CENTER = bru.BOOKING_RESOURCE_CENTER
    AND br.ID = bru.BOOKING_RESOURCE_ID
    AND br.TYPE = 'ROOM'
