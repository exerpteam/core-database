-- The extract is extracted from Exerp on 2026-02-08
-- Created as part of ES-39367
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '1 months','YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateOneMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '2 months','YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateTwoMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '3 months','YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateThreeMonths,
            datetolongTZ(TO_CHAR(CURRENT_DATE - interval '10 days','YYYY-MM-DD HH24:MI:SS'),
            c.time_zone) AS cutDateTenDays,
            c.id         AS centerid
        FROM
            goodlife.centers c
        WHERE
            c.time_zone IS NOT NULL
    )
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
                                            AND prlink.product_group_id = 6801 )
                                    AND (s.state > 8
                                        OR  s.state < 8)
                                    THEN 1
                                    ELSE 0
                                END) AS is_included
                        FROM
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
                                                    AND (ch.checkin_center > ch.person_center
                                                        OR  ch.checkin_center < ch.person_center)
                                                    THEN 1
                                                    ELSE 0
                                                END) Month1,
                                            SUM(
                                                CASE
                                                    WHEN ch.checkin_time < params.cutDateOneMonths
                                                    AND ch.checkin_time > params.cutDateTwoMonths
                                                    AND (ch.checkin_center > ch.person_center
                                                        OR  ch.checkin_center < ch.person_center)
                                                    THEN 1
                                                    ELSE 0
                                                END) Month2,
                                            SUM(
                                                CASE
                                                    WHEN ch.checkin_time < params.cutDateTwoMonths
                                                    AND ch.checkin_time > params.cutDateThreeMonths
                                                    AND (ch.checkin_center > ch.person_center
                                                        OR  ch.checkin_center < ch.person_center)
                                                    THEN 1
                                                    ELSE 0
                                                END)    Month3,
                                            COUNT(*) AS VisitsPerClub,
                                            SUM(COUNT(*)) OVER (PARTITION BY t2.PersonCenter,
                                            t2.PersonId ORDER BY 1) AS TotalVisits
                                        FROM
                                            (
                                                SELECT
                                                    t1.*
                                                FROM
                                                    (
                                                        SELECT DISTINCT
                                                            extra.PersonCenter,
                                                            extra.PersonId,
                                                            extra.firstname,
                                                            extra.lastname,
                                                            extra.LastActiveDate
                                                        FROM
                                                            (
                                                                SELECT
                                                                    nonexcl.center AS PersonCenter,
                                                                    nonexcl.id     AS PersonId,
                                                                    nonexcl.firstname,
                                                                    nonexcl.lastname,
                                                                    longtodateC
                                                                    (scl.entry_start_time,
                                                                    scl.center) AS LastActiveDate
                                                                FROM
                                                                    (
                                                                        SELECT
                                                                            p.center,
                                                                            p.id,
                                                                            p.firstname,
                                                                            p.lastname
                                                                        FROM
                                                                            goodlife.persons p
                                                                        WHERE
                                                                              (p.center >= 251 AND p.center <= 293)
                                                                        AND p.status = 1
                                                                        AND (
                                                                                p.persontype > 2
                                                                            OR  p.persontype < 2)
                                                                        AND NOT EXISTS
                                                                            ( -- Members on freeze
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    goodlife.subscription_freeze_period
                                                                                    sfp
                                                                                ON
                                                                                    sfp.subscription_center
                                                                                    = s.center
                                                                                AND
                                                                                    sfp.subscription_id
                                                                                    = s.id
                                                                                AND sfp.state =
                                                                                    'ACTIVE'
                                                                                    --AND
                                                                                    -- sfp.start_date
                                                                                    -- <=
                                                                                    -- current_date
                                                                                AND sfp.end_date >=
                                                                                    CURRENT_DATE
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                            )
                                                                        AND NOT EXISTS
                                                                            ( -- $0 Subscriptions
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    goodlife.product_and_product_group_link
                                                                                    ppl
                                                                                ON
                                                                                    s.subscriptiontype_center
                                                                                    =
                                                                                    ppl.product_center
                                                                                AND
                                                                                    s.subscriptiontype_id
                                                                                    =
                                                                                    ppl.product_id
                                                                                AND
                                                                                    ppl.product_group_id
                                                                                    = 1004
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                                AND
                                                                                    s.subscription_price
                                                                                    = 0 )
                                                                        AND NOT EXISTS
                                                                            ( -- Members with an
                                                                                -- active
                                                                                -- debt case
                                                                                -- Members with
                                                                                -- missing
                                                                                -- agreement case
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.cashcollectioncases
                                                                                    ccc
                                                                                WHERE
                                                                                    p.center =
                                                                                    ccc.personcenter
                                                                                AND p.id =
                                                                                    ccc.personid
                                                                                AND
                                                                                    ccc.missingpayment
                                                                                    IN ( 0 ,
                                                                                        1 )
                                                                                AND ccc.closed = 0
                                                                            )
                                                                            /*
                                                                            AND
                                                                            NOT EXISTS ( -- Members
                                                                            with
                                                                            missing agreement case
                                                                            SELECT
                                                                            *
                                                                            FROM
                                                                            goodlife.cashcollectioncases
                                                                            ccc
                                                                            WHERE
                                                                            p.center =
                                                                            ccc.personcenter
                                                                            AND p.id = ccc.personid
                                                                            AND ccc.missingpayment
                                                                            = 0
                                                                            AND ccc.closed = 0
                                                                            )*/
                                                                        AND NOT EXISTS
                                                                            ( -- Members with
                                                                                -- missing
                                                                                -- document case
                                                                                SELECT
                                                                                    1
                                                                                FROM
                                                                                    goodlife.journalentries
                                                                                    je
                                                                                LEFT JOIN
                                                                                    subscriptions s
                                                                                ON
                                                                                    je.ref_center =
                                                                                    s.center
                                                                                AND je.ref_id =
                                                                                    s.id
                                                                                AND je.jetype = 1
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                                LEFT JOIN
                                                                                    clipcards c
                                                                                ON
                                                                                    je.ref_center =
                                                                                    c.center
                                                                                AND je.ref_id =
                                                                                    c.id
                                                                                AND je.ref_subid =
                                                                                    c.subid
                                                                                AND je.jetype = 34
                                                                                AND c.blocked =
                                                                                    FALSE
                                                                                AND c.finished =
                                                                                    FALSE
                                                                                LEFT JOIN
                                                                                    relatives r
                                                                                ON
                                                                                    je.ref_center =
                                                                                    r.center
                                                                                AND je.ref_id =
                                                                                    r.id
                                                                                AND r.rtype = 12
                                                                                AND r.status = 1
                                                                                AND je.jetype = 16
                                                                                LEFT JOIN
                                                                                    goodlife.journalentry_signatures
                                                                                    link
                                                                                ON
                                                                                    je.id =
                                                                                    link.journalentry_id
                                                                                WHERE
                                                                                    je.signable = 1
                                                                                AND
                                                                                    je.person_center
                                                                                    = p.center
                                                                                AND je.person_id =
                                                                                    p.id
                                                                                AND
                                                                                    link.signature_center
                                                                                    IS NULL
                                                                                AND (
                                                                                        je.jetype =
                                                                                        1
                                                                                    AND s.center
                                                                                        IS NOT NULL
                                                                                    OR  je.jetype =
                                                                                        34
                                                                                    AND c.center
                                                                                        IS NOT NULL
                                                                                    OR  je.jetype =
                                                                                        16
                                                                                    AND r.center
                                                                                        IS NOT NULL
                                                                                    ) )
                                                                            /*
                                                                            AND NOT EXISTS ( --
                                                                            Members
                                                                            with any incomplete
                                                                            questionnaire case
                                                                            SELECT
                                                                            *
                                                                            FROM
                                                                            goodlife.questionnaire_answer
                                                                            qan
                                                                            WHERE
                                                                            p.center = qan.center
                                                                            AND p.id = qan.id
                                                                            AND qan.completed =
                                                                            false
                                                                            )
                                                                            */
                                                                        AND NOT EXISTS
                                                                            ( -- Members in regret
                                                                                -- period
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    params
                                                                                ON
                                                                                    params.centerid
                                                                                    = s.center
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                                AND s.creation_time
                                                                                    >
                                                                                    params.cutDateTenDays
                                                                                    --current_date
                                                                                    -- -
                                                                                    -- interval '10
                                                                                    -- days'
                                                                            )
                                                                        AND NOT EXISTS
                                                                            ( -- Members due to
                                                                                -- change
                                                                                -- subscription
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    goodlife.subscription_change
                                                                                    sc
                                                                                ON
                                                                                    sc.old_subscription_center
                                                                                    = s.center
                                                                                AND
                                                                                    sc.old_subscription_id
                                                                                    = s.id
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND sc.type =
                                                                                    'TYPE'
                                                                                AND sc.cancel_time
                                                                                    IS NULL
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                            )
                                                                        AND NOT EXISTS
                                                                            ( -- Members whose main
                                                                                -- membership
                                                                                -- subscription
                                                                                -- is EFT and the
                                                                                -- subscription
                                                                                -- period
                                                                                -- start date is
                                                                                -- NOT 'today
                                                                                -- '
                                                                                SELECT
                                                                                    *
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    goodlife.subscriptiontypes
                                                                                    st
                                                                                ON
                                                                                    s.subscriptiontype_center
                                                                                    = st.center
                                                                                AND
                                                                                    s.subscriptiontype_id
                                                                                    = st.id
                                                                                JOIN
                                                                                    goodlife.products
                                                                                    pr
                                                                                ON
                                                                                    st.center =
                                                                                    pr.center
                                                                                AND st.id = pr.id
                                                                                JOIN
                                                                                    goodlife.product_and_product_group_link
                                                                                    ppl
                                                                                ON
                                                                                    pr.center =
                                                                                    ppl.product_center
                                                                                AND pr.id =
                                                                                    ppl.product_id
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND
                                                                                    ppl.product_group_id
                                                                                    = 1004
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                                AND st.st_type = 1
                                                                                AND NOT EXISTS
                                                                                    (
                                                                                        SELECT
                                                                                            *
                                                                                        FROM
                                                                                            goodlife.subscriptionperiodparts
                                                                                            spp
                                                                                        WHERE
                                                                                            s.center
                                                                                            =
                                                                                            spp.center
                                                                                        AND s.id =
                                                                                            spp.id
                                                                                        AND (
                                                                                                (
                                                                                                    s.renewal_policy_override
                                                                                                    IN
                                                                                                        (
                                                                                                        6
                                                                                                        ,
                                                                                                        10
                                                                                                        )
                                                                                                AND
                                                                                                    spp.to_date
                                                                                                    =
                                                                                                    CURRENT_DATE
                                                                                                    -
                                                                                                    INTERVAL
                                                                                                    '1 day'
                                                                                                )
                                                                                            OR
                                                                                                spp.from_date
                                                                                                =
                                                                                                CURRENT_DATE
                                                                                            )
                                                                                        AND
                                                                                            spp.cancellation_time
                                                                                            =0 ) )
                                                                        AND NOT EXISTS
                                                                            ( -- Members who have a
                                                                                -- Corporate (part)
                                                                                -- sponsored
                                                                                -- members where
                                                                                -- the transfer
                                                                                -- timing
                                                                                -- would cause a
                                                                                -- pro-rata/
                                                                                -- period break in
                                                                                -- the
                                                                                -- company invoice.
                                                                                SELECT
                                                                                    s.*
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    s
                                                                                JOIN
                                                                                    goodlife.subscriptiontypes
                                                                                    st
                                                                                ON
                                                                                    s.subscriptiontype_center
                                                                                    = st.center
                                                                                AND
                                                                                    s.subscriptiontype_id
                                                                                    = st.id
                                                                                JOIN
                                                                                    goodlife.products
                                                                                    pr
                                                                                ON
                                                                                    pr.center =
                                                                                    st.center
                                                                                AND pr.id = st.id
                                                                                WHERE
                                                                                    p.center =
                                                                                    s.owner_center
                                                                                AND p.id =
                                                                                    s.owner_id
                                                                                AND pr.globalid =
                                                                                    'PAP_M_ALL_CLUB_KAFP'
                                                                                AND s.state IN (2,4
                                                                                                ,8)
                                                                                AND NOT EXISTS
                                                                                    (
                                                                                        SELECT
                                                                                            *
                                                                                        FROM
                                                                                            goodlife.subscriptionperiodparts
                                                                                            spp
                                                                                        WHERE
                                                                                            s.center
                                                                                            =
                                                                                            spp.center
                                                                                        AND s.id =
                                                                                            spp.id
                                                                                        AND
                                                                                            spp.from_date
                                                                                            =
                                                                                            CURRENT_DATE
                                                                                        AND
                                                                                            spp.cancellation_time
                                                                                            =0 ) )
                                                                        AND NOT EXISTS
                                                                            ( -- Members due to
                                                                                -- change
                                                                                -- person_type =
                                                                                -- private
                                                                                SELECT
                                                                                    ind.*
                                                                                FROM
                                                                                    goodlife.subscriptions
                                                                                    ind
                                                                                JOIN
                                                                                    goodlife.products
                                                                                    prind
                                                                                ON
                                                                                    ind.subscriptiontype_center
                                                                                    = prind.center
                                                                                AND
                                                                                    ind.subscriptiontype_id
                                                                                    = prind.id
                                                                                JOIN
                                                                                    goodlife.product_and_product_group_link
                                                                                    pl
                                                                                ON
                                                                                    prind.id =
                                                                                    pl.product_id
                                                                                AND prind.center =
                                                                                    pl.product_center
                                                                                JOIN
                                                                                    goodlife.persons
                                                                                    per
                                                                                ON
                                                                                    ind.owner_center
                                                                                    = per.center
                                                                                AND ind.owner_id =
                                                                                    per.id
                                                                                WHERE
                                                                                    ind.state IN (2
                                                                                                  ,
                                                                                                  4
                                                                                                  ,
                                                                                                  8
                                                                                                  )
                                                                                AND
                                                                                    ind.owner_center
                                                                                    = p.center
                                                                                AND ind.owner_id=
                                                                                    p.id
                                                                                AND
                                                                                    pl.product_group_id
                                                                                    IN ( 2801 ,
                                                                                        4201 )
                                                                                AND per.persontype
                                                                                    NOT IN ( 4 ) )
                                                                    ) nonexcl
                                                                    -- Minimum time ACTIVE at home
                                                                    -- club =>
                                                                    -- 3 months
                                                                JOIN
                                                                    goodlife.state_change_log scl
                                                                ON
                                                                    scl.center = nonexcl.center
                                                                AND scl.id = nonexcl.id
                                                                AND scl.entry_type=1
                                                                AND scl.entry_end_time IS NULL
                                                                AND scl.stateid = 1 ) extra
                                                        CROSS JOIN params
																  
															
																				
														  
                                                JOIN checkins ch ON extra.PersonCenter = ch.person_center AND extra.PersonId = ch.person_id 	 
																						 
																			 
																					 
                                                                            AND ch.checkin_time > params.cutDateThreeMonths AND ch.checkin_center = params.centerid
																					 
																							   
                                                                            --datetolongC(to_char(current_date - interval '3 months','YYYY-MM-DD HH24:MI:SS'), ch.checkin_center) 
																		 
																								  
																				 
															 
																				  
																				 
																				  
                                                                            AND ch.person_center != ch.checkin_center 
													 
                                        ) t1
                                                WHERE
                                                    t1.LastActiveDate < CURRENT_DATE - interval
                                                    '3 months' ) t2
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
                                            --AND ch.checkin_center != ch.person_center
                                        GROUP BY
                                            t2.PersonCenter,
                                            t2.PersonId,
                                            t2.firstname,
                                            t2.lastname,
                                            ch.checkin_center ) tch
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
                            withsub
                        LEFT JOIN
                            goodlife.subscriptions s
                        ON
                            s.owner_center = withsub.PersonCenter
                        AND s.owner_id = withsub.PersonId
                        WHERE
                            s.state IN (2,4,8) ) tab1
                GROUP BY
                    tab1.PersonCenter,
                    tab1.PersonId,
                    tab1.CheckinCenter,
                    tab1.firstname,
                    tab1.lastname,
                    tab1.homeclubname,
                    tab1.destinationclubname,
                    tab1.VisitsPerClub,
                    tab1.TotalVisits ) finalt
        WHERE
            finalt.Includedsubscriptions IS NOT NULL
