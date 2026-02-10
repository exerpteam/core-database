-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
 art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
 'credit reminder fee' AS "Text",
 art.amount,
 art.text,
 longtodate(art.entry_time)
 FROM
 AR_TRANS art
 JOIN
 ACCOUNT_RECEIVABLES ar
 ON
 art.center = ar.center
 AND art.id = ar.id
 WHERE
 art.center in (:scope)
 and
 art.entry_time between :datefrom and :dateto
 and
 art.TEXT = 'Payment Reminder'
 -- art.text = 'Betaling via indbetalingskort'
