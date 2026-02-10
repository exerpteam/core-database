-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    sub AS
    (
        SELECT
            p.center || 'p' || p.id AS PersonId,
            s.center || 'ss'|| s.id AS SubscriptionId,
            p.fullname,
            p.address1,
            p.city,
            p.zipcode,
            email.txtvalue AS email,
            pr.name        AS "Membership Name",
            s.subscription_price,
            p.external_id,
            CASE p.persontype
                WHEN 0
                THEN 'PRIVATE'
                WHEN 1
                THEN 'STUDENT'
                WHEN 2
                THEN 'STAFF'
                WHEN 3
                THEN 'FRIEND'
                WHEN 4
                THEN 'CORPORATE'
                WHEN 5
                THEN 'ONEMANCORPORATE'
                WHEN 6
                THEN 'FAMILY'
                WHEN 7
                THEN 'SENIOR'
                WHEN 8
                THEN 'GUEST'
                WHEN 9
                THEN 'CHILD'
                WHEN 10
                THEN 'EXTERNAL STAFF'
                ELSE 'UNKNOWN'
            END          AS "PersonType",
            s.start_date AS "Subscription start date",
            s.billed_until_date,
            s.end_date                                        AS "Subscription End date",
            existsrd.start_date                               AS ExistingSavedFreezStart,
            existsrd.end_date                                 AS ExistingSavedFreezeEnd ,
            existsrd.type                                     AS "FreezeType",
            existsrd.text                                     AS "Freeze Text",
            m.globalid                                        AS AddonName1,
            sa.start_date                                     AS AddonStartDate1,
            sa.end_date                                       AS AddonEndDate1,
            NVL(sa.individual_price_per_unit, addon_pr.PRICE) AS AddonPrice1
        FROM
            subscriptions s
        JOIN
            persons p
        ON
            p.center = s.owner_center
            AND p.id = s.owner_id
        JOIN
            subscriptiontypes st
        ON
            st.center = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_id
            AND st.st_type = 1
        JOIN
            PRODUCTS pr
        ON
            st.CENTER = pr.CENTER
            AND st.ID = pr.ID
            /* This is to show any partial free/freeze during the corona period */
        LEFT JOIN
            subscription_reduced_period existsrd
        ON
            existsrd.subscription_center = s.center
            AND existsrd.subscription_id = s.id
            AND existsrd.state = 'ACTIVE'
            AND existsrd.start_date <= to_date('16-04-2020', 'dd-MM-yyyy')
            AND existsrd.end_date >= to_date('12-03-2020', 'dd-MM-yyyy')
            AND existsrd.text != 'COVID19 Free Period'
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            p.CENTER = email.PERSONCENTER
            AND p.ID = email.PERSONID
            AND email.NAME = '_eClub_Email'
        LEFT JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
            AND sa.subscription_id = s.id
            AND sa.cancelled = 0
            AND sa.end_date BETWEEN to_date('12-03-2020', 'dd-MM-yyyy') AND to_date('31-03-2020', 'dd-MM-yyyy')
        LEFT JOIN
            masterproductregister m
        ON
            m.id = sa.addon_product_id
        LEFT JOIN
            PRODUCTS addon_pr
        ON
            addon_pr.GLOBALID = m.GLOBALID
            AND addon_pr.center = sa.CENTER_ID
        WHERE
            /* Exclude corporate members */
            p.persontype != 4
            /* Exclude Urban Gym clubs */
            AND s.center NOT BETWEEN 400 AND 420
            /* Exclude Poland clubs */
            AND s.center < 700
            AND s.state IN (2,
                            4,
                            8)
            /* Include Addon with end date between 12/03 and 31/03 */
            AND sa.ID IS NOT NULL
            /* Exclude subscription ended before 16/04 since there another extracts to catch it */
            AND (
                s.end_date IS NULL
                OR s.end_date > to_date('16-04-2020', 'dd-MM-yyyy'))
    )
    ,
    v_pivot AS
    (
        SELECT
            sub.* ,
            LEAD(AddonName1,1) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)      AS AddonName2 ,
            LEAD(AddonStartDate1,1) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1) AS AddonStartDate2 ,
            LEAD(AddonEndDate1,1) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)   AS AddonEndDate2 ,
            LEAD(AddonPrice1,1) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)     AS AddonPrice2,
            LEAD(AddonName1,2) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)      AS AddonName3 ,
            LEAD(AddonStartDate1,2) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1) AS AddonStartDate3 ,
            LEAD(AddonEndDate1,2) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)   AS AddonEndDate3 ,
            LEAD(AddonPrice1,2) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)     AS AddonPrice3,
            LEAD(AddonName1,3) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)      AS AddonName4 ,
            LEAD(AddonStartDate1,3) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1) AS AddonStartDate4 ,
            LEAD(AddonEndDate1,3) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)   AS AddonEndDate4 ,
            LEAD(AddonPrice1,3) OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)     AS AddonPrice4,
            ROW_NUMBER() OVER (PARTITION BY PERSONID, SubscriptionId ORDER BY AddonStartDate1)            AS ADDONSEQ
        FROM
            sub
    )
SELECT
    *
FROM
    v_pivot
WHERE
    ADDONSEQ = 1