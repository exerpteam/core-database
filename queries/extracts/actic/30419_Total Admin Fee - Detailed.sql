SELECT ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID
FROM
  AR_TRANS art
JOIN
  ACCOUNT_RECEIVABLES ar
ON
  ar.CENTER = art.CENTER
  AND ar.id = art.ID  
  AND ar.AR_TYPE = 4
WHERE
 art.REF_TYPE = 'INVOICE'
 AND art.CENTER in (:Scope)
 AND art.AMOUNT = -99
 AND TRIM(art.TEXT) = 'Årlig administrasjonsavgift for medlemskap'
 AND art.ENTRY_TIME > :To_Date
 AND art.ENTRY_TIME <  :To_Date + 86400000
