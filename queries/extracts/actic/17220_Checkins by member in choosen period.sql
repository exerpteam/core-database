-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Mikael Ahlberg
* Purpose: List checkins with statistics and reason for given
* member and period.
*
*/
SELECT
 	p.center || 'p' || p.id AS MemberKey,
	c.shortname as HomeCenter,
	centers.name As checkinCenter,
    p.FULLNAME                                       AS CustomerName,
    ph.txtvalue                                      AS phonehome,
    pm.txtvalue                                      AS phonemobile,
    pem.txtvalue	                                  AS email,
		CASE
		WHEN br.NAME IS NOT NULL THEN BR.NAME
		WHEN act.NAME IS NOT NULL THEN act.NAME
		ELSE 'NONE'
	END 															AS CheckinReason,
	

	
TO_CHAR(longToDate(cil.CHECKIN_TIME),'YYYY-MM-DD')
AS checkintime

	
FROM
    PERSONS p
join centers c
	on p.center = c.id
LEFT JOIN person_ext_attrs ph
    ON
        ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN person_ext_attrs pem
    ON
        pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN person_ext_attrs pm
    ON
        pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'


left JOIN CHECKINs cil
    ON
        cil.person_CENTER = p.CENTER
    AND cil.person_id = p.ID
    and cil.CHECKIN_TIME >= :FromDate
	and cil.CHECKIN_TIME < :ToDate + 1000*60*60*24

LEFT JOIN Centers
On cil.CHECKIN_CENTER = Centers.ID

-- Checkin reason (Attend/Class)

LEFT JOIN ATTENDS att
ON	
	att.PERSON_CENTER = cil.person_CENTER
	AND att.PERSON_ID = cil.person_ID
	AND (att.START_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and attend is allowed
LEFT JOIN BOOKING_RESOURCES br
ON
	att.BOOKING_RESOURCE_CENTER = br.CENTER
	AND att.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN PARTICIPATIONS par
ON	
	par.PARTICIPANT_CENTER = cil.person_CENTER
	AND par.PARTICIPANT_ID = cil.person_ID
	AND (par.SHOWUP_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and class participation is allowed
LEFT JOIN BOOKINGS bk
ON
	bk.CENTER = par.BOOKING_CENTER
	AND bk.ID = par.BOOKING_ID
LEFT JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID

WHERE
    (p.CENTER,p.ID) IN (:keys)
ORDER BY
    p.center,
	p.id
