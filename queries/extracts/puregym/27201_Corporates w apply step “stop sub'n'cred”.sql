SELECT
    p.CENTER||'p'||p.id AS MemberID,
    p.FULLNAME,
    c.NAME AS Center,
    longtodate(JE.CREATION_TIME),
    je.CREATORCENTER||'emp'||je.CREATORID AS EmployeeID
FROM
    persons p
JOIN
    PUREGYM.JOURNALENTRIES je
ON
    je.PERSON_CENTER = p.CENTER
    AND p.ID = je.PERSON_ID
JOIN
    PUREGYM.CENTERS c
ON
    c.ID = p.CENTER
WHERE
    JE.NAME = 'Apply: Stop subscription and credit invoices'
    AND (
        JE.CREATION_TIME BETWEEN dateToLong(TO_CHAR(SYSDATE-:Days, 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')))
    AND p.PERSONTYPE = 4
ORDER BY
    JE.CREATION_TIME ASC