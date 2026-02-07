 SELECT
     /*+ NO_BIND_AWARE */

     centre.SHORTNAME                      club,
     TO_CHAR(sub.start_date, 'DD-MM-YYYY') start_date,
     CASE
         WHEN salesPersonOverride.CENTER IS NOT NULL
             AND (salesPersonOverride.CENTER <> salesperson.CENTER
                 OR salesPersonOverride.ID <> salesperson.ID)
         THEN salesPersonOverride.FULLNAME
         ELSE salesperson.FULLNAME
     END sales_person,
     CASE
         WHEN salesPersonOverride.CENTER IS NOT NULL
             AND (salesPersonOverride.CENTER <> salesperson.CENTER
                 OR salesPersonOverride.ID <> salesperson.ID)
         THEN salesperson.FULLNAME
         ELSE NULL
     END                                                                             orig_sales_person,
     TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Europe/London'), 'DD-MM-YYYY') DATE_JOINED,
         TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Europe/London'), 'HH24:MI') TIME_JOINED,
         Sub.START_DATE,
     owner.CENTER || 'p' || owner.ID                                                 member_id,
     owner.FULLNAME                                                                  member_name,
         owner.firstname,
         email.TXTVALUE                                                                                                  AS Email,
         CASE 
                WHEN CanEmail.TXTVALUE = 'true' THEN 'Yes'
                WHEN CanEmail.TXTVALUE = 'false' THEN 'No'
                ELSE 'No'
        END AS "CanEmail",
     prod.NAME                                                                       MEMBERSHIP
 FROM
     SUBSCRIPTION_SALES ss
 JOIN
     SUBSCRIPTIONS sub
        ON sub.CENTER = ss.SUBSCRIPTION_CENTER
     AND sub.ID = ss.SUBSCRIPTION_ID
 JOIN
     SUBSCRIPTIONTYPES stype
        ON ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
     AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
 JOIN
     PRODUCTS prod
        ON stype.CENTER = prod.CENTER
     AND stype.ID = prod.ID
 JOIN
     PERSONS owner
        ON owner.CENTER = sub.OWNER_CENTER
     AND owner.ID = sub.OWNER_ID
 JOIN
     CENTERS centre
        ON owner.CENTER = centre.ID
 JOIN
     STATE_CHANGE_LOG SCL1
 ON
     (
         SCL1.CENTER = SUB.CENTER
         AND SCL1.ID = SUB.ID
         AND SCL1.ENTRY_TYPE = 2
         AND SCL1.STATEID IN (2,
                              4,8)
         AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
         AND (
             SCL1.ENTRY_END_TIME IS NULL
             OR SCL1.ENTRY_END_TIME < $$CreationTo$$ + (1000*60*60*24) ))
 LEFT JOIN
     SUBSCRIPTION_ADDON addon
 ON
     sub.CENTER = addon.SUBSCRIPTION_CENTER
     AND sub.ID = addon.SUBSCRIPTION_ID
     AND addon.CANCELLED = 0
 LEFT JOIN
     MASTERPRODUCTREGISTER mp
 ON
     addon.ADDON_PRODUCT_ID = mp.ID
 LEFT JOIN
     PERSON_EXT_ATTRS home
 ON
     owner.center = home.PERSONCENTER
     AND owner.id = home.PERSONID
     AND home.name = '_eClub_PhoneHome'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     owner.center = mobile.PERSONCENTER
     AND owner.id = mobile.PERSONID
     AND mobile.name = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     owner.center = email.PERSONCENTER
     AND owner.id = email.PERSONID
     AND email.name = '_eClub_Email'
     
 LEFT JOIN
        PERSON_EXT_ATTRS CanEmail
        ON owner.center=CanEmail.PERSONCENTER
        AND owner.id=CanEmail.PERSONID
        AND CanEmail.name='eClubIsAcceptingEmailNewsLetters'
        
 LEFT JOIN
     EMPLOYEES emp
 ON
     ss.EMPLOYEE_CENTER = emp.CENTER
     AND ss.EMPLOYEE_ID = emp.ID
 LEFT JOIN
     PERSONS salesperson
 ON
     salesperson.CENTER = emp.PERSONCENTER
     AND salesperson.ID = emp.PERSONID
 LEFT JOIN
     PERSON_EXT_ATTRS salesPersonOverrideExt
 ON
     owner.center = salesPersonOverrideExt.PERSONCENTER
     AND owner.id = salesPersonOverrideExt.PERSONID
     AND salesPersonOverrideExt.name = 'MC'
 LEFT JOIN
     PERSONS salesPersonOverride
 ON
     salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID = salesPersonOverrideExt.TXTVALUE
 WHERE
     CanEmail.TXTVALUE = 'true'
     AND ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
     AND sub.CREATION_TIME >= $$CreationFrom$$
     AND sub.CREATION_TIME < $$CreationTo$$ + (1000*60*60*24)
      AND ss.SUBSCRIPTION_CENTER != '999' --Added by request of Gibbo to exclude Online+ 05.07.21
     AND NOT EXISTS
     (
         SELECT
             *
         FROM
             SUBSCRIPTIONS oldsub
         JOIN
             PERSONS oldPerson
         ON
             oldSub.OWNER_CENTER = oldPerson.CENTER
             AND oldSub.OWNER_ID = oldPerson.ID
         JOIN
             PRODUCTS oldsubprod
         ON
             oldsubprod.CENTER = oldsub.subscriptiontype_center
             AND oldsubprod.ID = oldsub.subscriptiontype_id
             AND oldsubprod.name NOT IN ('Free Adult Guest',
                                         'Paying Adult Guest')
         WHERE
             oldPerson.CURRENT_PERSON_CENTER = owner.center
             AND OldPerson.CURRENT_PERSON_ID = owner.ID
             AND (
                 oldSub.CENTER <> sub.CENTER
                 OR oldSub.ID <> sub.ID)
             AND oldSub.END_DATE + 30 > longtodateTZ(sub.CREATION_TIME, 'Europe/London')
             AND (
                 oldSub.STATE != 5
                 AND NOT(
                     oldSub.STATE = 3
                     AND oldSub.SUB_STATE = 8)))
     -- Exclude all transfers, extensions, upgrades, downgrades, cancelled and regretted
     AND NOT EXISTS
     (
         SELECT
             *
         FROM
             STATE_CHANGE_LOG SCLCHECK
         WHERE
             SCLCHECK.CENTER = SUB.CENTER
             AND SCLCHECK.ID = SUB.ID
             AND SCLCHECK.ENTRY_TYPE = 2
             AND SCLCHECK.STATEID IN (2,3,
                                      4,8)
             AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
             AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
             AND SCL1.ENTRY_START_TIME < $$CreationTo$$ + (1000*60*60*24))
     AND EXISTS
     (
         SELECT
             *
         FROM
             PRODUCT_AND_PRODUCT_GROUP_LINK pgl
         WHERE
             pgl.PRODUCT_CENTER = prod.CENTER
             AND pgl.PRODUCT_ID = prod.ID
             AND pgl.PRODUCT_GROUP_ID = 248)
 GROUP BY
     CanEmail.TXTVALUE,
     sub.start_date,
     centre.SHORTNAME,
     salesperson.FULLNAME,
     salesperson.CENTER,
     salesperson.ID,
     salesPersonOverride.FULLNAME,
     salesPersonOverride.CENTER,
     salesPersonOverride.ID,
     sub.CREATION_TIME,
     owner.CENTER,
     owner.ID,
     owner.FULLNAME,
         owner.firstname,
         email.TXTVALUE,
     prod.NAME
 ORDER BY
     sub.CREATION_TIME,
     salesperson.FULLNAME