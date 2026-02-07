-- This is the version from 2026-02-05
--  
SELECT
    dat3.center,
    dat3.id,
    DECODE ( dat3.PersonType, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    dat3.SEX,
    dat3.CreditorId,
    DECODE(NVL(dat3.PaymentAgreementState,0),1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete', 'None') AS AgreementState,
    dat3.BalancePolicy1                                                                                                                                                                                                                                                                                                                                                   AS CurrentPolicy,
    dat3.OpenAmountPolicy,
    OpenAmountPolicy - BalancePolicy1 AS DiffBalance1AndOpenAmount,
    dat3.PaymentAccountBalance,
    dat3.InvoicedAmount,
    dat3.PaymentOpenedAmount,
    dat3.CCCaseAmount
FROM
    (
        SELECT
            dat2.*,
            CASE
                WHEN dat2.creditorId = 'Avtale Giro'
                    AND
                    (
                        dat2.TmpInvoicePolicy1 > 0
                        OR dat2.TmpInvoicePolicy1 <= -100
                    )
                THEN dat2.TmpInvoicePolicy1
                WHEN dat2.creditorId = 'Avtale Giro'
                THEN 0
                WHEN dat2.TmpBalancePolicy1 <= -100
                THEN dat2.TmpBalancePolicy1
                ELSE 0
            END AS BalancePolicy1,
            CASE
                WHEN dat2.TmpOpenAmountPolicy <= -100
                THEN dat2.TmpOpenAmountPolicy
                ELSE 0
            END AS OpenAmountPolicy
        FROM
            (
                SELECT
                    dat.*,
                    CASE
                        WHEN dat.PaymentAccountBalance >= 0
                        THEN 0
                        WHEN dat.CCAccountBalance <= 0
                            AND dat.PaymentAccountBalance + dat.CCAccountBalance + dat.CCCaseAmount < 0
                        THEN dat.PaymentAccountBalance + dat.CCAccountBalance + dat.CCCaseAmount
                        WHEN dat.CCAccountBalance > 0
                            AND dat.PaymentAccountBalance + dat.CCCaseAmount < 0
                        THEN dat.PaymentAccountBalance + dat.CCCaseAmount
                        ELSE 0
                    END AS TmpBalancePolicy1,
                    CASE
                        WHEN dat.PaymentAccountBalance >= 0
                        THEN 0
                        WHEN dat.InvoicedAmount >= 0
                        THEN 0
                        WHEN dat.PaymentAccountBalance < dat.InvoicedAmount
                        THEN dat.InvoicedAmount
                        ELSE dat.PaymentAccountBalance
                    END                AS TmpBalancePolicy2,
                    dat.InvoicedAmount AS TmpInvoicePolicy1,
                    CASE
                        WHEN dat.PaymentAccountBalance >= 0
                        THEN 0
                        WHEN dat.PaymentOpenedAmount < 0
                        THEN dat.PaymentOpenedAmount
                        ELSE 0
                    END AS TmpOpenAmountPolicy
                FROM
                    (
                        SELECT
                            ar.CUSTOMERCENTER                         AS CENTER,
                            ar.CUSTOMERID                             AS ID,
                            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PersonId ,
                            MAX(p.sex)                                AS Sex,
                            MAX(p.PERSONTYPE)                         AS PersonType,
                            MAX(pag.CREDITOR_ID)                      AS CreditorId,
                            MAX(pag.state)                            AS PaymentAgreementState,
                            MAX(ar.BALANCE)                           AS PaymentAccountBalance ,
                            MAX(NVL(ccar.BALANCE, 0))                 AS CCAccountBalance ,
                            MAX(NVL(cc.AMOUNT, 0))                    AS CCCaseAmount ,
                            SUM(
                                CASE
                                    WHEN payart.ref_type IS NOT NULL
                                        AND payart.ref_type IN ('INVOICE', 'CREDIT_NOTE')
                                    THEN payart.amount
                                    ELSE 0
                                END)                     AS InvoicedAmount ,
                            SUM(payart.UNSETTLED_AMOUNT) AS PaymentOpenedAmount
                        FROM
                            FW.ACCOUNT_RECEIVABLES ar
                        JOIN FW.PERSONS p
                        ON
                            p.center = ar.CUSTOMERCENTER
                            AND p.id = ar.CUSTOMERID
                        LEFT JOIN FW.PAYMENT_ACCOUNTS pac
                        ON
                            pac.center = ar.center
                            AND pac.id = ar.id
                        LEFT JOIN FW.PAYMENT_AGREEMENTS pag
                        ON
                            pag.center = pac.ACTIVE_AGR_CENTER
                            AND pag.id = pac.ACTIVE_AGR_ID
                            AND pag.subid = pac.ACTIVE_AGR_SUBID
                        LEFT JOIN FW.CASHCOLLECTIONCASES cc
                        ON
                            cc.personcenter = ar.CUSTOMERCENTER
                            AND cc.personid = ar.CUSTOMERID
                            AND cc.MISSINGPAYMENT = 1
                            AND cc.CLOSED = 0
                        LEFT JOIN FW.ACCOUNT_RECEIVABLES ccar
                        ON
                            ccar.CUSTOMERCENTER = p.center
                            AND ccar.CUSTOMERID = p.id
                            AND ccar.AR_TYPE = 5
                        JOIN FW.AR_TRANS payart
                        ON
                            payart.center = ar.center
                            AND payart.id = ar.id
                            AND payart.collected = 0
                            AND payart.ENTRY_TIME > ar.COLLECTED_UNTIL
                        LEFT JOIN FW.RELATIVES rel
                        ON
                            rel.RELATIVECENTER = p.center
                            AND rel.relativeid = p.id
                            AND rel.STATUS < 3
                            AND rel.RTYPE = 12
                        WHERE
                            ar.AR_TYPE = 4
                            AND rel.CENTER IS NULL -- exclude persons paid by others
                            AND ar.center IN (:scope)
                        GROUP BY
                            ar.CUSTOMERCENTER ,
                            ar.CUSTOMERID
                    )
                    dat
            )
            dat2
    )
    dat3
WHERE
    BalancePolicy1 != OpenAmountPolicy