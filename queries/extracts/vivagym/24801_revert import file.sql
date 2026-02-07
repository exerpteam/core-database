SELECT
 ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
 art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
 'revert incorrect file' AS "Text",
 art.amount,
 act.text "text account trans"
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
 act.info = (:file_id) -- Payment Import File ID