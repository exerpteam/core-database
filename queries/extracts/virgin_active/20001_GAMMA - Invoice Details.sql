 SELECT
    p.CENTER || 'p' || p.ID "PERSONID",
	CASE atts.NAME WHEN '_eClub_Comment' THEN 'COMMENT' WHEN '_eClub_InvoiceAddress1' THEN 'ADDRESS1' WHEN '_eClub_InvoiceAddress2' THEN 'ADDRESS2' WHEN '_eClub_InvoiceCity' THEN 'CITY' WHEN '_eClub_InvoiceCoName' THEN 'CO_NAME' WHEN '_eClub_InvoiceCountry' THEN 'COUNTRY' WHEN '_eClub_InvoiceEmail' THEN 'EMAIL' WHEN '_eClub_InvoiceZipCode' THEN 'ZIPCODE' END "INVOICEDETAIL",
    atts.TXTVALUE "INVOICEDETAILVALUE"
 FROM
         CENTERS c
   JOIN PERSON_EXT_ATTRS atts
         on atts.PERSONCENTER = c.ID
 JOIN PERSONS oldP
 ON
     oldP.CENTER = atts.PERSONCENTER
     AND oldP.ID = atts.PERSONID
 JOIN PERSONS p
 ON
     p.CENTER = oldP.CURRENT_PERSON_CENTER
     AND p.ID = oldP.CURRENT_PERSON_ID
 LEFT JOIN PERSON_CHANGE_LOGS pcl
 ON
     pcl.PERSON_CENTER = p.CENTER
     AND pcl.PERSON_ID = p.ID
     AND pcl.CHANGE_ATTRIBUTE = atts.NAME
 WHERE
     atts.NAME IN ('_eClub_Comment','_eClub_InvoiceAddress1','_eClub_InvoiceAddress2','_eClub_InvoiceCity','_eClub_InvoiceCoName','_eClub_InvoiceCountry','_eClub_InvoiceEmail','_eClub_InvoiceZipCode')
 and p.SEX != 'C' AND LENGTH(atts.TXTVALUE)>0
 and c.COUNTRY = 'IT'
 --and c.ID = 105
 GROUP BY
         p.center,
     p.ID,
     atts.NAME,
    atts.TXTVALUE
 ORDER BY p.CENTER, p.ID
