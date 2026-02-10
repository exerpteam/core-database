-- The extract is extracted from Exerp on 2026-02-08
-- Detailed report of every transation in the installment account - includes payments received aswell so the data must be manipulated to remove the duplicates (you will see two of the same transaction ID, that is how you identify the duplicates, then remove all the positive numbers that are duplicate transaction ID's). 
WITH params AS
(
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
),
filtered_data AS
(
    SELECT DISTINCT 
        act.center || 'acc' || act.id || 'tr' || act.subid AS "Transaction No",
        longtodatec(act.trans_time, act.center) AS "Date",
        CASE 
            WHEN art.text = 'Installment plan manual payment' THEN -art.amount
            ELSE art.amount
        END AS "Amount",
        credit.external_id || '-' || credit.name AS "Cost Center",
        ar.customercenter || 'p' || ar.customerid AS "Person ID",
        c.name AS "Club Name",
        c.id AS "Club ID",
        art.text AS "Description"
    FROM
        account_trans act
    JOIN
        ar_trans art
        ON act.center = art.ref_center
        AND act.id = art.ref_id
        AND act.subid = art.ref_subid
        AND art.ref_type = 'ACCOUNT_TRANS'
    JOIN
        accounts credit
        ON credit.center = act.credit_accountcenter
        AND credit.id = act.credit_accountid
        AND credit.external_id = '02.00.1283'
    JOIN
        accounts debit
        ON debit.center = act.debit_accountcenter
        AND debit.id = act.debit_accountid 
    JOIN
        centers c
        ON c.id = act.center   
    JOIN
        account_receivables ar
        ON ar.center = art.center
        AND ar.id = art.id              
    LEFT JOIN
        (
        SELECT
            pr.center,
            pr.id,
            pr.subid,
            ar.customercenter,
            ar.customerid
        FROM
            payment_requests pr
        JOIN
            payment_agreements pag
            ON pr.center = pag.center 
            AND pr.id = pag.id 
            AND pr.agr_subid = pag.subid 
        JOIN
            account_receivables ar 
            ON ar.center = pag.center 
            AND ar.id = pag.id
        ) pr                      
        ON pr.center = art.payreq_spec_center
        AND pr.id = art.payreq_spec_id
        AND pr.subid = art.payreq_spec_subid                        
    JOIN
        params
        ON params.center_id = act.center       
    WHERE
        act.center IN (:Scope)
        AND
        act.trans_time BETWEEN params.FromDate AND params.ToDate
        AND
        art.text NOT IN ('Installment plan changed', 'Installment plan stopped', 'Update installment plan')
),
duplicates AS
(
    SELECT 
        "Transaction No"
    FROM 
        filtered_data
    GROUP BY 
        "Transaction No"
    HAVING 
        COUNT(*) > 1
)
SELECT 
    *
FROM 
    filtered_data
WHERE 
    "Transaction No" NOT IN (SELECT "Transaction No" FROM duplicates WHERE "Amount" > 0)