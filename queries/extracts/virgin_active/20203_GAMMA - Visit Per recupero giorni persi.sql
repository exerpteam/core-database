SELECT
    p.UNIQUE_KEY "RecordID",
    to_char(longToDateC(cin.CHECKIN_TIME,p.center),'YYYY-MM-dd HH24:MI') "VisitDateTime",
    cin.CHECKIN_CENTER "ClubID",
    p.CENTER "HomeClubID",
	0 "EntryDenied"
FROM
    PERSONS_VW p
JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
where 
    cin.CHECKIN_TIME BETWEEN $$dateFrom$$ AND $$dateTo$$
	and p.country = 'IT'