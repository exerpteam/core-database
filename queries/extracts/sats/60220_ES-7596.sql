SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID                                                              AS "Current Member ID",
    DECODE(p.CENTER||p.ID, ar.CUSTOMERCENTER||ar.CUSTOMERID , 'Not transferred' , p.CENTER||'p'||p.ID) AS "Transferred Member ID",
    pea.TXTVALUE                                                                                       AS "BRP to SATS KID",
    pea2.TXTVALUE                                                                                      AS "FreshFitness to SATS KID",
    pa.EXAMPLE_REFERENCE                                                                               AS "Orginial PaymentAgreementRef",
    DECODE(pag2.EXAMPLE_REFERENCE, pa.EXAMPLE_REFERENCE, 'Original Agreement' ,pag2.EXAMPLE_REFERENCE) AS "Current PaymentAgreementRef"
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pa.CENTER
    AND ar.ID = pa.ID
JOIN
    PERSONS p
ON
    p.CURRENT_PERSON_CENTER = ar.CUSTOMERCENTER
    AND p.CURRENT_PERSON_ID = ar.CUSTOMERID
LEFT JOIN
    SATS.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID = p.id
    AND pea.NAME = 'BRP_AGREEMENT_REF'
LEFT JOIN
    SATS.PERSON_EXT_ATTRS pea2
ON
    pea2.PERSONCENTER = p.center
    AND pea2.PERSONID = p.id
    AND pea2.NAME = 'FF_AGREEMENT_REF'
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    SATS.PAYMENT_AGREEMENTS pag2
ON
    pag2.CENTER = pac.ACTIVE_AGR_CENTER
    AND pag2.ID = pac.ACTIVE_AGR_ID
    AND pag2.SUBID = pac.ACTIVE_AGR_SUBID
WHERE
    pa.SUBID = 1
    AND pea.TXTVALUE||pea2.TXTVALUE IS NOT NULL
    AND pea.TXTVALUE IN ($$KID$$)
    OR pea2.TXTVALUE IN ($$KID$$)