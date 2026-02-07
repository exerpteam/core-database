 SELECT
     c.SHORTNAME,
     emp.CENTER || 'emp' || emp.ID emp_id,
     pemp.FIRSTNAME EMP_FIRSTNAME,
     pemp.LASTNAME EMP_LASTNAME,
     ss.SALES_DATE,
     ss.START_DATE,
     ss.PRICE_PERIOD,
     p.CENTER,
     p.ID,
     p.FULLNAME,
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END AS STATUS,
     CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
     p.FIRSTNAME,
     p.LASTNAME,
     p.SEX,
     p.BLACKLISTED,
     p.ADDRESS1,
     p.ADDRESS2,
     p.COUNTRY,
     p.ZIPCODE,
     p.BIRTHDATE,
     p.PINCODE,
     p.FRIENDS_ALLOWANCE,
     p.CITY,
     ph.txtvalue  AS phonehome,
     pm.txtvalue  AS phonemobile,
     pem.txtvalue AS email,
     p.MIDDLENAME
 FROM
     SUBSCRIPTION_SALES ss
 join CENTERS c on c.ID = ss.OWNER_CENTER
 JOIN EMPLOYEES emp
 ON
     emp.CENTER = ss.EMPLOYEE_CENTER
     AND emp.ID = ss.EMPLOYEE_ID
 JOIN PERSONS pemp
 ON
     pemp.CENTER = emp.PERSONCENTER
     AND pemp.ID = emp.PERSONID
 JOIN PERSONS p
 ON
     p.CENTER = ss.OWNER_CENTER
     AND p.ID = ss.OWNER_ID
 LEFT JOIN relatives r
 ON
     p.center = r.relativecenter
     AND p.id = r.relativeid
     AND r.rtype = 2
     AND r.status <> 3
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
 where p.CENTER in (:scope)
 and ss.SALES_DATE between :salesDateFrom and :salesDateTo
