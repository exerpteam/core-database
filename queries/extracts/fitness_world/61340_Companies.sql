-- This is the version from 2026-02-05
--  
Select distinct
per.center || 'p' || per.id AS COMPANYID,
per.FULLNAME
FROM
    persons per

Where
per.center in (:scope)
AND per.SEX = 'C'