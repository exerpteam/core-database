-- The extract is extracted from Exerp on 2026-02-08
-- Quick 'n' dirty.
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
            TO_CHAR(longtodateTZ(sub_creationtime, 'Europe/London'), 'DD-MM-YYYY') DATE_JOINED,
            TO_CHAR(longtodateTZ(sub_creationtime, 'Europe/London'), 'HH24:MI') TIME_JOINED,
            TO_CHAR(sub_start_date, 'DD-MM-YYYY') start_date,
            
                   
                 salesperson.FULLNAME                                   orig_sales_person,
           
            ow_center || 'p' || ow_id                                              member_id,
            ow_fullname                                                            member_name,
            prod_name                                                              MEMBERSHIP
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
            EMPLOYEES emp
        ON
            ss_empcenter = emp.CENTER
        AND ss_empid = emp.ID
        LEFT JOIN
            persons salesperson
        ON
            salesperson.CENTER = emp.PERSONCENTER
        AND salesperson.ID = emp.PERSONID
        
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
       
        GROUP BY
                        sub_creationtime,
            sub_start_date,
            center_shortname,
            salesperson.FULLNAME,
            salesperson.CENTER,
            salesperson.ID,        
            ow_center,
            ow_id,
            ow_fullname,
            prod_name)x
--WHERE
--    Pend_Cleared = 'Y'
--AND Commissionable = 'NO'