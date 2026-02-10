-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     act.ID,
     act.SCOPE_TYPE,
     act.SCOPE_ID,
     act.NAME,
     act.STATE,
     act.DESCRIPTION
 FROM
     ACTIVITY act
 WHERE
     act.STATE = 'ACTIVE'
