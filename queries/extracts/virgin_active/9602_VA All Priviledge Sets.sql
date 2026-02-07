 SELECT
         ps.ID,
         ps.NAME,
         ps.DESCRIPTION,
         ps.SCOPE_TYPE,
         ps.PRIVILEGE_SET_GROUPS_ID,
         psg.NAME
 FROM
         PRIVILEGE_SETS ps
 JOIN
         PRIVILEGE_SET_GROUPS psg
 ON
         psg.ID = ps.PRIVILEGE_SET_GROUPS_ID
 WHERE
         ps.STATE = 'ACTIVE'
