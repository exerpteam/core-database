WITH 
params AS
(
    SELECT
        datetolongC(TO_CHAR(TO_DATE('01/12/2025', 'DD/MM/YYYY'), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((TO_DATE('31/12/2025', 'DD/MM/YYYY') + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
SELECT DISTINCT 
    act.center || 'acc' || act.id || 'tr' || act.subid AS "Transaction No",
    longtodatec(act.trans_time, act.center) AS "Date",
    art.amount AS "Amount",
    credit.external_id || '-' || credit.name AS "Cost Center",
    ar.customercenter || 'p' || ar.customerid AS "Person ID",
    c.name AS "Club Name",
    c.id AS "Club ID",
    art.text AS "Description",
    artp.text AS "Invoice description",
    artp.amount AS "Invoice Amount",
    armatch.amount AS "Settled Amount"
FROM
    fernwood.account_trans act
JOIN
    fernwood.ar_trans art
    ON act.center = art.ref_center
    AND act.id = art.ref_id
    AND act.subid = art.ref_subid
    AND art.ref_type = 'ACCOUNT_TRANS'
JOIN
    fernwood.accounts credit
    ON credit.center = act.credit_accountcenter
    AND credit.id = act.credit_accountid
    AND credit.external_id = '02.00.1283'
JOIN
    fernwood.accounts debit
    ON debit.center = act.debit_accountcenter
    AND debit.id = act.debit_accountid 
JOIN
    fernwood.centers c
    ON c.id = act.center   
JOIN
    fernwood.account_receivables ar
    ON ar.center = art.center
    AND ar.id = art.id
    AND ar.ar_type = 6             
LEFT JOIN
  art_match armatch                                  
  ON armatch.art_paying_center = art.center
  AND armatch.art_paying_id = art.id
  AND armatch.art_paying_subid = art.subid 
  AND armatch.cancelled_time IS NULL
LEFT JOIN
  fernwood.ar_trans artp
  ON armatch.art_paid_center = artp.center
  AND armatch.art_paid_id = artp.id
  AND armatch.art_paid_subid = artp.subid      
JOIN
    params
    ON params.center_id = act.center       
WHERE
    act.center IN (:Scope)
    AND act.trans_time BETWEEN params.FromDate AND params.ToDate
    AND art.text = 'Installment plan manual payment'  -- Filter only for the specified description
ORDER BY 
    "Date", "Transaction No";  -- Optional: Order by date and transaction number