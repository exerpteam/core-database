-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
 art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
 'revert incorrect file' AS "Text",
 art.info,
 art.amount,
 art.status,
 longtodate(art.trans_time),
 act.text
 FROM
 ACCOUNT_RECEIVABLES ar
 JOIN
 AR_TRANS art
 ON
 art.center = ar.center
 AND art.id = ar.id
 JOIN
 ACCOUNT_TRANS act
 ON
 art.REF_CENTER = act.CENTER
 AND art.REF_ID = act.ID
 AND art.REF_SUBID = act.SUBID
 AND art.REF_TYPE = 'ACCOUNT_TRANS'
 WHERE
--art.info = '103-1095797'
--ar.ar_type = 5
art.amount in (-695,695)
--longtodate(art.trans_time) = '2023-04-04'
--and art.status = 'NEW'
AND longtodate(art.trans_time) > (:fradate)