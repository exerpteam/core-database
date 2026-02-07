SELECT DISTINCT
	P.CENTER ||'p'|| P.ID PersID,
	(select c.lastname from persons c where c.center = r.center and c.id = r.id ) as companyname,
	P.FIRSTNAME,
	P.MIDDLENAME,
	P.LASTNAME,
	P.ADDRESS1,
	P.ADDRESS2,
	P.COUNTRY,
	P.ZIPCODE,
	P.BIRTHDATE,
	P.SEX,
	P.PINCODE,
	P.FRIENDS_ALLOWANCE,
	P.CITY,
	ph.txtvalue AS phonehome,
	pm.txtvalue AS phonemobile,
	pem.txtvalue AS email,
	cen.SHORTNAME AS Centername,
	cen.external_id AS CostCenter
FROM PERSONS P 
LEFT JOIN CENTERS cen
ON
p.CENTER = cen.ID

LEFT JOIN SUBSCRIPTIONS S 
ON  
	P.CENTER = S.OWNER_CENTER  
	AND P.ID = S.OWNER_ID 
left join relatives r 
on 
	p.center = r.relativecenter 
	and p.id = r.relativeid 
	and r.rtype = 2 
	and r.status <> 3 
left join person_ext_attrs ph 
on 
	ph.personcenter = p.center 
	and ph.personid = p.id 
	and ph.name = '_eClub_PhoneHome' 
left join person_ext_attrs pem 
on 
	pem.personcenter = p.center 
	and pem.personid = p.id 
	and pem.name = '_eClub_Email' 
left join person_ext_attrs pm 
on 
	pm.personcenter = p.center 
	and pm.personid = p.id 
	and pm.name = '_eClub_PhoneSMS' 
WHERE 
	P.CENTER IN ( :Scoope ) 
	AND EXISTS ( SELECT checkins.person_CENTER, checkins.person_ID, COUNT(*) as NB FROM CHECKINs WHERE  checkins.person_CENTER = P.CENTER and checkins.person_ID = P.ID and CHECKIN_TIME BETWEEN :CheckinFrom AND :CheckinTo GROUP BY checkins.person_CENTER, checkins.person_ID HAVING COUNT(*) BETWEEN :min AND :max )
	AND P.STATUS IN ( :PersonStatus )
	AND S.START_DATE >= :MinStartDate 
	AND S.START_DATE <= :MaxStartDate
