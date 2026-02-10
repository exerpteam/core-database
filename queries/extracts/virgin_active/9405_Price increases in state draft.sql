-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.CENTER||'p'||p.ID                                                                    AS "Member ID",
     p.FULLNAME                                                                             AS "Member Name",
     s.CENTER||'ss'||s.ID                                                                   AS "Subscription ID",
     CASE  s.STATE  WHEN 2 THEN 'Active'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "Subscription State",
     p2.FULLNAME                                                                            AS "Employee Name",
     sp.EMPLOYEE_CENTER||'emp'||sp.EMPLOYEE_ID                                              AS "Employee ID",
     sp.FROM_DATE                                                                           AS "Price Change: FromDate",
     longtodate(sp.ENTRY_TIME)                                                      AS "Price Change: EntryTime"
 FROM
     SUBSCRIPTION_PRICE sp
 JOIN
     SUBSCRIPTIONS s
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.id
 JOIN
     persons p
 ON
     s.OWNER_CENTER = p.CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     EMPLOYEES e
 ON
     e.CENTER = sp.EMPLOYEE_CENTER
     AND e.ID = sp.EMPLOYEE_ID
 JOIN
     persons p2
 ON
     e.PERSONCENTER = p2.CENTER
     AND e.PERSONID = p2.ID
 WHERE
     sp.TYPE = 'SCHEDULED'
     AND sp.APPROVED = 0
     AND sp.APPLIED = 0
     AND sp.PENDING = 0
     AND sp.CANCELLED = 0
     AND s.STATE IN (2,4)
