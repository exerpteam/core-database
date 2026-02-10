-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT

    p.center || 'p' || p.ID 		AS PersonId,
	p.FIRST_ACTIVE_START_DATE,
	email.txtvalue AS email,
	DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,
    'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', NULL) AS "Membertype",
	p.center,
	p.sex,
	p.city,
	c.COUNTRY,
	TO_CHAR(trunc(months_between(TRUNC(:MemberBaseDate),p.birthdate)/12)) AS Age,

	DECODE ( channelEmail.txtvalue, 'true', 1, 0)                                                                                                             AS ALLOWEDCHANNELEMAIL,
    DECODE ( channelLetter.txtvalue, 'true', 1, 0)                                                                                                            AS ALLOWEDCHANNELLETTER,
    DECODE ( channelPhone.txtvalue, 'true', 1, 0)                                                                                                             AS ALLOWEDCHANNELPHONE,
    DECODE ( channelSMS.txtvalue, 'true', 1, 0)                                                                                                               AS ALLOWEDCHANNELSMS,
    DECODE ( emailNewsLetter.txtvalue, 'true', 1, 0)                                                                                                          AS ALLOWEDCHANNELNEWSLETTERS,
    DECODE ( thirdPartyOffers.txtvalue, 'true', 1, 0)                                                                                                         AS ALLOWEDCHANNELTHIRDPARTYOFFERS


	
	
  
	
FROM PERSONS p


LEFT JOIN SUBSCRIPTIONS sub
ON
	sub.OWNER_CENTER = p.CENTER
	AND sub.OWNER_ID = p.ID

JOIN centers c
ON c.id = p.center

	
	LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    p.CENTER = scl_ptype.CENTER
    AND p.ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (:MemberBaseDate +1))

LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
	
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
    AND p.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    p.center=channelLetter.PERSONCENTER
    AND p.id=channelLetter.PERSONID
    AND channelLetter.name='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
    AND p.id=channelPhone.PERSONID
    AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
    AND p.id=channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS emailNewsLetter
ON
    p.center=emailNewsLetter.PERSONCENTER
    AND p.id=emailNewsLetter.PERSONID
    AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    p.center=thirdPartyOffers.PERSONCENTER
    AND p.id=thirdPartyOffers.PERSONID
    AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'

	
WHERE
	p.CENTER IN (:Scope)


	AND sub.START_DATE <= date '2019-10-31' -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= date '2019-10-31') -- Date