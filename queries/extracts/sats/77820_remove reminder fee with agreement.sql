 SELECT
 ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
 art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
 'credit reminder fee' AS "Text",
 art.amount,
 art.text,
 pa.CLEARINGHOUSE,
 longtodate(art.entry_time)
 FROM
 AR_TRANS art
 JOIN
 ACCOUNT_RECEIVABLES ar
 ON
 art.center = ar.center
 AND art.id = ar.id
 JOIN
     PAYMENT_AGREEMENTS pa
 ON
     pa.center = ar.center
 AND pa.id = ar.id
 WHERE
 art.center in (:scope)
 and
 art.entry_time between :datefrom and :dateto
 and
 art.TEXT = 'Payment Reminder'
 and
 pa.CLEARINGHOUSE = 3412
