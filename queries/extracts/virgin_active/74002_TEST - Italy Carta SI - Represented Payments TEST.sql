WITH params AS MATERIALIZED
(
        SELECT
                DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                c.ID                                       AS CenterID
        FROM
                CENTERS c
        WHERE
                c.country = 'IT'
)
SELECT
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID person,
     pr.REJECTED_REASON_CODE reasoncode,
     pr.REQ_AMOUNT,
	 prs.open_amount
FROM virginactive.payment_request_specifications prs
JOIN PARAMS par
        ON par.centerid = prs.center
JOIN virginactive.account_receivables ar
        ON ar.center = prs.center
        AND ar.id = prs.id
JOIN virginactive.persons p
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
JOIN virginactive.payment_requests pr
        ON prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid
        AND pr.request_type = 1
        AND pr.state NOT IN (1,2,3,4,8,12,18)
JOIN payment_agreements pag
        ON pag.center = pr.center
        AND pag.id = pr.id
        AND pag.subid = pr.agr_subid
WHERE
        pr.req_date > par.cutdate
        AND pr.clearinghouse_id IN  (2803, 2804)
        AND ar.balance < 0
        AND pag.state = 4
        AND ar.ar_type = 4
        AND p.sex != 'C'
        AND prs.open_amount > 0
        --AND pr.rejected_reason_code IS NOT NULL
        AND EXTRACT('year' from AGE(p.BIRTHDATE)) > 17
        AND NOT EXISTS
        (
                SELECT
                        *
                FROM virginactive.cashcollectioncases cc
                WHERE
                        cc.personcenter = p.center
                        AND cc.personid = p.id
                        AND cc.cc_agency_amount IS NOT NULL
                        AND cc.missingpayment = true
                        AND cc.closed = false
        )
