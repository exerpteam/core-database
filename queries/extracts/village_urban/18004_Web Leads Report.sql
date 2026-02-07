WITH 
params AS materialized (
	SELECT c.id center,
		CAST(datetolongc(TO_CHAR(to_date(:start_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) AS FromDate,
		CAST(datetolongc(TO_CHAR(to_date(:to_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) + (24 * 3600 * 1000) - 1 AS ToDate
	FROM centers c
	),
journals AS materialized (
	SELECT PERSON_ID,
		PERSON_CENTER,
		name,
		convert_from(je.BIG_TEXT, 'UTF-8') AS "Note Details",
		CREATION_TIME,
		CREATORID,
		CREATORCENTER
	FROM JOURNALENTRIES je
	JOIN params
		ON params.center = je.person_center
	WHERE je.CREATION_TIME BETWEEN params.FromDate
			AND params.ToDate
		AND je.PERSON_CENTER IN (:Scope)
		AND je.NAME ilike :je_name
	),
chkins AS materialized (
	SELECT je.PERSON_CENTER,
		je.PERSON_ID,
		MAX(chk.CHECKIN_TIME) AS Last_Checkin
	FROM journals je
	LEFT JOIN CHECKINS chk
		ON chk.PERSON_CENTER = je.PERSON_CENTER
			AND chk.PERSON_ID = je.PERSON_ID
	GROUP BY je.PERSON_CENTER,
		je.PERSON_ID
	)
	
SELECT  p.CENTER || 'p' || p.ID                        AS PersonId,
	p.FULLNAME                                     AS "Member Name",
	email.TXTVALUE                                 AS Email,
	mobile.TXTVALUE                                AS Mobile,
	Home.TXTVALUE                                  AS "Home tel",
	c.NAME                                         AS Club,
	p.ZIPCODE                                      AS PostCode,
	p.SEX                                          AS Sex,
	pro.NAME                                       AS Subscription_Name,
	CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'UNKNOWN' END 
	                                               AS P_STATUS,
	TO_CHAR(longtodateC(je.CREATION_TIME, p.center), 'YYYY-MM-DD HH24:MI') 
	                                               AS "Date contact",
	je.NAME                                        AS "Note Subject",
	"Note Details",
	staff.FULLNAME                                 AS Staff,
	TO_CHAR(longtodateC(chkins.Last_Checkin, p.center), 'YYYY-MM-DD HH24:MI') 
	                                               AS "Last Attendance"
FROM journals je
LEFT JOIN PERSONS p
	ON p.ID = je.PERSON_ID
		AND p.CENTER = je.PERSON_CENTER
LEFT JOIN PERSON_EXT_ATTRS email
	ON email.PERSONCENTER = je.PERSON_CENTER
		AND email.PERSONID = je.PERSON_ID
		AND email.name = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS home
	ON p.center = home.PERSONCENTER
		AND p.id = home.PERSONID
		AND home.name = '_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS mobile
	ON p.center = mobile.PERSONCENTER
		AND p.id = mobile.PERSONID
		AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN CENTERS c
	ON je.PERSON_CENTER = c.ID
JOIN EMPLOYEES staffLogin
	ON staffLogin.ID = je.CREATORID
		AND staffLogin.CENTER = je.CREATORCENTER
LEFT JOIN PERSONS staff
	ON staff.ID = staffLogin.PERSONID
		AND staff.CENTER = staffLogin.PERSONCENTER
LEFT JOIN chkins
	ON chkins.PERSON_CENTER = je.PERSON_CENTER
		AND chkins.PERSON_ID = je.PERSON_ID
LEFT JOIN SUBSCRIPTIONS s
	ON s.OWNER_CENTER = p.CENTER
		AND s.OWNER_ID = p.ID
		AND s.STATE IN (2, 4, 8)
LEFT JOIN PRODUCTS pro
	ON pro.CENTER = s.SUBSCRIPTIONTYPE_CENTER
		AND pro.ID = s.SUBSCRIPTIONTYPE_ID