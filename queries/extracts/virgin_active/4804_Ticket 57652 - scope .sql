SELECT
    SID ,
    SUBSCRIPTION_OWNER,
    PAYER,
    SUB_OWNER_AGE,
    PAYER_AGE,
    SUM(INVL_AMOUNT-CNL_AMOUNT) amount_per_subscription
FROM
    (

        SELECT
            TO_CHAR(longToDate(srp.ENTRY_TIME ),'YYYY-MM-DD')           done,
            s.CENTER || 'ss' || s.ID                                            sid,
            s.OWNER_CENTER || 'p' || s.OWNER_ID                                 subscription_owner,
            payer.CENTER || 'p' || payer.id                                     payer,
            floor(months_between(NVL(cc.STARTDATE,SYSDATE),p.BIRTHDATE)/12)     SUB_OWNER_AGE,
            floor(months_between(NVL(cc.STARTDATE,SYSDATE),payer.BIRTHDATE)/12) PAYER_AGE,
            spp.FROM_DATE,
            spp.TO_DATE,
            DECODE(spp.SPP_STATE,1,'ACTIVE',2,'CANCELLED'),
            TO_CHAR(longToDate(spp.ENTRY_TIME ),'YYYY-MM-DD')       ENTRY_TIME,
            TO_CHAR(longToDate(spp.CANCELLATION_TIME ),'YYYY-MM-DD')CANCELLATION_TIME,
            CASE
                WHEN inv.EMPLOYEE_CENTER = 4
                    AND inv.EMPLOYEE_ID = 834
                    AND TO_CHAR(longToDate(spp.ENTRY_TIME ),'YYYY-MM-DD') IN ('2015-03-04',
                                                                                      '2015-03-05')
                THEN invl.TOTAL_AMOUNT
                ELSE 0
            END AS INVL_AMOUNT,
            CASE
                WHEN cn.EMPLOYEE_CENTER = 4
                    AND cn.EMPLOYEE_ID = 834
                    AND TO_CHAR(longToDate(spp.CANCELLATION_TIME ),'YYYY-MM-DD') IN ('2015-03-04',
                                                                                             '2015-03-05')
                THEN cnl.TOTAL_AMOUNT
                ELSE 0
            END                                             AS CNL_AMOUNT,
            inv.EMPLOYEE_CENTER || 'emp' || inv.EMPLOYEE_ID    emp_inv,
            cn.EMPLOYEE_CENTER || 'emp' || cn.EMPLOYEE_ID      emp_cn
        FROM
            SUBSCRIPTION_REDUCED_PERIOD srp
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = srp.SUBSCRIPTION_CENTER
            AND s.ID = srp.SUBSCRIPTION_ID
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = s.CENTER
            AND spp.ID = s.ID
        JOIN
            SPP_INVOICELINES_LINK link
        ON
            link.PERIOD_CENTER = spp.CENTER
            AND link.PERIOD_ID = spp.ID
            AND link.PERIOD_SUBID = spp.SUBID
        JOIN
            INVOICELINES invl
        ON
            invl.CENTER = link.INVOICELINE_CENTER
            AND invl.ID = link.INVOICELINE_ID
            AND invl.SUBID = link.INVOICELINE_SUBID
        LEFT JOIN
            INVOICES inv
        ON
            inv.CENTER = invl.CENTER
            AND inv.ID = invl.ID
            AND inv.EMPLOYEE_CENTER = 4
            AND inv.EMPLOYEE_ID = 834
        LEFT JOIN
            CREDIT_NOTES cn
        ON
            cn.INVOICE_CENTER = link.INVOICELINE_CENTER
            AND cn.INVOICE_ID = link.INVOICELINE_ID
            AND cn.EMPLOYEE_CENTER = 4
            AND cn.EMPLOYEE_ID = 834
        LEFT JOIN
            CREDIT_NOTE_LINES cnl
        ON
            cnl.INVOICELINE_CENTER = cn.INVOICE_CENTER
            AND cnl.INVOICELINE_ID = cn.INVOICE_ID
            AND cnl.INVOICELINE_SUBID = link.INVOICELINE_SUBID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        LEFT JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = p.CENTER
            AND rel.RELATIVEID = p.ID
            AND rel.RTYPE = 12
            AND rel.STATUS = 1
        LEFT JOIN
            PERSONS payer
        ON
            payer.CENTER = rel.CENTER
            AND payer.ID = rel.ID
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ((
                    rel.CENTER IS NOT NULL
                    AND rel.CENTER = ar.CUSTOMERCENTER
                    AND rel.ID = ar.CUSTOMERID )
                OR (
                    rel.CENTER IS NULL
                    AND s.OWNER_CENTER = ar.CUSTOMERCENTER
                    AND s.OWNER_ID = ar.CUSTOMERID))
            AND ar.AR_TYPE = 4
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = ar.CUSTOMERCENTER
            AND cc.PERSONID = ar.CUSTOMERID
            AND cc.MISSINGPAYMENT = 1
        WHERE
--                        s.CENTER = 446
--                        AND s.ID = 3098
--                        AND
            srp.EMPLOYEE_CENTER = 4
            AND srp.EMPLOYEE_ID = 834
            AND TO_CHAR(longToDate(srp.ENTRY_TIME ),'YYYY-MM-DD') IN ('2015-03-04',
                                                                              '2015-03-05')
            AND (
                TO_CHAR(longToDate(spp.CANCELLATION_TIME ),'YYYY-MM-DD') IN ('2015-03-04',
                                                                                     '2015-03-05')
                OR TO_CHAR(longToDate(spp.ENTRY_TIME ),'YYYY-MM-DD') IN ('2015-03-04',
                                                                                 '2015-03-05') )
            AND (
                cc.CENTER IS NULL
                OR (
                    cc.STARTDATE) IN
                (
                    SELECT
                        MAX(cc2.STARTDATE)
                    FROM
                        CASHCOLLECTIONCASES cc2
                    WHERE
                        cc2.PERSONCENTER = cc.PERSONCENTER
                        AND cc2.PERSONID = cc.PERSONID
                        AND cc2.MISSINGPAYMENT = 1) ) )

WHERE
    (
        SUB_OWNER_AGE >= 18
        AND (
            PAYER_AGE IS NULL
            OR PAYER_AGE >= 18)
            )
GROUP BY
    SID ,
    SUBSCRIPTION_OWNER,
    PAYER,
    SUB_OWNER_AGE,
    PAYER_AGE
