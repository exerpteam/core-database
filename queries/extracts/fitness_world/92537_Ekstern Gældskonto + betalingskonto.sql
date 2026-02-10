-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  case when  t1.ref is null
  then t1.INFO
  else t1.ref end as info,
    sum(t1.AMOUNT*-1),
    CASE t1.AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' WHEN 6 THEN 'installment' END AS AR_TYPE,
    case when t1.unsettled_amount < 0 then 'OPEN' else 'CLOSED' end as AMOUNT_SETTLED
--    t1.text  
FROM
    (
        SELECT
            ART.AMOUNT,
            ART.INFO,
            ar.AR_TYPE,
            art.unsettled_amount,
            art.text,
            prs.ref
            
        FROM
            AR_TRANS ART
   
       JOIN
            ACCOUNT_RECEIVABLES AR
        ON
            AR.CENTER = ART.CENTER
        AND AR.ID = ART.ID
        AND ar_type in (5,4)
 left join payment_request_specifications prs
on art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid

       
        WHERE
            AR.CUSTOMERCENTER = :CENTER
        AND AR.CUSTOMERID = :ID
        /*AND art.unsettled_amount < 0*/) t1
GROUP BY
    t1.info,
    t1.ref,
    t1.AR_TYPE,
    t1.unsettled_amount
   --t1.text