-- The extract is extracted from Exerp on 2026-02-08
--  
select
null as remote_chain_id,
P.CENTER as remote_site_id,
P.CENTER||'p'||P.ID as remote_user_id,
1 as membership_type,
--DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') as membership_type,
P.LASTNAME as sname,
P.FIRSTNAME as fname,
P.SEX as gender,
nvl(to_char(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), CREATIONDATE.txtvalue) as joined,
CREATIONDATE.TXTVALUE as created, 
to_char(P.BIRTHDATE, 'YYYY-MM-DD') as dob,
P.ADDRESS1 as house,
P.ADDRESS2 as street,
P.ADDRESS3 as locality,
Z.CITY as town,
Z.COUNTY as county,
Z.ZIPCODE as postcode,
HOMEPHONE.TXTVALUE as telno,
MOBILEPHONE.TXTVALUE as mobno,
EMAIL.TXTVALUE as email,
null as updated,
DECODE (P.STATUS, 0,'INACTIVE', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE') as valid,
P.EXTERNAL_ID as remote_barcode,
case when active_subs.MaxEndDate is not null and active_subs.MaxEndDate < to_date('2100-01-01', 'YYYY-MM-DD') then active_subs.MaxEndDate else null end as expires, 
case when p.status not in (1,3) then P.LAST_ACTIVE_END_DATE else null end as cancelled, --CHECK
null as member_category,
case
        when ALLOWLETTER.TXTVALUE = 'true' and ALLOWNEWSLETTER.TXTVALUE = 'true' then 0
        else 1
end as letter_opt,
case
        when ALLOWEMAIL.TXTVALUE = 'true' and ALLOWNEWSLETTER.TXTVALUE = 'true' then 0
        else 1
end as email_opt,
case
        when ALLOWSMS.TXTVALUE = 'true' and ALLOWNEWSLETTER.TXTVALUE = 'true' then 0
        else 1
end as sms_opt,
case
        when ALLOWPHONE.TXTVALUE = 'true' and ALLOWNEWSLETTER.TXTVALUE = 'true' then 0
        else 1
end as phone_opt,
case
        when SMSMARKETING.TXTVALUE = 'true' and ALLOWNEWSLETTER.TXTVALUE = 'true' then 0
        else 1
end as SMSMARKETING
from PERSONS P
join ZIPCODES Z on (P.COUNTRY = Z.COUNTRY and P.ZIPCODE = Z.ZIPCODE and P.CITY = Z.CITY)
left join PERSON_EXT_ATTRS HOMEPHONE on (P.CENTER = HOMEPHONE.PERSONCENTER and P.ID = HOMEPHONE.PERSONID and HOMEPHONE.NAME = '_eClub_PhoneHome')
left join PERSON_EXT_ATTRS MOBILEPHONE on (P.CENTER = MOBILEPHONE.PERSONCENTER and P.ID = MOBILEPHONE.PERSONID and MOBILEPHONE.NAME = '_eClub_PhoneSMS')
left join PERSON_EXT_ATTRS EMAIL on (P.CENTER = EMAIL.PERSONCENTER and P.ID = EMAIL.PERSONID and EMAIL.NAME = '_eClub_Email')
left join PERSON_EXT_ATTRS CREATIONDATE on (P.CENTER = CREATIONDATE.PERSONCENTER and P.ID = CREATIONDATE.PERSONID and CREATIONDATE.NAME = 'CREATION_DATE')
left join PERSON_EXT_ATTRS ALLOWLETTER on (P.CENTER = ALLOWLETTER.PERSONCENTER and P.ID = ALLOWLETTER.PERSONID and ALLOWLETTER.NAME = '_eClub_AllowedChannelLetter')
left join PERSON_EXT_ATTRS ALLOWEMAIL on (P.CENTER = ALLOWEMAIL.PERSONCENTER and P.ID = ALLOWEMAIL.PERSONID and ALLOWEMAIL.NAME = '_eClub_AllowedChannelEmail')
left join PERSON_EXT_ATTRS ALLOWSMS on (P.CENTER = ALLOWSMS.PERSONCENTER and P.ID = ALLOWSMS.PERSONID and ALLOWSMS.NAME = '_eClub_AllowedChannelSMS')
left join PERSON_EXT_ATTRS ALLOWPHONE on (P.CENTER = ALLOWPHONE.PERSONCENTER and P.ID = ALLOWPHONE.PERSONID and ALLOWPHONE.NAME = '_eClub_AllowedChannelPhone')
left join PERSON_EXT_ATTRS ALLOWNEWSLETTER on (P.CENTER = ALLOWNEWSLETTER.PERSONCENTER and P.ID = ALLOWNEWSLETTER.PERSONID and ALLOWNEWSLETTER.NAME = '_eClubIsAcceptingEmailNewsLetters')
left join PERSON_EXT_ATTRS SMSMARKETING on (P.CENTER = SMSMARKETING.PERSONCENTER and P.ID = SMSMARKETING.PERSONID and SMSMARKETING.NAME = 'SMSMARKETING')
left join (
        select sub.owner_center, sub.owner_id, max(nvl(sub.end_date, to_date('2100-01-01', 'YYYY-MM-DD'))) as MaxEndDate from PUREGYM.SUBSCRIPTIONS sub where sub.state in (2,4,8) group by sub.owner_center, sub.owner_id         
) active_subs on active_subs.owner_center = p.center and active_subs.owner_id = p.id
where p.center in (:Scope) and p.LAST_ACTIVE_START_DATE is not null and p.status < 4 and p.sex != 'C' and p.persontype not in (2)