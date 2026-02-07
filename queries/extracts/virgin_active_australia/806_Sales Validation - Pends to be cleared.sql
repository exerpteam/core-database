-- This is the version from 2026-02-05
--  
WITH base AS (
    SELECT
        /*+ NO_BIND_AWARE */
        centre.SHORTNAME AS club,
        TO_CHAR(sub.start_date, 'DD-MM-YYYY') AS start_date,
        CASE
            WHEN salesPersonOverride.CENTER IS NOT NULL
                 AND (salesPersonOverride.CENTER <> salesperson.CENTER
                     OR salesPersonOverride.ID <> salesperson.ID)
            THEN salesPersonOverride.FULLNAME
            ELSE salesperson.FULLNAME
        END AS sales_person,
        CASE
            WHEN salesPersonOverride.CENTER IS NOT NULL
                 AND (salesPersonOverride.CENTER <> salesperson.CENTER
                     OR salesPersonOverride.ID <> salesperson.ID)
            THEN salesperson.FULLNAME
            ELSE NULL
        END AS orig_sales_person,
        TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Australia/Sydney'), 'DD-MM-YYYY') AS DATE_JOINED,
        TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Australia/Sydney'), 'HH24:MI') AS TIME_JOINED,
        owner.CENTER || 'p' || owner.ID AS member_id,
        owner.FULLNAME AS member_name,
        prod.NAME AS MEMBERSHIP,

        -- VALIDATION FIELDS FOR COMMISSION
        id_seen.TXTVALUE AS "ID Provided",
        linked_member.TXTVALUE AS "Linked Member",
        emergencyDetails.TXTVALUE AS "Emergency Details Completed",
        paf.TXTVALUE AS "PAF Completed",
        signatureTC.TXTVALUE AS "Contract Signature",

        CASE
            WHEN COALESCE(UPPER(TRIM(id_seen.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(linked_member.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(emergencyDetails.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(paf.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(signatureTC.TXTVALUE)), 'N') IN ('Y', 'N/A')
            THEN 'YES'
            ELSE 'NO'
        END AS "Pend Cleared",

        CASE
            WHEN COALESCE(UPPER(TRIM(id_seen.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(linked_member.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(emergencyDetails.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(paf.TXTVALUE)), 'N') IN ('Y', 'N/A')
             AND COALESCE(UPPER(TRIM(signatureTC.TXTVALUE)), 'N') IN ('Y', 'N/A')
            THEN 'YES'
            ELSE 'NO'
        END AS Commissionable,

        CASE
            WHEN salesperson.center = 100 AND salesperson.id = 407
            THEN 'Y'
            ELSE 'N'
        END AS "Online Join sale"

    FROM
        SUBSCRIPTION_SALES ss
    JOIN SUBSCRIPTIONS sub 
        ON sub.CENTER = ss.SUBSCRIPTION_CENTER 
       AND sub.ID = ss.SUBSCRIPTION_ID
    JOIN SUBSCRIPTIONTYPES stype 
        ON ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER 
       AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
    JOIN PRODUCTS prod 
        ON stype.CENTER = prod.CENTER 
       AND stype.ID = prod.ID
    JOIN PERSONS owner 
        ON owner.CENTER = sub.OWNER_CENTER 
       AND owner.ID = sub.OWNER_ID
    JOIN CENTERS centre 
        ON owner.CENTER = centre.ID
    JOIN STATE_CHANGE_LOG SCL1 
        ON SCL1.CENTER = SUB.CENTER
       AND SCL1.ID = SUB.ID
       AND SCL1.ENTRY_TYPE = 2
       AND SCL1.STATEID IN (2, 4, 8)

    LEFT JOIN SUBSCRIPTION_ADDON addon 
        ON sub.CENTER = addon.SUBSCRIPTION_CENTER 
       AND sub.ID = addon.SUBSCRIPTION_ID 
       AND addon.CANCELLED = 0
    LEFT JOIN MASTERPRODUCTREGISTER mp 
        ON addon.ADDON_PRODUCT_ID = mp.ID
    LEFT JOIN PERSON_EXT_ATTRS home 
        ON owner.center = home.PERSONCENTER 
       AND owner.id = home.PERSONID 
       AND home.name = '_eClub_PhoneHome'
    LEFT JOIN PERSON_EXT_ATTRS mobile 
        ON owner.center = mobile.PERSONCENTER 
       AND owner.id = mobile.PERSONID 
       AND mobile.name = '_eClub_PhoneSMS'
    LEFT JOIN PERSON_EXT_ATTRS email 
        ON owner.center = email.PERSONCENTER 
       AND owner.id = email.PERSONID 
       AND email.name = '_eClub_Email'
    LEFT JOIN PERSON_EXT_ATTRS id_seen 
        ON owner.center = id_seen.PERSONCENTER 
       AND owner.id = id_seen.PERSONID 
       AND id_seen.name = 'IDseenapproved'
    LEFT JOIN PERSON_EXT_ATTRS linked_member 
        ON owner.center = linked_member.PERSONCENTER 
       AND owner.id = linked_member.PERSONID 
       AND linked_member.name = 'Linkedmembervalid'
    LEFT JOIN PERSON_EXT_ATTRS emergencyDetails 
        ON owner.center = emergencyDetails.PERSONCENTER 
       AND owner.id = emergencyDetails.PERSONID 
       AND emergencyDetails.name = 'EmergencyContactDetailsCompleted'
    LEFT JOIN PERSON_EXT_ATTRS paf 
        ON owner.center = paf.PERSONCENTER 
       AND owner.id = paf.PERSONID 
       AND paf.name = 'PaymentAgreementCompleted'
    LEFT JOIN PERSON_EXT_ATTRS signatureTC 
        ON owner.center = signatureTC.PERSONCENTER 
       AND owner.id = signatureTC.PERSONID 
       AND signatureTC.name = 'Signatureinplace'
    LEFT JOIN PERSON_EXT_ATTRS validStartdate 
        ON owner.center = validStartdate.PERSONCENTER 
       AND owner.id = validStartdate.PERSONID 
       AND validStartdate.name = 'VALID_START_DATE'
    LEFT JOIN PERSON_EXT_ATTRS signatureDDI 
        ON owner.center = signatureDDI.PERSONCENTER 
       AND owner.id = signatureDDI.PERSONID 
       AND signatureDDI.name = 'SIGNATURE_IN_PLACE_DDM'
    LEFT JOIN PERSON_EXT_ATTRS Pend 
        ON owner.center = Pend.PERSONCENTER 
       AND owner.id = Pend.PERSONID 
       AND pend.name = 'PENDCLEAREDRG'
    LEFT JOIN EMPLOYEES emp 
        ON ss.EMPLOYEE_CENTER = emp.CENTER 
       AND ss.EMPLOYEE_ID = emp.ID
    LEFT JOIN PERSONS salesperson 
        ON salesperson.CENTER = emp.PERSONCENTER 
       AND salesperson.ID = emp.PERSONID
    LEFT JOIN PERSON_EXT_ATTRS salesPersonOverrideExt 
        ON owner.center = salesPersonOverrideExt.PERSONCENTER 
       AND owner.id = salesPersonOverrideExt.PERSONID 
       AND salesPersonOverrideExt.name = 'MC'
    LEFT JOIN PERSONS salesPersonOverride 
        ON salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID = salesPersonOverrideExt.TXTVALUE

    WHERE
        ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
        AND ss.SUBSCRIPTION_CENTER != '999'
        AND NOT EXISTS (
            SELECT 1
            FROM SUBSCRIPTIONS oldsub
            JOIN PERSONS oldPerson 
                ON oldSub.OWNER_CENTER = oldPerson.CENTER 
               AND oldSub.OWNER_ID = oldPerson.ID
            JOIN PRODUCTS oldsubprod 
                ON oldsubprod.CENTER = oldsub.subscriptiontype_center 
               AND oldsubprod.ID = oldsub.subscriptiontype_id 
               AND oldsubprod.name NOT IN ('Free Adult Guest', 'Paying Adult Guest','Trial Membership', 'Guest', 'Guest Pass Subscription', 'Online Membership','Free Trial','Hyrox Training','Invite A Friend')
            WHERE oldPerson.CURRENT_PERSON_CENTER = owner.center 
              AND oldPerson.CURRENT_PERSON_ID = owner.ID
              AND (oldSub.CENTER <> sub.CENTER OR oldSub.ID <> sub.ID)
              AND oldSub.END_DATE + 30 > longtodateC(sub.CREATION_TIME, sub.CENTER)
              AND (oldSub.STATE != 5 AND NOT (oldSub.STATE = 3 AND oldSub.SUB_STATE = 8))
        )
        AND NOT EXISTS (
            SELECT 1
            FROM STATE_CHANGE_LOG SCLCHECK
            WHERE SCLCHECK.CENTER = sub.CENTER 
              AND SCLCHECK.ID = sub.ID
              AND SCLCHECK.ENTRY_TYPE = 2 
              AND SCLCHECK.STATEID IN (2, 3, 4, 8)
              AND SCLCHECK.SUB_STATE IN (3, 4, 5, 6, 7, 8)
        )
        AND EXISTS (
            SELECT 1
            FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
            WHERE pgl.PRODUCT_CENTER = prod.CENTER 
              AND pgl.PRODUCT_ID = prod.ID 
              AND pgl.PRODUCT_GROUP_ID = 203
        )

    GROUP BY
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
        prod.NAME,
        id_seen.TXTVALUE,
        linked_member.TXTVALUE,
        emergencyDetails.TXTVALUE,
        paf.TXTVALUE,
        signatureTC.TXTVALUE,
        validStartdate.TXTVALUE,
        signatureDDI.TXTVALUE,
        Pend.TXTVALUE
)
SELECT *
FROM base
WHERE "Pend Cleared" = 'NO'
ORDER BY DATE_JOINED, sales_person;
