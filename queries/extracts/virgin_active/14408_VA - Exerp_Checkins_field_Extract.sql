SELECT
P.ID,
OldPID.txtvalue as OldPersonID,
CI.PERSON_CENTER,
longToDate(CI.CHECKIN_TIME),
longToDate(CI.CHECKIN_TIME)
FROM
    PERSONS P
LEFT JOIN CHECKINS CI
ON
    CI.PERSON_CENTER = P.CENTER
    AND CI.PERSON_ID = P.ID
left join PERSON_EXT_ATTRS OldPID 
on 
   P.ID = OldPID.Personid
   and OldPID.name = '_eClub_OldSystemPersonId'
WHERE CI.PERSON_CENTER = 199
AND OldPID.txtvalue is not null