SELECT
    ca.center,
    ca.id,
    ca.center||'p'||ca.id                            AS CompanyId,
    ca.subid                                         AS agreementid,
    c.lastname                                       AS company,
    ca.name                                          AS agreement,
    p.center||'p'||p.id                              AS Customer,
    p.FULLNAME                                       AS CustomerName,
    TO_CHAR(longToDate(cil.CHECKIN_TIME),'mm') AS MONTH,
    ph.txtvalue                                      AS phonehome,
    pm.txtvalue                                      AS phonemobile,
    pem.txtvalue                                     AS email,
    COUNT(cil.CHECKIN_TIME)                          AS checkins
FROM
    COMPANYAGREEMENTS ca
JOIN PERSONS c
ON
    ca.CENTER = c.CENTER
    AND ca.ID = c.ID
JOIN RELATIVES rel
ON
    rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
JOIN PERSONS p
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
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
left JOIN CHECKIN_LOG cil
ON
    cil.CENTER = p.CENTER
    AND cil.id = p.ID
    -- attends only during a period
    and cil.CHECKIN_TIME between :FromDate and :ToDate
WHERE
    -- filter company
    c.SEX = 'C'
    AND 
    (p.CENTER,p.ID) IN (:persons)
    and rel.STATUS < 3
    
GROUP BY
    ca.center,
    ca.id,
    ca.center||'p'||ca.id ,
    ca.subid ,
    c.lastname ,
    ca.name ,
    p.center||'p'||p.id ,
    p.FULLNAME ,
    TO_CHAR(longToDate(cil.CHECKIN_TIME),'mm') ,
    ph.txtvalue ,
    pm.txtvalue ,
    pem.txtvalue
    
    ORDER BY
    p.center||'p'||p.id,
    to_char(longToDate(cil.CHECKIN_TIME),'mm')