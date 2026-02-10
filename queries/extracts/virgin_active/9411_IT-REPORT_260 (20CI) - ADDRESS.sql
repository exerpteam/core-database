-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     p.EXTERNAL_ID "ADDRESSID",
     REPLACE(REPLACE(REPLACE(REPLACE(p.ADDRESS1,chr(10),' '),chr(13),' '),';',' '),'"','''') "ADDRESS1",
     REPLACE(REPLACE(REPLACE(REPLACE(p.ADDRESS2,chr(10),' '),chr(13),' '),';',' '),'"','''') "ADDRESS2",
     REPLACE(REPLACE(REPLACE(REPLACE(p.ADDRESS3,chr(10),' '),chr(13),' '),';',' '),'"','''') "ADDRESS3",
     p.CITY "TOWN",
     p.COUNTRY "COUNTY",
     p.ZIPCODE "POSTCODE"
 FROM
     PERSONS pOld
 JOIN PERSONS p
 ON
     p.CENTER = pOld.CURRENT_PERSON_CENTER
     AND p.ID = pOld.CURRENT_PERSON_ID
 where p.SEX != 'C'
 and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
