-- This is the version from 2026-02-05
--  
SELECT
    dat3.center, dat3.id,
    --dat3.PersonId,
    DECODE ( dat3.PersonType, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    dat3.SEX,
    dat3.CreditorId,
    DECODE(nvl(dat3.PaymentAgreementState,0),1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete', 'None') as AgreementState,
    dat3.InvoicedAmount as CurrentPolicy,
    dat3.InvoicedAmount as InvoicedAmount,
--    dat3.BalancePolicy2,
    dat3.OpenAmountPolicy,
--    BalancePolicy1 - BalancePolicy2   AS DiffBalance1And2,
--    OpenAmountPolicy - BalancePolicy2 AS DiffBalance2AndOpenAmount,
    OpenAmountPolicy - dat3.InvoicedAmount AS DiffInvoiceAmountAndOpenAmount,
    
/*
    CASE
        WHEN
            (
                BalancePolicy1 - BalancePolicy2 != 0
            )
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS HasDiffBalance1And2, -- 370
    CASE
        WHEN
            (
                OpenAmountPolicy - BalancePolicy2 != 0
            )
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS HasDiffBalance2AndOpenAmount, --299

    CASE
        WHEN
            (
                OpenAmountPolicy - BalancePolicy1 != 0
            )
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS HasDiffBalance1AndOpenAmount, --299
*/ 
    dat3.PaymentAccountBalance,
    dat3.InvoicedAmount,
    dat3.PaymentOpenedAmount
    --,
--    dat3.CCCaseAmount
    --,dat3.PaymentAccountOverdueDebt
    
FROM
    (
        SELECT
            dat2.*,
            CASE
                WHEN dat2.creditorId = 'Faktura' and (dat2.TmpInvoicePolicy1 > 0 or dat2.TmpInvoicePolicy1 <= -15) then dat2.TmpInvoicePolicy1
                WHEN dat2.creditorId = 'Faktura' then 0
                WHEN dat2.TmpBalancePolicy1 <= -15
                THEN dat2.TmpBalancePolicy1
                ELSE 0
            END AS BalancePolicy1,
            
            /*
            CASE
                WHEN dat2.TmpBalancePolicy2 <= -15
                THEN dat2.TmpBalancePolicy2
                ELSE 0
            END AS BalancePolicy2,*/
            CASE
                WHEN dat2.TmpOpenAmountPolicy <= -15
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
                        WHEN dat.CCAccountBalance <= 0 and dat.PaymentAccountBalance + dat.CCAccountBalance + dat.CCCaseAmount <
                            0
                        THEN dat.PaymentAccountBalance + dat.CCAccountBalance + dat.CCCaseAmount
                        WHEN dat.CCAccountBalance > 0 and dat.PaymentAccountBalance + dat.CCCaseAmount <
                            0
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
                    END AS TmpBalancePolicy2,
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
                            ar.CUSTOMERCENTER as CENTER, ar.CUSTOMERID as ID,
                            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PersonId ,
                            ar.COLLECTED_UNTIL,
                            max(p.sex) as Sex,
                            max(p.PERSONTYPE) as PersonType,
                            max(pag.CREDITOR_ID)  as CreditorId,
                            max(pag.state) as PaymentAgreementState,
                            MAX(ar.BALANCE)                           AS PaymentAccountBalance
                            --, max(cashar.BALANCE) as CashAccountBalance
                            ,
                            MAX(NVL(ccar.BALANCE, 0)) AS CCAccountBalance ,
                            MAX(NVL(cc.AMOUNT, 0))    AS CCCaseAmount ,
                            --CASE WHEN MIN(nvl(overdue_debt.amount, 0)) < 0 then MIN(nvl(overdue_debt.amount, 0)) else 0 end AS PaymentAccountOverdueDebt ,
                            SUM(
                                CASE
                                    WHEN payart.ref_type IS NOT NULL
                                    AND payart.ref_type IN ('INVOICE', 'CREDIT_NOTE')
                                    THEN payart.amount
                                    ELSE 0
                                END)                     AS InvoicedAmount ,
                            SUM(payart.UNSETTLED_AMOUNT) AS PaymentOpenedAmount
                        FROM
                            ACCOUNT_RECEIVABLES ar
                        JOIN PERSONS p
                        ON
                            p.center = ar.CUSTOMERCENTER
                        AND p.id = ar.CUSTOMERID
                        LEFT JOIN PAYMENT_ACCOUNTS pac on pac.center = ar.center and pac.id = ar.id
                        LEFT join PAYMENT_AGREEMENTS pag on pag.center = pac.ACTIVE_AGR_CENTER and pag.id = pac.ACTIVE_AGR_ID and pag.subid = pac.ACTIVE_AGR_SUBID
                        LEFT JOIN CASHCOLLECTIONCASES cc
                        ON
                            cc.personcenter = ar.CUSTOMERCENTER
                        AND cc.personid = ar.CUSTOMERID
                        AND cc.MISSINGPAYMENT = 1
                        AND cc.CLOSED = 0
                        LEFT JOIN ACCOUNT_RECEIVABLES ccar
                        ON
                            ccar.CUSTOMERCENTER = p.center
                        AND ccar.CUSTOMERID = p.id
                        AND ccar.AR_TYPE = 5
                            --join ACCOUNT_RECEIVABLES cashar on cashar.CUSTOMERCENTER =
                            -- p.center and cashar.CUSTOMERID = p.id and ccar.AR_TYPE = 1
                        JOIN AR_TRANS payart
                        ON
                            payart.center = ar.center
                        AND payart.id = ar.id
                        AND payart.collected = 0
                        and payart.ENTRY_TIME > ar.COLLECTED_UNTIL
                        LEFT JOIN RELATIVES rel
                        ON
                            rel.RELATIVECENTER = p.center
                        AND rel.relativeid = p.id
                        AND rel.STATUS < 3
                        AND rel.RTYPE = 12
                        /*
                        JOIN (
                              select art_od.center, art_od.id, sum(art_od.amount) as amount from ar_trans art_od 
                              where    art_od.AMOUNT > 0 or (art_od.AMOUNT < 0 and art_od.DUE_DATE < exerpsysdate() - 1) group by art_od.center, art_od.id
                        ) overdue_debt on overdue_debt.center = ar.center and overdue_debt.id = ar.id 
                        */
                        WHERE
                            ar.AR_TYPE = 4
                        --AND ar.CENTER >= 200
                            --and ar.BALANCE + NVL(ccar.BALANCE, 0) + NVL(cc.AMOUNT, 0) != 0
                        --AND p.SEX = 'C'
                        AND rel.CENTER IS NULL -- exclude persons paid by others
                            --and p.center = 202 and p.id = 6763
                        --and pag.CREDITOR_ID = 'InvoiceSE'
                        --and ar.center in (select id from centers where country = 'SE')
                        GROUP BY
                            ar.CUSTOMERCENTER , ar.CUSTOMERID, ar.COLLECTED_UNTIL
                            --having max(ar.BALANCE) + max(NVL(ccar.BALANCE, 0)) + max(NVL(
                            -- cc.AMOUNT, 0)) - sum(case when art.ref_type in ('INVOICE', '
                            -- CREDIT_NOTE') then art.amount else 0 end) != 0
                    )
                    dat
            )
            dat2
    )
    dat3
WHERE
      -- BalancePolicy1 != OpenAmountPolicy
dat3.InvoicedAmount != OpenAmountPolicy

--and dat3.CREDITORID = 'InvoiceSE'
;