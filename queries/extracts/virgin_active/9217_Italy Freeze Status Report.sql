-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS

(
SELECT 
TRUNC(CURRENT_TIMESTAMP) as ts,
CAST(extract(epoch from timezone('Europe/Rome',date_trunc('year', now()) - interval '5 year')) AS BIGINT)*1000 as fromdate

)

 SELECT DISTINCT
     p.center || 'p' || p.id AS "PID",
     s.CENTER || 'ss' || s.ID "Membership Number",
     p.FIRSTNAME                                                                AS "FIRSTNAME",
     p.LASTNAME                                                                 AS "LASTNAME",
     prod.NAME                                                                  AS "SUBSCRIPTION_NAME",
     pg.NAME                                                                    AS "PRIMARY_PRODUCT_GROUP",
     floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12)             AS "AGE",
     longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) 		AS "LAST_CHECKIN",
     c.NAME                                                                     AS "CENTER_NAME",
     CASE
         WHEN sfp.START_DATE > par.ts
         THEN 'FUTURE'
         ELSE 'CURRENT'
     END      AS "Freeze Status",
     sfp.TYPE AS "Freeze type",
     sfp.TEXT AS "FREEZE_REASON",
     sfp.START_DATE "Freeze Start Date" ,
     sfp.END_DATE "Freeze End Date" ,
     email.TXTVALUE         "EMAIL" ,
     mob.TXTVALUE           "MOBILE",
     hp.TXTVALUE        AS "HOME_PHONE",
     spp.SUBSCRIPTION_PRICE AS "freeze price",
         s.START_DATE AS "Start date",
         s.END_DATE AS "End date",
         s.BINDING_END_DATE "Binding date"
 FROM
     params par,
     SUBSCRIPTION_FREEZE_PERIOD sfp
 LEFT JOIN
     SUBSCRIPTIONPERIODPARTS spp
 ON
     spp.center = sfp.SUBSCRIPTION_CENTER
     AND spp.id = sfp.SUBSCRIPTION_ID
     AND spp.FROM_DATE = sfp.START_DATE
     AND spp.SPP_STATE = 1
     -- and spp.TO_DATE = sfp.END_DATE
 JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = sfp.SUBSCRIPTION_CENTER
     AND s.ID = sfp.SUBSCRIPTION_ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
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
     PERSON_EXT_ATTRS hp
 ON
     hp.PERSONCENTER = p.CENTER
     AND hp.PERSONID = p.ID
     AND hp.NAME = '_eClub_PhoneHome'
 LEFT JOIN
     CHECKINS ci
 ON
     ci.PERSON_CENTER = p.CENTER
     AND ci.PERSON_ID = p.ID
 WHERE
     (
         sfp.START_DATE >= TRUNC(CURRENT_TIMESTAMP)
         OR (
             sfp.END_DATE > TRUNC(CURRENT_TIMESTAMP - 1)
             AND sfp.START_DATE <= TRUNC(CURRENT_TIMESTAMP) ))
     AND sfp.STATE != 'CANCELLED'
     AND s.center IN ($$scope$$)
--AND ci.checkin_time > par.fromdate