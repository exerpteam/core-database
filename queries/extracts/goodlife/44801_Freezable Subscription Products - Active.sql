with mpr_xml as (
select m.id, 
       cast(convert_from(m.product, 'UTF-8') AS xml) AS pxml 
from   masterproductregister m
where  m.cached_producttype = 10
)
select  m.id,
        m.cached_productname,
        m.globalId,
        unnest(xpath('//subscriptionType/freeze/FREEZELIMIT', mpr_xml.pxml)) AS freeze_limit,
        m.mapi_description,
        m.state AS mprState
from    masterproductregister m
join    mpr_xml on m.id = mpr_xml.id and m.cached_producttype = 10
where   m.state = 'ACTIVE'