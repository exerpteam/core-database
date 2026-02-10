-- The extract is extracted from Exerp on 2026-02-08
--  
select 
        per.FULLNAME,
        per.center || 'p' || per.id AS "P ref",
        pin.IDENTITY as PIN,
        DECODE ( per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
      DECODE ( per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS STATUS

from PUREGYM.PERSONS per

join PUREGYM.PERSON_EXT_ATTRS ext
on ext.PERSONCENTER = per.CENTER
and ext.PERSONID = per.ID

LEFT JOIN PUREGYM.ENTITYIDENTIFIERS pin
ON
    pin.REF_CENTER = per.CENTER
    AND pin.REF_ID = per.ID
    AND pin.IDMETHOD = 5
    AND pin.ENTITYSTATUS = 1
    AND pin.REF_TYPE = 1

where   
    
    ext.TXTVALUE = 'ACCESS'
    and ext.NAME = 'STAFF_ACCESS'
    and per.CENTER in (:scope)
