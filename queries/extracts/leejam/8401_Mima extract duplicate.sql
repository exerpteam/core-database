SELECT
    firstname||' '||lastname AS "Member name", center||'p'||id AS "Member ID",
    -- as "Email",
    CASE STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS "Person status",
    -- as "Subscription name",
    -- as "Subscription start date",
    -- as "Subscription end date",
    -- as "Subscription centre id",
    -- as "Subscription centre name",
    NATIONAL_ID AS "National ID", RESIDENT_ID AS "Resident ID"
    -- as "Passport",
    -- as "Mobile phone",
    -- as "Status",
FROM
    (
     SELECT
            *, COUNT(*) OVER (PARTITION BY NATIONAL_ID) AS cnt
       FROM
            persons
       where NATIONAL_ID is not null and status IN (0, 1, 3, 9)           
            ) p1
WHERE
    cnt > 1
    
    
UNION

SELECT
    firstname||' '||lastname AS "Member name", center||'p'||id AS "Member ID",
    -- as "Email",
    CASE STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS "Person status",
    -- as "Subscription name",
    -- as "Subscription start date",
    -- as "Subscription end date",
    -- as "Subscription centre id",
    -- as "Subscription centre name",
    NATIONAL_ID AS "National ID", RESIDENT_ID AS "Resident ID"
    -- as "Passport",
    -- as "Mobile phone",
    -- as "Status",
FROM
    (
     SELECT
            *, COUNT(*) OVER (PARTITION BY RESIDENT_ID) AS cnt
       FROM
            persons
       where RESIDENT_ID is not null and status IN (0, 1, 3, 9)     
            ) p2
WHERE
    cnt > 1