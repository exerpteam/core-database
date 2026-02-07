-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            c.id, 
            c.name,
            getstartofday((:start)::DATE::VARCHAR, 
            c.id)::bigint AS first_day,
            getendofday((:end)::DATE::VARCHAR, 
            c.id)::bigint AS last_day
        FROM 
            centers c 
    )
SELECT
    pm.id as SiteID, 
    pm.name as SiteName, 
    SUM(art.amount)::numeric(12,2) AS Total
FROM
    account_receivables ar
--JOIN
--    person_ext_attrs pea
--ON
--   ar.customercenter=pea.personcenter
--AND ar.customerid=pea.personid
JOIN
    ar_trans art
ON
    ar.center=art.center
AND ar.id=art.id
JOIN
    params pm
ON
    ar.center=pm.id
JOIN
    credit_notes cn
ON
    art.ref_center=cn.center
AND art.ref_id=cn.id
WHERE
    --they only use payment account
    ar.ar_type=4
    --pea marks bad debtors that have been written off
--AND pea.name='BadDebtor'
--AND pea.txtvalue='YES'
AND art.trans_time >= pm.first_day
AND art.trans_time <= pm.last_day
AND art.ref_type='CREDIT_NOTE'
AND EXISTS
    (   SELECT
            1
        FROM
            credit_note_lines_mt cl
        WHERE
            cn.center=cl.center
        AND cn.id=cl.id
            ---wrong sale, refund, faulty product
        AND cl.canceltype IN (0,1,2)
            ---free credit line
        AND cl.reason=16
			---this picks only the write off service
 	    AND cl.text ilike '%write off%')
GROUP BY 
    pm.id, 
    pm.name