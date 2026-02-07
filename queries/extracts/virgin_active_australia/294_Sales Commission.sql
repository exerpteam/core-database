-- This is the version from 2026-02-05
--  
 SELECT
     club,
     sales_person,
     COUNT(*) sales_completed,
     SUM(
         CASE
             WHEN Commissionable LIKE 'YES'
             THEN 1
             ELSE 0
         END) sales_commissionable
 FROM
     (
         SELECT
             centre.SHORTNAME club,
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
             END orig_sales_person,
             TO_CHAR(longtodateTZ(sub.CREATION_TIME, 'Australia/Sydney'), 'DD-MM-YYYY') DATE_JOINED,
             owner.CENTER || 'p' || owner.ID member_id,
             owner.FULLNAME member_name,
             prod.NAME MEMBERSHIP,
             CASE
        WHEN id_seen.TXTVALUE IN ('Y', 'N/A')
             AND linked_member.TXTVALUE IN ('Y', 'N/A')
             AND emergencyDetails.TXTVALUE IN ('Y', 'N/A')
             AND paf.TXTVALUE IN ('Y', 'N/A')
             AND signatureTC.TXTVALUE IN ('Y', 'N/A')
        THEN 'YES'
        ELSE 'NO'
    END AS Commissionable,
             --VALIDATION FIELDS FOR COMMISSION
             id_seen.TXTVALUE AS "ID Provided",
    linked_member.TXTVALUE AS "Linked Member",
    emergencyDetails.TXTVALUE AS "Emergency Details Completed",
    paf.TXTVALUE AS "PAF Completed",
    signatureTC.TXTVALUE AS "Contract Signature"
         FROM
             SUBSCRIPTION_SALES ss
         JOIN
             SUBSCRIPTIONS sub
         ON
             sub.CENTER = ss.SUBSCRIPTION_CENTER
             AND sub.ID = ss.SUBSCRIPTION_ID
         JOIN
             SUBSCRIPTIONTYPES stype
         ON
             ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
             AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
         JOIN
             PRODUCTS prod
         ON
             stype.CENTER = prod.CENTER
             AND stype.ID = prod.ID
         JOIN
             PERSONS owner
         ON
             owner.CENTER = sub.OWNER_CENTER
             AND owner.ID = sub.OWNER_ID
         JOIN
             CENTERS centre
         ON
             owner.CENTER = centre.ID
         JOIN
             STATE_CHANGE_LOG SCL1
         ON
             (
                 SCL1.CENTER = SUB.CENTER
                 AND SCL1.ID = SUB.ID
                 AND SCL1.ENTRY_TYPE = 2
                 AND SCL1.STATEID IN (2,
                                      4,8)
                 AND SCL1.ENTRY_START_TIME >= EXTRACT(EPOCH FROM $$CreationFrom$$::TIMESTAMP) * 1000

                 AND (
                     SCL1.ENTRY_END_TIME IS NULL
                     OR SCL1.ENTRY_END_TIME < (EXTRACT(EPOCH FROM $$CreationTo$$::TIMESTAMP) * 1000 + 86400000) ))
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
             PERSON_EXT_ATTRS id_seen ON owner.center = id_seen.PERSONCENTER AND owner.id = id_seen.PERSONID AND id_seen.name = 'IDseenapproved'
LEFT JOIN
    PERSON_EXT_ATTRS linked_member ON owner.center = linked_member.PERSONCENTER AND owner.id = linked_member.PERSONID AND linked_member.name = 'Linkedmembervalid'
LEFT JOIN
    PERSON_EXT_ATTRS emergencyDetails ON owner.center = emergencyDetails.PERSONCENTER AND owner.id = emergencyDetails.PERSONID AND emergencyDetails.name = 'EmergencyContactDetailsCompleted'
LEFT JOIN
    PERSON_EXT_ATTRS paf ON owner.center = paf.PERSONCENTER AND owner.id = paf.PERSONID AND paf.name = 'PaymentAgreementCompleted'
LEFT JOIN
    PERSON_EXT_ATTRS signatureTC ON owner.center = signatureTC.PERSONCENTER AND owner.id = signatureTC.PERSONID AND signatureTC.name = 'Signatureinplace'
         LEFT JOIN
             PERSON_EXT_ATTRS validStartdate
         ON
             owner.center = validStartdate.PERSONCENTER
             AND owner.id = validStartdate.PERSONID
             AND validStartdate.name = 'VALID_START_DATE'
         LEFT JOIN
             PERSON_EXT_ATTRS signatureDDI
         ON
             owner.center = signatureDDI.PERSONCENTER
             AND owner.id = signatureDDI.PERSONID
             AND signatureDDI.name = 'SIGNATURE_IN_PLACE_DDM'
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
             ss.SUBSCRIPTION_CENTER IN ($$Scope$$)
             AND sub.CREATION_TIME >= EXTRACT(EPOCH FROM $$CreationFrom$$::TIMESTAMP) * 1000
             AND sub.CREATION_TIME < (EXTRACT(EPOCH FROM $$CreationTo$$::TIMESTAMP) * 1000 + 86400000)
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
                 WHERE
                     oldPerson.EXTERNAL_ID = owner.EXTERNAL_ID
                     AND (
                         oldSub.CENTER <> sub.CENTER
                         OR oldSub.ID <> sub.ID)
                     AND oldSub.END_DATE + 30 > longtodateTZ(sub.CREATION_TIME, 'Australia/Sydney')
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
                     AND SCLCHECK.STATEID IN (2,
                                              4,8)
                     AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
                     AND SCL1.ENTRY_START_TIME >= EXTRACT(EPOCH FROM $$CreationFrom$$::TIMESTAMP) * 1000
                     AND SCL1.ENTRY_START_TIME < (EXTRACT(EPOCH FROM $$CreationTo$$::TIMESTAMP) * 1000 + 86400000))
             AND EXISTS
             (
                 SELECT
                     *
                 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                 WHERE
                     pgl.PRODUCT_CENTER = prod.CENTER
                     AND pgl.PRODUCT_ID = prod.ID
                     AND pgl.PRODUCT_GROUP_ID = 203)
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
             signatureDDI.TXTVALUE
         ORDER BY
             sub.CREATION_TIME,
             salesperson.FULLNAME ) t
 GROUP BY
     club,
     sales_person
