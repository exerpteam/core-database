-- The extract is extracted from Exerp on 2026-02-08
-- Used to establish how many members have an RFID band at a club
 SELECT DISTINCT
     p.CENTER || 'p' || p.id member_id,
     ' ' || ei.IDENTITY || ' ' "CARDNO",
     to_char(longToDateC(ei.START_TIME,p.center),'YYYY-MM-dd HH24:MI')                                                      "ISSUEDATE",
 case ei.IDMETHOD when 1 then 'Magnetic' when 2 then 'MagneticCard' when 4 then 'RFCard' when 5 then 'Pin' end CARD_TYPE
 FROM
     ENTITYIDENTIFIERS ei
 JOIN
     PERSONS oldP
 ON
     oldP.CENTER = ei.REF_CENTER
     AND oldP.ID = ei.REF_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = oldP.CURRENT_PERSON_CENTER
     AND p.ID = oldP.CURRENT_PERSON_ID
 WHERE
     ei.ENTITYSTATUS = 1
     AND ei.REF_TYPE = 1
         and p.center in ($$scope$$)
     AND ei.IDMETHOD = 4
