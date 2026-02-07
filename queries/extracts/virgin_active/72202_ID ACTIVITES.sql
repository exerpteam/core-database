 SELECT
     act.ID,
     act.SCOPE_TYPE,
     act.SCOPE_ID,
     act.NAME,
     act.STATE,
     act.DESCRIPTION,
	 act.external_id
 FROM
     ACTIVITY act
 WHERE
     act.STATE = 'ACTIVE'
AND SCOPE_ID = '24'