-- The extract is extracted from Exerp on 2026-02-08
--  
select
TRIM(lower(person_email.txtvalue))                              as "email",
null                                                            as "email",
null                                                            as "email",
person_phone.txtvalue                                           as "phone",
person_phone_work.txtvalue                                      as "phone",
_eClub_PhoneSMS.txtvalue                                        as "phone",
null                                                            as "madid",
p.firstname                                                     as "fn",
p.lastname                                                      as "ln",
p.zipcode                                                       as "zip",
p.city                                                          as "ct",
null                                                            as "st",
co.name                                                         as "country",
p.birthdate                                                     as "dob",
EXTRACT('YEAR' from p.birthdate)                                as "doby",
case when p.sex in('F','M') then p.sex else null end            as "gen",
date_part('year', age(current_date, p.birthdate))::int          as "age",
COALESCE(legacyPersonId.txtvalue,p.external_id)                 AS "uid",
null                                                            AS "value"
from persons p
join countries co on 
        p.country = co.id and p.persontype not in (2,10) and lower(p.sex) <>'c' -- 2= staff and 10= external staff
left join
person_ext_attrs person_email on
        p.center =person_email.PERSONCENTER
        AND p.id =person_email.PERSONID AND person_email.name='_eClub_Email'
left join
person_ext_attrs person_phone on
        p.center =person_phone.PERSONCENTER
        AND p.id =person_phone.PERSONID AND person_phone.name='_eClub_PhoneHome'
left join
person_ext_attrs person_phone_work on
        p.center =person_phone_work.PERSONCENTER
        AND p.id =person_phone_work.PERSONID AND person_phone_work.name='_eClub_PhoneWork'
left join
person_ext_attrs _eClub_PhoneSMS on
        p.center =_eClub_PhoneSMS.PERSONCENTER
        AND p.id =_eClub_PhoneSMS.PERSONID AND _eClub_PhoneSMS.name='_eClub_PhoneSMS'
LEFT JOIN
        PERSON_EXT_ATTRS legacyPersonId
    ON
        p.center=legacyPersonId.PERSONCENTER
    AND p.id=legacyPersonId.PERSONID
    AND legacyPersonId.name='_eClub_OldSystemPersonId'
WHERE EXISTS  -- should be a member or ex-member
(
SELECT 1
FROM subscriptions s
WHERE s.owner_center = p.center
AND s.owner_id = p.id
)