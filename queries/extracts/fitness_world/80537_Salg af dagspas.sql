-- This is the version from 2026-02-05
--  
SELECT DISTINCT
TO_CHAR(longtodate(inv.TRANS_TIME), 'DD-MM-YYYY') AS "DATE",
TO_CHAR(longtodate(inv.TRANS_TIME), 'HH24:MI') AS "TIME",
invl.CENTER,
prod.NAME,
invl.TOTAL_AMOUNT,
invl.QUANTITY,
inv.EMPLOYEE_CENTER ||'emp'|| inv.EMPLOYEE_ID AS salesperson,
salesperson.FULLNAME AS salesperson_name,
invl.PERSON_CENTER ||'p'|| invl.PERSON_ID AS Member,
member.FULLNAME AS Member_name,
member.external_ID

FROM
CLIPCARDS cc
JOIN INVOICELINES invl
ON
invl.CENTER = cc.INVOICELINE_CENTER
AND invl.ID = cc.INVOICELINE_ID
AND invl.SUBID = cc.INVOICELINE_SUBID
JOIN PRODUCTS prod
ON
prod.CENTER = invl.PRODUCTCENTER
AND prod.ID = invl.PRODUCTID
JOIN INVOICES inv
ON
inv.CENTER = invl.CENTER
AND inv.ID = invl.ID
JOIN PERSONS member
ON member.CENTER = invl.PERSON_CENTER
AND member.ID = invl.PERSON_ID
JOIN EMPLOYEES emp
ON emp.CENTER = inv.EMPLOYEE_CENTER
AND emp.ID = inv.EMPLOYEE_ID
JOIN PERSONS salesperson
ON salesperson.CENTER = emp.PERSONCENTER
AND salesperson.ID = emp.PERSONID
WHERE
inv.TRANS_TIME >= :dateFrom 
AND inv.TRANS_TIME <:dateTo
AND cc.INVOICELINE_CENTER in (:scope)
--AND prod.globalid = 'CLIPCARD_SPONSORED_TRIAL' 
AND prod.GLOBALID = 'DAYPASS_LOCAL'

GROUP BY
TO_CHAR(longtodate(inv.TRANS_TIME), 'DD-MM-YYYY'),
TO_CHAR(longtodate(inv.TRANS_TIME), 'HH24:MI'),
invl.CENTER,
prod.NAME,
invl.TOTAL_AMOUNT,
invl.QUANTITY,
(inv.EMPLOYEE_CENTER ||'emp'|| inv.EMPLOYEE_ID),
salesperson.FULLNAME,
(invl.PERSON_CENTER ||'p'|| invl.PERSON_ID),
member.FULLNAME,
member.external_id
