WITH
        params AS materialized
        (
         SELECT
                    to_date (:fromdate, 'yyyy-MM-dd') AS FromDate,
                    to_date (:todate, 'yyyy-MM-dd')   AS ToDate,
                    c.id                              AS centerid
               FROM
                    centers c
                     --WHERE c.id IN (:scope)
        )
 SELECT
            "Member ID",
            "Member name",
            "Member External ID",
            "Center",
            "Center Name",
            "Center ID Delegacion",
            "SEPA details (IBAN no)",
            "Exerp reference (payment reference)",
            "Amount which was last inluded in a payment request",
            "Date when last included in a payment request"
       FROM
            (
             SELECT
                        p.center||'p'||p.id                                                         AS "Member ID",
                        p.fullname                                                                  AS "Member name",
                        p.external_id                                                               AS "Member External ID",
                        p.center                                                                    AS "Center",
                        c.name                                                                      AS "Center Name",
                        cea.txt_value                                                               AS "Center ID Delegacion",
                        pag.iban                                                                    AS "SEPA details (IBAN no)",
                        pag.ref                                                                     AS "Exerp reference (payment reference)",
                        ROUND (pr.req_amount, 2)                                              AS "Amount which was last inluded in a payment request",
                        pr.req_date                                                                 AS "Date when last included in a payment request",
                        row_number() over (partition BY pr.center, pr.id, pr.request_type ORDER BY pag.last_modified DESC) req_date_rank
                   FROM
                        PAYMENT_AGREEMENTS pag
                   JOIN
                        ACCOUNT_RECEIVABLES ar ON ar.CENTER = pag.CENTER AND ar.ID = pag.ID
                   JOIN
                        PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
                   JOIN
                        centers c ON p.center = c.id
                   JOIN
                        center_ext_attrs cea ON c.id = cea.center_id AND cea.name = 'IdDelegacion'
                   JOIN
                        payment_requests pr ON ar.CENTER = pr.CENTER AND ar.ID = pr.ID
                   JOIN
                        params ON centerid = p.center
                   JOIN
                        clearing_out ci ON pr.req_delivery = ci.id
                   JOIN vivagym.clearinghouses ch
                        ON ch.id = pag.clearinghouse
                  WHERE
                        ch.ctype = 185 --SEPA
                        and p.center in (:scope) 
						AND pag.iban is not null
                        AND pr.request_type IN (1, 6) --payment,representation
                        AND ci.generated_date BETWEEN params.FromDate AND params.ToDate) t
      WHERE
            req_date_rank = 1