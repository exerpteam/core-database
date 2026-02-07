SELECT
    book.NAME As ClassesBooked,
    p.EXTERNAL_ID, par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID participant_pid,
	p.FIRSTNAME, p.MIDDLENAME, p.LASTNAME, p.FULLNAME, 
	p.ADDRESS1,	p.ADDRESS2,	p.ADDRESS3,	p.COUNTRY,	p.ZIPCODE,	p.CITY,	p.BIRTHDATE, p.SEX,
	DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PersonStatus,
	home.txtvalue                      AS homephone,
	workphone.txtvalue                 AS workphone,
	mobile.txtvalue                    AS mobilephone,
	email.txtvalue                     AS email
	
FROM
    ACTIVITY_GROUP ag
JOIN ACTIVITY act
ON
    act.ACTIVITY_GROUP_ID = ag.ID
JOIN BOOKINGS book
ON
    book.ACTIVITY = act.ID
JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = book.CENTER
    AND par.BOOKING_ID = book.ID
JOIN PERSONS p
ON
	par.PARTICIPANT_CENTER = p.CENTER
	AND par.PARTICIPANT_ID = p.ID
	
LEFT JOIN
	PERSON_EXT_ATTRS personCreation
ON
	p.center=personCreation.PERSONCENTER
	AND p.id=personCreation.PERSONID
	AND personCreation.name='CREATION_DATE'
LEFT JOIN
	PERSON_EXT_ATTRS home
ON
	p.center=home.PERSONCENTER
	AND p.id=home.PERSONID
	AND home.name='_eClub_PhoneHome'
LEFT JOIN
	PERSON_EXT_ATTRS mobile
ON
	p.center=mobile.PERSONCENTER
	AND p.id=mobile.PERSONID
	AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
	PERSON_EXT_ATTRS workphone
ON
	p.center=workphone.PERSONCENTER
	AND p.id=workphone.PERSONID
	AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
	PERSON_EXT_ATTRS email
ON
	p.center=email.PERSONCENTER
	AND p.id=email.PERSONID
	AND email.name='_eClub_Email'
	
LEFT JOIN PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = par.CENTER
    AND pu.TARGET_ID = par.ID
    AND pu.TARGET_SERVICE = 'Participation'
LEFT JOIN PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
    AND pg.GRANTER_SERVICE = 'GlobalSubscription'
LEFT JOIN MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = pg.GRANTER_ID
LEFT JOIN PRODUCT_GROUP pg
ON
    pg.ID = mpr.PRIMARY_PRODUCT_GROUP_ID
WHERE
   	    par.start_time between $$fromTime$$ and $$toTime$$ * (1000*60*60*24)
    AND pu.ID IS NOT NULL
	and par.PARTICIPANT_CENTER in ($$scope$$)
    AND par.STATE = 'PARTICIPATION'

