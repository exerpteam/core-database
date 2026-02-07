SELECT
    oldp.center || 'p' || oldp.id                                                                                                                                                      AS oldmemberid,
    oldp.fullname                                                                                                                                                                      AS memberfullname,
    fromcenter.id                                                                                                                                                                      AS oldclubid,
    fromcenter.shortNAME                                                                                                                                                                    AS oldclubname,
    oldppd.name                                                                                                                                                                        AS oldsubscriptionname,
    oldpsub.subscription_price                                                                                                                                                         AS oldsubscriptionprice,
    DECODE (newp.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS newstatus,
    newp.center || 'p' || newp.id                                                                                                                                                      AS newmemberid,    
    tocenter.id                                                                                                                                                                        AS newclubid,
    tocenter.shortNAME                                                                                                                                                                      AS newclubname,
    newppd.name                                                                                                                                                                        AS newsubscriptionname,
    newpsub.subscription_price                                                                                                                                                         AS newsubscriptionprice,    
    trd.txtvalue                                                                                                                                                                       AS transferdate
FROM
    persons oldp
JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER= oldp.CENTER
    AND pea.PERSONID= oldp.ID
    AND pea.NAME = '_eClub_TransferredToId'
JOIN
    PERSON_EXT_ATTRS trd
ON
    trd.PERSONCENTER= oldp.CENTER
    AND trd.PERSONID= oldp.ID
    AND trd.NAME = '_eClub_TransferDate'
JOIN
    PERSONS newp
ON
    newp.center || 'p' || newp.id = pea.txtvalue
JOIN
    CENTERS fromcenter
ON
    fromcenter.ID=oldp.center
JOIN
    CENTERS tocenter
ON
    tocenter.ID=newp.center
LEFT JOIN
  ( SELECT 
      s.owner_center, 
      s.owner_id, 
      max(s.start_date) as start_date
    FROM 
      subscriptions s
    group by s.owner_center, s.owner_id
  ) oldplatestsub
ON
    oldplatestsub.owner_center = oldp.center
    AND oldplatestsub.owner_id = oldp.id
LEFT JOIN
    subscriptions oldpsub
ON
   oldpsub.owner_center = oldplatestsub.owner_center
   AND oldpsub.owner_id = oldplatestsub.owner_id 
   AND oldpsub.start_date = oldplatestsub.start_date 
   AND oldpsub.sub_state = 6
LEFT JOIN
   SUBSCRIPTIONTYPES oldpst
ON
   oldpsub.SUBSCRIPTIONTYPE_CENTER=oldpst.center
   AND oldpsub.SUBSCRIPTIONTYPE_ID=oldpst.id
LEFT JOIN
   PRODUCTS oldppd
ON
   oldpst.center=oldppd.center
   AND oldpst.id=oldppd.id
LEFT JOIN
  ( SELECT 
      s.owner_center, 
      s.owner_id, 
      max(s.start_date) as start_date
    FROM 
      subscriptions s
    group by s.owner_center, s.owner_id
  ) newplatestsub
ON
    newplatestsub.owner_center = newp.center
    AND newplatestsub.owner_id = newp.id
LEFT JOIN
    subscriptions newpsub
ON
   newpsub.owner_center = newplatestsub.owner_center
   AND newpsub.owner_id = newplatestsub.owner_id 
   AND newpsub.start_date = newplatestsub.start_date
   AND newpsub.state in (2,4,8) 
LEFT JOIN
   SUBSCRIPTIONTYPES newpst
ON
   newpsub.SUBSCRIPTIONTYPE_CENTER=newpst.center
   AND newpsub.SUBSCRIPTIONTYPE_ID=newpst.id
LEFT JOIN
   PRODUCTS newppd
ON
   newpst.center=newppd.center
   AND newpst.id=newppd.id   
WHERE
    to_date(trd.txtvalue, 'yyyy-MM-dd') >= to_date('2017-03-21', 'yyyy-MM-dd')
    and oldp.center IN (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443
)
    and newp.center NOT IN (403,
440,
436,
411,
441,
442,
419,
434,
407,
400,
406,
435,
401,
443)     