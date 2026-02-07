-- This is the version from 2026-02-05
--  
SELECT
p.center AS "Medlem center",
p.id::varchar(20) AS "Medlem id",
p.blacklisted AS "Blacklisted",
p.firstname AS "Navn",
p.lastname AS "Efternavn",
p.fullname AS "Fulde navn",
p.address1 AS "Adresse",
p.address2 AS "Adresse 2",
p.address3 AS "Adresse 3",
p.country AS "Land",
p.zipcode AS "Postnummer",
p.city AS "By",
p.birthdate AS "Fødselsdag",
p.sex AS "Køn",
p.co_name AS "C/O Navn",
p.ssn AS "CPR",
p.friends_allowance AS "Ven tilladt",
p.first_active_start_date AS "Første startdato",
p.last_active_start_date "Seneste startdato",
p.last_active_end_date AS "Seneste slutdato",
p.memberdays AS "Medlemsdage",
p.accumulated_memberdays AS "Akkumulerede medlemsdage"
FROM
persons p
WHERE
p.center ||'p'|| p.id IN (:memberid)