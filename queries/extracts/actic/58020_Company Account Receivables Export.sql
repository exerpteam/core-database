WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
    ,
    comps AS
    (
        SELECT DISTINCT
            comp.*
        FROM
            plist p
        JOIN
            RELATIVES rel_comp
        ON
            p.CENTER = rel_comp.RELATIVECENTER
        AND p.ID = rel_comp.RELATIVEID
        AND rel_comp.RTYPE = 2
        AND rel_comp.STATUS=1
        JOIN
            persons comp
        ON
            comp.center = rel_comp.center
        AND comp.id = rel_comp.id
    )
SELECT DISTINCT
    (c.center || 'p' || c.id) AS CompanyId,
    NULL                      AS AccountBalanceDueDate, -- exerp to exerp migrations have due dates
    -- for each transaction
    pa.REF                  PaymentAgreementReferenceId,
    pa.clearinghouse_ref AS PaymentAgreementContractId,
    (
        CASE pa.STATE
            WHEN 1
            THEN 'CREATED'
            WHEN 2
            THEN 'SENT'
            WHEN 3
            THEN 'FAILED'
            WHEN 4
            THEN 'OK'
            WHEN 5
            THEN 'ENDED BY BANK'
            WHEN 6
            THEN 'ENDED BY CLEARING HOUSE'
            WHEN 7
            THEN 'ENDED BY DEBTOR'
            WHEN 8
            THEN 'CANCELLED'
            WHEN 9
            THEN 'END SENT'
            WHEN 10
            THEN 'AGREEMENT ENDED BY CREDITOR'
            WHEN 11
            THEN 'NO AGREEMENT WITH DEBITOR'
            WHEN 12
            THEN 'DEPRICATED'
            WHEN 13
            THEN 'NOT NEEDED'
            WHEN 14
            THEN 'INCOMPLETE'
            WHEN 15
            THEN 'TRANSFERRED'
            ELSE 'UNKNOWN'
        END)                                            AS PaymentAgreementState,
    pa.BANK_REGNO                                       AS PaymentAgreementBankReg,
    pa.bank_branch_no                                   AS PaymentAgreementBankBranch,
    pa.BANK_ACCNO                                       AS PaymentAgreementBankAccount,
    TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS PaymentAgreementCreationDate,
    pa.extra_info                                       AS PaymentAgreementExtraInfo,
    pa.bank_account_holder                              AS PaymentAgreementBankAccountHolder,
    pcc.name                                            AS PaymentAgreementPaymentCycle,
    CASE
        WHEN requests_sent > 0
        THEN 1
        ELSE 0
    END AS PaymentAgreementRequestsSent,
    CASE cl.ctype
        WHEN 142
        THEN 'INVOICE'
        WHEN 145
        THEN 'EFT'
        WHEN 184
        THEN 'CREDIT_CARD'
    END AS PaymentAgreementType,
    --- where to get credit card token?
    CASE
        WHEN cl.ctype = 184
        THEN ''
        ELSE NULL
    END AS CreditCardToken,
    CASE
        WHEN cl.ctype = 184
        THEN pa.expiration_date
        ELSE NULL
    END AS CreditCardExpiryDate,
    --- where to get credit card number?
    CASE
        WHEN cl.ctype = 184
        THEN ''
        ELSE NULL
    END                         AS CreditCardMaskedNumber,
    pa.iban                     AS IBAN,
    pa.bic                      AS BIC,
    pa.individual_deduction_day AS IndividualDeductionDay
    /*,
    pa.ACTIVE,
    (
    CASE
    WHEN paymentaccount.ACTIVE_AGR_SUBID = pa.SUBID
    THEN 1
    ELSE 0
    END) AS DefaultAgreement*/
FROM
    comps c
JOIN
    ACCOUNT_RECEIVABLES account
ON
    account.CUSTOMERCENTER=c.center
AND account.CUSTOMERID=c.id
AND account.AR_TYPE=4
JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.CENTER = account.CENTER
AND paymentaccount.ID = account.ID
JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.CENTER
AND paymentaccount.ACTIVE_AGR_ID = pa.ID
LEFT JOIN
    AGREEMENT_CHANGE_LOG acl
ON
    pa.CENTER = acl.AGREEMENT_CENTER
AND pa.ID = acl.AGREEMENT_ID
AND pa.SUBID = acl.AGREEMENT_SUBID
AND acl.STATE > 4
JOIN
    clearinghouses cl
ON
    cl.id = pa.clearinghouse
JOIN
    payment_cycle_config pcc
ON
    pcc.id = pa.payment_cycle_config_id
WHERE
    (pa.ACTIVE = 1
    OR  acl.ENTRY_TIME > datetolong('2018-06-01 00:00')) -- adjust according to cut date
    -- for agreements export