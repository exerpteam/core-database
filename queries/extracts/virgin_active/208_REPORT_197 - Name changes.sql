 SELECT
     to_char(longToDateC(log.ENTRY_TIME,p.center),'YYYY-MM-DD HH24:MI') "Time",
     cen.SHORTNAME Club,
     p.CENTER || 'p' || p.ID pid,
     log.CHANGE_ATTRIBUTE,
     log2.NEW_VALUE value_before,
     log.NEW_VALUE value_after,
     log.CHANGE_SOURCE ,
     CASE
         WHEN log.LOGIN_TYPE = 'p'
         THEN log.PERSON_CENTER || 'p' || log.PERSON_ID || ' (' || p.FULLNAME || ')'
         WHEN log.LOGIN_TYPE = 'emp'
         THEN log.EMPLOYEE_CENTER || 'emp' || log.EMPLOYEE_ID || ' (' || pemp.FULLNAME || ')'
         ELSE 'Change source undefined, please report to Exerp'
     END AS "Changed by"
 FROM
     PERSON_CHANGE_LOGS log
 LEFT JOIN EMPLOYEES emp
 ON
     emp.CENTER = log.EMPLOYEE_CENTER
     AND emp.ID = log.EMPLOYEE_ID
 LEFT JOIN PERSONS pemp
 ON
     pemp.CENTER = emp.PERSONCENTER
     AND pemp.ID = emp.PERSONID
 JOIN PERSONS p
 ON
     p.CENTER = log.PERSON_CENTER
     AND p.ID = log.PERSON_ID
 LEFT JOIN PERSON_CHANGE_LOGS log2
 ON
     log2.ID = log.PREVIOUS_ENTRY_ID
 LEFT JOIN
     CENTERS cen
     ON p.CENTER = cen.ID
 WHERE
     log2.NEW_VALUE IS NOT NULL
  and p.center in (:scope)
 and log.ENTRY_TIME between :startDate and (:endDate + 1000*60*60*24)
 ORDER BY
     log.PERSON_CENTER,
     log.PERSON_ID,
     log.ENTRY_TIME
