WITH PRG AS (
select * from (
select prg.id,
EXTRACTVALUE(xmltype(prg.PLUGIN_CONFIG, 871), '/configuration/section[@id = "ExtendedAttribute"]/value/text') as txtVal,
prg.name
from
SATS.PRIVILEGE_RECEIVER_GROUPS prg
)
where txtVal like 'UNBROKENMEMBERSHIPGROUPALL%'
)
select
t1.personid,
t1.text,
t1.name,
t1.useddatetime

from
(
select 
 pu.PERSON_CENTER || 'p' || pu.PERSON_ID as personid,
   invl.TEXT,
   prg.name, 
    to_char(longtodate(pu.USE_TIME),'dd-mm-yyyy HH24:Mi:SS') as useddatetime
 
from PRG

JOIN
    PRIVILEGE_GRANTS pg
on prg.id = pg.GRANTER_ID    
    
Join    
    PRIVILEGE_USAGES pu
ON
    pg.ID = pu.GRANT_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
   -- AND pg.GRANTER_ID = 149289
left JOIN
    INVOICE_LINES_MT invl
ON
    invl.CENTER = pu.TARGET_CENTER
    AND invl.ID = pu.TARGET_ID
    AND invl.SUBID = pu.TARGET_SUBID
    AND pu.TARGET_SERVICE = 'InvoiceLine'
    and invl.text not like 'PT discount%'

JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
and ptype in (2,4)

join persons p
on
pu.PERSON_CENTER  = p.center
and pu.PERSON_id = p.id
 

where p.external_id = :externalid

group by
pu.PERSON_CENTER || 'p' || pu.PERSON_ID,
   invl.TEXT,
    prg.name ,
    pu.USE_TIME) t1
group by
t1.personid,
t1.text,
t1.name,
t1.useddatetime