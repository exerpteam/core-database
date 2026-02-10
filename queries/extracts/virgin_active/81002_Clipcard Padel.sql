-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct * FROM (
select distinct
--p.center as club,
c.shortname as club_name,
p.center ||'p'|| p.id as id_socio, 
p.fullname as full_name,
prod.name as nome_clipcard,
--pg.NAME as Primary_Product_Group_NAME,
--pg.id as Primary_Product_Group_ID,
--STRING_AGG(DISTINCT pgAll.NAME, ' ; ') AS All_Prod_Groups,
--STRING_AGG(DISTINCT CAST(pgAll.id AS VARCHAR), ' ; ') AS All_Prod_Groups,
TO_TIMESTAMP(cl.valid_from / 1000) as data_vendita_clip,
TO_TIMESTAMP(cl.valid_until / 1000) as data_scadenza_clip,
--cl.clips_left as clips_left,
case cl.finished 
	WHEN 'FALSE' THEN 'Active'
	WHEN 'TRUE' THEN 'Used'
END as status
from 
clipcards cl 
join products prod on cl.id = prod.id
JOIN PERSONS p ON p.CENTER = cl.OWNER_CENTER AND p.ID = cl.OWNER_ID
join centers c on c.id = p.center and c.country = 'IT'
JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
 ON
     pgLink.PRODUCT_CENTER = prod.CENTER
     AND pgLink.PRODUCT_ID = prod.ID
 LEFT JOIN
     PRODUCT_GROUP pgAll
 ON
     pgAll.ID = pgLink.PRODUCT_GROUP_ID
where 
prod.center in ($$scope$$)
and prod.blocked = 0
AND prod.PTYPE = 4
and TO_TIMESTAMP(cl.valid_from / 1000) >= ($$venduta_dal$$)
--and prod.name in ('CLIPCARD HOTEL DES EPOQUES COLLECTION')
and pgAll.id in ('53401')
group by
	p.center,
	c.shortname,
	p.center ||'p'|| p.id, 
	p.fullname,
	prod.name,
	--pg.NAME,
	--pg.id, 
	TO_TIMESTAMP(cl.valid_from / 1000),
	TO_TIMESTAMP(cl.valid_until / 1000),
	cl.finished 
) test 
