

SELECT
     cc.CENTER || 'cc' || cc.ID || 'id' || cc.SUBID id,
     TO_CHAR(longtodate(inv.TRANS_TIME), 'DD-MM-YYYY') salesdate,
     prod.NAME prod,
     pg.NAME prodgroup,
     p.CENTER || 'p' || p.ID personId,
     TO_CHAR(longtodate(cc.VALID_FROM), 'DD-MM-YYYY') validFrom,
     TO_CHAR(longtodate(cc.VALID_UNTIL), 'DD-MM-YYYY') validTo,
     invl.TOTAL_AMOUNT / invl.QUANTITY amountInclVat,
     (invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT * invl.RATE)) / invl.QUANTITY amountExclVat,
     cc.CLIPS_INITIAL,
     (((invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT * invl.RATE)) / invl.QUANTITY)/ cc.CLIPS_INITIAL) clip_value,
     COALESCE(cc_usage.usages, 0) realized_clips,
     cc.CLIPS_INITIAL - COALESCE(cc_usage.usages, 0) deferred_clips,
     COALESCE(cc_usage.usages, 0) * (((invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT * invl.RATE)) / invl.QUANTITY)/
     cc.CLIPS_INITIAL) realized_Amount,
     least((cc.CLIPS_INITIAL - COALESCE(cc_usage.usages, 0))* (((invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT * invl.RATE)) /
     invl.QUANTITY)/ cc.CLIPS_INITIAL), (invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT * invl.RATE))) deferred_Amount,
         longtodate(inv.TRANS_TIME),
cc.assigned_staff_id AS "TrainerAssigned"

 FROM
     CLIPCARDS cc
 JOIN
     INVOICELINES invl
 ON
     invl.CENTER = cc.INVOICELINE_CENTER
     AND invl.ID = cc.INVOICELINE_ID
     AND invl.SUBID = cc.INVOICELINE_SUBID
 JOIN
     INVOICES inv
 ON
     invl.CENTER = inv.CENTER
     AND invl.ID = inv.ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
 JOIN
     PERSONS p
 ON
     p.CENTER = cc.OWNER_CENTER
     AND p.ID = cc.OWNER_ID
 LEFT JOIN
     (
         SELECT
             ccu.CARD_CENTER,
             ccu.CARD_ID,
             ccu.CARD_SUBID,
             -SUM(ccu.CLIPS) usages
         FROM
             HP.CARD_CLIP_USAGES ccu
         WHERE
             ccu.STATE = 'ACTIVE'
             AND ccu.TIME < :CutDate + (1000*60*60*24)
             -- AND ccu.TIME < datetolong('2013-02-28 00:00') + (1000*60*60*24)
         GROUP BY
             ccu.CARD_CENTER,
             ccu.CARD_ID,
             ccu.CARD_SUBID ) cc_usage
 ON
     cc_usage.CARD_CENTER = cc.CENTER
     AND cc_usage.CARD_ID = cc.ID
     AND cc_usage.CARD_SUBID = cc.SUBID
 WHERE
     cc.CENTER IN (:Scope)
     --cc.CENTER IN (14)
     AND cc.CANCELLED = 0
     AND inv.TRANS_TIME < :CutDate + (1000*60*60*24)
     -- AND inv.TRANS_TIME < datetolong('2013-02-28 00:00') + (1000*60*60*24)
     AND cc_usage.usages < cc.CLIPS_INITIAL
 ORDER BY
         inv.TRANS_TIME
