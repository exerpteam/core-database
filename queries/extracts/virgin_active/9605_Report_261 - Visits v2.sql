SELECT
    p.UNIQUE_KEY "RecordID",
    longToDate(cin.CHECKIN_TIME) "VisitDateTime",
    cin.CHECKIN_CENTER "ClubID",
    p.CENTER "HomeClubID",
    'N/A' "EntryDenied"
FROM
    PERSONS_VW p
JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
	and p.country = 'GB'