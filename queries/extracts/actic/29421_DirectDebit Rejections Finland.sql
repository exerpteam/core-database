-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4330
SELECT
        ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PersonId,
        pr.*
FROM EXERP_RRT.AGREEMENTREF aref
LEFT JOIN PAYMENT_REQUESTS pr ON aref.AgreementRef = pr.FULL_REFERENCE
LEFT JOIN PAYMENT_ACCOUNTS pac ON pr.CENTER = pac.CENTER AND pr.ID = pac.ID
LEFT JOIN ACCOUNT_RECEIVABLES ar ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID