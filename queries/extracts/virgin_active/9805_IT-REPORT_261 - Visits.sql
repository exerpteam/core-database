WITH
    params AS
    (
        SELECT
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ), 'Europe/Rome') - 1000*60*
            60*24 AS bigint) AS from_date,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ), 'Europe/Rome') AS bigint) -1
            AS to_date
    )
 SELECT
     p.external_id AS "RecordID",
     to_char(longToDatetz(cin.CHECKIN_TIME,'Europe/Rome'),'YYYY-MM-dd HH24:MI') "VisitDateTime",
     cin.CHECKIN_CENTER "ClubID",
     p.CENTER "HomeClubID",
                 0 "EntryDenied"
 FROM
    params,
    PERSONS p
JOIN
    CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
AND cin.PERSON_ID = p.ID
WHERE
    cin.CHECKIN_TIME BETWEEN params.from_date AND params.to_date
AND p.country = 'IT'
and p.EXTERNAL_ID is not null
