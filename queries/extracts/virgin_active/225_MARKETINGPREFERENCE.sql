SELECT
    p.EXTERNAL_ID "MARKETINGPREFERENCEID",
    p.EXTERNAL_ID "PERSONID",
    DECODE(atts.NAME,'_eClub_AllowedChannelEmail','ALLOW_EMAIL','_eClub_AllowedChannelLetter','ALLOW_LETTER','_eClub_AllowedChannelPhone','ALLOW_HOME_PHONE','_eClub_AllowedChannelSMS','ALLOW_CELLULAR_PHONE') "MARKETINGPREFERENCE",
    'NEED SOME CONTEXT FOR THIS AND ABOVE' "OPTIN",
    'N/A' "PREFERENCEDATE",
    'EXERP' "LATESTSOURCESYSTEM",
    '?' "SECKEY"
FROM
    PERSON_EXT_ATTRS atts
JOIN PERSONS oldP
ON
    oldP.CENTER = atts.PERSONCENTER
    AND oldP.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
WHERE
    atts.NAME IN ('_eClub_AllowedChannelEmail','_eClub_AllowedChannelLetter','_eClub_AllowedChannelPhone','_eClub_AllowedChannelSMS')
    /*
    USE BELOW?
    _eClub_IsAcceptingEmailNewsLetters
    _eClub_IsAcceptingThirdPartyOffers
    */
