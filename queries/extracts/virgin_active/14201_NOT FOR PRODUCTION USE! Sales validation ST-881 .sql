/*
Parameters:
Scope: Scope in which clubs are included in the extract
Creation from: The date from which new membership are included based on the creation time
Creation to: The date up until which new membership are included based on the creation time
Logic:
Get all memberships creation in the selected period and scope
Exclude all memberships where member have had a previous membership within last 30 days from the creation time of this membership - except if this was cancelled
Exclude all memberships with sub state equal to either transfers, extensions, upgrades, downgrades, cancelled and regretted
Exclude all membership types that are not in the product group for 'Commissionable sales'
From date (indicator)
To Date (indicator)
Subscription creation date (indicator)
Subscription created between (including) from and to date (Rule)
list of old subs before 30 days cut date with end date and states (indicator)
list of old subs after 30 days cut date with end date and states (indicator)
did the member have a membership ended lesser then 30 days before the new sub was created where old sub state (cancelled subs should not be included in this or if the previous sub was CASH which was extended) (Rule)
Substate of current sub (indicator)
State of current sub (indicator)
The current sub should not be transfers, extensions, upgrades, downgrades, cancelled or regretted (Rule)
cocateneted list of current sub groduct groups (indicator)
the current sub should be connected to product group 248
*/
SELECT
    CASE
        WHEN IS_SUB_CREATED_BETWEEN_DATES = 1
            AND OTHER_SUBS_WITHIN_30 IS NULL
            AND SUB_STATE_OK = 1
            AND PG_COMISSIONABLE_SALES = 1
            AND COMMISSIONABLE = 'YES'
        THEN 1
        ELSE 0
    END sales_ok_new,
    CASE
        WHEN IS_SUB_CREATED_BETWEEN_DATES = 1
            AND INCLUDE_OLD = 1
            AND SUB_STATE_NOT_OK_OLD != 1
            AND PG_COMISSIONABLE_SALES = 1
            AND COMMISSIONABLE = 'YES'
        THEN 1
        ELSE 0
    END sales_ok_old,
    i1.*
FROM
    (
        SELECT
            /*+ NO_BIND_AWARE */
            ' --> ' RULES ,
            /* 1 if the subscriptionis created between the dates selected */
            CASE
                WHEN sub.CREATION_TIME >= $$CreationFrom$$
                    AND sub.CREATION_TIME < $$CreationTo$$ + (1000*60*60*24)
                THEN 1
                ELSE 0
            END IS_SUB_CREATED_BETWEEN_DATES,
            /* List with information about old subs that has an end date lesser then 30 days away from the creation date of the new subscription. This should be null for sales validation */
            (
                SELECT
                    LISTAGG(RPAD('SSID:' || allS.CENTER || 'ss' || allS.ID,20) || RPAD('END_DATE:' || allS.END_DATE,'20') || RPAD('STATE:' || DECODE(allS.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN'),15) || RPAD('SUB STATE:' || DECODE (allS.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN'),20) || RPAD('SUB TYPE:' || DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect'),20) ,' / ') within GROUP (ORDER BY allS.END_DATE DESC) concat
                FROM
                    PERSONS allP
                JOIN
                    SUBSCRIPTIONS allS
                ON
                    allS.OWNER_CENTER = allP.CENTER
                    AND allS.OWNER_ID = allP.ID
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = allS.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = allS.SUBSCRIPTIONTYPE_ID
                WHERE
                    allP.CURRENT_PERSON_CENTER = owner.CENTER
                    AND allp.CURRENT_PERSON_ID = owner.ID
                    AND (
                        allS.CENTER,allS.ID) NOT IN ((SUB.CENTER,
                                                      SUB.ID))
                    AND NOT (
                        allS.STATE = 3
                        AND allS.SUB_STATE = 8)
                    AND NOT (
                        allS.STATE = 3
                        AND allS.SUB_STATE = 8)
                    AND allS.END_DATE + 30 > exerpro.longtodateTZ(sub.CREATION_TIME, 'Europe/London') ) OTHER_SUBS_WITHIN_30,
            /* 1 If current state of sub is in CREATED, ACTIVE, FROZEN and sub state in NONE, BLOCKED*/
            CASE
                WHEN SUB.STATE IN (2,4,8)
                    AND sub.SUB_STATE IN (1,9)
                THEN 1
                ELSE 0
            END SUB_STATE_OK,
            /* 1 If sub state in CREATED, ACTIVE, FROZEN at any time between from and to date. Old style */
            (
                SELECT
                    MAX(1)
                FROM
                    STATE_CHANGE_LOG SCL1
                WHERE
                    SCL1.CENTER = SUB.CENTER
                    AND SCL1.ID = SUB.ID
                    AND SCL1.ENTRY_TYPE = 2
                    AND SCL1.STATEID IN (2,
                                         4,8)
                    AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
                    AND (
                        SCL1.ENTRY_END_TIME IS NULL
                        OR SCL1.ENTRY_END_TIME < $$CreationTo$$ + (1000*60*60*24) ) ) include_old,
            (
                /* 1 Doesen't make any sense at all. These states are not possible with those sub states and then it limits by another state change log */
                SELECT
                    MAX(1)
                FROM
                    STATE_CHANGE_LOG SCL1
                JOIN
                    STATE_CHANGE_LOG SCLCHECK
                ON
                    SCLCHECK.ENTRY_TYPE = 2
                    AND SCLCHECK.STATEID IN (2,
                                             4,8)
                    AND SCLCHECK.SUB_STATE IN (3,4,5,6,7,8)
                    AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
                    AND SCL1.ENTRY_START_TIME < $$CreationTo$$ + (1000*60*60*24)
                WHERE
                    SCLCHECK.CENTER = SUB.CENTER
                    AND SCLCHECK.ID = SUB.ID
                    AND SCL1.CENTER = SUB.CENTER
                    AND SCL1.ID = SUB.ID
                    AND SCL1.ENTRY_TYPE = 2
                    AND SCL1.STATEID IN (2,
                                         4,8)
                    AND SCL1.ENTRY_START_TIME >= $$CreationFrom$$
                    AND (
                        SCL1.ENTRY_END_TIME IS NULL
                        OR SCL1.ENTRY_END_TIME < $$CreationTo$$ + (1000*60*60*24) ) ) SUB_STATE_NOT_OK_OLD,
            (
                /* One if the subscription is connected the product group commissionable sales */
                SELECT
                    MAX(1)
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                WHERE
                    pgl.PRODUCT_CENTER = prod.CENTER
                    AND pgl.PRODUCT_ID = prod.ID
                    AND pgl.PRODUCT_GROUP_ID = 248)                                                                PG_COMISSIONABLE_SALES,
            ' --> '                                                                                                INDICATORS,
            TO_CHAR(exerpro.longToDateTz($$CreationFrom$$,'Europe/london'),'YYYY-MM-DD HH24:MI')                         Creation_From_Parameter,
            TO_CHAR(exerpro.longToDateTz($$CreationTo$$ + (1000 * 60 * 60 * 24),'Europe/london'),'YYYY-MM-DD HH24:MI') Creation_To_Parameter,
            TO_CHAR(exerpro.longToDateTz(sub.CREATION_TIME ,'Europe/london'),'YYYY-MM-DD HH24:MI')                 SUB_CREATED_TIME,
            (
                SELECT
                    LISTAGG(RPAD('SSID:' || allS.CENTER || 'ss' || allS.ID,20) || RPAD('END_DATE:' || allS.END_DATE,'20') || RPAD('STATE:' || DECODE(allS.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN'),15) || RPAD('SUB STATE:' || DECODE (allS.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN'),20) || RPAD('SUB TYPE:' || DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect'),20) ,' / ') within GROUP (ORDER BY allS.END_DATE DESC) concat
                FROM
                    PERSONS allP
                JOIN
                    SUBSCRIPTIONS allS
                ON
                    allS.OWNER_CENTER = allP.CENTER
                    AND allS.OWNER_ID = allP.ID
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = allS.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = allS.SUBSCRIPTIONTYPE_ID
                WHERE
                    allP.CURRENT_PERSON_CENTER = owner.CENTER
                    AND allp.CURRENT_PERSON_ID = owner.ID
                    AND (
                        allS.CENTER,allS.ID) NOT IN ((SUB.CENTER,
                                                      SUB.ID)) )                                                                                                                      all_other_subs,
            DECODE (SUB.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN')                                                                                  AS SUB_STATE,
            DECODE (SUB.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS SUB_SUB_STATE,
            DECODE(stype.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect')                                                                                                                 AS SUB_TYPE,
            (
                SELECT
                    LISTAGG(pg.NAME || '(' || pg.ID || ')' ,' / ') within GROUP (ORDER BY pg.NAME)
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pg.ID = pgl.PRODUCT_GROUP_ID
                WHERE
                    pgl.PRODUCT_CENTER = prod.CENTER
                    AND pgl.PRODUCT_ID = prod.ID ) product_groups,
            '-->'                                  REGULAR_COLUMNS,
            centre.SHORTNAME                       club,
            TO_CHAR(sub.start_date, 'DD-MM-YYYY')  start_date,
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
            TO_CHAR(exerpro.longtodateTZ(sub.CREATION_TIME, 'Europe/London'), 'DD-MM-YYYY') DATE_JOINED,
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
            parq.TXTVALUE           parq,
            signatureTC.TXTVALUE    signatureTC,
            validStartdate.TXTVALUE validStartDate,
            signatureDDI.TXTVALUE   signatureDDI
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
        LEFT JOIN
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
            /*
            AND sub.CREATION_TIME >= $$CreationFrom$$
            AND sub.CREATION_TIME < $$CreationTo$$ + (1000*60*60*24)
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
                    AND oldSub.END_DATE + 30 > exerpro.longtodateTZ(sub.CREATION_TIME, 'Europe/London')
                    AND (
                        oldSub.STATE != 5
                        AND NOT(
                            oldSub.STATE = 3
                            AND oldSub.SUB_STATE = 8)))
                            */
            -- Exclude all transfers, extensions, upgrades, downgrades, cancelled and regretted
            /*
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
                    */
        GROUP BY
            prod.CENTER,
            prod.ID,
            sub.state,
            sub.SUB_STATE,
            stype.ST_TYPE,
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
            signatureDDI.TXTVALUE,
            SUB.CENTER,
            SUB.ID
        ORDER BY
            sub.CREATION_TIME,
            salesperson.FULLNAME ) i1