SELECT
    opa.CENTER,
    opa.ID,
    opa.PERSONID,
    opa.SEX,
    opa.PERSONTYPE,
    opa.CREDITORID,
    DECODE(opa.PAYMENTAGREEMENTSTATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') PAYMENTAGREEMENTSTATE,
    opa.PAYMENTACCOUNTBALANCE,
    opa.CCACCOUNTBALANCE,
    opa.CCCASEAMOUNT,
    opa.PAYMENTOPENEDAMOUNT NORMAL_AMOUNT ,
    SUM(art2.UNSETTLED_AMOUNT) overdue_balance,
    opa.PAYMENTOPENEDAMOUNT + SUM(art2.UNSETTLED_AMOUNT) amount_with_recollect
FROM
    (
        SELECT
            ar.CENTER                                      AS center,
            ar.ID                                          AS id,
            MAX(ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID) AS PersonId ,
            MAX(ar.COLLECTED_UNTIL)                        AS COLLECTED_UNTIL,
            MAX(p.sex)                                     AS Sex,
            MAX(p.PERSONTYPE)                              AS PersonType,
            MAX(pag.CREDITOR_ID)                           AS CreditorId,
            MAX(pag.state)                                 AS PaymentAgreementState,
            MAX(ar.BALANCE)                                AS PaymentAccountBalance ,
            MAX(NVL(ar5.BALANCE, 0))                       AS CCAccountBalance ,
            MAX(NVL(cc.AMOUNT, 0))                         AS CCCaseAmount ,
            SUM(art.UNSETTLED_AMOUNT)                      AS PaymentOpenedAmount
        FROM
            ACCOUNT_RECEIVABLES ar
        JOIN PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        LEFT JOIN PAYMENT_ACCOUNTS pac
        ON
            pac.center = ar.center
            AND pac.id = ar.id
        LEFT JOIN PAYMENT_AGREEMENTS pag
        ON
            pag.center = pac.ACTIVE_AGR_CENTER
            AND pag.id = pac.ACTIVE_AGR_ID
            AND pag.subid = pac.ACTIVE_AGR_SUBID
        LEFT JOIN CASHCOLLECTIONCASES cc
        ON
            cc.personcenter = ar.CUSTOMERCENTER
            AND cc.personid = ar.CUSTOMERID
            AND cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
        LEFT JOIN ACCOUNT_RECEIVABLES ar5
        ON
            ar5.CUSTOMERCENTER = p.center
            AND ar5.CUSTOMERID = p.id
            AND ar5.AR_TYPE = 5
        JOIN AR_TRANS art
        ON
            art.center = ar.center
            AND art.id = ar.id
            AND art.collected = 0
            AND art.ENTRY_TIME > ar.COLLECTED_UNTIL
        LEFT JOIN RELATIVES rel
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
            ar.CENTER,
            ar.ID
    )
    opa
JOIN AR_TRANS art2
ON
    art2.CENTER = opa.center
    AND art2.ID = opa.id
    AND art2.UNSETTLED_AMOUNT < 0
    AND
    (
        art2.DUE_DATE IS NOT NULL
        AND art2.DUE_DATE < exerpsysdate()
    )
    AND NOT
    (
        art2.collected = 0
        AND art2.ENTRY_TIME > opa.COLLECTED_UNTIL
    )
GROUP BY
    opa.CENTER,
    opa.ID,
    opa.PERSONID,
    opa.SEX,
    opa.PERSONTYPE,
    opa.CREDITORID,
    opa.PAYMENTAGREEMENTSTATE,
    opa.PAYMENTACCOUNTBALANCE,
    opa.CCACCOUNTBALANCE,
    opa.CCCASEAMOUNT,
    opa.PAYMENTOPENEDAMOUNT