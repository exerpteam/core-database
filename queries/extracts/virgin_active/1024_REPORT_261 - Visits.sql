WITH
    PARAMS AS
    (
        SELECT
            CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE - interval '1 day' AS TIMESTAMP))) AS bigint)*1000 AS from_date,
            (CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE AS TIMESTAMP))) AS bigint)*1000) - 1 AS to_date
    
    )
SELECT
    p.EXTERNAL_ID                                                        "RecordID",
    TO_CHAR(longToDatetz(cin.CHECKIN_TIME,'Europe/London'),'YYYY-MM-dd HH24:MI') "VisitDateTime",
    cin.CHECKIN_CENTER                                                   "ClubID",
    p.CENTER                                                             "HomeClubID",
    0                                                                    "EntryDenied"
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
AND p.country = 'GB'
and p.EXTERNAL_ID is not null