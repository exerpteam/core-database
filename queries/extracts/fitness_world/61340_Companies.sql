-- The extract is extracted from Exerp on 2026-02-08
--  
Select distinct
per.center || 'p' || per.id AS COMPANYID,
per.FULLNAME
FROM
    persons per

Where
per.center in (:scope)
AND per.SEX = 'C'