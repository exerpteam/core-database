SELECT
*
FROM
    (
        SELECT DISTINCT
            cc.PERSONCENTER || 'p' || cc.PERSONID member_id
            ,decode(p.SEX,'C','COMPANY','PRIVATE') member_type
          ,artp.CENTER || 'ar' || artp.ID || 't' || artp.SUBID payment_unique_id
          , artp.AMOUNT PAID_AMOUNT
          ,artp.TEXT PAYMENT_TEXT
          ,longToDateC(artp.TRANS_TIME,artp.CENTER) paid_time
          ,'-->' settles
          ,art.UNSETTLED_AMOUNT
          ,art.AMOUNT DEBT_AMOUNT
          ,artm.AMOUNT SETTLED_AMOUNT
          ,prs.REF                                  INVOICE_NUMBER
          ,prs.ORIGINAL_DUE_DATE
        FROM
            CASHCOLLECTIONCASES cc
        JOIN
            CASHCOLLECTION_REQUESTS ccr
        ON
            ccr.CENTER = cc.CENTER
            AND ccr.id = cc.ID
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = ccr.PRSCENTER
            AND prs.ID = ccr.PRSID
            AND prs.SUBID = ccr.PRSSUBID
            
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = cc.PERSONCENTER
            AND ar.CUSTOMERID = cc.PERSONID
            AND ar.AR_TYPE = 5
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND ar.ID = art.ID and art.INFO = ccr.REF
        JOIN
            ART_MATCH artm
        ON
            artm.ART_PAID_CENTER = art.CENTER
            AND artm.ART_PAID_ID = art.ID
            AND artm.ART_PAID_SUBID = art.SUBID
        JOIN
            AR_TRANS artp
        ON
            artp.CENTER = artm.ART_PAYING_CENTER
            AND artp.ID = artm.ART_PAYING_ID
            AND artp.SUBID = artm.ART_PAYING_SUBID
            AND artp.TRANS_TIME > dateToLong('2016-06-01 00:00')
            AND artp.REF_TYPE = 'ACCOUNT_TRANS'
            AND artp.INFO IS NULL
        JOIN
            PERSONS p
        ON
            p.CENTER = cc.PERSONCENTER
            AND p.id = cc.PERSONID
        JOIN
            CENTERS c
        ON
            c.id = p.CENTER
            AND c.COUNTRY = 'NO'
        WHERE
            cc.CASHCOLLECTIONSERVICE = 602
            AND ccr.REQ_AMOUNT > 0 

            )
            order by member_id, payment_unique_id