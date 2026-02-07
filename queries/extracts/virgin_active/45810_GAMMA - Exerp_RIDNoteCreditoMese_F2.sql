WITH
    PARAMS AS
    (
        SELECT
            EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1)) AS sel_month,
            EXTRACT(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))  AS sel_year
 
    )

SELECT
    s.clubId                AS "CLUBID",
    s.personId              AS "PERSONID",
    SUM(s.importoRichiesto) AS "IMPORTORICHIESTO",
    SUM(s.importoPagato)    AS "IMPORTOPAGATO"
FROM
    (
        SELECT
            c.EXTERNAL_ID                                                             AS clubId,
            CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))) AS personId,
            pr.REQ_AMOUNT                                                             AS
                 importoRichiesto,
            0 AS importoPagato
        FROM
            
            PERSONS p1
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p1.CENTER
        AND ar.CUSTOMERID = p1.ID
        AND ar.AR_TYPE = 4
        LEFT JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
        AND pac.ID = ar.ID
        LEFT JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
        AND pr.ID = ar.id
        LEFT JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            pr.INV_COLL_CENTER = prs.CENTER
        AND pr.INV_COLL_ID = prs.ID
        AND pr.INV_COLL_SUBID = prs.SUBID
        LEFT JOIN
            AR_TRANS art
        ON
            art.PAYREQ_SPEC_SUBID = prs.SUBID
        AND art.PAYREQ_SPEC_ID = prs.ID
        AND art.PAYREQ_SPEC_CENTER = prs.CENTER
        LEFT JOIN
            INVOICELINES invl
        ON
            invl.ID = art.REF_ID
        AND invl.CENTER = art.REF_CENTER
        LEFT JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = invl.ACCOUNT_TRANS_CENTER
        AND act.ID = invl.ACCOUNT_TRANS_ID
        AND act.SUBID = invl.ACCOUNT_TRANS_SUBID
        INNER JOIN
            ACCOUNTS debac
        ON
            debac.center = act.DEBIT_ACCOUNTCENTER
        AND debac.ID = act.DEBIT_ACCOUNTID
        INNER JOIN
            ACCOUNTS credac
        ON
            credac.center = act.CREDIT_ACCOUNTCENTER
        AND credac.ID = act.CREDIT_ACCOUNTID
        LEFT JOIN
            CENTERS c
        ON
            c.ID = pr.CENTER
        WHERE
            --PR.center = 102
            c.COUNTRY = 'IT'
        AND extract(MONTH FROM pr.req_date) = EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))
        AND extract(YEAR FROM pr.req_date) = extract(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))
        AND extract(DAY FROM pr.req_date) <= 4
        AND pr.STATE IS NOT NULL
        AND pr.STATE != 12
        AND ART.REF_TYPE = 'INVOICE'
            --AND ar.CUSTOMERID = 7338
        AND art.COLLECTED_AMOUNT <> 0
            --AND pr.CLEARINGHOUSE_ID = 803
        AND pr.CLEARINGHOUSE_ID IN(803,
                                   2801,
                                   2802,
                                   2803,
                                   2804)
        AND pr.STATE != 12
            --AND p1.ID IN(17756, 17754)
            --AND p1.CENTER = 101
        GROUP BY
            c.EXTERNAL_ID,
            CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))),
            pr.REQ_AMOUNT,
            pr.CENTER,
            pr.ID,
            pr.SUBID
        UNION ALL
        SELECT
            C.EXTERNAL_ID AS ClubId,
            CONCAT(CONCAT(CAST(a.CUSTOMERCENTER AS CHAR(3)),'p'), CAST(a.CUSTOMERID AS VARCHAR(8)))
                           AS personId,
            SUM(0)         AS importoRichiesto,
            SUM(ar.AMOUNT) AS importoPagato
        FROM
            params par,
            AGGREGATED_TRANSACTIONS agt
        INNER JOIN
            CENTERS c
        ON
            c.ID = agt.CENTER
        INNER JOIN
            ACCOUNT_TRANS act
        ON
            agt.CENTER = act.AGGREGATED_TRANSACTION_CENTER
        AND agT.id = act.AGGREGATED_TRANSACTION_ID
        INNER JOIN
            AR_TRANS ar
        ON
            act.ID = ar.REF_ID
        AND act.SUBID = ar.REF_SUBID
        AND act.CENTER = ar.REF_CENTER
        INNER JOIN
            ACCOUNT_RECEIVABLES a
        ON
            ar.center = a.center
        AND ar.id = a.id
        WHERE
            agt.TEXT ~ ' Debt to [0-9]{3},[0-9]{1,}$'
            --SELECT * FROM ACCOUNT_TRANS WHERE AGGREGATED_TRANSACTION_ID = 8951
            --AND AGGREGATED_TRANSACTION_CENTER = 101
        AND extract(MONTH FROM agt.BOOK_DATE) = par.sel_month
        AND extract(YEAR FROM agt.BOOK_DATE) = par.sel_year
        AND c.COUNTRY = 'IT'
        AND agt.INFO != '0'
        AND C.ID != 100
        GROUP BY
            C.EXTERNAL_ID,
            CONCAT(CONCAT(CAST(a.CUSTOMERCENTER AS CHAR(3)),'p'), CAST(a.CUSTOMERID AS VARCHAR(8)))
    ) s
GROUP BY
    s.clubId,
    s.personId
ORDER BY
    s.clubId,
    s.personId