-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
     p.center || 'p' || p.id AS  "PID",
     s.CENTER || 'ss' || s.ID "Membership Number",
     --p.FIRSTNAME AS "FIRSTNAME",
     --p.LASTNAME AS "LASTNAME",
     prod.NAME AS "SUBSCRIPTION_NAME",
     pg.NAME AS "PRIMARY_PRODUCT_GROUP",
     --floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12) AS "AGE",
     longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) AS "LAST_CHECKIN",
     c.NAME AS "CENTER_NAME",
     CASE
         WHEN sfp.START_DATE > DATE_TRUNC('day', CURRENT_TIMESTAMP)
         THEN 'FUTURE'
         ELSE 'CURRENT'
     END      AS "Freeze Status",
     sfp.TYPE AS "Freeze type",
         sfp.TEXT as "Reason",
     sfp.START_DATE "Freeze Start Date" ,
     sfp.END_DATE "Freeze End Date" ,
     --email.TXTVALUE AS "EMAIL",
     --mob.TXTVALUE AS "MOBILE",
    case
     when sfp.TYPE = 'UNRESTRICTED'
    then   0
   ELSE
      f_pr.PRICE
    end  AS "Freeze Price"
 FROM
     SUBSCRIPTION_FREEZE_PERIOD sfp
 JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = sfp.SUBSCRIPTION_CENTER
     AND s.ID = sfp.SUBSCRIPTION_ID
 join PRODUCTS prod on prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER and     prod.ID = s.SUBSCRIPTIONTYPE_ID
 join PRODUCT_GROUP pg on pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 join SUBSCRIPTIONTYPES st ON st.center = s.SUBSCRIPTIONTYPE_CENTER AND st.id = s.SUBSCRIPTIONTYPE_ID	 
 LEFT JOIN PRODUCTS f_pr ON f_pr.center = st.FREEZEPERIODPRODUCT_CENTER AND f_pr.id = st.FREEZEPERIODPRODUCT_ID	 
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = p.CENTER
     AND email.PERSONID = p.ID
     AND email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mob
 ON
     mob.PERSONCENTER = p.CENTER
     AND mob.PERSONID = p.ID
     AND mob.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
     CHECKINS ci
 ON
     ci.PERSON_CENTER = p.CENTER
     AND ci.PERSON_ID = p.ID
 WHERE
     (
         sfp.START_DATE >= DATE_TRUNC('day', CURRENT_TIMESTAMP)
         OR (
             sfp.END_DATE > DATE_TRUNC('day', CURRENT_TIMESTAMP) - INTERVAL '1 day'
             AND sfp.START_DATE <= DATE_TRUNC('day', CURRENT_TIMESTAMP) ))
     AND sfp.STATE != 'CANCELLED'
     AND s.center IN ($$scope$$)
