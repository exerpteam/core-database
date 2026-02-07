 WITH PARAMS AS (
         select :IncludeMigration as IncludeMigration 
 )
 SELECT
     FrzPerMem.sums as "AccumulatedFreezeDays",
     cen.NAME as MainGym,
     p.center || 'p' || p.id AS personid,
     p.FULLNAME,
     e.IDENTITY as PIN,
     p.ADDRESS1,
     p.ADDRESS2,
     p.ADDRESS3,
     p.ZIPCODE,
     email.TXTVALUE as email,
     phone.TXTVALUE as phone,
     mobile.TXTVALUE as mobile
 FROM
     PERSONS p
 LEFT JOIN
         PERSON_EXT_ATTRS email
         on email.PERSONCENTER = p.CENTER and email.PERSONID = p.ID and email.NAME = '_eClub_Email'
 LEFT JOIN
         PERSON_EXT_ATTRS mobile
         on mobile.PERSONCENTER = p.CENTER and mobile.PERSONID = p.ID and mobile.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
         PERSON_EXT_ATTRS phone
         on phone.PERSONCENTER = p.CENTER and phone.PERSONID = p.ID and phone.NAME = '_eClub_PhoneHome'
 JOIN CENTERS cen
         on cen.ID = p.CENTER
 LEFT JOIN
             ENTITYIDENTIFIERS e
         ON
             e.IDMETHOD = 5
             AND e.ENTITYSTATUS = 1
             AND e.REF_CENTER = p.CENTER
             AND e.REF_ID = p.ID
             AND e.REF_TYPE = 1
 JOIN /*this finds the supbscriptions the member has and sums their freeze sums*/
     (
         SELECT
             s.OWNER_CENTER,
             s.OWNER_ID,
             SUM(frz.freeze) AS sums
         FROM
             SUBSCRIPTIONS s
         JOIN /*this finds and sums the freeze periods for each subscription the member has*/
             (
                 SELECT
                     sfp.SUBSCRIPTION_ID,
                     sfp.SUBSCRIPTION_CENTER,
                     SUM ( sfp.END_DATE +1 - sfp.START_DATE )  AS freeze
                 FROM
                     SUBSCRIPTION_FREEZE_PERIOD sfp, PARAMS
                 WHERE
                     sfp.STATE = 'ACTIVE'
                    AND (PARAMS.IncludeMigration::int = 1 or (sfp.TEXT <> 'Data Migration' or sfp.TEXT is null))
                 GROUP BY
                     sfp.SUBSCRIPTION_ID,
                     sfp.SUBSCRIPTION_CENTER ) frz
         ON
             frz.SUBSCRIPTION_CENTER = s.CENTER
             AND frz.SUBSCRIPTION_ID = s.ID
         GROUP BY
             s.OWNER_CENTER,
             s.OWNER_ID ) FrzPerMem
 ON
     p.ID = FrzPerMem.OWNER_ID
     AND p.CENTER = FrzPerMem.OWNER_CENTER
     where p.STATUS in (1,3) and p.CENTER in(:scope)
