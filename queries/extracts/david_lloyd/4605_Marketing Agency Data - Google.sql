-- The extract is extracted from Exerp on 2026-02-08
--  
select
TRIM(lower(person_email.txtvalue :: Text))                      as "Email",
coalesce(_eClub_PhoneSMS.txtvalue,person_phone_work.txtvalue)   as "Phone",
p.firstname                                                     as "First Name",
p.lastname                                                      as "Last Name",
co.name                                                         as "Country",
p.zipcode                                                       as "Zip"
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
WHERE EXISTS  -- should be a member or ex-member
(
SELECT 1
FROM subscriptions s
WHERE s.owner_center = p.center
AND s.owner_id = p.id
)