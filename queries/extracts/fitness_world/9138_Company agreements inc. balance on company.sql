-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ca.CENTER                                                                                                                       AS company_center,
    ca.ID                                                                                                                           AS company_id,
    comp.LASTNAME                                                                                                                   AS company,
    ca.NAME                                                                                                                         AS agrrement,
    grants.sponsorship_name                                                                                                         AS sponsor_level,
    DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted') AS agreement_state,
    ar.balance,
    ccc.STARTDATE debt_case_start,
    ccc.AMOUNT,
    ean.TXTVALUE AS "EAN"
FROM
    FW.PERSONS comp
JOIN FW.COMPANYAGREEMENTS ca
ON
    comp.CENTER = ca.CENTER
    AND comp.ID = ca.ID
LEFT JOIN FW.CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = ca.CENTER
    AND ccc.PERSONID = ca.ID
    AND ccc.CLOSED = 0
    AND ccc.SUCCESSFULL = 0
    AND ccc.MISSINGPAYMENT = 1
JOIN FW.privilege_grants grants
ON
    ca.center = grants.granter_center
    AND ca.id = grants.granter_id
    AND ca.subid = grants.granter_subid
JOIN FW.ACCOUNT_RECEIVABLES ar
ON
    comp.center = ar.customerCenter
    AND comp.id = ar.customerID
    AND ar.AR_TYPE = 4
LEFT JOIN FW.PERSON_EXT_ATTRS ean
ON
    ean.PERSONCENTER = comp.CENTER
    AND ean.PERSONID = comp.ID
    AND ean.NAME = '_eClub_BillingNumber'
WHERE
    grants.granter_service = 'CompanyAgreement'
    AND grants.sponsorship_name = 'FULL'
GROUP BY
    ca.CENTER ,
    ca.ID ,
    comp.LASTNAME ,
    ca.NAME ,
    grants.sponsorship_name ,
    ca.STATE,
    ar.balance,
    ccc.STARTDATE,
    ccc.AMOUNT,
    ean.TXTVALUE
ORDER BY
    ca.center,
    ca.id,
    ca.state
