select 
    p.center,
    p.id,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DEL','UNKNOWN') AS STATUS,
    p.FIRSTNAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ZIPCODE,
    p.CITY,
    p.BIRTHDATE,
    p.SEX,
    p.SSN,
    email.TXTVALUE AS Email,
    home_phone.TXTVALUE AS HomePhone,
    mobile_phone.TXTVALUE AS MobilePhone,
    work_phone.TXTVALUE AS WorkPhone,
    NVL(channel_email.TXTVALUE, 'false') AS ACCEPT_CHANNEL_EMAIL ,
    NVL(channel_Phone.TXTVALUE, 'false') AS ACCEPT_CHANNEL_PHONE,
    NVL(channel_sms.TXTVALUE, 'false') AS ACCEPT_CHANNEL_SMS,
    NVL(pref_channel.TXTVALUE, 'none') AS PREFERRED_CHANNEL,
    NVL(accept_newsletters.TXTVALUE, 'false') AS ACCEPT_NEWSLETTERS,
    NVL(accept_3rd.TXTVALUE, 'false') AS ACCEPT_THIRD_PARTY,
    company_agr_rel.RELATIVECENTER as COMPANY_CENTER,
    company_agr_rel.RELATIVEID as COMPANY_ID,
    company_agr_rel.RELATIVESUBID as COMPANY_SUBID,
    case when transfer_from.txtvalue is not null then substr(transfer_from.txtvalue, 1, 3) else null end as OLD_TRANSFER_CENTER,
    case when transfer_from.txtvalue is not null then substr(transfer_from.txtvalue, 5) else null end as OLD_TRANSFER_ID

from 
    persons p

LEFT JOIN PERSON_EXT_ATTRS home_phone
ON
    home_phone.PERSONCENTER=p.center
    AND home_phone.PERSONID=p.id
    AND home_phone.name='_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS work_phone
ON
    work_phone.PERSONCENTER=p.center
    AND work_phone.PERSONID=p.id
    AND work_phone.name='_eClub_PhoneWork'
LEFT JOIN PERSON_EXT_ATTRS mobile_phone
ON
    mobile_phone.PERSONCENTER=p.center
    AND mobile_phone.PERSONID=p.id
    AND mobile_phone.name='_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS channel_email
ON
    channel_email.PERSONCENTER=p.center
    AND channel_email.PERSONID=p.id
    AND channel_email.name='_eClub_AllowedChannelEmail'
LEFT JOIN PERSON_EXT_ATTRS channel_letter
ON
    channel_letter.PERSONCENTER=p.center
    AND channel_letter.PERSONID=p.id
    AND channel_letter.name='_eClub_AllowedChannelLetter'
LEFT JOIN PERSON_EXT_ATTRS channel_phone
ON
    channel_phone.PERSONCENTER=p.center
    AND channel_phone.PERSONID=p.id
    AND channel_phone.name='_eClub_AllowedChannelPhone'
LEFT JOIN PERSON_EXT_ATTRS channel_sms
ON
    channel_sms.PERSONCENTER=p.center
    AND channel_sms.PERSONID=p.id
    AND channel_sms.name='_eClub_AllowedChannelSMS'
LEFT JOIN PERSON_EXT_ATTRS pref_channel
ON
    pref_channel.PERSONCENTER=p.center
    AND pref_channel.PERSONID=p.id
    AND pref_channel.name='_eClub_DefaultMessaging'
LEFT JOIN PERSON_EXT_ATTRS accept_newsletters
ON
    accept_newsletters.PERSONCENTER=p.center
    AND accept_newsletters.PERSONID=p.id
    AND accept_newsletters.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN PERSON_EXT_ATTRS accept_3rd
ON
    accept_3rd.PERSONCENTER=p.center
    AND accept_3rd.PERSONID=p.id
    AND accept_3rd.name='_eClub_IsAcceptingThirdPartyOffers'
LEFT JOIN PERSON_EXT_ATTRS transfer_from
ON
    transfer_from.PERSONCENTER=p.center
    AND transfer_from.PERSONID=p.id
    AND transfer_from.name='_eClub_TransferredFromId'
LEFT JOIN RELATIVES company_agr_rel 
ON
company_agr_rel.center = p.center and company_agr_rel.id = p.id and company_agr_rel.STATUS < 3 and company_agr_rel.RTYPE = 3

where
exists (
select 
    1
from 
    STATE_CHANGE_LOG scl
join 
    persons pers on pers.center=scl.center and pers.id = scl.id 
where 
    scl.ENTRY_TYPE = 1 
    and scl.STATEID = 1
    and (scl.BOOK_END_TIME >= datetolong(to_char(exerpsysdate()-3*365, 'YYYY-MM-DD HH24:MI')) or scl.BOOK_END_TIME is null)
    and pers.status not in (5,6) 
    and pers.sex != 'C'
    and pers.center = p.center and pers.id = p.id
) and 
    p.center >= :FromCenter
    and p.center <= :ToCenter

