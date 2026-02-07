SELECT
    p.CENTER || 'p' || p.ID pid
  , p.FIRSTNAME
  , p.MIDDLENAME
  , p.LASTNAME
  , p.ADDRESS1
  , p.ADDRESS2
  , p.COUNTRY
  , p.ZIPCODE
  , p.CITY
  , p.BIRTHDATE
  , p.SEX
  ,ExtAllowedChannelPhone.TXTVALUE         AllowedChannelPhone
  ,ExtAllowedChannelEmail.TXTVALUE         AllowedChannelEmail
  ,ExtSalutation.TXTVALUE                  Salutation
  ,ExtPhoneHome.TXTVALUE                   PhoneHome
  ,ExtIsAcceptingThirdPartyOffers.TXTVALUE IsAcceptingThirdPartyOffers
  ,ExtAllowedChannelSMS.TXTVALUE           AllowedChannelSMS
  ,ExtIsAcceptingEmailNewsLetters.TXTVALUE IsAcceptingEmailNewsLetters
  ,ExtPhoneSMS.TXTVALUE                    PhoneSMS
FROM
    PERSONS p
LEFT JOIN
    PERSON_EXT_ATTRS ExtAllowedChannelPhone
ON
    ExtAllowedChannelPhone.PERSONCENTER = p.CENTER
    AND ExtAllowedChannelPhone.PERSONID = p.ID
    AND ExtAllowedChannelPhone.NAME = '_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS ExtAllowedChannelEmail
ON
    ExtAllowedChannelEmail.PERSONCENTER = p.CENTER
    AND ExtAllowedChannelEmail.PERSONID = p.ID
    AND ExtAllowedChannelEmail.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS ExtSalutation
ON
    ExtSalutation.PERSONCENTER = p.CENTER
    AND ExtSalutation.PERSONID = p.ID
    AND ExtSalutation.NAME = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS ExtPhoneHome
ON
    ExtPhoneHome.PERSONCENTER = p.CENTER
    AND ExtPhoneHome.PERSONID = p.ID
    AND ExtPhoneHome.NAME = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS ExtIsAcceptingThirdPartyOffers
ON
    ExtIsAcceptingThirdPartyOffers.PERSONCENTER = p.CENTER
    AND ExtIsAcceptingThirdPartyOffers.PERSONID = p.ID
    AND ExtIsAcceptingThirdPartyOffers.NAME = 'eClubIsAcceptingThirdPartyOffers'
LEFT JOIN
    PERSON_EXT_ATTRS ExtAllowedChannelSMS
ON
    ExtAllowedChannelSMS.PERSONCENTER = p.CENTER
    AND ExtAllowedChannelSMS.PERSONID = p.ID
    AND ExtAllowedChannelSMS.NAME = '_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS ExtIsAcceptingEmailNewsLetters
ON
    ExtIsAcceptingEmailNewsLetters.PERSONCENTER = p.CENTER
    AND ExtIsAcceptingEmailNewsLetters.PERSONID = p.ID
    AND ExtIsAcceptingEmailNewsLetters.NAME = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS ExtPhoneSMS
ON
    ExtPhoneSMS.PERSONCENTER = p.CENTER
    AND ExtPhoneSMS.PERSONID = p.ID
    AND ExtPhoneSMS.NAME = '_eClub_PhoneSMS'
left join CLIPCARDS cc on cc.OWNER_CENTER = p.CENTER and cc.OWNER_ID = p.ID and cc.CANCELLED = 0 and cc.BLOCKED = 0    
WHERE
        cc.CENTER is null and 
    (
        p.CENTER,p.ID) IN
                           (
                           SELECT DISTINCT
                               table1.CENTER
                             , table1.ID
                           FROM
                               (
                                   SELECT
                                       cp.external_id
                                     , p.current_person_center                                           AS CENTER
                                     , p.current_person_id                                               AS ID
                                     , COUNT(DISTINCT s.center||s.id) over (partition BY cp.external_id)    cnt
                                   FROM
                                       persons p
                                   JOIN
                                       persons cp
                                   ON
                                       p.current_person_center = cp.center
                                       AND p.current_person_id = cp.id
                                   LEFT JOIN
                                       SUBSCRIPTIONS s
                                   ON
                                       s.OWNER_CENTER = p.CENTER
                                       AND s.OWNER_ID = p.ID
                                   WHERE
                                       cp.CENTER in ($$scope$$)
                               ) table1
                           JOIN
                               RELATIVES rel
                           ON
                               rel.CENTER = table1.CENTER
                               AND rel.ID = table1.ID
                               AND rel.rtype = 8
                               AND ((
                                       RELATIVECENTER = 100
                                       AND RELATIVEID = 27001)
                                   OR (
                                       RELATIVECENTER = 100
                                       AND RELATIVEID = 203))
                           JOIN
                               PERSON_EXT_ATTRS pea
                           ON
                               pea.PERSONCENTER = table1.CENTER
                               AND pea.PERSONID = table1.ID
                               AND pea.NAME in ('eClubIsAcceptingEmailNewsLetters','eClubIsAcceptingThirdPartyOffers')
                               AND pea.TXTVALUE = 'true'
                           WHERE
                               cnt = 0 )