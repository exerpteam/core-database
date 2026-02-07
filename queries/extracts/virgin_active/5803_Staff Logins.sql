 SELECT
     per.FIRSTNAME,
     per.LASTNAME,
     emp.CENTER ||'emp'|| emp.ID as EMPLOYEE
 FROM
     PERSONS per
 JOIN
     EMPLOYEES emp
 ON
     emp.PERSONCENTER = per.CENTER
     AND emp.PERSONID = per.ID
  Where EMP.CENTER in (:scope)
