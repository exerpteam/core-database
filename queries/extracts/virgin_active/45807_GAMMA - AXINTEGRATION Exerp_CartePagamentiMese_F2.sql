WITH
    PARAMS AS
    (
        SELECT
            EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1)) AS sel_month,
            EXTRACT(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))  AS sel_year
    )


 SELECT
     p.EXTERNAL_ID AS "CLUBID",
     p.personId AS "PERSONID",
     SUM(p.AMOUNT) AS "IMPORTOPAGATO"
 FROM
     (
         SELECT
             CONCAT(CONCAT(CAST(p.CENTER AS CHAR(3)),'p'), CAST(p.ID AS VARCHAR(8))) AS personId,
             ART.AMOUNT,
             c.EXTERNAL_ID,
             pr.CLEARINGHOUSE_ID
         FROM
             params par,
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
             p.ID = a.CUSTOMERID
             AND p.CENTER = a.CUSTOMERCENTER
         INNER JOIN
             ART_MATCH art
         ON
             ar.CENTER = art.ART_PAYING_CENTER
             AND ar.ID = art.ART_PAYING_ID
             AND ar.SUBID = art.ART_PAYING_SUBID
         INNER JOIN
             AR_TRANS ar1
         ON
             ar1.CENTER = art.ART_PAID_CENTER
             AND ar1.ID = art.ART_PAID_ID
             AND ar1.SUBID = art.ART_PAID_SUBID
         INNER JOIN
             PAYMENT_REQUESTS pr
         ON
             pr.CENTER = ar1.PAYREQ_SPEC_CENTER
             AND pr.ID = ar1.PAYREQ_SPEC_ID
             AND pr.SUBID = ar1.PAYREQ_SPEC_SUBID
         INNER JOIN
             PAYMENT_REQUEST_SPECIFICATIONS prs
         ON
             prs.ID = pr.ID
             AND prs.SUBID = pr.SUBID
         WHERE
             c.COUNTRY = 'IT'
             AND extract(MONTH FROM LongToDate(ar.TRANS_TIME)) = par.sel_month
             AND extract(YEAR FROM LongToDate(ar.TRANS_TIME)) = par.sel_year
             AND c.COUNTRY = 'IT'
             AND ar.TEXT = 'Payment into account'
             AND Extract(DAY FROM pr.REQ_DATE) <= 4
             AND extract(MONTH FROM pr.REQ_DATE) = par.sel_month
             AND extract(YEAR FROM pr.REQ_DATE) = par.sel_year
             AND pr.CLEARINGHOUSE_ID IN(803,
                                        2801,
                                        2802,
                                        2803,
                                        2804)
             AND pr.STATE != 12
             --and p.center = 105
             --and p.id = 4773
         GROUP BY
             c.EXTERNAL_ID,
             ART.AMOUNT,
             pr.STATE,
             CONCAT(CONCAT(CAST(p.CENTER AS CHAR(3)),'p'), CAST(p.ID AS VARCHAR(8))),
             c.EXTERNAL_ID,
             pr.CLEARINGHOUSE_ID) p
 GROUP BY
     p.EXTERNAL_ID,
     p.personId,
     p.CLEARINGHOUSE_ID
 ORDER BY
     p.EXTERNAL_ID,
     p.personId
 --SELECT
 --    *
 --FROM
     --VA.CLEARINGHOUSES
