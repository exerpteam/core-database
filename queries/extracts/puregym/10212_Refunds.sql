--21p3364
SELECT
    pr.DUE_DATE,
    pr.REQ_AMOUNT,
    p.center||'p'||p.id                                                   MemberID,
    longtodate(pr.ENTRY_TIME)                                             ENTRY_TIME,
    UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(je.BIG_TEXT, 2000,1), 'UTF8') AS Note,
    DECODE(e.CENTER||'emp'||e.id,'emp',NULL, e.CENTER||'emp'||e.id)    AS Employee,
    emp.FULLNAME                                                       AS Employee_name
FROM
    PUREGYM.PAYMENT_REQUESTS pr
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
    AND ar.AR_TYPE = 4
JOIN
    PUREGYM.PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
LEFT JOIN
    PUREGYM.JOURNALENTRIES je
ON
    je.PERSON_CENTER = p.CENTER
    AND je.PERSON_ID = p.id
    AND je.CREATION_TIME BETWEEN pr.ENTRY_TIME -1000*60 AND pr.ENTRY_TIME + 1000*60*2
LEFT JOIN
    PUREGYM.EMPLOYEES e
ON
    e.CENTER = je.CREATORCENTER
    AND e.id= je.CREATORID
LEFT JOIN
    PUREGYM.PERSONS emp
ON
    emp.CENTER = e.PERSONCENTER
    AND emp.id = e.PERSONID
WHERE
    pr.REQUEST_TYPE = 5
    AND p.center IN ($$scope$$)
    --AND p.id = 3364
     AND pr.DUE_DATE BETWEEN $$from_date$$ AND $$to_date$$