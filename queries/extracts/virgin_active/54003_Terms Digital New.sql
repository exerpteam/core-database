-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
        S.CENTER,
        S.ID,
        CASE  S.STATE  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END as STATE,
        CASE  SUB_STATE  WHEN 1 THEN 'None'  WHEN 6 THEN  'Transferred'  WHEN 9 THEN 'Blocked' END AS SUB_STATE,
        -- S.SUBSCRIPTIONTYPE_CENTER,
        S.BINDING_END_DATE,
        S.SUBSCRIPTION_PRICE,
        S.START_DATE,
        S.END_DATE,
        S.TRANSFERRED_CENTER,
        PR.NAME as SUBSCRIPTION_ID,
        P.center||'p'||P.id as PERSON_ID,
        email.TXTVALUE as "email"
 FROM
        SUBSCRIPTIONS S
 LEFT JOIN
        PERSONS P ON P.CENTER = S.OWNER_CENTER  AND P.ID = S.OWNER_ID
 LEFT JOIN
        PRODUCTS PR ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER AND PR.ID = S.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = P.CENTER
     AND email.PERSONID = P.ID
     AND email.NAME = '_eClub_Email'
 WHERE
        P.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
        AND
        S.END_DATE >= :End_Date_From AND S.END_DATE <= :End_Date_To
        AND
        P.STATUS IN ( :PersonStatus ) AND S.STATE IN ( :Subscription_state )
