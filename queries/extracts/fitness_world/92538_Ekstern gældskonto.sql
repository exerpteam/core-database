-- This is the version from 2026-02-05
--  
SELECT
    t1.INFO,
    SUM(t1.AMOUNT*-1)
FROM
    (
        SELECT
            ART.AMOUNT,
            ART.INFO
        FROM
            AR_TRANS ART
        JOIN
            ACCOUNT_TRANS ACT
        ON
            ART.REF_CENTER = ACT.CENTER
        AND ART.REF_ID = ACT.ID
        AND ART.REF_SUBID = ACT.SUBID
        JOIN
            ACCOUNT_RECEIVABLES AR
        ON
            AR.CENTER = ART.CENTER
        AND AR.ID = ART.ID
        AND ar_type =5
        WHERE
            AR.CUSTOMERCENTER = :CENTER
        AND AR.CUSTOMERID = :ID
        AND art.unsettled_amount < 0) t1
GROUP BY
    t1.info