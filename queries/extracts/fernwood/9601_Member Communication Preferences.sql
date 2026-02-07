SELECT 
        p.center ||'p'||p.id as "Person ID"
        ,p.external_id AS "External ID"
        ,Case
               WHEN p.status = 0 THEN 'Lead'
               WHEN p.status = 1 THEN 'Active'
               WHEN p.status = 2 THEN 'Inactive'
               WHEN p.status = 3 THEN 'Temporary Inactive'
               WHEN p.status = 4 THEN 'Transfered'
               WHEN p.status = 5 THEN 'Duplicate'
               WHEN p.status = 6 THEN 'Prospect'
               WHEN p.status = 7 THEN 'Deleted'
               WHEN p.status = 8 THEN 'Anonymized'
               WHEN p.status = 9 THEN 'Contact'
               ELSE 'Unknown'
        END AS "Person Status"
        ,Case
               When p.persontype = 0 THEN 'Private'
               When p.persontype = 1 THEN 'Student'
               When p.persontype = 2 THEN 'Staff'
               When p.persontype = 3 THEN 'Friend'
               When p.persontype = 4 THEN 'Corporate'
               When p.persontype = 5 THEN 'Onemancorporate'
               When p.persontype = 6 THEN 'Family'
               When p.persontype = 7 THEN 'Senior'
               When p.persontype = 8 THEN 'Guest'
               When p.persontype = 9 THEN 'Child'
               When p.persontype = 10 THEN 'External_Staff'
               ELSE 'Unknown'
        END AS "Person Type"
        ,Mobile.txtvalue AS "Mobile Number"
        ,Email.txtvalue AS "Email Address"
        ,Case
               WHEN AllowEmail.txtvalue = 'true' then 'Opted In'
               WHEN AllowEmail.txtvalue IS NULL then 'Opted In'
               WHEN AllowEmail.txtvalue = 'false' then 'Opted Out'
        END AS "Exerp Service Messages - Email"
        ,Case
               WHEN AllowSMS.txtvalue = 'true' then 'Opted In'
               WHEN AllowSMS.txtvalue IS NULL then 'Opted In'
               WHEN AllowSMS.txtvalue = 'false' then 'Opted Out'
        END AS "Exerp Service Messages - SMS"
        ,Case
               WHEN AcceptEmailMarketing.txtvalue = 'true' then 'Opted In'
               WHEN AcceptEmailMarketing.txtvalue IS NULL then 'Opted In'
               WHEN AcceptEmailMarketing.txtvalue = 'false' then 'Opted Out'
        END AS "Marketing Emails"
        ,Case
               WHEN AcceptSMSMarketing.txtvalue = 'true' then 'Opted In'
               WHEN AcceptSMSMarketing.txtvalue IS NULL then 'Opted In'
               WHEN AcceptSMSMarketing.txtvalue = 'false' then 'Opted Out'
        END AS "Marketing SMS"
        ,Case
               WHEN AcceptPhoneMarketing.txtvalue = 'true' then 'Opted In'
               WHEN AcceptPhoneMarketing.txtvalue IS NULL then 'Opted In'
               WHEN AcceptPhoneMarketing.txtvalue = 'false' then 'Opted Out'
        END AS "Marketing Phone Calls"
FROM
        persons p
LEFT JOIN
        person_ext_attrs Email
               on Email.personcenter = p.center
               and Email.personid = p.id
               and Email.name = '_eClub_Email'
LEFT JOIN
        person_ext_attrs Mobile
               on Mobile.personcenter = p.center
               and Mobile.personid = p.id
               and Mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
        person_ext_attrs AllowEmail
               on AllowEmail.personcenter = p.center
               and AllowEmail.personid = p.id
               and AllowEmail.name = '_eClub_AllowedChannelEmail'
LEFT JOIN
        person_ext_attrs AllowSMS
               on AllowSMS.personcenter = p.center
               and AllowSMS.personid = p.id
               and AllowSMS.name = '_eClub_AllowedChannelSMS'
LEFT JOIN
        person_ext_attrs AcceptSMSMarketing
               on AcceptSMSMarketing.personcenter = p.center
               and AcceptSMSMarketing.personid = p.id
               and AcceptSMSMarketing.name = 'AcceptSMSMarketing'
LEFT JOIN
        person_ext_attrs AcceptEmailMarketing
               on AcceptEmailMarketing.personcenter = p.center
               and AcceptEmailMarketing.personid = p.id
               and AcceptEmailMarketing.name = 'AcceptEmailMarketing'
LEFT JOIN
        person_ext_attrs AcceptPhoneMarketing
               on AcceptPhoneMarketing.personcenter = p.center
               and AcceptPhoneMarketing.personid = p.id
               and AcceptPhoneMarketing.name = 'AcceptPhoneMarketing'
WHERE
        p.status not in (4,5,7,8)
        AND 
        p.center in (:Scope)