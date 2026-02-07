select
    c.ID,
    c.SHORTNAME,
    c.NAME,
    c.ADDRESS1,
    c.ADDRESS2,
    c.ZIPCODE,
    c.CITY,
    c.COUNTRY,
    decode(c.CENTER_TYPE, 1, 'GLOBAL_HO', 2, 'NATIONAL_HO', 3, 'REGIONAL_HO', 4, 'CENTER') as CENTER_TYPE
from 
    eclub2.centers c
where
    c.id >= 100 and c.ID < 900
order by 1
