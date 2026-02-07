 select
 ca.center,
 ca.id,
 ca.subid,
 c.LASTNAME,
 ca.NAME,
 c.ADDRESS1,
 c.ADDRESS2,
 c.ZIPCODE,
 c.CITY,
 c.COUNTRY
 from
     PERSONS c
 join
     COMPANYAGREEMENTS ca on ca.center = c.center and ca.id = c.id
 where
 c.center >= :FromCenter
     and c.center <= :ToCenter
 order by 1,2,3
