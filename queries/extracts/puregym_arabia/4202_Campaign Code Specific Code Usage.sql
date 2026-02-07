SELECT
 cen.NAME as CENTER,
 p.FULLNAME,
 p.CENTER || 'p' || p.ID as Pref,
 p.ADDRESS1,
 p.ADDRESS2,
 p.ADDRESS3,
 p.ZIPCODE,
 longToDate(inv.TRANS_TIME) used_time,
 prg.NAME campaign_name,
 longToDate(cc.CREATION_TIME) codes_created,
 longToDate(prg.STARTTIME) campaign_start_time,
 prod.NAME,
 invl.TOTAL_AMOUNT,
 invl.QUANTITY,
 prg.NAME AS "Campaign",
 p.EXTERNAL_ID::bigint AS "ExternalId",
 longtodate(prg.ENDTIME) as CampaignStopDate,
 (CASE
    WHEN lower(prod.NAME) LIKE '%day pass%' THEN
      s.START_DATE
    ELSE
      NULL
 END) AS StartDateTrial,
 (CASE
    WHEN lower(prod.NAME) LIKE '%day pass%' THEN
      s.END_DATE
    ELSE
      NULL
 END) AS EndDateTrial,
 cc.CODE
 FROM
 INVOICES inv
 JOIN PERSONS p
 ON
 p.CENTER = inv.PAYER_CENTER
 AND p.ID = inv.PAYER_ID
 JOIN INVOICE_LINES_mt invl
 ON
 inv.CENTER = invl.CENTER
 AND inv.ID = invl.ID
 JOIN PRODUCTS prod
 ON
 invl.PRODUCTID = prod.ID
 AND invl.PRODUCTCENTER = prod.CENTER
 JOIN PRIVILEGE_USAGES pu
 ON
 pu.TARGET_SERVICE = 'InvoiceLine'
 AND pu.PRIVILEGE_TYPE = 'PRODUCT'
 AND pu.TARGET_CENTER = invl.CENTER
 AND pu.TARGET_ID = invl.ID
 AND pu.TARGET_SUBID = invl.SUBID
 JOIN CAMPAIGN_CODES cc
 ON
 pu.CAMPAIGN_CODE_ID = cc.ID
 AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
 JOIN PRIVILEGE_RECEIVER_GROUPS prg
 ON
 prg.ID = cc.CAMPAIGN_ID
 left join CENTERS cen
 on cen.ID = p.CENTER
 LEFT JOIN
     SPP_INVOICELINES_LINK sil
 ON
     sil.INVOICELINE_CENTER = invl.CENTER
     AND sil.INVOICELINE_ID = invl.ID
     AND sil.INVOICELINE_SUBID = invl.SUBID
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = sil.PERIOD_CENTER
     AND s.ID = sil.PERIOD_ID
 WHERE
 inv.TRANS_TIME BETWEEN CAST(datetolong(TO_CHAR(DATE (:from_date), 'YYYY-MM-DD')) AS bigint) 
AND CAST(datetolong(TO_CHAR(DATE (:to_date), 'YYYY-MM-DD')) AS bigint)+1000*60*60*24
 and cc.CODE = :code
 and prod.CENTER in (:scope)