-- The extract is extracted from Exerp on 2026-02-08
-- ES-23445
SELECT
    t1.*
FROM
    (
       WITH
        params AS
        (
                 SELECT
                     /*+ materialize */
                     to_date(:from_date,'YYYY-MM-DD') AS FromDate,
                     to_date(:to_date,'YYYY-MM-DD') AS ToDate,
                     c.id                                      AS centerid
                 FROM
                     lifetime.centers c
)
        SELECT
            person.external_id as "Member ID",
            person.fullname as "Member Name",
            staff.external_id as "Staff ID",
            staff.fullname as "Staff Name",
            ps.name AS "Product Name",
            pu.state AS "Privilege State",
            spp.from_date AS "Subscription Period Start",
            spp.to_date   AS "Subscription Period End",
            pu.privilege_type,
            ps.frequency_restriction_unit,
            ps.frequency_restriction_type,
            ps.frequency_restriction_value,
            ps.frequency_restriction_count,
             SUM
                (
                        CASE
                                WHEN
                                        pu.use_time BETWEEN datetolongC(TO_CHAR(spp.from_date,'YYYY-MM-DD HH24:MI'), spp.center) AND datetolongC(TO_CHAR(spp.to_date,'YYYY-MM-DD HH24:MI'), spp.center)
                                THEN 1
                                ELSE 0
                        END
                ) AS TOTAL_COUNT
        FROM
            lifetime.privilege_usages pu
        JOIN
            lifetime.privilege_grants pg
        ON
            pu.grant_id = pg.id
        JOIN
            lifetime.privilege_sets ps
        ON
            pg.privilege_set = ps.id
        JOIN
            lifetime.subscriptions s
        ON
            pu.source_center = s.center
        AND pu.source_id = s.id
        JOIN
            params par
        ON
            par.centerid = pu.target_center
        JOIN
            lifetime.subscriptionperiodparts spp
        ON
            spp.center = s.center
        AND spp.id = s.id
        AND spp.spp_state = 1
        AND spp.from_date <= par.ToDate
        AND spp.to_date >= par.FromDate
        JOIN
            lifetime.persons person
        ON
            s.owner_center = person.center
        AND s.owner_id = person.id
        JOIN
            lifetime.persons staff
        ON
            pu.source_center = staff.center
        AND pu.source_id = staff.id
       WHERE spp.center in (:Center)
      --  WHERE    
        --        pu.state NOT IN ('CANCELLED')
           --     AND pg.granter_service = 'GlobalSubscription'
             --   AND pu.use_time BETWEEN par.fromdateBooking AND par.todateBooking
           --     AND ps.id NOT IN (1608, 5005)

         GROUP BY
            person.external_id,
            person.fullname,
            staff.external_id,
            staff.fullname,
            pg.granter_service,
            pu.state,
            pu.misuse_state,
            pu.privilege_type,
            pu.target_service,
            ps.name,
            ps.id,
            ps.frequency_restriction_unit,
            ps.frequency_restriction_type,
            ps.frequency_restriction_value,
            ps.frequency_restriction_count,
            pu.source_center,
            pu.source_id,
            spp.from_date,
            spp.to_date) t1
WHERE
    t1.TOTAL_COUNT > t1.frequency_restriction_count