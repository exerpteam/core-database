-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    RECORDTYPE || SEPARATOR ||
    TERMINALID || SEPARATOR ||
    ORDERID || SEPARATOR ||
    PAN || SEPARATOR ||
    EXPMONTH || SEPARATOR ||
    EXPYEAR || SEPARATOR ||
    CARDDATA || SEPARATOR ||
    AMOUNT || SEPARATOR ||
    CURRENCY || SEPARATOR ||
    AUTHCODE || SEPARATOR ||
    DOCREDIT || SEPARATOR ||
    DOAUTHOR || SEPARATOR ||
    TIMEDATE line
FROM
    (
        SELECT
            'ICCT100' RECORDTYPE,
            cr.FIELD_1 TERMINALID,
            pa.CONTRACT_ID ORDERID,
            'CARDREFID:' || pa.REF PAN,
            TO_CHAR(pa.EXPIRATION_DATE, 'MM') EXPMONTH,
            TO_CHAR(pa.EXPIRATION_DATE, 'YY') EXPYEAR,
            'M' CARDDATA,
            TRUNC ((pr.REQ_AMOUNT * 100), 0) AMOUNT,
            'EUR' CURRENCY,
            '' AUTHCODE,
            '0' DOCREDIT,
            '1' DOAUTHOR,
            TO_CHAR(pr.REQ_DATE, 'YYYYMMDD') || '0100' TIMEDATE,
            ',' SEPARATOR
        FROM
            HP.PAYMENT_REQUESTS pr
        JOIN HP.CLEARINGHOUSE_CREDITORS cr
        ON
            cr.CLEARINGHOUSE = pr.CLEARINGHOUSE_ID
            AND cr.CREDITOR_ID = pr.CREDITOR_ID
        JOIN HP.PAYMENT_AGREEMENTS pa
        ON
            pa.CENTER = pr.CENTER
            AND pa.ID = pr.ID
            AND pa.SUBID = pr.AGR_SUBID
        WHERE
            pr.CREDITOR_ID like 'CC%'
            AND pr.STATE = 1
            AND pr.REQ_DATE = :DeductionDate
			AND pr.center = :Center
    )
