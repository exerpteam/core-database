-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
         p.EXTERNAL_ID AS CLUBiD
       , p.personId
       , SUM(p.AMOUNT) as importoPagato
from
         (
                    SELECT
                                          CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId
                             , ART.AMOUNT
                             , c.EXTERNAL_ID
                    FROM
                               AR_TRANS ar
                               INNER JOIN
                                          CENTERS C
                                          ON
                                                     ar.CENTER = C.id
                               INNER JOIN
                                          ACCOUNT_RECEIVABLES A
                                          ON
                                                     a.CENTER = AR.CENTER
                                                     AND A.ID = AR.ID
                               INNER JOIN
                                          PERSONS p
                                          ON
                                                     p.ID         = a.CUSTOMERID
                                                     AND p.CENTER = a.CUSTOMERCENTER
                               INNER JOIN
                                          ART_MATCH art
                                          ON
                                                     ar.CENTER    = art.ART_PAYING_CENTER
                                                     and ar.ID    = art.ART_PAYING_ID
                                                     and ar.SUBID = art.ART_PAYING_SUBID
                               INNER JOIN
                                          AR_TRANS ar1
                                          ON
                                                     ar1.CENTER    = art.ART_PAID_CENTER
                                                     and ar1.ID    = art.ART_PAID_ID
                                                     and ar1.SUBID = art.ART_PAID_SUBID
                               INNER JOIN
                                          PAYMENT_REQUESTS pr
                                          ON
                                                     pr.CENTER    = ar1.PAYREQ_SPEC_CENTER
                                                     AND pr.ID    = ar1.PAYREQ_SPEC_ID
                                                     AND pr.SUBID = ar1.PAYREQ_SPEC_SUBID
                               INNER JOIN
                                          PAYMENT_REQUEST_SPECIFICATIONS prs
                                          ON
                                                     prs.ID        = pr.ID
                                                     AND prs.SUBID = pr.SUBID
                    WHERE
                               c.COUNTRY                                         = 'IT'
                               AND Extract(MONTH FROM LongToDate(ar.TRANS_TIME)) =EXTRACT(month FROM ADD_MONTHS(SYSDATE,-1))
                               AND Extract(YEAR FROM LongToDate(ar.TRANS_TIME))  = EXTRACT(year FROM ADD_MONTHS(SYSDATE,-1))
                               AND c.COUNTRY                                     = 'IT'
                               AND ar.TEXT                                       = 'Payment into account'
                               AND Extract(DAY FROM pr.REQ_DATE)                <= 2
                               AND Extract(MONTH FROM pr.REQ_DATE)               = EXTRACT(month FROM ADD_MONTHS(SYSDATE,-1))
                               AND Extract(YEAR FROM pr.REQ_DATE)                = EXTRACT(year FROM ADD_MONTHS(SYSDATE,-1))
                               AND pr.CLEARINGHOUSE_ID                          NOT IN (803,
																					   2801,
																					   2802,
																					   2803,
																					   2804)
                               AND pr.STATE                                     != 12
                               --and c.ID < 203
                               --and p.id = 1666
                    GROUP BY
                               c.EXTERNAL_ID
                             , ART.AMOUNT
                             , pr.STATE
                             , CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8)))
                             , c.EXTERNAL_ID
         )
         p
GROUP by
         p.EXTERNAL_ID
       , p.personId
ORDER BY
         p.EXTERNAL_ID
       , p.personId