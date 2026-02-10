-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    t1.*
FROM
(
    WITH RECURSIVE

    -- Per-center "today" (execution date) based on center-local time
    params AS MATERIALIZED
    (
        SELECT
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') AS executionDate,
            c.ID                                       AS CenterID
        FROM centers c
    ),

    -- Base set: eligible payment requests to consider for retry scheduling
    base AS
    (
        SELECT
            pr.center,
            pr.id,
            pr.subid,
            p.center || 'p' || p.id AS "PERSONKEY",
            p.external_id,
            par.executionDate,
            pr.req_date::date       AS t0  -- anchor date for retry schedule
        FROM payment_request_specifications prs
        JOIN params par
            ON par.CenterID = prs.center
        JOIN account_receivables ar
            ON ar.center = prs.center
           AND ar.id     = prs.id
        JOIN persons p
            ON p.center = ar.customercenter
           AND p.id     = ar.customerid
        JOIN payment_requests pr
            ON prs.center = pr.inv_coll_center
           AND prs.id     = pr.inv_coll_id
           AND prs.subid  = pr.inv_coll_subid
           AND pr.request_type = 1                 -- payment request
        JOIN payment_agreements pag
            ON pag.center = pr.center
           AND pag.id     = pr.id
           AND pag.subid  = pr.agr_subid
        JOIN clearinghouses ch
            ON ch.id = pag.clearinghouse
        WHERE
            ch.ctype IN (198,200)              -- credit card & EFT clearinghouse
            AND pag.state NOT IN (1, 2, 8, 9, 11, 12, 13, 14, 15, 17)
            AND ar.balance < 0          -- outstanding amount owed
            AND ar.ar_type = 4          -- Payment Account AR type
            AND p.sex != 'C'            -- exclude corporate persons
            AND prs.open_amount > 0     -- still open amount to collect
            AND pr.center IN (:center)  -- only requested centers
    ),

    -- Build up to 3 retry dates per request (weekends pushed to Monday)
    retries(
        center,
        id,
        subid,
        "PERSONKEY",
        external_id,
        executionDate,
        t0,
        retry_num,
        scheduled_day
    ) AS
    (
        -- Retry #1: t0 + 1 day, weekend-adjusted
        SELECT
            b.center,
            b.id,
            b.subid,
            b."PERSONKEY",
            b.external_id,
            b.executionDate,
            b.t0,
            1 AS retry_num,
            CASE
                WHEN EXTRACT(DOW FROM (b.t0 + 1)) = 6 THEN (b.t0 + 1) + 2  -- Sat -> Mon
                WHEN EXTRACT(DOW FROM (b.t0 + 1)) = 0 THEN (b.t0 + 1) + 1  -- Sun -> Mon
                ELSE (b.t0 + 1)
            END AS scheduled_day
        FROM base b

        UNION ALL

        -- Retry #2: +2 days after retry #1 (weekend-adjusted)
        -- Retry #3: +1 day after retry #2 (weekend-adjusted)
        SELECT
            r.center,
            r.id,
            r.subid,
            r."PERSONKEY",
            r.external_id,
            r.executionDate,
            r.t0,
            r.retry_num + 1 AS retry_num,
            CASE
                WHEN EXTRACT(DOW FROM (r.scheduled_day + CASE WHEN r.retry_num = 1 THEN 2 ELSE 1 END)) = 6
                    THEN (r.scheduled_day + CASE WHEN r.retry_num = 1 THEN 2 ELSE 1 END) + 2
                WHEN EXTRACT(DOW FROM (r.scheduled_day + CASE WHEN r.retry_num = 1 THEN 2 ELSE 1 END)) = 0
                    THEN (r.scheduled_day + CASE WHEN r.retry_num = 1 THEN 2 ELSE 1 END) + 1
                ELSE (r.scheduled_day + CASE WHEN r.retry_num = 1 THEN 2 ELSE 1 END)
            END AS scheduled_day
        FROM retries r
        WHERE r.retry_num < 3
    )

    -- Return requests whose scheduled retry date is "today" for that center
    SELECT
        r.center,
        r.id,
        r.subid,
        r."PERSONKEY",
        r.external_id
    FROM retries r
    WHERE r.scheduled_day = r.executionDate
    GROUP BY
        r.center,
        r.id,
        r.subid,
        r."PERSONKEY",
        r.external_id
) t1;