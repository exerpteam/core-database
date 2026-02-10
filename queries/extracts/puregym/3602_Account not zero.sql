-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 p.CENTER || 'p' || p.id pid,
 p.FULLNAME,
 ar.BALANCE
 FROM
 STATE_CHANGE_LOG scl
 JOIN PERSONS p
 ON
 p.CENTER = scl.CENTER
 AND p.ID = scl.ID
 AND scl.ENTRY_START_TIME < dateToLong(TO_CHAR(current_timestamp-4,'YYYY-MM-dd HH24:MI'))
 JOIN ACCOUNT_RECEIVABLES ar
 ON
 ar.CUSTOMERCENTER = p.CENTER
 AND ar.CUSTOMERID = p.ID
 AND ar.BALANCE != 0
 WHERE
 scl.ENTRY_TYPE = 1
 AND scl.ENTRY_END_TIME IS NULL
 AND scl.STATEID = 2
 and p.CENTER in (:scope)
 and p.persontype not in (2,4)
