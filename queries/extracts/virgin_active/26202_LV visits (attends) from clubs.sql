SELECT
p.center||'p'||p.id "MembersshipNumber",
title.TXTVALUE "Title",
p.firstname "MemberFirstName",
p.lastname "MemberLastName",
p.address1 "Address1",
p.address2 "Address2",
p.address3 "Address3",
p.zipcode "Postcode",
p.city "City",
email.TXTVALUE "Email",
p.birthdate "DOB",
DECODE (p.status, 1, 'Active', 2, 'Inactive', 3, 'Temporary Inactive', 4, 'Transferred') "MemberStatus",
    a.CENTER "SITEID",
    p.CENTER "HOMESITEID",
    longToDate(a.START_TIME) "ATTENDANCEDATE"
 

FROM
    ATTENDS a

JOIN PERSONS p
ON
    p.CENTER = a.PERSON_CENTER
    AND p.ID = a.PERSON_id

Left Join PERSON_EXT_ATTRS email
        ON
            p.center=email.PERSONCENTER
            AND p.id=email.PERSONID
            AND email.name='_eClub_Email'
            AND email.TXTVALUE IS NOT NULL
Join
PERSON_EXT_ATTRS title
on
p.center = title.personcenter
and p.id = title.personid
and
title.name = '_eClub_Salutation'

where

p.center in (67)
and
longToDate(a.START_TIME) between :From_date  AND :To_date 