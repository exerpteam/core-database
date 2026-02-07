-- This is the version from 2026-02-05
--  
SELECT
     center, id, persons.LASTNAME, persons.ADDRESS1, persons.ADDRESS2, persons.ZIPCODE, persons.CITY FROM
     persons
 WHERE
     persons.SEX = 'C'
   