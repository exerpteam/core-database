SELECT DISTINCT
    ID,
    PID,
    PERSON_STATUS,
    FILE_IN_DATE,
    XFR_INFO,
    INVOICE_REF_PART,
    AGREEMENT_REF_PART,
    CASE
        WHEN CREDITOR_EXISTS_IN_SCOPE = 1
            AND PAYMENT_AGREEMENT_FOUND = 1
            AND CREDITOR_MATCH = 1
        THEN 1
        ELSE 0
    END AS MATCH_POSSIBLE,
    PAYMENT_AGREEMENT_FOUND,
    CREDITOR_MATCH,
    REQUEST_MATCH,
    REQUEST_MATCH_AMOUNT,
    CREDITOR_EXISTS_IN_SCOPE,
    CREDITOR_EXISTS_ANYWHERE,
    clearing_house_agrmeent,
    clearing_house_file_read,
    PAYMENT_AGR_CREDITOR,
    FILE_CREDITOR
FROM
    (
        SELECT
            up.id,
            p.CENTER || 'p' || p.ID                                                                                                                                                            pid,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
            up.XFR_DATE                                                                                                                                                                        file_in_date,
            up.XFR_INFO ,
            up.XFR_TEXT          invoice_ref_part,
            up.XFR_DEBITOR_ID    agreement_ref_part,
            nvl2(pa.CENTER,1,0)  payment_agreement_found,
            nvl2(pa2.CENTER,1,0) creditor_match,
            nvl2(pr.CENTER,1,0)  request_match,
            nvl2(pa2.CENTER,1,0) request_match_amount,
            nvl2(
            (
                SELECT
                    1
                FROM
                    CLEARINGHOUSE_CREDITORS chc
                WHERE
                    chc.CREDITOR_ID = pa.CREDITOR_ID
                    AND chc.CLEARINGHOUSE = ci.CLEARINGHOUSE),1,0) creditor_exists_in_scope,
            nvl2(
            (
                SELECT
                    1
                FROM
                    CLEARINGHOUSE_CREDITORS chc
                WHERE
                    chc.CREDITOR_ID = pa.CREDITOR_ID ),1,0) creditor_exists_anywhere,
            pa_ch.NAME                                      clearing_house_agrmeent,
            ci_ch.NAME                                      clearing_house_file_read,
            pa.CREDITOR_ID                                  PAYMENT_AGR_CREDITOR ,
            up.XFR_CREDITOR_ID                              FILE_CREDITOR
        FROM
            UNPLACED_PAYMENTS up
        LEFT JOIN
            PAYMENT_AGREEMENTS pa
        ON
            pa.REF = up.XFR_DEBITOR_ID
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = pa.CENTER
            AND ar.ID = pa.id
        LEFT JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
            AND p.ID = ar.CUSTOMERID
        LEFT JOIN
            CLEARINGHOUSES pa_ch
        ON
            pa_ch.ID = pa.CLEARINGHOUSE
        LEFT JOIN
            CLEARING_IN ci
        ON
            ci.ID = up.XFR_DELIVERY
        LEFT JOIN
            CLEARINGHOUSES ci_ch
        ON
            ci_ch.ID = ci.CLEARINGHOUSE
        LEFT JOIN
            PAYMENT_AGREEMENTS pa2
        ON
            pa2.REF = up.XFR_DEBITOR_ID
            AND pa2.CREDITOR_ID = up.XFR_CREDITOR_ID
        LEFT JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.CENTER = pa.CENTER
            AND pr.ID = pa.id
            AND pr.AGR_SUBID = pa.SUBID
            AND pr.REF = up.XFR_TEXT
        LEFT JOIN
            PAYMENT_REQUESTS pr2
        ON
            pr2.CENTER = pa.CENTER
            AND pr2.ID = pa.id
            AND pr2.AGR_SUBID = pa.SUBID
            AND pr2.REF = up.XFR_TEXT
            AND up.XFR_AMOUNT = pr2.REQ_AMOUNT
        WHERE
            up.STATE IN ($$state$$)
            AND up.XFR_DATE >= $$from_date$$ )