-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT usages.*,
 CASE WHEN creditNotes.AMOUNT IS NOT NULL
 THEN creditNotes.AMOUNT
 ELSE scontiCash.sconto
 END as importoAumentato
  from (
 SELECT
 LongToDate(g.PURCHASE_TIME) as dataVendita,
 giftProd.NAME as tipoGift,
 CONCAT(CONCAT(CAST(g.PAYER_CENTER as CHAR(3)),'p'), CAST(g.PAYER_ID as VARCHAR(6))) as idPagante,
 g.AMOUNT as prezzoVendita,
 payer.FULLNAME as nomePagante,
 usages.idUtilizzatore,
 usages.nomeUtilizzatore,
 usages.prodotto,
 usages.dataUtilizzo,
 SUM(usages.prezzo) as costoProdotto,
 MAX(usages.amount) as importoUtilizzato
 FROM GIFT_CARDS g
 INNER JOIN
 CENTERS c
 ON
 c.ID = g.CENTER
 INNER JOIN PRODUCTS giftProd
 ON
 giftProd.ID = g.PRODUCT_ID
 AND
 giftProd.CENTER = g.PRODUCT_CENTER
 INNER JOIN PERSONS payer
 ON payer.ID = g.PAYER_ID
 AND
 payer.CENTER = g.PAYER_CENTER
 LEFT OUTER JOIN
  (
 select
 g.CENTER,
 G.ID,
 LOngToDate(g.PURCHASE_TIME) as dataVendita,
 giftProd.NAME as tipoGift,
 g.AMOUNT as prezzoVendita,
 CONCAT(CONCAT(CAST(g.PAYER_CENTER as CHAR(3)),'p'), CAST(g.PAYER_ID as VARCHAR(6))) as idPagante,
 payer.FULLNAME as nomePagante,
 CONCAT(CONCAT(CAST(crt.CUSTOMERCENTER as CHAR(3)),'p'), CAST(crt.CUSTOMERID as VARCHAR(6))) as idUtilizzatore,
 usr.FULLNAME as nomeUtilizzatore,
 REPLACE(REPLACE(p.NAME, 'Creation ',''),'ProRata ','') as prodotto,
 LongToDate(u.TIME) as dataUtilizzo,
 invl.TOTAL_AMOUNT as prezzo,
 u.AMOUNT,
 u.ID as idUsage
 FROM GIFT_CARDS g
 INNER JOIN
 CENTERS c
 ON
 c.ID = g.CENTER
 INNER JOIN PRODUCTS giftProd
 ON
 giftProd.ID = g.PRODUCT_ID
 AND
 giftProd.CENTER = g.PRODUCT_CENTER
 INNER JOIN PERSONS payer
 ON payer.ID = g.PAYER_ID
 AND
 payer.CENTER = g.PAYER_CENTER
 INNER JOIN
 GIFT_CARD_USAGES u
 ON
 g.ID = u.GIFT_CARD_ID
 AND
 g.CENTER = u.GIFT_CARD_CENTER
 INNER JOIN
 ACCOUNT_TRANS act
 ON
 act.SUBID = u.TRANSACTION_SUBID
 AND
 act.ID = u.TRANSACTION_ID
 AND
 act.CENTER = u.TRANSACTION_CENTER
 INNER JOIN
 CASHREGISTERTRANSACTIONS
  crt
 ON
 crt.GLTRANSCENTER = act.CENTER
 AND
 crt.GLTRANSID = act.ID
 AND
 crt.GLTRANSSUBID = act.SUBID
 INNER JOIN
 CASHREGISTERS cr
 ON
 cr.CENTER = crt.CENTER
 AND cr.ID = crt.ID
 INNER JOIN INVOICES inv
 ON
  crt.PAYSESSIONID = inv.PAYSESSIONID
     AND crt.CRCENTER = inv.CASHREGISTER_CENTER
     AND crt.CRID = inv.CASHREGISTER_ID
 INNER JOIN INVOICELINES invl
 ON invl.CENTER = inv.CENTER
 AND
 invl.ID = inv.ID
 INNER JOIN
 PRODUCTS p
 ON
 p.CENTER = invl.PRODUCTCENTER
 AND
 p.ID = invl.PRODUCTID
 INNER JOIN
 PERSONS usr
 ON
 crt.CUSTOMERCENTER = usr.CENTER
 AND
 crt.CUSTOMERID = usr.ID
 WHERE
 c.COUNTRY = 'IT'
 AND
 LongToDate(u.TIME) BETWEEN CAST($$dataDa$$ AS DATE) AND CAST($$dataA$$ AS DATE) + interval '1' day
 AND invl.TOTAL_AMOUNT > 0
 UNION ALL
 select
 g.CENTER,
 G.ID,
 LOngToDate(g.PURCHASE_TIME) as dataVendita,
 giftProd.NAME as tipoGift,
 g.AMOUNT as prezzoVendita,
 CONCAT(CONCAT(CAST(g.PAYER_CENTER as CHAR(3)),'p'), CAST(g.PAYER_ID as VARCHAR(6))) as idPagante,
 payer.FULLNAME AS   nomePagante,
 CONCAT(CONCAT(CAST(usr.CENTER as CHAR(3)),'p'), CAST(usr.ID as VARCHAR(6))) as idUtilizzatore,
 usr.FULLNAME as nomeUtilizzatore,
 'Credito sull''abbonamento' as prodotto,
 LongToDate(u.TIME) as dataUtilizzo,
 art.AMOUNT as prezzo,
 u.AMOUNT,
 u.id as idUsage
 FROM GIFT_CARDS g
 INNER JOIN PRODUCTS giftProd
 ON
 giftProd.ID = g.PRODUCT_ID
 AND
 giftProd.CENTER = g.PRODUCT_CENTER
 INNER JOIN PERSONS payer
 ON payer.ID = g.PAYER_ID
 and
 payer.CENTER = g.PAYER_CENTER
 INNER JOIN CENTERS c
 ON c.ID = payer.CENTER
 INNER JOIN
 GIFT_CARD_USAGES u
 ON
 g.ID = u.GIFT_CARD_ID
 AND
 g.CENTER = u.GIFT_CARD_CENTER
 INNER JOIN
 ACCOUNT_TRANS act
 ON
 act.SUBID = u.TRANSACTION_SUBID
 AND
 act.ID = u.TRANSACTION_ID
 AND
 act.CENTER = u.TRANSACTION_CENTER
 INNER JOIN
 CASHREGISTERTRANSACTIONS
  crt
 ON
 crt.GLTRANSCENTER = act.CENTER
 AND
 crt.GLTRANSID = act.ID
 AND
 crt.GLTRANSSUBID = act.SUBID
 INNER JOIN
 CASHREGISTERS cr
 ON
 cr.CENTER = crt.CENTER
 AND cr.ID = crt.ID
 INNER JOIN AR_TRANS art
 ON art.CENTER = crt.ARTRANSCENTER
 AND
 art.ID = crt.ARTRANSID
 AND
 art.SUBID = crt.ARTRANSSUBID
 LEFT OUTER JOIN ACCOUNT_RECEIVABLES ar
 ON ar.ID = art.ID
 AND ar.CENTER = art.CENTER
 INNER JOIN PERSONS usr
 ON
  ar.CUSTOMERCENTER = usr.CENTER
     AND ar.CUSTOMERID = usr.ID
 WHERE
 c.COUNTRY = 'IT'
 AND
 LongToDate(u.TIME) BETWEEN CAST($$dataDa$$ AS DATE) AND CAST($$dataA$$ AS DATE) + interval '1' day) usages
 ON
 g.ID = usages.ID
 AND
 g.CENTER = usages.CENTER
 GROUP BY
 LongToDate(g.PURCHASE_TIME),
 giftProd.NAME,
 CONCAT(CONCAT(CAST(g.PAYER_CENTER as CHAR(3)),'p'), CAST(g.PAYER_ID as VARCHAR(6))),
 g.AMOUNT,
 payer.FULLNAME,
 usages.idUtilizzatore,
 usages.nomeUtilizzatore,
 usages.prodotto,
 usages.dataUtilizzo,
 usages.idUsage
 ) usages
 LEFT OUTER JOIN
 (select
 CONCAT(CONCAT(CAST(crl.PERSON_CENTER as CHAR(3)),'p'), CAST(crl.PERSON_ID as VARCHAR(6))) as personId, ar.AMOUNT,
 LongToDate(ar.ENTRY_TIME) AS dataUtilizzo
  from AR_TRANS ar
 INNER JOIN
 CREDIT_NOTE_LINES crl
 ON
 ar.REF_ID = crl.ID
 and
 ar.REF_CENTER = crl.CENTER
 INNER JOIN CENTERS
 C
 ON c.ID = crl.PERSON_CENTER
 WHERE ar.TEXT = 'FreeCreditnote: Gift Card Natale'
 AND c.COUNTRY  = 'IT'
 AND ar.REF_TYPE = 'CREDIT_NOTE'
 AND LongToDate(ar.ENTRY_TIME) BETWEEN CAST($$dataDa$$ AS DATE) AND CAST($$dataA$$ AS DATE) + interval '1' day)
 creditNotes
 ON usages.idUtilizzatore = creditNotes.personId
 LEFT OUTER JOIN
 (
 SELECT
         table1.personId,
         table1.dataUtilizzo,
         table1.PRICE_MODIFICATION_AMOUNT as sconto
 FROM
         (SELECT
          p.CENTER,
 CONCAT(CONCAT(CAST(p.CENTER as CHAR(3)),'p'), CAST(p.ID as VARCHAR(6))) as personId,
                                 LongToDate(pu.USE_TIME) as dataUtilizzo,
                                 invl.TOTAL_AMOUNT as importo,
                                 invl1.TOTAL_AMOUNT as importoCreation,
                                 invl.PRODUCT_NORMAL_PRICE  as prezzoNormale,
                                 invl1.PRODUCT_NORMAL_PRICE  as prezzoNormaleCreation,
                                 cc.CODE AS Code,
                 pp.PRICE_MODIFICATION_AMOUNT
         FROM CAMPAIGN_CODES cc
         JOIN PRIVILEGE_USAGES pu ON pu.CAMPAIGN_CODE_ID = cc.ID AND pu.TARGET_SERVICE in ('InvoiceLine','SubscriptionPrice') AND pu.PRIVILEGE_TYPE = 'PRODUCT'
         JOIN PRODUCT_PRIVILEGES pp
         ON pp.ID = pu.PRIVILEGE_ID
                 JOIN PERSONS p
         ON
                         p.ID = pu.PERSON_ID
                 AND
                         p.CENTER = pu.PERSON_CENTER
         LEFT JOIN PRIVILEGE_GRANTS pgra ON pgra.ID = pu.GRANT_ID
         LEFT JOIN PRIVILEGE_SETS priset ON priset.ID = pgra.PRIVILEGE_SET
         LEFT JOIN STARTUP_CAMPAIGN sc ON sc.id = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE ='STARTUP'
         LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg ON prg.ID = cc.CAMPAIGN_ID AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
         LEFT JOIN INVOICELINES invl ON invl.CENTER = pu.TARGET_CENTER AND invl.ID = pu.TARGET_ID AND invl.SUBID = pu.TARGET_SUBID
         LEFT JOIN INVOICES inv ON inv.CENTER = invl.CENTER AND inv.ID = invl.ID
         LEFT JOIN SUBSCRIPTION_PRICE sp ON sp.ID = pu.TARGET_ID AND pu.TARGET_SERVICE = 'SubscriptionPrice'
         LEFT JOIN SUBSCRIPTIONS s ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
 LEFT JOIN INVOICELINES invl1 ON invl1.CENTER = s.INVOICELINE_CENTER AND invl1.ID = s.INVOICELINE_ID AND invl1.SUBID = s.INVOICELINE_SUBID
                 WHERE
                 LongToDate(pu.USE_TIME) BETWEEN CAST($$dataDa$$ AS DATE) AND CAST($$dataA$$ AS DATE) + interval '1' day
                  ) table1
 LEFT JOIN CENTERS cen ON cen.ID = table1.CENTER
 WHERE cen.COUNTRY = 'IT'
 AND
 (
 table1.CODE LIKE 'S159%'
 OR
 table1.CODE LIKE 'S495%'
 OR
 table1.CODE LIKE 'S795%'
 OR
 table1.CODE LIKE 'S99%'
 )
 and table1.importo IS NOT NULL
 ) scontiCash
 ON
 scontiCash.personid = usages.idUtilizzatore
 order by usages.idPagante, usages.idUtilizzatore
