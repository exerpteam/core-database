-- This is the version from 2026-02-05
-- Columns:  
* RecordID: This is the unique key for the person. It's similar as the p-number but will only exist for the active person. If the person for example gets transferred the p-number will change but the unique key (RecordID) will stay the same
* VisitDateTime: Date and time when the check-in was made
* ClubID: Club where the check-in was made
* HomeClubID: Home club of the member doing the check-in
* EntryDenied: Will always return zero since Exerp don't log invalid access attempts 

The extract reports ALL check-ins done yesterday related to when the extract was ran. 
If the same member checks in more then once a day all his check-ins will be counted. 
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
AND p.country = 'AU'
and p.EXTERNAL_ID is not null