-- The extract is extracted from Exerp on 2026-02-08
-- Extract Upcomingpayment to be used in ExtractAPI.
/*SELECT * FROM INVOICE_LINES_MT il WHERE
PERSON_CENTER = 45 AND
PERSON_ID = 2067*/

SELECT * FROM INVOICES WHERE ROWNUM < 1000
