SELECT DISTINCT
      p.center ||'p'||p.id AS "Person key",
     p.external_id AS "Member id",
    p.FULLNAME AS "Member name",
    pa.ref AS "Exerp reference",
	EMAIL.txtvalue AS "Email",
	MOBILE.txtvalue AS "Mobile",
    pa.creditor_id AS "CIN",
    pa.clearinghouse_ref AS "EasyPay ref"
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pm
ON
    pm.center = ar.center
    AND pm.id = ar.id
JOIN
	person_ext_attrs EMAIL
ON
	p.center = EMAIL.personcenter	
AND p.id = EMAIL.personid
AND EMAIL.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs MOBILE
ON
    p.center = MOBILE.personcenter
AND p.id = MOBILE.personid
AND MOBILE.name = '_eClub_PhoneSMS'

JOIN
    PAYMENT_AGREEMENTS pa
ON
    pm.ACTIVE_AGR_CENTER = pa.center
    AND pm.ACTIVE_AGR_ID = pa.id
    AND pm.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID
WHERE
    p.center in (:center)
    and
    pa.state in (4,5,6,7,10,15)
    and
    pa.clearinghouse_ref is NOT NULL
    