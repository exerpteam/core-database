SELECT
P.ID,
OldPID.txtvalue as OldPersonID,
longToDate(JE.CREATION_TIME)as CR_date,
JE.TEXT,
JE.NAME
FROM
    PERSONS p
Left JOIN JOURNALENTRIES JE
ON
    JE.PERSON_CENTER = p.CENTER
    AND JE.PERSON_ID = p.ID
left join PERSON_EXT_ATTRS OldPID 
on 
   P.ID = OldPID.Personid
   and OldPID.name = '_eClub_OldSystemPersonId'
WHERE P.CENTER = 401
AND OldPID.txtvalue is not null
and rownum <=10000