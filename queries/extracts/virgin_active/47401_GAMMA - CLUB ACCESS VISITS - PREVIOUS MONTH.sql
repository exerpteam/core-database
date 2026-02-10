-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CAST(datetolongtz(TO_CHAR(add_months(CURRENT_DATE, -1), 'yyyy-MM-dd HH24:MI' ),
            'Europe/Rome') AS bigint) AS FROMDATE,
            CAST(datetolongtz(TO_CHAR(last_day(add_months(CURRENT_DATE, -1)), 'yyyy-MM-dd HH24:MI'
            ), 'Europe/Rome') AS bigint) -1 AS TODATE,
            id 
            
            from centers c
            where c.country= 'IT'
    )
SELECT
    p.external_id                                                         "RecordID",
    TO_CHAR(longToDateC(cin.CHECKIN_TIME,p.center),'YYYY-MM-dd HH24:MI') "VisitDateTime",
    cin.CHECKIN_CENTER                                                   "ClubID",
    p.CENTER                                                             "HomeClubID",
    0                                                                    "EntryDenied"
FROM

    persons p
JOIN
    CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
AND cin.PERSON_ID = p.ID

JOIN params par
on par.id = p.center
WHERE
    cin.CHECKIN_TIME BETWEEN par.fromdate AND par.todate

