SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS cutdate,
                        extract(DAY FROM(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'))) AS executionDate,
                        c.ID                                       AS CenterID
                FROM evolutionwellness.centers c
                WHERE c.country = 'TH'
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY",
                CASE 
                        WHEN pr.clearinghouse_id = 1801 THEN 'Bangkok BBL'
                        WHEN pr.clearinghouse_id = 2001 THEN 'Kasikorn KBANK'
                        WHEN pr.clearinghouse_id = 3601 THEN 'Krungthai KTB'
                        WHEN pr.clearinghouse_id = 3801 THEN 'Siam SCB'
                END AS ClearingHouse                        
        FROM payment_request_specifications prs
        JOIN params par
                ON par.CenterID = prs.center
        JOIN account_receivables ar
                ON ar.center = prs.center
                AND ar.id = prs.id
        JOIN persons p
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
        JOIN payment_requests pr
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
                pr.req_date >= par.cutdate
                AND ar.balance < 0
                AND ar.ar_type = 4
                AND p.sex != 'C'
                AND prs.open_amount > 0
                AND pr.clearinghouse_id IN (1801,2001,3601,3801)
                AND pag.state = 4
                AND pr.center IN (:center) 
                AND pr.clearinghouse_id IN (:Clearinghouse)
) t1
ORDER BY 5,4