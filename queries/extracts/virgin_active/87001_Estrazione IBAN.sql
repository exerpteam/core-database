-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    pa.IBAN
FROM PAYMENT_AGREEMENTS pa
WHERE pa.IBAN IS NOT NULL;
