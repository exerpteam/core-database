-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     cen.NAME,
     p.center || 'p' || p.id AS PersonKey,
     p.FULLNAME,
     CASE  WHEN pag.STATE IS NULL THEN 'No Agreement' WHEN pag.STATE = 1 THEN 'Created' WHEN pag.STATE = 2 THEN 'Sent' WHEN pag.STATE = 3 THEN 'Failed' WHEN pag.STATE = 4 THEN 'OK' WHEN pag.STATE = 5 THEN 'Ended, bank' WHEN pag.STATE = 6 THEN 'Ended, clearing house' WHEN pag.STATE = 7 THEN 'Ended, debtor' WHEN pag.STATE = 8 THEN 'Cancelled, not sent' WHEN pag.STATE = 9 THEN 'Cancelled, sent' WHEN pag.STATE = 10 THEN 'Ended, creditor' WHEN pag.STATE = 11 THEN 'No agreement (deprecated)' WHEN pag.STATE = 12 THEN 'Cash payment (deprecated)' WHEN pag.STATE = 13 THEN 'Agreement not needed (invoice payment)' WHEN pag.STATE = 14 THEN 'Agreement information incomplete' END as DDIstatus,
     TO_CHAR(longtodateTZ(pag.CREATION_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI') as DDICreationTime,
     e.IDENTITY as PIN,
         email.TXTVALUE as Email,
         mobile.TXTVALUE as Mobile,
         homephone.TXTVALUE as HomePhone,
     TO_CHAR(longtodateTZ(j.CREATION_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI') as PersonCreationTime,
     newsletter.TXTVALUE as "Accepting Newsletter",
     offers.TXTVALUE as "Accepting 3rd party offers"
 FROM
     PERSONS p
 LEFT JOIN
     JOURNALENTRIES j
 ON
     j.PERSON_CENTER = p.CENTER
     AND j.PERSON_ID = p.ID
     AND j.NAME = 'Person created'
 left join EMPLOYEES emp on j.CREATORCENTER = emp.CENTER and j.CREATORID = emp.id
 LEFT JOIN
     ENTITYIDENTIFIERS e
 ON
     e.IDMETHOD = 5
     AND e.ENTITYSTATUS = 1
     AND e.REF_CENTER = p.CENTER
     AND e.REF_ID = p.ID
     AND e.REF_TYPE = 1
 LEFT JOIN
      CENTERS cen
      on
      cen.ID = p.CENTER
         LEFT JOIN PERSON_EXT_ATTRS email
         ON
             email.personcenter = p.center
             AND email.personid = p.id
             AND email.name = '_eClub_Email'
  LEFT JOIN PERSON_EXT_ATTRS mobile
         ON
             mobile.personcenter = p.center
             AND mobile.personid = p.id
             AND mobile.name = '_eClub_PhoneSMS'
  LEFT JOIN PERSON_EXT_ATTRS homephone
         ON
             homephone.personcenter = p.center
             AND homephone.personid = p.id
             AND homephone.name = '_eClub_PhoneHome'
  LEFT JOIN PERSON_EXT_ATTRS newsletter
         ON
             newsletter.personcenter = p.center
             AND newsletter.personid = p.id
             AND newsletter.name = 'eClubIsAcceptingEmailNewsLetters'
  LEFT JOIN PERSON_EXT_ATTRS offers
         ON
             offers.personcenter = p.center
             AND offers.personid = p.id
             AND offers.name = 'eClubIsAcceptingThirdPartyOffers'
 left join
      ACCOUNT_RECEIVABLES acr
      on acr.CUSTOMERCENTER = p.CENTER
      and acr.CUSTOMERID = p.ID
      and acr.AR_TYPE = 4
 left join
      PAYMENT_ACCOUNTS pac
      on pac.CENTER = acr.CENTER
      and pac.ID = acr.ID
 left join
      PAYMENT_AGREEMENTS pag
      on pag.CENTER = pac.ACTIVE_AGR_CENTER
      and pag.ID = pac.ACTIVE_AGR_ID
      and pag.SUBID = pac.ACTIVE_AGR_SUBID
 WHERE
     j.CREATION_TIME between :fromDate and :toDate
     AND p.STATUS = 0
 --    AND j.CREATORCENTER = 100
 --    AND j.CREATORID = 17401
 and emp.USE_API = 1
