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
                WHERE c.country = 'ID'
        )
        SELECT
                pr.center,
                pr.id,
                pr.subid,
                p.center || 'p' || p.id AS "PERSONKEY"
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
                AND par.executionDate IN (3,4,5,6,11,15,18,25) 
                AND ar.balance < 0
                AND ar.ar_type = 4
                AND p.sex != 'C'
                AND prs.open_amount > 0
AND (p.center || 'p' || p.id) NOT IN ('308p1250')
                AND pr.clearinghouse_id IN (602,801)
                AND pag.state = 4
                AND pr.xfr_info IN ('Not enough balance',
                                'Refused',
                                'Issuer Unavailable',
                                'Pin tries exceeded',
                                'Transaction Not Permitted',
                                'Withdrawal amount exceeded',
                                'Withdrawal count exceeded',
                                'Acquirer Error',
                                'Declined Non Generic',
                                'Expired Card')
                AND pr.center IN (:center) 
) t1