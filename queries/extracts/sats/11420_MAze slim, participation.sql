SELECT /*+ index(par IDX_START_TIME) */
    per.center||'p'||per.id AS PersonId,
    per.Firstname,
    per.Lastname,
    per.SSN,
    par.center,
    to_char(eclub2.longtodate(par.start_time), 'YYYY-MM-dd') AS Participation_start,
    per.address1,
    per.address2,
    per.zipcode,
    z.city,
    pe_email.txtvalue as email,
    allowed_email.txtvalue as allowed_email,
    allowed_NewsLetter.txtvalue as allowed_newsletter,
    allowed_ChannelLetter.txtvalue as allowed_letter,
    third_party_offers.txtvalue as allowed_3rd,
    allowed_ChannelPhone.txtvalue as allowed_phone,
    allowed_ChannelSMS.txtvalue as allowed_SMS 
FROM
     eclub2.participations par
JOIN eclub2.Persons per
    ON
    par.participant_center = Per.Center
    AND par.participant_id = Per.Id
JOIN eclub2.zipcodes z
    ON
    z.zipcode=per.zipcode
    AND z.country =per.country
left join eclub2.person_ext_attrs pe_email
    on
    per.center = pe_email.personcenter
    and per.id = pe_email.personid
    and pe_email.name = '_eClub_Email'
left join eclub2.person_ext_attrs allowed_email
    on
    per.center = allowed_email.personcenter
    and per.id = allowed_email.personid
    and allowed_email.name = '_eClub_AllowedChannelEmail'
left join eclub2.person_ext_attrs allowed_NewsLetter
    on
    per.center = allowed_NewsLetter.personcenter
    and per.id = allowed_NewsLetter.personid
    and allowed_NewsLetter.name = '_eClub_IsAcceptingEmailNewsLetters'
left join eclub2.person_ext_attrs allowed_ChannelLetter
    on
    per.center = allowed_ChannelLetter.personcenter
    and per.id = allowed_ChannelLetter.personid
    and allowed_ChannelLetter.name = '_eClub_AllowedChannelLetter'
left join eclub2.person_ext_attrs   third_party_offers
    on
    per.center = third_party_offers.personcenter
    and per.id = third_party_offers.personid
    and third_party_offers.name = '_eClub_IsAcceptingThirdPartyOffers'
left join eclub2.person_ext_attrs allowed_ChannelPhone
    on
    per.center = allowed_ChannelPhone.personcenter
    and per.id = allowed_ChannelPhone.personid
    and allowed_ChannelPhone.name = '_eClub_AllowedChannelPhone'
left join eclub2.person_ext_attrs allowed_ChannelSMS
    on
    per.center = allowed_ChannelSMS.personcenter
    and per.id = allowed_ChannelSMS.personid
    and allowed_ChannelSMS.name = '_eClub_AllowedChannelSMS' 
WHERE
    par.center >= :centerFrom
AND par.center <= :centerTo
and par.start_time >= eclub2.datetolong(to_char(exerpsysdate() - :Days_back_in_time,'yyyy-mm-dd HH24:MI'))
and par.start_time <= (eclub2.datetolong(to_char(exerpsysdate() - 1, 'yyyy-mm-dd HH24:MI'))+ 24*3600*1000)
ORDER BY
    par.showup_time