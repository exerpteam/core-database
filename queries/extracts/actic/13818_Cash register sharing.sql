SELECT
   c.CENTER || 'cr' || sp.TXTVALUE cr_key,
   sp.ID sp_primary_key,
   c.ID,
   c.CLIENTID,
   c.NAME,
   c.DESCRIPTION,
   c.STATE
FROM
   SYSTEMPROPERTIES sp
join CLIENTS c on c.ID = sp.CLIENT
WHERE
   sp.GLOBALID = 'CLIENT_CASHREGISTER'
   and c.CENTER in (:scope)