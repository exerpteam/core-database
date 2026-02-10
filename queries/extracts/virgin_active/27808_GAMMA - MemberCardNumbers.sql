-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         CONCAT(CONCAT(cast(REF_CENTER as char(3)),'p'), cast(REF_ID as varchar(8))) as "PERSONID"
         , IDENTITY AS "MEMBERCARDNUMBER"
 FROM
         ENTITYIDENTIFIERS ei
 INNER JOIN
         CENTERS c ON c.ID = ei.REF_CENTER
 WHERE
         C.COUNTRY = 'IT'
 AND
         ei.ENTITYSTATUS = 1
 AND
         ei.IDMETHOD = 1
