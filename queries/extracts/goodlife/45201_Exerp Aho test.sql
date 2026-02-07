WITH
    params AS materialized
    (
        SELECT
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '1 months', 'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateOneMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '2 months', 'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateTwoMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '3 months', 'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateThreeMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '10 days', 'YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateTenDays,
            c.id         AS centerid
        FROM
            goodlife.centers c
        WHERE
            c.time_zone IS NOT NULL
    )
    ,
    members_on_freeze AS
    ( -- Members on freeze
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            goodlife.subscription_freeze_period sfp
        ON
            sfp.subscription_center = s.center
        AND sfp.subscription_id = s.id
        AND sfp.state = 'ACTIVE'
        AND sfp.start_date <= CURRENT_DATE
        AND sfp.end_date >= CURRENT_DATE
        WHERE
            s.state IN (2,
                        4,
                        8)
    )
    ,
    zero_subscriptions AS
    ( -- $0 Subscriptions
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            goodlife.product_and_product_group_link ppl
        ON
            s.subscriptiontype_center = ppl.product_center
        AND s.subscriptiontype_id = ppl.product_id
        AND ppl.product_group_id = 1004
        WHERE
            s.state IN (2,
                        4,
                        8)
        AND s.subscription_price = 0
    )
    ,
    active_debt_cases AS 
    ( -- Members with an active debt case
        SELECT DISTINCT
            ccc.personcenter AS center,
            ccc.personid     AS id
        FROM
            goodlife.cashcollectioncases ccc
        WHERE
            ccc.missingpayment IN (0,
                                   1)
        AND ccc.closed = 0
    )
    ,
    missing_document_cases AS 
    ( -- Members with missing document case
        SELECT DISTINCT
            je.person_center AS center,
            je.person_id     AS id
        FROM
            goodlife.journalentries je
        LEFT JOIN
            goodlife.journalentry_signatures link
        ON
            je.id = link.journalentry_id
        LEFT JOIN
            goodlife.subscriptions s
        ON
            je.ref_center = s.center
        AND je.ref_id = s.id
        AND je.jetype = 1
        AND s.state IN (2,
                        4,
                        8)
        LEFT JOIN
            goodlife.clipcards c
        ON
            je.ref_center = c.center
        AND je.ref_id = c.id
        AND je.ref_subid = c.subid
        AND je.jetype = 34
        AND c.blocked = FALSE
        AND c.finished = FALSE
        LEFT JOIN
            goodlife.relatives r
        ON
            je.ref_center = r.center
        AND je.ref_id = r.id
        AND r.rtype = 12
        AND r.status = 1
        AND je.jetype = 16
        WHERE
            je.signable = 1
        AND link.signature_center IS NULL
        AND (
                je.jetype = 1
            AND s.center IS NOT NULL
            OR  je.jetype = 34
            AND c.center IS NOT NULL
            OR  je.jetype = 16
            AND r.center IS NOT NULL )
    )
    ,
    members_in_regret_period AS
    ( -- Members in regret period
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            params
        ON
            params.centerid = s.center
        WHERE
            s.state IN (2,
                        4,
                        8)
        AND s.creation_time > params.cutDateTenDays
    )
    ,
    members_with_change_subscription AS
    ( -- Members due to change subscription
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            goodlife.subscription_change sc
        ON
            sc.old_subscription_center = s.center
        AND sc.old_subscription_id = s.id
        WHERE
            s.state IN (2,
                        4,
                        8)
        AND sc.type = 'TYPE'
        AND sc.cancel_time IS NULL
    )
    ,
    members_with_eft_subscription AS
    ( -- Members whose main membership subscription is EFT and the subscription period start date
        -- is NOT 'today'
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            goodlife.subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        JOIN
            goodlife.products pr
        ON
            st.center = pr.center
        AND st.id = pr.id
        JOIN
            goodlife.product_and_product_group_link ppl
        ON
            pr.center = ppl.product_center
        AND pr.id = ppl.product_id
        WHERE
            ppl.product_group_id = 1004
        AND s.state IN (2,
                        4,
                        8)
        AND st.st_type = 1
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    goodlife.subscriptionperiodparts spp
                WHERE
                    s.center = spp.center
                AND s.id = spp.id
                AND ( (
                            s.renewal_policy_override IN (6,
                                                          10)
                        AND spp.to_date = CURRENT_DATE - INTERVAL '1 DAY')
                    OR  spp.from_date = CURRENT_DATE )
                AND spp.cancellation_time = 0 )
    )
    ,
    members_with_corporate_sponsored AS
    ( -- Members who have a Corporate (part) sponsored members where the transfer timing would
        -- cause a pro-rata/period break in the company invoice.
        SELECT
            s.owner_center AS center,
            s.owner_id     AS id
        FROM
            goodlife.subscriptions s
        JOIN
            goodlife.subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        JOIN
            goodlife.products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        WHERE
            pr.globalid = 'PAP_M_ALL_CLUB_KAFP'
        AND s.state IN (2,
                        4,
                        8)
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    goodlife.subscriptionperiodparts spp
                WHERE
                    s.center = spp.center
                AND s.id = spp.id
                AND spp.from_date = CURRENT_DATE
                AND spp.cancellation_time = 0 )
    )
    ,
    member_due_change AS
    (-- Members due to change
        -- person_type = private
        SELECT
            ind.owner_center AS center,
            ind.owner_id     AS id
        FROM
            goodlife.subscriptions ind
        JOIN
            goodlife.products prind
        ON
            ind.subscriptiontype_center = prind.center
        AND ind.subscriptiontype_id = prind.id
        JOIN
            goodlife.product_and_product_group_link pl
        ON
            prind.id = pl.product_id
        AND prind.center = pl.product_center
        JOIN
            goodlife.persons per
        ON
            ind.owner_center= per.center
        AND ind.owner_id = per.id
        WHERE
            ind.state IN (2,4,8)
        AND pl.product_group_id IN ( 2801,
                                    4201 )
        AND per.persontype NOT IN (4)
    )
    ,
    members_selected AS
    (
        SELECT
            p.center    AS center,
            p.id        AS id,
            p.firstname AS firstname,
            p.lastname  AS lastname
        FROM
            goodlife.persons p
        WHERE
           p.center IN (:Scope)
        AND p.status = 1
        AND p.persontype NOT IN (2)
   
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    members_on_freeze mf
                WHERE
                    p.center = mf.center
                AND p.id = mf.id )
        
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    zero_subscriptions zs
                WHERE
                    p.center = zs.center
                AND p.id = zs.id )
           
    )
    

    ,
    members_selected_active_debt AS 
    (--heavy, not as much as the missing docs
        SELECT
            *
        FROM
            members_selected p
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    active_debt_cases adc
                WHERE
                    p.center = adc.center
                AND p.id = adc.id )
    )
    , --heavy join
    members_selected_missing_documents AS
    (
        SELECT
            *
        FROM
            members_selected_active_debt p
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    missing_document_cases mdc
                WHERE
                    p.center = mdc.center
                AND p.id = mdc.id )
    )
        ,
    members_selected_rest AS 
    (
        SELECT
            *
        FROM
            members_selected_missing_documents p
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    members_in_regret_period mrip
                WHERE
                    p.center = mrip.center
                AND p.id = mrip.id )
        
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    members_with_change_subscription mwcs
                WHERE
                    p.center = mwcs.center
                AND p.id = mwcs.id )
          
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    members_with_eft_subscription mwes
                WHERE
                    p.center = mwes.center
                AND p.id = mwes.id )
          
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    members_with_corporate_sponsored mwcs
                WHERE
                    p.center = mwcs.center
                AND p.id = mwcs.id )
          
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    member_due_change mdc
                WHERE
                    mdc.center= p.center
                AND mdc.id=p.id)
    )
--SELECT *FROM members_selected_missing_documents 
,
    members_selected_active AS
    ( --heavy join of state change log
    SELECT
    nonexcl.center AS PersonCenter,
    nonexcl.id     AS PersonId,
    nonexcl.firstname,
    nonexcl.lastname,
    longtodateC(scl.entry_start_time, scl.center) AS LastActiveDate
    FROM
    members_selected_rest nonexcl
    JOIN
    goodlife.state_change_log scl
    ON
    scl.center = nonexcl.center
    AND scl.id = nonexcl.id
    AND scl.entry_type=1
    AND scl.entry_end_time IS NULL
    AND scl.stateid = 1 
    )
  -- select * from members_selected_active
  ,
    members_checkin_home AS
    ( -- ACTIVE at home club => 3 months
    SELECT DISTINCT
    extra.PersonCenter,
    extra.PersonId,
    extra.firstname,
    extra.lastname
    FROM
    members_selected_active AS extra
    CROSS JOIN
    params
    JOIN
    goodlife.checkins ch
    ON
    extra.PersonCenter = ch.person_center
    AND extra.PersonId = ch.person_id
    WHERE
    ch.checkin_time > params.cutDateThreeMonths
    AND ch.checkin_center = params.centerid
    AND extra.PersonCenter != ch.checkin_center
    AND extra.LastActiveDate < CURRENT_DATE - interval '3 months' )
    -- select * from members_checkin_home 
    ,
    visits_grouped AS
    (
    SELECT
    t2.PersonCenter,
    t2.PersonId,
    t2.firstname,
    t2.lastname,
    ch.checkin_center AS CheckinCenter,
    SUM(
    CASE
    WHEN ch.checkin_time > params.cutDateOneMonths
    AND ch.checkin_center != ch.person_center
    THEN 1
    ELSE 0
    END) Month1,
    SUM(
    CASE
    WHEN ch.checkin_time < params.cutDateOneMonths
    AND ch.checkin_time > params.cutDateTwoMonths
    AND ch.checkin_center != ch.person_center
    THEN 1
    ELSE 0
    END) Month2,
    SUM(
    CASE
    WHEN ch.checkin_time < params.cutDateTwoMonths
    AND ch.checkin_time > params.cutDateThreeMonths
    AND ch.checkin_center != ch.person_center
    THEN 1
    ELSE 0
    END)                                                                 Month3,
    COUNT(*)                                                               AS VisitsPerClub,
    SUM(COUNT(*)) OVER (PARTITION BY t2.PersonCenter,t2.PersonId ORDER BY 1) AS TotalVisits
    FROM
    members_checkin_home t2
    JOIN
    goodlife.checkins ch
    ON
    t2.PersonCenter = ch.person_center
    AND t2.PersonId = ch.person_id
    AND ch.checkin_result = 1
    JOIN
    params
    ON
    params.centerid = ch.checkin_center
    WHERE
    ch.checkin_time > params.cutDateThreeMonths
    GROUP BY
    t2.PersonCenter,
    t2.PersonId,
    t2.firstname,
    t2.lastname,
    ch.checkin_center )
    -- select * from visits_grouped 
    ,
    visits_stat AS
    (
    SELECT
    tch.PersonCenter,
    tch.PersonId,
    tch.CheckinCenter,
    tch.firstname,
    tch.lastname,
    origin.name      AS homeclubname,
    destination.name AS destinationclubname,
    tch.VisitsPerClub,
    tch.TotalVisits
    FROM
    visits_grouped tch
    JOIN
    goodlife.centers origin
    ON
    tch.PersonCenter = origin.id
    JOIN
    goodlife.centers destination
    ON
    tch.CheckinCenter = destination.id
    WHERE
    tch.Month1 > 3
    AND tch.Month2 > 3
    AND tch.Month3 > 3
    AND ((
    tch.VisitsPerClub * 100) / tch.TotalVisits) > 60 )
    -- select * from visits_stat 
    ,
    included_subscription AS
    (
    SELECT
    withsub.PersonCenter,
    withsub.PersonId,
    withsub.CheckinCenter,
    withsub.firstname,
    withsub.lastname,
    withsub.homeclubname,
    withsub.destinationclubname,
    withsub.VisitsPerClub,
    withsub.TotalVisits,
    s.center || 'ss' || s.id AS SubscriptionId,
    (
    CASE
    WHEN EXISTS
    (
    SELECT
    1
    FROM
    goodlife.product_and_product_group_link prlink
    WHERE
    prlink.product_center = s.subscriptiontype_center
    AND prlink.product_id = s.subscriptiontype_id
    AND prlink.product_group_id IN (6801) )
    AND s.state NOT IN (8)
    THEN 1
    ELSE 0
    END) AS is_included
    FROM
    visits_stat withsub
    LEFT JOIN
    goodlife.subscriptions s
    ON
    s.owner_center = withsub.PersonCenter
    AND s.owner_id = withsub.PersonId
    WHERE
    s.state IN (2,4,8) )
    --select * from included_subscription 
    ,
    everything_group AS
    (
    SELECT
    tab1.PersonCenter  AS Personhomeclub,
    tab1.PersonId      AS Personid,
    tab1.CheckinCenter AS Destinationcentre,
    STRING_AGG(CAST((
    CASE
    WHEN tab1.is_included = 1
    THEN SubscriptionId
    END) AS text), ',') AS Includedsubscriptions,
    STRING_AGG(CAST((
    CASE
    WHEN tab1.is_included = 0
    THEN SubscriptionId
    END) AS text), ',')               AS Excludesubscriptions,
    tab1.PersonCenter || 'p' || tab1.PersonId AS Membershipnumber,
    tab1.firstname                            AS Firstname,
    tab1.lastname                             AS Lastname,
    tab1.homeclubname                         AS Currenthomeclubname,
    tab1.destinationclubname                  AS Destinationclubname,
    tab1.VisitsPerClub                        AS VisitsTransferClub,
    tab1.TotalVisits
    FROM
    included_subscription tab1
    GROUP BY
    tab1.PersonCenter,
    tab1.PersonId,
    tab1.CheckinCenter,
    tab1.firstname,
    tab1.lastname,
    tab1.homeclubname,
    tab1.destinationclubname,
    tab1.VisitsPerClub,
    tab1.TotalVisits )
    --select * from everything_group 
    SELECT
    finalt.Personhomeclub || 'p' || finalt.Personid AS "Person Key",
    finalt.Destinationcentre                        AS "DESTINATION CENTER ID",
    finalt.Includedsubscriptions                    AS "Included subscriptions",
    finalt.Excludesubscriptions                     AS "Exclude subscriptions",
    finalt.Membershipnumber                         AS "Membership number",
    finalt.Firstname                                AS "First name",
    finalt.Lastname                                 AS "Last name",
    finalt.Currenthomeclubname                      AS "Current home club name",
    finalt.Destinationclubname                      AS "Destination club name",
    finalt.VisitsTransferClub                       AS "VisitsTransferClub",
    finalt.TotalVisits,
    TRUE  AS "Keep Cash Prices",
    TRUE  AS "Keep Pre-Authorized Payment Prices Inside Binding",
    TRUE  AS "Keep Pre-Authorized Payment Prices Outside Binding",
    TRUE  AS "Keep Subscription Add-On Prices",
    FALSE AS "Issue New Contract",
    TRUE  AS "Override Product Availability",
    TRUE  AS "Ignore System Properties To Recalculate Prices"
    FROM
    everything_group finalt
    WHERE
    finalt.Includedsubscriptions IS NOT NULL
