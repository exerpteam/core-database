SELECT
    p.CENTER||'p'||p.ID   AS "MemberId",
    p.FIRSTNAME           AS "FirstName",
    p.LASTNAME            AS "LastName",
    cc.CREDITOR_ID        AS "Creditor",
    pag.REF               AS "ClubleadRef",
    CASE
        WHEN rel.CENTER IS NULL
        THEN ''
        ELSE rel.CENTER||'p'||rel.ID
    END AS "OtherPayer"
FROM
    PERSONS p
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4 -- Exclde CASH accounts
LEFT JOIN
    PAYMENT_ACCOUNTS pa
ON
    pa.CENTER = ar.CENTER
    AND pa.ID = ar.ID
LEFT JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pa.ACTIVE_AGR_CENTER
    AND pag.ID = pa.ACTIVE_AGR_ID
    AND pag.SUBID = pa.ACTIVE_AGR_SUBID
    AND pag.STATE IN (1,2,13,4) -- Exclude payment agreements that are not OK , CREATED , SENT , NOT NEEDED (INVOICE)
LEFT JOIN
    CLEARINGHOUSE_CREDITORS cc
ON
    pag.CREDITOR_ID = cc.CREDITOR_ID
    AND pag.CLEARINGHOUSE = cc.CLEARINGHOUSE
LEFT JOIN
    RELATIVES rel
ON
    rel.RELATIVECENTER = p.CENTER
    AND rel.RELATIVEID = p.ID
    AND rel.RTYPE = 12 -- 'Other payer' relation type
    AND rel.STATUS = 1 -- Exclude inactive relations
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,7,8)
WHERE
    p.CENTER = 524 -- Only account for members in Oslo Holmlia club
    AND p.STATUS IN (1,3) -- Only account for ACTIVE or Temporary Inactive members
    
