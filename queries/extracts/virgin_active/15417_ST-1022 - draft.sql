SELECT
    c.SHORTNAME "Member home club name"
  , gm.FULLNAME "Member home club GM full name"
  , p.CENTER || 'p' || p.ID "Member membership number"
  , p.EXTERNAL_ID "Member external ID"
  , ExtSalutation.TXTVALUE "Member salutation"
  , p.FIRSTNAME "Member first name"
  , p.LASTNAME "Member last name"
  , p.ADDRESS1 "Member address 1"
  , p.ADDRESS2 "Member address 2"
  , p.ADDRESS3 "Member address 3"
  , p.ZIPCODE "Member postcode"
  , p.CITY "Member city"
  , ExtEmail.TXTVALUE "Member email address"
  , oldProd.NAME "Member original subscription"
  , prod.NAME "Member new subscription"
  , s.START_DATE "Member new sub start date"
  , nvl2(pp.center,pp.CENTER || 'p' || pp.id,p.CENTER || 'p' || p.id) "Payer membership number"
  ,nvl2(pp.center,pp.EXTERNAL_ID,p.EXTERNAL_ID) "Payer external id"
  , nvl2(pp.center,PExtSalutation.TXTVALUE,ExtSalutation.TXTVALUE) "Payer salutation"
  , nvl2(pp.center,pp.FIRSTNAME,p.FIRSTNAME) "Payer first name"
  , nvl2(pp.center,pp.LASTNAME,p.LASTNAME) "Payer last name"
  , nvl2(pp.center,pp.ADDRESS1,p.ADDRESS1) "Payer address 1"
  , nvl2(pp.center,pp.ADDRESS2,p.ADDRESS2) "Payer address 2"
  , nvl2(pp.center,pp.ADDRESS3,p.ADDRESS3) "Payer address 3"
  , nvl2(pp.center,pp.ZIPCODE,p.ZIPCODE) "Payer Postcode"
  , nvl2(pp.center,pp.CITY,p.CITY) "Payer city"
  , nvl2(pp.center,PExtEmail.TXTVALUE,ExtEmail.TXTVALUE) "Payer email address"
  , m.SUBJECT "Communication type sent"
  , DECODE (m.DELIVERYMETHOD, 0, 'STAFF', 1, 'EMAIL', 2, 'SMS', 3, 'PERSINTF',4, 'BLOCKPERSINTF',5, 'LETTER','UNDEFINED') "Communication method"
  , empp.FULLNAME  "employee"
FROM
    JOURNALENTRIES je
left join MESSAGES m on m.CENTER = je.PERSON_CENTER  and   m.ID = je.PERSON_ID and m.SENTTIME between (je.CREATION_TIME - 10000) and (je.CREATION_TIME + 10000)
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = je.PERSON_CENTER
    AND s.OWNER_ID = je.PERSON_ID
    AND s.CREATION_TIME BETWEEN je.CREATION_TIME - 10000 AND je.CREATION_TIME + 10000
    
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    SUBSCRIPTIONS sold
ON
    sold.CHANGED_TO_CENTER = s.CENTER
    AND sold.CHANGED_TO_ID = s.ID
JOIN
    PRODUCTS oldProd
ON
    oldProd.CENTER = sold.SUBSCRIPTIONTYPE_CENTER
    AND oldProd.ID = sold.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN
    RELATIVES rel
ON
    rel.RELATIVECENTER = p.CENTER
    AND rel.RELATIVEID = p.id
    AND rel.RTYPE = 12
    AND rel.STATUS = 1
LEFT JOIN
    PERSONS pp
ON
    pp.CENTER = rel.CENTER
    AND pp.ID = rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS ExtSalutation
ON
    ExtSalutation.PERSONCENTER = p.CENTER
    AND ExtSalutation.PERSONID = p.ID
    AND ExtSalutation.NAME = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS ExtEmail
ON
    ExtEmail.PERSONCENTER = p.CENTER
    AND ExtEmail.PERSONID = p.ID
    AND ExtEmail.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS PExtSalutation
ON
    PExtSalutation.PERSONCENTER = pp.CENTER
    AND PExtSalutation.PERSONID = pp.ID
    AND PExtSalutation.NAME = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS PExtEmail
ON
    PExtEmail.PERSONCENTER = pp.CENTER
    AND PExtEmail.PERSONID = pp.ID
    AND PExtEmail.NAME = '_eClub_Email'    
JOIN
    CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    PERSONS gm
ON
    gm.CENTER = c.MANAGER_CENTER
    AND gm.ID = c.MANAGER_ID
join EMPLOYEES emp on emp.CENTER = je.CREATORCENTER and emp.ID = je.CREATORID
join PERSONS empp on empp.CENTER = emp.PERSONCENTER and empp.ID = emp.PERSONID    
WHERE
    je.NAME = 'Apply: Change membership by date'
    and p.CENTER in ($$scope$$)
    and floor(months_between(sysdate, p.BIRTHDATE) /12) between $$age_from$$ and $$age_to$$
    and s.START_DATE >= $$sub_start_over$$