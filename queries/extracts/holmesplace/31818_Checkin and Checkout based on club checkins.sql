SELECT
    p.center ||'p'|| p.id as "Person Id",
	c.city as scope,
	c.shortname as "home club",
	cil.CHECKIN_CENTER as center,
p.sex,
p.firstname as FirstName,
p.lastNAME as LastName,
CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
    ph.txtvalue                                      AS phonehome,
    pm.txtvalue                                      AS phonemobile,
    pem.txtvalue                                     AS email,
to_char(longToDate(cil.CHECKIN_TIME),'yyyy-MM-dd HH24:MI:SS')                        AS checkin,
to_char(longToDate(cil.CHECKout_TIME),'yyyy-MM-dd HH24:MI:SS')                           AS checkOut
/*cil.CHECKout_TIME - cil.CHECKIN_TIME as TrainingTime */
FROM
   PERSONS p
join centers c
	on
	p.center = c.id
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
 JOIN CHECKINS cil
    ON
        cil.PERSON_CENTER = p.center
    AND cil.PERSON_ID = p.id
    and cil.CHECKIN_TIME between :FromDate and (:ToDate + 86400 * 1000 - 1)
WHERE
    cil.CHECKIN_CENTER in (:center)  

  
