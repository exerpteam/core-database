-- This is the version from 2026-02-05
--  
SELECT me.CENTER || 'p' || me.ID AS CustomerID,
       pe.TXTVALUE AS email,
       TO_CHAR(longToDate(me.SENTTIME), 'yyyy-mm-dd') AS sent_time,
       TO_CHAR(longToDate(me.last_modified), 'yyyy-mm-dd') AS last_modified,
       TO_CHAR(longToDate(me.earliest_delivery_time), 'yyyy-mm-dd') AS earliest_delivery_time,
       me.subject AS Subject
FROM fw.MESSAGES me
JOIN fw.PERSON_EXT_ATTRS pe
  ON me.CENTER = pe.PERSONCENTER
 AND me.ID = pe.PERSONID
WHERE pe.NAME = '_eClub_Email'
  AND me.CENTER IN (:scope)
  AND me.SENTTIME BETWEEN :StartDate AND :ToDate
  AND (
        me.subject LIKE '%PureGym: Husk din betaling for denne måned - så er du good to go!%'
     OR me.subject LIKE '%Rykker nr. 2 - PureGym Denmark A/S%'
     OR me.subject LIKE '%Rykker nr. 1 - PureGym Denmark A/S%'
     OR me.subject LIKE '%CASH_COLLECTION%'
      );
