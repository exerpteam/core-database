SELECT
    *
FROM
    (
        WITH
            init AS MATERIALIZED
            (
                SELECT
                    owner.center           AS ow_center,
                    owner.id               AS ow_id,
                    owner.FULLNAME         AS ow_fullname,
                    ss.EMPLOYEE_CENTER     AS ss_empcenter,
                    ss.EMPLOYEE_ID         AS ss_empid,
                    ss.subscription_center AS ss_subcenter,
                    ss.subscription_id     AS ss_subid,
                    sub.creation_time      AS sub_creationtime,
                    sub.center             AS sub_center,
                    sub.id                 AS sub_id,
                    SCL1.entry_start_time  AS scl1_entrystart,
                    SCL1.entry_end_time    AS scl1_entryend,
                    prod.CENTER            AS prod_center,
                    prod.ID                AS prod_id,
                    sub.start_date         AS sub_start_date,
                    centre.shortname       AS center_shortname,
                    prod.NAME              AS prod_name
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
                    persons owner
                ON
                    owner.center = sub.OWNER_CENTER
                AND owner.ID = sub.OWNER_ID
                JOIN
                    CENTERS centre
                ON
                    owner.center = centre.ID
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
                        OR  SCL1.ENTRY_END_TIME < $$CreationTo$$ + (1000*60*60*24) ))
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
            )
        SELECT
            /*+ NO_BIND_AWARE */
            center_shortname                      club,
            TO_CHAR(sub_start_date, 'DD-MM-YYYY') start_date,
            CASE
                WHEN salesPersonOverride.CENTER IS NOT NULL
                AND (salesPersonOverride.CENTER <> salesperson.CENTER
                    OR  salesPersonOverride.ID <> salesperson.ID)
                THEN salesPersonOverride.FULLNAME
                ELSE salesperson.FULLNAME
            END sales_person,
            CASE
                WHEN salesPersonOverride.CENTER IS NOT NULL
                AND (salesPersonOverride.CENTER <> salesperson.CENTER
                    OR  salesPersonOverride.ID <> salesperson.ID)
                THEN salesperson.FULLNAME
                ELSE NULL
            END                                                                   orig_sales_person,
            TO_CHAR(longtodateTZ(sub_creationtime, 'Europe/London'), 'DD-MM-YYYY') DATE_JOINED,
            ow_center || 'p' || ow_id                                              member_id,
            ow_fullname                                                            member_name,
            prod_name                                                              MEMBERSHIP,
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
            signatureDDI.TXTVALUE   signatureDDI,
            Pend.TXTVALUE           Pend_Cleared
        FROM
            init
        LEFT JOIN
            person_ext_attrs home
        ON
            ow_center = home.PERSONCENTER
        AND ow_id = home.PERSONID
        AND home.name = '_eClub_PhoneHome'
        LEFT JOIN
            person_ext_attrs mobile
        ON
            ow_center = mobile.PERSONCENTER
        AND ow_id = mobile.PERSONID
        AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
            person_ext_attrs email
        ON
            ow_center = email.PERSONCENTER
        AND ow_id = email.PERSONID
        AND email.name = '_eClub_Email'
        LEFT JOIN
            person_ext_attrs id_seen
        ON
            ow_center = id_seen.PERSONCENTER
        AND ow_id = id_seen.PERSONID
        AND id_seen.name = 'ID_SEEN_APPROVED'
        LEFT JOIN
            person_ext_attrs linked_member
        ON
            ow_center = linked_member.PERSONCENTER
        AND ow_id = linked_member.PERSONID
        AND linked_member.name = 'LINKED_MEMBER_VALID'
        LEFT JOIN
            person_ext_attrs Member_Details
        ON
            ow_center = Member_Details.PERSONCENTER
        AND ow_id = Member_Details.PERSONID
        AND Member_Details.name = 'MEMBER_PERSONAL_DETAILS_ACCURATE'
        LEFT JOIN
            person_ext_attrs parq
        ON
            ow_center = parq.PERSONCENTER
        AND ow_id = parq.PERSONID
        AND parq.name = 'PARQ_COMPLETED_ALL_NO'
        LEFT JOIN
            person_ext_attrs signatureTC
        ON
            ow_center = signatureTC.PERSONCENTER
        AND ow_id = signatureTC.PERSONID
        AND signatureTC.name = 'SIGNATURE_IN_PLACE_TOM'
        LEFT JOIN
            person_ext_attrs validStartdate
        ON
            ow_center = validStartdate.PERSONCENTER
        AND ow_id = validStartdate.PERSONID
        AND validStartdate.name = 'VALID_START_DATE'
        LEFT JOIN
            person_ext_attrs signatureDDI
        ON
            ow_center = signatureDDI.PERSONCENTER
        AND ow_id = signatureDDI.PERSONID
        AND signatureDDI.name = 'SIGNATURE_IN_PLACE_DDM'
        LEFT JOIN
            person_ext_attrs Pend
        ON
            ow_center = Pend.PERSONCENTER
        AND ow_id = Pend.PERSONID
        AND pend.name = 'PENDCLEAREDRG'
        LEFT JOIN
            EMPLOYEES emp
        ON
            ss_empcenter = emp.CENTER
        AND ss_empid = emp.ID
        LEFT JOIN
            persons salesperson
        ON
            salesperson.CENTER = emp.PERSONCENTER
        AND salesperson.ID = emp.PERSONID
        LEFT JOIN
            person_ext_attrs salesPersonOverrideExt
        ON
            ow_center = salesPersonOverrideExt.PERSONCENTER
        AND ow_id = salesPersonOverrideExt.PERSONID
        AND salesPersonOverrideExt.name = 'MC'
        LEFT JOIN
            persons salesPersonOverride
        ON
            salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID =
            salesPersonOverrideExt.TXTVALUE
        WHERE
            ss_subcenter IN ($$Scope$$)
        AND sub_creationtime >= $$CreationFrom$$
        AND sub_creationtime < $$CreationTo$$ + (1000*60*60*24)
        AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    SUBSCRIPTIONS oldsub
                JOIN
                    persons oldPerson
                ON
                    oldSub.OWNER_CENTER = oldPerson.CENTER
                AND oldSub.OWNER_ID = oldPerson.ID
                WHERE
                    oldPerson.CURRENT_PERSON_CENTER = ow_center
                AND OldPerson.CURRENT_PERSON_ID = ow_id
                AND (
                        oldSub.CENTER <> ss_subcenter
                    OR  oldSub.ID <> ss_subid)
                AND oldSub.END_DATE + 30 > longtodateTZ(sub_creationtime, 'Europe/London')
                AND (
                        oldSub.STATE != 5
                    AND NOT(
                            oldSub.STATE = 3
                        AND oldSub.SUB_STATE = 8)))
        AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    STATE_CHANGE_LOG SCLCHECK
                WHERE
                    SCLCHECK.CENTER = sub_center
                AND SCLCHECK.ID = sub_id
                AND SCLCHECK.ENTRY_TYPE = 2
                AND SCLCHECK.STATEID IN (2,3,
                                         4,8)
                AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
                AND scl1_entrystart >= $$CreationFrom$$
                AND scl1_entrystart < $$CreationTo$$ + (1000*60*60*24))
        AND EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                WHERE
                    pgl.PRODUCT_CENTER = prod_center
                AND pgl.PRODUCT_ID = prod_id
                AND pgl.PRODUCT_GROUP_ID = 248)
        GROUP BY
            sub_start_date,
            center_shortname,
            salesperson.FULLNAME,
            salesperson.CENTER,
            salesperson.ID,
            salesPersonOverride.FULLNAME,
            salesPersonOverride.CENTER,
            salesPersonOverride.ID,
            sub_creationtime,
            ow_center,
            ow_id,
            ow_fullname,
            prod_name,
            id_seen.TXTVALUE,
            linked_member.TXTVALUE,
            Member_Details.TXTVALUE,
            parq.TXTVALUE,
            signatureTC.TXTVALUE,
            validStartdate.TXTVALUE,
            signatureDDI.TXTVALUE,
            Pend.TXTVALUE )x
WHERE
    Pend_Cleared = 'Y'
AND Commissionable = 'NO'