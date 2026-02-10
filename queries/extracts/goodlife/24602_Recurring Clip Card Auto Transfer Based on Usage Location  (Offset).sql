-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (        
                SELECT
                    /*+ materialize */
					datetolongTZ(TO_CHAR(current_date - interval '41 days','YYYY-MM-DD HH24:MI:SS'), c.time_zone)                       AS newCurrentDate,
                    datetolongTZ(TO_CHAR(current_date - interval '1 months' - interval '41 days','YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateOneMonthsLong,
                    datetolongTZ(TO_CHAR(current_date - interval '10 days'  - interval '41 days','YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateTenDaysLong,
                    current_date - interval '3 months' - interval '41 days'                                                             AS cutDateThreeMonths,
                    c.id                                                                                                                AS centerid
                FROM
                    goodlife.centers c
                WHERE
                    c.time_zone IS NOT NULL
        )
SELECT
        DISTINCT
        t2.SubCenter || 'ss' || t2.SubId AS "Subscription ID",
        t2.target_center AS "Destination center id",
        destination.shortname AS "Destination club name",
        t2.PersonCenter || 'p' || t2.PersonId AS "Membership number",
        t2.PersonId AS "Person id",
        t2.firstname AS "First name",
        t2.lastname AS "Last name",
        origin.shortname AS "Current subscription home club name"
FROM
(
        SELECT
                t1.*
        FROM
        (
                SELECT
                        eligsub.PersonCenter,
                        eligsub.PersonId,
                        eligsub.firstname,
                        eligsub.lastname,
                        eligsub.SubCenter,
                        eligsub.SubId,
                        --c.center AS ClipcardCenter,
                        --c.id AS ClipcardId,
                        --c.subid AS ClipcardSubId,
                        pu.target_center,
                        COUNT(*) AS VisitPerClub,
                        SUM(COUNT(*)) OVER (PARTITION BY eligsub.SubCenter,eligsub.SubId ORDER BY 1) AS TotalBookings
                        --SUM(COUNT(*)) OVER (PARTITION BY eligsub.SubCenter,eligsub.SubId,pu.target_center ORDER BY 1) AS TotalBookingsPerCenter
                FROM
                (
                        SELECT
                                p.center AS PersonCenter,
                                p.id AS PersonId,
                                p.firstname,
                                p.lastname,
                                s.start_date,
                                s.center AS SubCenter,
                                s.id AS SubId
                        FROM 
                                goodlife.persons p
                        JOIN
                                goodlife.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id AND s.state in (2,4,8)
                        JOIN
                                goodlife.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id AND st.st_type = 2
                        JOIN
                                goodlife.product_and_product_group_link prlink ON prlink.product_center = st.center AND prlink.product_id = st.id AND prlink.product_group_id IN (1001)
                        JOIN params ON params.centerid = s.center
                        WHERE
                                p.center IN (:Scope) AND
                                p.status IN (1)
                                AND p.persontype NOT IN (2)
                                -- Recurring Clip Card minimum active time: 3 months
                                AND s.start_date < params.cutDateThreeMonths
                                AND NOT EXISTS ( -- Members on freeze
                                                        SELECT
                                                                *
                                                        FROM goodlife.subscriptions s 
                                                        JOIN goodlife.subscription_freeze_period sfp 
                                                                ON  sfp.subscription_center = s.center 
                                                                AND sfp.subscription_id = s.id 
                                                                AND sfp.state = 'ACTIVE' 
                                                                --AND sfp.start_date <= current_date 
                                                                AND sfp.end_date >= current_date
                                                        WHERE
                                                                p.center = s.owner_center 
                                                                AND p.id = s.owner_id
                                                                AND s.state IN (2,4,8)
                                               )
                                AND NOT EXISTS ( -- Members with an active debt case
                                                 -- Members with missing agreement case
                                                        SELECT
                                                                *
                                                        FROM    goodlife.cashcollectioncases ccc
                                                        WHERE
                                                                p.center = ccc.personcenter
                                                                AND p.id = ccc.personid
                                                                AND ccc.missingpayment IN (0,1)
                                                                AND ccc.closed = 0
                                               )                                      
                                AND NOT EXISTS ( -- Members with missing document case
                                                        SELECT
                                                                *
                                                        FROM    goodlife.journalentries je
                                                        LEFT JOIN goodlife.journalentry_signatures link
                                                                ON je.id = link.journalentry_id
                                                        WHERE 
                                                                p.center = je.person_center
                                                                AND p.id = je.person_id
                                                                AND je.signable = 1
                                                                AND link.signature_center IS NULL
                                               )
                                AND NOT EXISTS ( -- Members in regret period
                                                        SELECT
                                                                *
                                                        FROM    goodlife.subscriptions s
                                                        JOIN params ON params.centerid = s.center
                                                        WHERE
                                                                p.center = s.owner_center 
                                                                AND p.id = s.owner_id
                                                                AND s.state IN (2,4,8)
                                                                AND s.creation_time > params.cutDateTenDaysLong
                                                                --current_date - interval '10 days'
                                               )
                               AND NOT EXISTS ( -- Members due to change subscription
                                                        SELECT
                                                                *
                                                        FROM    goodlife.subscription_change sc         
                                                        WHERE 
                                                                sc.old_subscription_center = s.center 
                                                                AND sc.old_subscription_id = s.id
                                                                AND sc.type = 'TYPE'
                                                                AND sc.cancel_time IS NULL
                                               )
                ) eligsub
                JOIN goodlife.subscriptionperiodparts spp ON spp.center = eligsub.SubCenter AND spp.id = eligsub.SubId
                JOIN goodlife.spp_invoicelines_link link ON link.period_center = spp.center AND link.period_id = spp.id AND link.period_subid = spp.subid
                JOIN goodlife.clipcards c ON c.invoiceline_center = link.invoiceline_center AND c.invoiceline_id = link.invoiceline_id AND c.invoiceline_subid = link.invoiceline_subid
                JOIN goodlife.privilege_usages pu ON pu.source_center = c.center AND pu.source_id = c.id and pu.source_subid = c.subid AND pu.state != 'CANCELLED'
                JOIN goodlife.privilege_grants pg ON pg.id = pu.grant_id AND pg.granter_service = 'GlobalCard'
                JOIN params ON params.centerid = pu.target_center
                WHERE   
                        pu.use_time > params.cutDateOneMonthsLong
						AND pu.use_time < params.newCurrentDate
                        --AND pu.target_center != c.center
                GROUP BY
                        eligsub.PersonCenter,
                        eligsub.PersonId,
                        eligsub.firstname,
                        eligsub.lastname,
                        eligsub.SubCenter,
                        eligsub.SubId,
                        --c.center,
                        --c.id,
                        --c.subid,
                        pu.target_center
        ) t1
        WHERE t1.VisitPerClub > 3
        AND t1.target_center != t1.SubCenter
) t2
JOIN goodlife.centers destination ON destination.id = t2.target_center
JOIN goodlife.centers origin ON origin.id = t2.SubCenter
WHERE
        --t2.TotalBookingsPerCenter = t2.TotalBookings
        t2.VisitPerClub = t2.TotalBookings
        
