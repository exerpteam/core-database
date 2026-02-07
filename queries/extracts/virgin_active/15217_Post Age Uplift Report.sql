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
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.CENTER || 'p' || pp.id ELSE p.CENTER || 'p' || p.id END) "Payer membership number"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.EXTERNAL_ID ELSE p.EXTERNAL_ID END) "Payer external id"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN PExtSalutation.TXTVALUE ELSE ExtSalutation.TXTVALUE END) "Payer salutation"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.FIRSTNAME ELSE p.FIRSTNAME END) "Payer first name"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.LASTNAME ELSE p.LASTNAME END) "Payer last name"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.ADDRESS1 ELSE p.ADDRESS1 END) "Payer address 1"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.ADDRESS2 ELSE p.ADDRESS2 END) "Payer address 2"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.ADDRESS3 ELSE p.ADDRESS3 END) "Payer address 3"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.ZIPCODE ELSE p.ZIPCODE END) "Payer Postcode"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN pp.CITY ELSE p.CITY END) "Payer city"
   , (CASE WHEN pp.CENTER IS NOT NULL THEN PExtEmail.TXTVALUE ELSE ExtEmail.TXTVALUE END) "Payer email address"
   , m.SUBJECT "Communication type sent"
   , (CASE m.DELIVERYMETHOD
                WHEN 0 THEN 'STAFF'
                WHEN 1 THEN 'EMAIL'
                WHEN 2 THEN 'SMS'
                WHEN 3 THEN 'PERSINTF'
                WHEN 4 THEN 'BLOCKPERSINTF'
                WHEN 5 THEN 'LETTER'
                ELSE 'UNDEFINED'
        END) "Communication method"
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
     AND CAST(EXTRACT('year' from AGE(p.BIRTHDATE)) AS INTEGER) between $$age_from$$ and $$age_to$$
     and s.START_DATE >= $$sub_start_over$$
