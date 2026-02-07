SELECT
    p.CENTER || 'p' || p.ID pid,
    p.FIRSTNAME,
    p.LASTNAME,
    atts.TXTVALUE             old_system_id,
    nvl2(ar_debt.CENTER,1,0)  debt_case_in_exerp,
    SUM(art.UNSETTLED_AMOUNT) UNSETTLED_AMOUNT,
    SUM(art.AMOUNT)           ORIGINAL_DEBT,
    CASE
        WHEN SUM(art.UNSETTLED_AMOUNT) = 0
        THEN 1
        ELSE 0
    END AS DEBT_SETTLED
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
LEFT JOIN
    ACCOUNT_RECEIVABLES ar_debt
ON
    ar_debt.CUSTOMERCENTER = p.CENTER
    AND ar_debt.CUSTOMERID = p.ID
    AND ar_debt.AR_TYPE = 5
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
LEFT JOIN
    PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.ID
    AND atts.NAME = '_eClub_OldSystemPersonId'
WHERE
    ar.AR_TYPE = 4
    --AND p.CENTER = 24and p.id = 2537
    AND art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND art.EMPLOYEECENTER = 100
    AND art.EMPLOYEEID = 1
    AND art.REF_TYPE = 'ACCOUNT_TRANS'
    AND art.AMOUNT < 0
    AND ar.CENTER IN (22,
                      5,
                      19,
                      17,
                      12,
                      9,
                      28,
                      20,
                      8,
                      24,
                      15,
                      6,
                      11,
                      16,
                      75,
                      14 )
GROUP BY
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER ,
    p.ID ,
    atts.TXTVALUE,
    nvl2(ar_debt.CENTER,1,0)