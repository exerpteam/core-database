SELECT
    c.NAME                                                                                                                                                                          AS "Center name",
    p.CENTER || 'p' || p.ID                                                                                                                                                         AS "Person ID",
    s.CENTER || 'ss' || s.ID                                                                                                                                                        AS "Subscription ID",
    pr.NAME                                                                                                                                                                         AS "Member Subscription Type",
    DECODE (p.PersonType, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'One Man Corporate', 6,'Family', 7,'Senior',8, 'Guest', 'UNKNOWN')                      AS PersonType,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    DECODE(cc1.CURRENTSTEP_TYPE,0,'Message',1,'Reminder',2,'Block',3,'Request and Stop',4,'Cash Collection',5,'Close',6,'Wait','No Debt case')                                      AS "Member Debt Case Status",
    sal1.TXTVALUE                                                                                                                                                                   AS "Member Salutation",
    p.FIRSTNAME,
    --    p.MIDDLENAME,
    p.LASTNAME,
    p.BIRTHDATE                                                                                                                                AS "Member Birthday",
    opp.Center ||'p'|| opp.Id                                                                                                                  AS "Payer's membership number",
    sal2.TXTVALUE                                                                                                                              AS "Payer Salutation",
    opp.firstname                                                                                                                              AS PayerFirstName,
    opp.lastname                                                                                                                               AS PayerLastName,
    opp.address1                                                                                                                               AS PayerAddress1,
    opp.address2                                                                                                                               AS PayerAddress2,
    opp.address3                                                                                                                               AS PayerAddress3,
    opp.zipcode                                                                                                                                AS PayerZip,
    opp.city                                                                                                                                   AS PayerCity,
    opp.COUNTRY                                                                                                                                AS PayerCountry,
    DECODE(cc2.CURRENTSTEP_TYPE,0,'Message',1,'Reminder',2,'Block',3,'Request and Stop',4,'Cash Collection',5,'Close',6,'Wait','No Debt case') AS "Payer Debt Case Status",
    em2.TXTVALUE                                                                                                                               AS "Payer email address",
    em1.TXTVALUE                                                                                                                               AS "Member email address",
    p.FIRST_ACTIVE_START_DATE,
    p.LAST_ACTIVE_START_DATE,
    p.EXTERNAL_ID AS "Member EXTERNAL_ID"
FROM
    VA.PERSONS p
JOIN
    VA.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
JOIN
    VA.CENTERS c
ON
    c.ID = p.CENTER
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    VA.RELATIVES rel
ON
    rel.RELATIVECENTER=p.Center
    AND rel.RELATIVEID = p.Id
    AND rel.RTYPE=12
    AND rel.STATUS = 1
LEFT JOIN
    VA.PERSONS opp
ON
    rel.Center = opp.CENTER
    AND rel.Id = opp.Id
LEFT JOIN
    VA.PERSON_EXT_ATTRS em2
ON
    opp.center = em2.PERSONCENTER
    AND opp.id = em2.PERSONID
    AND em2.NAME = '_eClub_Email'
LEFT JOIN
    VA.PERSON_EXT_ATTRS sal2
ON
    opp.center = sal2.PERSONCENTER
    AND opp.id = sal2.PERSONID
    AND sal2.name = '_eClub_Salutation'
LEFT JOIN
    VA.PERSON_EXT_ATTRS em1
ON
    p.center = em1.PERSONCENTER
    AND p.id = em1.PERSONID
    AND em1.NAME = '_eClub_Email'
LEFT JOIN
    VA.PERSON_EXT_ATTRS sal1
ON
    p.center = sal1.PERSONCENTER
    AND p.id = sal1.PERSONID
    AND sal1.name = '_eClub_Salutation'
LEFT JOIN
    CASHCOLLECTIONCASES cc1
ON
    cc1.PERSONCENTER = p.CENTER
    AND cc1.PERSONID = p.ID
    AND cc1.CLOSED = 0
    AND cc1.MISSINGPAYMENT = 1
LEFT JOIN
    CASHCOLLECTIONCASES cc2
ON
    cc2.PERSONCENTER = opp.CENTER
    AND cc2.PERSONID = opp.ID
    AND cc2.CLOSED = 0
    AND cc2.MISSINGPAYMENT = 1
WHERE
    s.STATE IN ( 2,
                4)
    AND p.STATUS IN (1,3)
    AND p.center IN (:Scope)
    AND p.BIRTHDATE >= :Startdate
    AND p.BIRTHDATE <= :EndDate