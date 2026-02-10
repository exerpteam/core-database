-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')- interval '1 day', 'YYYY-MM-DD'),
            c.id) AS BIGINT) AS CreationFrom,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id) AS BIGINT) AS CreationTo,
            c.id AS centerid
        FROM
            centers c
       )
          
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
    owner.CENTER || 'p' || owner.ID                                                 member_id,
    owner.FULLNAME                                                                  member_name,
    prod.NAME                                                                       MEMBERSHIP,
    CASE
        WHEN id_seen.TXTVALUE IN ('Y',
                                  'NA')
            AND linked_member.TXTVALUE IN ('Y',
                                           'NA')
            AND Member_Details.TXTVALUE IN ('Y',
                                            'NA')
            AND parq.TXTVALUE IN ('Y',
                                  'NA')
            AND signatureTC.TXTVALUE IN ('Y',
                                         'NA')
            AND validStartdate.TXTVALUE IN ('Y',
                                            'NA')
            AND signatureDDI.TXTVALUE IN ('Y',
                                          'NA')
        THEN 'YES'
        ELSE 'NO'
    END Commissionable,
    --VALIDATION FIELDS FOR COMMISSION
    id_seen.TXTVALUE        id_seen,
    linked_member.TXTVALUE  linked_member,
    Member_Details.TXTVALUE Member_Details,
    parq.TXTVALUE           parq_HCS,
    signatureTC.TXTVALUE    signatureTC,
    validStartdate.TXTVALUE validStartDate,
    signatureDDI.TXTVALUE   signatureDDI
FROM
    SUBSCRIPTION_SALES ss

JOIN
    params
ON
    params.centerid = ss.subscription_center

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
        AND SCL1.ENTRY_START_TIME >= params.CreationFrom
        AND (
            SCL1.ENTRY_END_TIME IS NULL
            OR SCL1.ENTRY_END_TIME < params.CreationTo ))
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
    PERSON_EXT_ATTRS id_seen
ON
    owner.center = id_seen.PERSONCENTER
    AND owner.id = id_seen.PERSONID
    AND id_seen.name = 'ID_SEEN_APPROVED'
LEFT JOIN
    PERSON_EXT_ATTRS linked_member
ON
    owner.center = linked_member.PERSONCENTER
    AND owner.id = linked_member.PERSONID
    AND linked_member.name = 'LINKED_MEMBER_VALID'
LEFT JOIN
    PERSON_EXT_ATTRS Member_Details
ON
    owner.center = Member_Details.PERSONCENTER
    AND owner.id = Member_Details.PERSONID
    AND Member_Details.name = 'MEMBER_PERSONAL_DETAILS_ACCURATE'
LEFT JOIN
    PERSON_EXT_ATTRS parq
ON
    owner.center = parq.PERSONCENTER
    AND owner.id = parq.PERSONID
    AND parq.name = 'PARQ_COMPLETED_ALL_NO'
LEFT JOIN
    PERSON_EXT_ATTRS signatureTC
ON
    owner.center = signatureTC.PERSONCENTER
    AND owner.id = signatureTC.PERSONID
    AND signatureTC.name = 'SIGNATURE_IN_PLACE_TOM'
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
    AND sub.CREATION_TIME >= params.CreationFrom
    AND sub.CREATION_TIME <  params.CreationTo
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
            AND SCL1.ENTRY_START_TIME >= params.CreationFrom
            AND SCL1.ENTRY_START_TIME < params.CreationTo)
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
    Member_Details.TXTVALUE,
    parq.TXTVALUE,
    signatureTC.TXTVALUE,
    validStartdate.TXTVALUE,
    signatureDDI.TXTVALUE
ORDER BY
    sub.CREATION_TIME,
    salesperson.FULLNAME