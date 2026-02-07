-- This is the version from 2026-02-05
-- ST - 1473 Refund - Step 1 - SYDBANK with ext. (FRESH)
SELECT
    payer.center
  , payer.id
  , pag.BANK_REGNO
  , pag.BANK_ACCNO
  ,pea.txtvalue
  , - art.amount AS REFUND_AMOUNT
  , MAX('"CMBO","4928008711","' || nvl2(pea.txtvalue,replace(pea.txtvalue,',',''),pag.BANK_REGNO ||  pag.BANK_ACCNO) || '","' || to_char(-art.AMOUNT,'FM9999999999990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '","","DKK","N","","","","","","N","","","","","","","Refund ' || payer.center || 'p' || payer.id || '","","FW Refundering","","","","' ||
    payer.center || 'p' || payer.id || '","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","' || payer.FULLNAME || '","' || payer.ADDRESS1 || '","","' || payer.ZIPCODE || '","' || payer.CITY ||
    '","","","","","","","","","","","",""') line
FROM
    FW.AR_TRANS art
JOIN
    FW.ACCOUNT_RECEIVABLES ar
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN
    FW.PERSONS payer
ON
    ar.CUSTOMERCENTER = payer.center
    AND ar.CUSTOMERID = payer.id
LEFT JOIN
    FW.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.id = ar.id
LEFT JOIN
    FW.PAYMENT_AGREEMENTS pag
ON
    pag.center = pac.ACTIVE_AGR_CENTER
    AND pag.id = pac.ACTIVE_AGR_ID
    AND pag.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    FW.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = payer.center
    AND pea.PERSONID = payer.id
    AND pea.NAME = 'ACCOUNT_INFO_WEB'
    AND pea.txtvalue != ','
WHERE

    art.center >= (:center_from)
    AND art.center <= (:center_to)
    AND art.ENTRY_TIME BETWEEN :trans_date AND (
        :trans_date + 24 * 3600 * 1000)
    AND art.TEXT = :trans_text
    
      
GROUP BY
    payer.center
  , payer.id
  , - art.amount
  , pea.TXTVALUE
  , pag.BANK_REGNO
  , pag.BANK_ACCNO  
