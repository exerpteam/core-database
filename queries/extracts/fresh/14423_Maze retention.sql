SELECT  /*+ index(Checkin_Log IDX_CHKIN_TIME) */
    per.center||'p'||per.id AS PersonId,
    per.Firstname,
    per.Lastname,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE',
3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT',
7,'DELETED','UNKNOWN') AS Person_STATUS,
/*    per.SSN, */
    checkin_log.Checkin_Center,
    to_char(longtodate(Checkin_Log.Checkin_Time), 'YYYY-MM-dd')AS CheckinDate,
/*    per.address1,
    per.address2,
    per.zipcode,
    z.city,*/
 per.First_active_start_date,
    pe_email.txtvalue as email,
    allowed_email.txtvalue as allowed_email
/*    allowed_NewsLetter.txtvalue as allowed_newsletter,
    allowed_ChannelLetter.txtvalue as allowed_letter,
    third_party_offers.txtvalue as allowed_3rd,
    allowed_ChannelPhone.txtvalue as allowed_phone,
    allowed_ChannelSMS.txtvalue as allowed_SMS */
FROM
    Checkin_Log
JOIN Persons per
    ON
    Checkin_log.center = Per.Center
    AND Checkin_log.id = Per.Id
/* JOIN zipcodes z
    ON
    z.zipcode=per.zipcode
    AND z.country =per.country */
left join person_ext_attrs pe_email
    on
    per.center = pe_email.personcenter
    and per.id = pe_email.personid
    and pe_email.name = '_eClub_Email' 
left join person_ext_attrs allowed_email
    on
    per.center = allowed_email.personcenter
    and per.id = allowed_email.personid
    and allowed_email.name = '_eClub_AllowedChannelEmail'

/*left join person_ext_attrs allowed_NewsLetter
    on
    per.center = allowed_NewsLetter.personcenter
    and per.id = allowed_NewsLetter.personid
    and allowed_NewsLetter.name = '_eClub_IsAcceptingEmailNewsLetters'
left join person_ext_attrs allowed_ChannelLetter
    on
    per.center = allowed_ChannelLetter.personcenter
    and per.id = allowed_ChannelLetter.personid
    and allowed_ChannelLetter.name = '_eClub_AllowedChannelLetter'
left join person_ext_attrs   third_party_offers
    on
    per.center = third_party_offers.personcenter
    and per.id = third_party_offers.personid
    and third_party_offers.name = '_eClub_IsAcceptingThirdPartyOffers'
left join person_ext_attrs allowed_ChannelPhone
    on
    per.center = allowed_ChannelPhone.personcenter
    and per.id = allowed_ChannelPhone.personid
    and allowed_ChannelPhone.name = '_eClub_AllowedChannelPhone'
left join person_ext_attrs allowed_ChannelSMS
    on
    per.center = allowed_ChannelSMS.personcenter
    and per.id = allowed_ChannelSMS.personid
    and allowed_ChannelSMS.name = '_eClub_AllowedChannelSMS' */
WHERE
    Checkin_Log.Checkin_Center >= :centerFrom
AND Checkin_Log.Checkin_Center <= :centerTo
and Checkin_Log.Checkin_Center not in(100,200,300,400)
and Checkin_Log.CHECKIN_TIME  >= datetolong(to_char(exerpsysdate() - :Days_back_in_time,'yyyy-mm-dd HH24:MI'))
and Checkin_Log.CHECKIN_TIME <= (datetolong(to_char(exerpsysdate() - 1, 'yyyy-mm-dd HH24:MI'))+ 24*3600*1000)
and pe_email.name is not null
and per.status in (1,3)
    and per.persontype <> 2 /*excluding staff*/
 ORDER BY
    Checkin_Time
