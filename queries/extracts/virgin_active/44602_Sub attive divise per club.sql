SELECT   c.id, c.SHORTNAME as club,
CONCAT(CONCAT(cast(ST.CENTER as char(3)),'SS'), cast(st.ID as varchar(8))) as subscriptionId, p.NAME as nome, p.PRICE as prezzoMensile, a.PRICE as prezzoAttivazione, p.requiredrole as ruolo
FROM
CENTERS c
INNER JOIN
SUBSCRIPTIONTYPES st
ON 
c.ID = st.CENTER
INNER JOIN PRODUCTS p
ON 
p.CENTER = st.CENTER
AND
p.ID = st.ID
INNER JOIN
PRODUCTS a
ON 
a.ID = st.PRODUCTNEW_ID
AND
a.CENTER = st.PRODUCTNEW_CENTER
WHERE
c.COUNTRY = 'IT'
and p.NAME NOT LIKE '%Cash%'
order by c.SHORTNAME, p.NAME