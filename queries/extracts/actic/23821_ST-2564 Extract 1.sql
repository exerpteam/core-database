-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    longtodateC(trans_time,act.CENTER) AS BOOK_DATE,
    longtodateC(entry_time,act.CENTER) AS ENTRY_DATE,
    (
        SELECT
            EXTERNAL_ID
        FROM
            ACCOUNTS acc
        WHERE
            acc.center = act.CREDIT_ACCOUNTCENTER
        AND acc.id = act.CREDIT_ACCOUNTID) AS CREDIT_ACCOUNT,
    (
        SELECT
            NAME
        FROM
            ACCOUNTS acc
        WHERE
            acc.center = act.CREDIT_ACCOUNTCENTER
        AND acc.id = act.CREDIT_ACCOUNTID) AS CREDIT_ACCOUNT_NAME,
    (
        SELECT
            EXTERNAL_ID
        FROM
            ACCOUNTS acc
        WHERE
            acc.center = act.DEBIT_ACCOUNTCENTER
        AND acc.id = act.DEBIT_ACCOUNTID) AS DEBIT_ACCOUNT,
    (
        SELECT
            NAME
        FROM
            ACCOUNTS acc
        WHERE
            acc.center = act.DEBIT_ACCOUNTCENTER
        AND acc.id = act.DEBIT_ACCOUNTID) AS DEBIT_ACCOUNT_NAME,
    act.AMOUNT,
    act.TEXT,
    act.CENTER,
    act.ID,
    act.SUBID,
    (
        SELECT
            ar.CUSTOMERCENTER || 'p' || ar.customerid
        FROM
            ar_trans art
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            art.center = ar.center
        AND art.id = ar.id
        WHERE
            art.REF_CENTER = act.center
        AND art.REF_ID = act.id
        AND art.REF_subid = act.subid
        AND art.REF_TYPE ='ACCOUNT_TRANS') AS MemberId
FROM
    ACCOUNT_TRANS act
WHERE
    act.EXPORT_FILE IS NULL
AND act.TRANSFERRED = 0
AND trans_time >= $$cutDate$$
AND entry_time < $$cutDate$$
AND act.CENTER 	in ($$scope$$)
ORDER BY
    entry_time