-- The extract is extracted from Exerp on 2026-02-08
-- 
WITH
  PARAMS AS MATERIALIZED (
    SELECT
      c.id AS CENTER_ID,
      datetolongtz(TO_CHAR(CAST(CURRENT_DATE - 8 AS DATE), 'YYYY-MM-dd'), c.time_zone) AS FROM_DATE,
      datetolongtz(TO_CHAR(CAST(CURRENT_DATE     AS DATE), 'YYYY-MM-dd'), c.time_zone) AS TO_DATE
    FROM centers c
  )

SELECT DISTINCT
    t."Payment Date",
    t."Amount",
    t."Member Name",
    t."Person ID",
    t."Center Name",
    t."Description",
    t."Employee Name"
FROM (
    -- AR_TRANS-derived payments/credits etc.
    SELECT DISTINCT
        TO_CHAR(CAST(longtodatec(art.entry_time, art.center) AS date), 'DD/MM/YYYY') AS "Payment Date",
        art.amount                     AS "Amount",
        p.fullname                     AS "Member Name",
        p.center || 'p' || p.id        AS "Person ID",
        c.shortname                    AS "Center Name",
        art.text                       AS "Description",
        pemp.fullname                  AS "Employee Name"
    FROM ar_trans art
    CROSS JOIN params
    JOIN art_match artm
      ON artm.art_paying_center = art.center
     AND artm.art_paying_id     = art.id
     AND artm.art_paying_subid  = art.subid
     AND artm.cancelled_time IS NULL
    JOIN account_receivables ar
      ON ar.center = art.center
     AND ar.id     = art.id
    JOIN persons p
      ON p.center = ar.customercenter
     AND p.id     = ar.customerid
    JOIN centers c
      ON c.id = p.center
    LEFT JOIN employees emp
      ON emp.center = art.employeecenter
     AND emp.id     = art.employeeid
    LEFT JOIN persons pemp
      ON pemp.center = emp.personcenter
     AND pemp.id     = emp.personid
    WHERE art.ref_type IN ('ACCOUNT_TRANS','CREDIT_NOTE')
      AND (
           art.text LIKE '%recouped%'
        OR art.text LIKE 'FreeCre%'
        OR art.text LIKE 'PartialCre%'
        OR art.text LIKE 'Manual registered payment of reques%'
        OR art.text =  'Payment for sale'
        OR art.text =  'Payment into account'
        OR art.text LIKE 'Automatic placement%'
        OR art.text LIKE 'Creditnot%'
        OR art.text LIKE 'Debt payment%'
      )
      AND p.center IN (:Scope)
      AND art.entry_time > params.FROM_DATE
      AND art.employeecenter IS NOT NULL
      AND art.employeecenter || 'emp' || art.employeeid <> '100emp1'

    UNION ALL

    -- Successful representations
    SELECT DISTINCT
        TO_CHAR(pr.req_date, 'DD/MM/YYYY') AS "Payment Date",
        pr.req_amount                      AS "Amount",
        p.fullname                         AS "Member Name",
        p.center || 'p' || p.id            AS "Person ID",
        c.shortname                        AS "Center Name",
        'Representation'                   AS "Description",
        'N/A'                              AS "Employee Name"
    FROM payment_requests pr
    CROSS JOIN params
    JOIN account_receivables ar
      ON ar.center = pr.center
     AND ar.id     = pr.id
    JOIN persons p
      ON p.center = ar.customercenter
     AND p.id     = ar.customerid
    JOIN centers c
      ON c.id = p.center
    WHERE pr.request_type = 6
      AND pr.state = 3
      AND datetolongtz(TO_CHAR(pr.req_date, 'YYYY-MM-DD HH24:MI'), c.time_zone)
            BETWEEN params.FROM_DATE AND params.TO_DATE
      AND p.center IN (:Scope)

    UNION ALL

    -- ACCOUNT_TRANS (source) that created AR transactions
    SELECT DISTINCT
        TO_CHAR(CAST(longtodatec(act.trans_time, act.center) AS date), 'DD/MM/YYYY') AS "Payment Date",
        act.amount                        AS "Amount",
        p.fullname                        AS "Member Name",
        p.center || 'p' || p.id           AS "Person ID",
        c.shortname                       AS "Center Name",
        act.text                          AS "Description",
        pemp.fullname                     AS "Employee Name"
    FROM account_trans act
    CROSS JOIN params
    JOIN ar_trans art
      ON art.ref_center = act.center
     AND art.ref_id     = act.id
     AND art.ref_subid  = act.subid
    JOIN account_receivables ar
      ON ar.center = art.center
     AND ar.id     = art.id
    JOIN persons p
      ON p.center = ar.customercenter
     AND p.id     = ar.customerid
    JOIN employees emp
      ON emp.center = art.employeecenter
     AND emp.id     = art.employeeid
    JOIN persons pemp
      ON pemp.center = emp.personcenter
     AND pemp.id     = emp.personid
    JOIN centers c
      ON c.id = act.center
    WHERE act.trans_type = 2
      AND act.info_type  = 23
      AND art.ref_type   = 'ACCOUNT_TRANS'
      AND p.center IN (:Scope)
      AND art.entry_time > params.FROM_DATE
) t;
