 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$StartDate$$                      AS GiftcardPurchaseTimeFrom,
             ($$EndDate$$ + 86400 * 1000) - 1 AS GiftcardPurchaseTimeTo
         
     )
 SELECT
      longtodatec(gc.purchase_time ,gc.center) "Gift card purchased date",
     gc.expirationdate "Gift card expiry date",
     pd.name "Gift card product",
     gc.amount "Giftcard amount",
     gc.amount_remaining "Remaining amount",
     gc.payer_center||'p'||gc.payer_id "Payer ID",
     gc.center||'gc'||gc.id "Gift card ID",
     e.Identity "Reference",
     CASE e.IDMETHOD  WHEN 1 THEN  'BARCODE'  WHEN 2 THEN  'MAGNETIC_CARD'  WHEN 3 THEN  'SSN'  WHEN 4 THEN  'RFID_CARD'  WHEN 5 THEN  'PIN'  WHEN 6 THEN 
     'ANTI DROWN'  WHEN 7 THEN  'QRCODE'  ELSE 'Undefined' END AS "Type",
     CASE gc.STATE  WHEN 0 THEN  'ISSUED'  WHEN 1 THEN  'CANCELLED'  WHEN 2 THEN  'EXPIRED'  WHEN 3 THEN  'USED'  WHEN 4 THEN  'PARTIAL USED' END AS
     "Gift card state",
  (select inv.employee_center||'emp'||inv.employee_id  from invoice_lines_mt imt join invoices inv on inv.id=imt.id and inv.center=imt.center where gc.INVOICELINE_CENTER = imt.center and gc.INVOICELINE_id = imt.id and gc.INVOICELINE_subid=imt.subid ) "Sale employee of gift card",
     CASE WHEN gc.invoiceline_center IS NOT NULL THEN  gc.invoiceline_center||'inv'||gc.invoiceline_id ELSE NULL END
     "Invoice ID of the gift card sale",
     CASE WHEN gcu.transaction_center IS NOT NULL THEN  gcu.transaction_center||'acc'||gcu.transaction_id||'tr'||
     gcu.transaction_subid ELSE NULL END "Gift card usage account transaction ID",
     longtodatec(gcu.time,gc.center) "Usage time",
   gcu.amount "Total amount used",
     imt.total_amount "Usage amount (sale)",
     gcu.type "Usage source" ,
      case
     when imt.productcenter is null and gcu.amount is not null then 'Payment into account,'||crt.customercenter||'p'||crt.customerid
     when imt.productcenter is not null and gcu.amount is not null
     then
    (
         SELECT
             prd1.name
         FROM
             products prd1
         WHERE
             prd1.center= imt.productcenter
         AND prd1.id= imt.productid
    )
         end "Products sold",
          imt.quantity "Product quantity of usage",
    CASE WHEN  CAST(inv.center AS VARCHAR)||CAST(inv.id AS VARCHAR) IS NOT NULL THEN inv.center||'inv'||inv.id ELSE NULL END "Invoice ID of Products sold",
 CASE WHEN CAST(gcu.Employee_center AS VARCHAR)||CAST(gcu.employee_id AS VARCHAR) IS NOT NULL THEN gcu.employee_center ||'emp'||gcu.employee_id  ELSE NULL END
     "Sale employee of usage"
 --,act.text  , art.amount "Deposit amount"
 FROM
     gift_cards gc
 cross join  params
 JOIN
     products pd
 ON
     pd.id = gc.product_id
 AND pd.center = gc.product_center
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK pgl
 ON
     pgl.product_center = pd.center
 AND pgl.product_id = pd.id
 JOIN
     product_group pg
 ON
     pg.id = pgl.product_group_id
 AND pg.id in (34801,39601,45401) --GIFT CARD CASH BACK, Gift CARDS Natale 2021. Gift Card Natale 2022
 JOIN
     ENTITYIDENTIFIERS e
 ON
     gc.center = e.ref_center
 AND gc.id = e.ref_id
 and e.ref_type= 5 --gift card
 JOIN
     centers cen
 ON
     gc.center=cen.id
 LEFT JOIN
     gift_card_usages gcu
 ON
     gcu.gift_card_center = gc.center
 AND gcu.gift_card_id = gc.id
 left JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = gcu.TRANSACTION_CENTER
 AND act.ID = gcu.TRANSACTION_ID
 AND act.SUBID = gcu.TRANSACTION_SUBId
 left JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     crt.GLTRANSCENTER = act.CENTER
 AND crt.GLTRANSID = act.ID
 AND crt.GLTRANSSUBID = act.SUBID
 AND gcu.TYPE = 'CashRegister'
 left JOIN
     invoices inv
 ON
     crt.paysessionid = inv.paysessionid
 AND inv.CASHREGISTER_CENTER = crt.CENTER
 AND inv.CASHREGISTER_ID = crt.id
 left JOIN
     invoice_lines_mt imt
 ON
     imt.id=inv.id
 AND imt.center = inv.center
 WHERE
     cen.country='IT' -- Italy Scope
 and cen.id in ($$Scope$$)
 AND gc.purchase_time >= CAST(params.GiftcardPurchaseTimeFrom AS BIGINT)
 AND gc.purchase_time <= CAST(params.GiftcardPurchaseTimeTo AS BIGINT)
