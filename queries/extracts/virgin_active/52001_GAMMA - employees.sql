 SELECT
         CONCAT(CONCAT(cast(ei.PERSONCENTER as char(3)),'p'), cast(ei.PERSONID as varchar(8))) as personId,
         CONCAT(CONCAT(cast(ei.CENTER as char(3)),'emp'), cast(ei.ID as varchar(8))) as employeeId,
         ei.USE_API,
         ei.LAST_LOGIN,
         ei.BLOCKED
 FROM
         EMPLOYEES ei
 INNER JOIN
         CENTERS c ON c.ID = ei.PERSONCENTER
 WHERE
         C.COUNTRY = 'IT'
