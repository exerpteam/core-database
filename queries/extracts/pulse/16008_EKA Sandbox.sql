 SELECT
     p.FULLNAME                                                                             AS "SubscriptionOwner",
     p.center||'p'||p.id                                                                    AS "SubscriptionOwnerKey",
     pr.NAME                                                                                AS "Subscription",
          CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "Subscription State",
     em.TXTVALUE                                                                            AS "Email",
     stu.txtvalue                                                                           AS "Student / Staff Number"
 FROM
     persons p
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.center
     AND s.OWNER_ID = p.id
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     s.SUBSCRIPTIONTYPE_CENTER = st.center
     AND s.SUBSCRIPTIONTYPE_ID = st.id
 JOIN
     products pr
 ON
     st.center = pr.center
     AND st.id = pr.id
 JOIN
     PERSON_EXT_ATTRS em
 ON
     em.PERSONCENTER = p.center
     AND em.PERSONID = p.id
    AND em.NAME = '_eClub_Email'
 JOIN
     PERSON_EXT_ATTRS stu
 ON
     stu.PERSONCENTER = p.center
     AND stu.PERSONID = p.id
 --    AND stu.NAME = 'studentnumber'
 WHERE
 p.center = 500
AND p.id = 806