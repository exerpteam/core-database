SELECT DISTINCT
    longToDate(art.TRANS_TIME) debt_migarted,
    art.AMOUNT,
    art.TEXT,
    atts.TXTVALUE                             cc_id,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID exerp_id,
    nvl2(cc.CENTER,1,0)                       cash_collection_case_in_exerp,
    cc.AMOUNT                                 cash_collection_case_amount,
    ar.BALANCE                                payment_account_balance
FROM
    AR_TRANS art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.id = art.id
LEFT JOIN
    PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = ar.CUSTOMERCENTER
    AND atts.PERSONID = ar.CUSTOMERID
    AND atts.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = ar.CUSTOMERCENTER
    AND cc.PERSONID = ar.CUSTOMERID
    AND cc.CLOSED = 0
    AND cc.SUCCESSFULL = 0
WHERE
    art.TEXT LIKE '%CCTransID=%'
 and ar.center in (:scope)