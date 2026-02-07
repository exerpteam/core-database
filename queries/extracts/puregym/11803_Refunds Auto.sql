 SELECT
     pr.DUE_DATE,
     pr.REQ_AMOUNT,
     p.center||'p'||p.id       MemberID,
     longtodate(pr.ENTRY_TIME) ENTRY_TIME,
     convert_from(je.big_text, 'UTF-8') AS Note,
     length(convert_from(je.big_text, 'UTF-8'))                                 AS lgth,
     CASE 
     WHEN e.CENTER||'emp'||e.id IS NULL 
     THEN 'emp'
     ELSE e.CENTER||'emp'||e.id
     END AS Employee,
     emp.FULLNAME                                                    AS Employee_name
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.center = pr.center
     AND ar.id = pr.id
     AND ar.AR_TYPE = 4
 JOIN
     PERSONS p
 ON
     p.CENTER = ar.CUSTOMERCENTER
     AND p.id = ar.CUSTOMERID
 LEFT JOIN
     JOURNALENTRIES je
 ON
     je.PERSON_CENTER = p.CENTER
     AND je.PERSON_ID = p.id
     AND je.CREATION_TIME BETWEEN pr.ENTRY_TIME -1000*60 AND pr.ENTRY_TIME + 1000*60*2
 LEFT JOIN
     EMPLOYEES e
 ON
     e.CENTER = je.CREATORCENTER
     AND e.id= je.CREATORID
 LEFT JOIN
     PERSONS emp
 ON
     emp.CENTER = e.PERSONCENTER
     AND emp.id = e.PERSONID
 WHERE
     pr.REQUEST_TYPE = 5
     AND p.center IN ($$scope$$)
     --AND p.id = 3364
     AND pr.DUE_DATE BETWEEN TRUNC(CURRENT_DATE - 7)AND TRUNC(CURRENT_DATE)