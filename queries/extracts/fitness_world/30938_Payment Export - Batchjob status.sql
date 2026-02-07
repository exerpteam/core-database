-- This is the version from 2026-02-05
--  
SELECT
    ch.NAME,
    SUM(DECODE(pr.state,1,1,0))                                                        AS CountPending,
    SUM(DECODE(pr.state,2,1,0))                                                        AS CountIncluded,
    COUNT(*)                                                                           AS Total,
    COUNT(DISTINCT pr.REQ_DELIVERY)                                                    AS FileCount,
    exerpro.longtodate(MIN(bl.STARTTIME))                                              AS FileGenerationStarted,
    exerpro.longtodate(DECODE(MAX(bl.COMPLETIONTIME),0, NULL, MAX(bl.COMPLETIONTIME))) AS FileGenerationEndTime
FROM
    PAYMENT_REQUESTS pr
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pr.CLEARINGHOUSE_ID
LEFT JOIN
    BATCHLOGS bl
ON
    bl.STARTDATE = TRUNC(exerpsysdate())
    AND bl.JOBNAME = 'GenerateOutgoingPaymentDeliveryJob'
WHERE
    pr.REQ_DATE = :DeductionDate
    AND pr.state IN (1,2)
    AND ch.GEN_PAYMENT_TYPE != 'NONE'
GROUP BY
    ch.NAME