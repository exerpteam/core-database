-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     center, id, persons.LASTNAME, persons.ADDRESS1, persons.ADDRESS2, persons.ZIPCODE, persons.CITY FROM
     persons
 WHERE
     persons.SEX = 'C'
   