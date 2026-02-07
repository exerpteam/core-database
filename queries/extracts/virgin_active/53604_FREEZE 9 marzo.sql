 SELECT DISTINCT
     p.center || 'p' || p.id pid,
     s.CENTER || 'ss' || s.ID "Membership Number",
         CASE
                 WHEN sfp.START_DATE >= TO_DATE('20200309', 'yyyymmdd') AND sfp.END_DATE >= TO_DATE('20200331', 'yyyymmdd') THEN TO_DATE('20200331', 'yyyymmdd') - sfp.START_DATE +1
                 WHEN sfp.START_DATE < TO_DATE('20200309', 'yyyymmdd') AND sfp.END_DATE >= TO_DATE('20200331', 'yyyymmdd') THEN TO_DATE('20200331', 'yyyymmdd') - TO_DATE('20200309', 'yyyymmdd') +1
                 WHEN sfp.START_DATE < TO_DATE('20200309', 'yyyymmdd') AND sfp.END_DATE <= TO_DATE('20200331', 'yyyymmdd') THEN sfp.END_DATE -  TO_DATE('20200308', 'yyyymmdd') +1
                 WHEN sfp.START_DATE >= TO_DATE('20200309', 'yyyymmdd') AND sfp.END_DATE <= TO_DATE('20200331', 'yyyymmdd') THEN sfp.END_DATE - sfp.START_DATE +1
         END "giorni freeze",
     p.FIRSTNAME                                                                FIRSTNAME,
     p.LASTNAME                                                                 LASTNAME ,
     prod.NAME                                                                  SUBSCRIPTION_NAME,
     pg.NAME                                                                    PRIMARY_PRODUCT_GROUP,
     floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12)                       age,
     longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) last_checkin,
     c.NAME                                                                     CENTER_NAME ,
     CASE
         WHEN sfp.START_DATE > TRUNC(CURRENT_TIMESTAMP)
         THEN 'FUTURE'
         ELSE 'CURRENT'
     END      AS "Freeze Status",
     sfp.TYPE AS "Freeze type",
     sfp.TEXT FREEZE_REASON,
     sfp.START_DATE "Freeze Start Date" ,
     sfp.END_DATE "Freeze End Date" ,
     email.TXTVALUE         EMAIL ,
     mob.TXTVALUE           MOBILE,
     hp.TXTVALUE            home_phone,
     spp.SUBSCRIPTION_PRICE AS "freeze price",
         s.START_DATE AS "Start date",
         s.END_DATE AS "End date",
         s.BINDING_END_DATE "Binding date"
 FROM
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
         sfp.START_DATE BETWEEN TO_DATE('20200309', 'yyyymmdd') AND TO_DATE('20200331', 'yyyymmdd')
                 OR
                 sfp.END_DATE BETWEEN TO_DATE('20200309', 'yyyymmdd') AND TO_DATE('20200331', 'yyyymmdd')
                 OR
                 (sfp.START_DATE < TO_DATE('20200309', 'yyyymmdd') AND sfp.END_DATE > TO_DATE('20200331', 'yyyymmdd'))
      )
     AND sfp.STATE != 'CANCELLED'
     AND s.center IN (101,107,210,214,219,232,220,208)
