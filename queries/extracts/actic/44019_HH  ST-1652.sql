WITH
    params AS
    (
        SELECT
            dateToLongC(TO_CHAR(trunc(rp.START_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)   FromDate 
            ,dateToLongC(TO_CHAR(trunc(rp.END_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)   ToDate             
        FROM
            REPORT_PERIODS rp
        JOIN
            CENTERS c
        ON
            c.COUNTRY = DECODE(rp.SCOPE_ID,28,'FI',2,'SE',4,'NO',44,'DE')
        WHERE
            rp.HARD_CLOSE_TIME IS NOT NULL
            AND c.id = $$Club$$
            AND rp.HARD_CLOSE_TIME IN
            (
                SELECT
                    MAX (rp2.HARD_CLOSE_TIME)
                FROM
                    REPORT_PERIODS rp2
                WHERE
                    rp2.SCOPE_TYPE = rp.SCOPE_TYPE
                    AND rp2.SCOPE_ID = rp.SCOPE_ID)
    )

SELECT
            /*+ INDEX(ACCOUNT_TRANS IDX_ACT_INFO_TIME) */
            p.CENTER || 'p' || p.id payerid
          , prs.ref
          , art.AMOUNT
          , TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate
          , artSales.REF_CENTER
          , artSales.REF_ID
          , artSales.REF_TYPE
          , CASE
                WHEN p.SEX = 'C'
                THEN 'Corporate'
                ELSE 'AG/Faktura'
            END type
        FROM
            params
          , ACCOUNT_TRANS act
        JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            art.center = ar.center
            AND art.id = ar.id
        JOIN
            PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.REF = art.INFO
            AND (
                prs.REQUESTED_AMOUNT = art.AMOUNT
                OR prs.TOTAL_INVOICE_AMOUNT = art.AMOUNT)
        LEFT JOIN
            AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
            AND artSales.PAYREQ_SPEC_ID = prs.id
            AND artSales.PAYREQ_SPEC_SUBID = prs.subid
            AND artSales.REF_TYPE IN ('INVOICE'
                                    , 'CREDIT_NOTE')
        WHERE
            act.INFO_TYPE IN (3
                            , 16)
            AND artSales.REF_CENTER = $$Club$$
            AND act.TRANS_TIME >= params.FromDate
            AND act.TRANS_TIME < params.ToDate + 1000 * 60 * 60 * 24
           /* AND act.CENTER IN
            (
                SELECT
                    id
                FROM
                    centers
                WHERE
                    id <= 200)*/