SELECT
    per.center,
    per.id,
    per.firstname                                                                                                                                      AS Firstname,
    per.lastname                                                                                                                                       AS Lastname,
    per.address1                                                                                                                                       AS Address1,
    per.address2                                                                                                                                       AS Address2,
    per.Zipcode                                                                                                                                        AS ZipCode,
    Zip.City                                                                                                                                           AS City,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'D_ELETED','UNKNOWN') AS PERSON_STATUS,
    eclub2.longToDate(book.STARTTIME) BOOKING_START_TIME,
    book.name AS bookingName,
    act.NAME  AS ACTIVITY_NAME
FROM
    ECLUB2.PARTICIPATIONS par
JOIN ECLUB2.BOOKINGS book
ON
    book.CENTER = par.BOOKING_CENTER
    AND book.id = par.BOOKING_ID
JOIN ECLUB2.ACTIVITIES_NEW act
ON
    act.id = book.ACTIVITY
JOIN persons per
ON
    per.CENTER = par.PARTICIPANT_CENTER
    AND per.id = par.PARTICIPANT_ID
JOIN ECLUB2.ZIPCODES zip
ON
    zip.COUNTRY = per.COUNTRY
    AND zip.ZIPCODE = per.ZIPCODE
WHERE
    --/* time frame */
    book.STARTTIME >= :from
    AND book.STARTTIME < :to
    --/* only active */
    AND par.STATE = 'PARTICIPATION'
    --/* a specific center */
    AND book.CENTER = :center
ORDER BY
    act.name ,
    book.starttime