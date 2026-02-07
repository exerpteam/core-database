SELECT
    p.center||'p'||p.id AS MEMBER_ID
FROM
    account_trans act
JOIN
    ACCOUNTS DEB_ACC
ON
    DEB_ACC.CENTER = ACT.DEBIT_ACCOUNTCENTER
    AND DEB_ACC.ID = ACT.DEBIT_ACCOUNTID
JOIN
    ACCOUNTS CRED_ACC
ON
    CRED_ACC.CENTER = ACT.CREDIT_ACCOUNTCENTER
    AND CRED_ACC.ID = ACT.CREDIT_ACCOUNTID
JOIN
    ar_trans deb_art
ON
    deb_art.ref_center = act.center
    AND deb_art.ref_id = act.id
    AND deb_art.REF_SUBID = act.SUBID
    AND deb_art.REF_TYPE = 'ACCOUNT_TRANS'
JOIN
    account_receivables ar
ON
    ar.center = deb_art.center
    AND ar.id = deb_art.id
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
WHERE
    act.aggregated_transaction_center = :centerRef
    AND act.aggregated_transaction_id = :IdRef