select 
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
    --NATIONAL_ID AS "National ID", RESIDENT_ID AS "Resident ID"
    txtvalue as "Identifier"
    -- as "Passport",
    -- as "Mobile phone",
    -- as "Status",
 
from (   
select *, COUNT(*) OVER (PARTITION BY txtvalue) AS cnt
from person_ext_attrs pea

where pea.name IN ('_eClub_PhoneSMS', '_eClub_Email', '_eClub_PassportNumber')
and txtvalue is not null 
) pea
join persons p on pea.personcenter = p.center and pea.personid = p.id and status IN (0, 1, 3, 9)
--group by name, txtvalue
where cnt > 1

limit 100000