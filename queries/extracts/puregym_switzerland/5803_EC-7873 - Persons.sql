-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center AS "Member center",
        CAST(p.id AS TEXT) AS "Member id",
        p.blacklisted AS "Blacklisted",
        p.firstname AS "First name",
        p.lastname AS "Last name",
        p.fullname AS "Full name",
        p.address1 AS "Adress",
        p.address2 AS "Adress 2",
        p.address3 AS "Adress 3",
        p.country AS "Country",
        p.zipcode AS "Postcode",
        p.city AS "City",
        p.birthdate AS "Birthday",
        p.sex AS "Gender",
        p.co_name AS "C/O Name",
        p.ssn AS "CPR",
        p.friends_allowance AS "Friend allowance",
        p.first_active_start_date AS "First start date",
        p.last_active_start_date "Latest start date",
        p.last_active_end_date AS "Latest end date",
        p.memberdays AS "Member days",
        p.accumulated_memberdays AS "Accumulated member days"
FROM persons p
WHERE
        (p.center,p.id) IN (:memberid)