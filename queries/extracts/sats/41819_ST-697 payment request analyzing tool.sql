SELECT
    ar.CUSTOMERCENTER || 'p' ||    ar.CUSTOMERID pid,
    to_char(exerpro.longToDate(prs.ENTRY_TIME),'YYYY-MM-DD HH24:MI') ENTRY_TIME_PAYMENT_REQUEST,
    prs.REF                            PAYMENT_REQUEST_SPEC_REF,
    to_char(exerpro.longToDate(art.TRANS_TIME),'YYYY-MM-DD HH24:MI') TRANS_TIME_AR_TRANS,
    to_char(exerpro.longToDate(art.ENTRY_TIME),'YYYY-MM-DD HH24:MI') ENTRY_TIME_AR_TRANS,
    art.AMOUNT,
    art.DUE_DATE,
    art.TEXT,
    art.REF_TYPE,
    art.STATUS,
    art.UNSETTLED_AMOUNT,
    art.COLLECTED_AMOUNT,
    'Settled by -->'                    settled_by,
    to_char(exerpro.longToDate(armp.ENTRY_TIME),'YYYY-MM-DD HH24:MI') ENTRY_TIME_SETTLEMENT,
    artp.TEXT,
    armp.AMOUNT                                                                                                                                                                                                        AMOUNT_SETTLEMENT,
    prsp.REF                                                                                                                                                                                                        SETTLED_INVOICE_REF,
    to_char(exerpro.longToDate(prsp.ENTRY_TIME),'YYYY-MM-DD HH24:MI')                                                                                                                                                                                                        SETTLED_INVOICE_CREATED,
    DECODE(armp.USED_RULE,1,'MATCH_BATCH', 2,'MATCH_AMOUNT', 3,'MATCH_ALL_UNCOLLECTED', 4,'MATCH_PAYMENT_REQUEST', 5,'MATCH_ALL_HISTORY', 6,'MATCH_MANUAL', 7,'MATCH_CREDIT_NOTE', 8,'MATCH_CREDIT_NOTE_UNCOLLECTED', 9,'MATCH_REVOKED_PAYMENT', 10,'MATCH_TRANSFER_PAYMENT', 11,'MATCH_COLLECTED', 12,'MATCH_AMOUNT_COLLECTED', 13,'MATCH_INSTALLMENT_PLAN_TRANSFER_PAYMENT', 14,'MATCH_PAYMENT_DEBT_TRANSFER', 15,'MATCH_CREDIT_NOTE_INSTALLMENT_PLAN', 16,'MATCH_REVERTED_TRANSACTION',armp.USED_RULE)           USED_RULE_SETTLEMENT_PAID,
    'Has settled -->'                                                                                                                                                                                                        setteling,
    to_char(exerpro.longToDate(armPaying.ENTRY_TIME),'YYYY-MM-DD HH24:MI')                                                                                                                                                                                                        ENTRY_TIME_SETTLEMENT,
    armPaying.AMOUNT                                                                                                                                                                                                        AMOUNT_SETTLEMENT,
    prsPaid.REF                                                                                                                                                                                                        SETTLED_INVOICE_REF,
    to_char(exerpro.longToDate(prsPaid.ENTRY_TIME),'YYYY-MM-DD HH24:MI')                                                                                                                                                                                                        SETTLED_INVOICE_CREATED,
    DECODE(armPaying.USED_RULE,1,'MATCH_BATCH', 2,'MATCH_AMOUNT', 3,'MATCH_ALL_UNCOLLECTED', 4,'MATCH_PAYMENT_REQUEST', 5,'MATCH_ALL_HISTORY', 6,'MATCH_MANUAL', 7,'MATCH_CREDIT_NOTE', 8,'MATCH_CREDIT_NOTE_UNCOLLECTED', 9,'MATCH_REVOKED_PAYMENT', 10,'MATCH_TRANSFER_PAYMENT', 11,'MATCH_COLLECTED', 12,'MATCH_AMOUNT_COLLECTED', 13,'MATCH_INSTALLMENT_PLAN_TRANSFER_PAYMENT', 14,'MATCH_PAYMENT_DEBT_TRANSFER', 15,'MATCH_CREDIT_NOTE_INSTALLMENT_PLAN', 16,'MATCH_REVERTED_TRANSACTION',armPaying.USED_RULE) USED_RULE_SETTLEMENT_PAYING,
    to_char(exerpro.longToDate(artPaid.TRANS_TIME),'YYYY-MM-DD HH24:MI')                                                                                                                                                                                                        PAID_TRANSACTION_TIME,
    artPaid.TEXT,
    art.CENTER || 'ar' || art.ID || 't' || art.SUBID art_key
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
join ACCOUNT_RECEIVABLES ar on ar.CENTER = art.CENTER and ar.ID = art.ID and ar.AR_TYPE = 4    
LEFT JOIN
    ART_MATCH armp
ON
    armp.ART_PAID_CENTER = art.CENTER
    AND armp.ART_PAID_ID = art.ID
    AND armp.ART_PAID_SUBID = art.SUBID
    /* Only display the settlememnts that where when the request was created */
    AND armp.ENTRY_TIME < prs.ENTRY_TIME
LEFT JOIN
    AR_TRANS artp
ON
    artp.CENTER = armp.ART_PAYING_CENTER
    AND artp.ID = armp.ART_PAYING_ID
    AND artp.SUBID = armp.ART_PAYING_SUBID
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prsp
ON
    prsp.CENTER = artp.PAYREQ_SPEC_CENTER
    AND prsp.ID = artp.PAYREQ_SPEC_ID
    AND prsp.SUBID = artp.PAYREQ_SPEC_SUBID
LEFT JOIN
    ART_MATCH armPaying
ON
    armPaying.ART_PAYING_CENTER = art.CENTER
    AND armPaying.ART_PAYING_ID = art.ID
    AND armPaying.ART_PAYING_SUBID = art.SUBID
    /* Only display the settlememnts that where when the request was created */
    --AND armPaying.ENTRY_TIME < prs.ENTRY_TIME
LEFT JOIN
    AR_TRANS artPaid
ON
    artPaid.CENTER = armPaying.ART_PAID_CENTER
    AND artPaid.ID = armPaying.ART_PAID_ID
    AND artPaid.SUBID = armPaying.ART_PAID_SUBID
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prsPaid
ON
    prsPaid.CENTER = artPaid.PAYREQ_SPEC_CENTER
    AND prsPaid.ID = artPaid.PAYREQ_SPEC_ID
    AND prsPaid.SUBID= artPaid.PAYREQ_SPEC_SUBID
WHERE
    --prs.REF = '590-24001'
    --prs.REF = '590-7264'
    prs.REF = $$requestRef$$
    AND art.ENTRY_TIME < prs.ENTRY_TIME
    --AND art.ENTRY_TIME <= exerpro.dateToLong(TO_CHAR(TRUNC(exerpro.longToDate(1444313188181)+1),'YYYY-MM-DD') || ' 00:00')-1
    --    AND art.REF_TYPE IN ('INVOICE',
    --                         'CREDIT_NOTE')
ORDER BY
    art.CENTER || 'ar' || art.ID || 't' || art.SUBID DESC