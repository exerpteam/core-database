-- The extract is extracted from Exerp on 2026-02-08
--  
  -- Parameters: scope(SCOPE)
 SELECT
   x.*,
   COALESCE(last_usage.TARGET_CENTER, x.CENTER) AS LAST_USED_CENTER,
   /*TO_CHAR(LONGTODATEC(
   (
         SELECT
                 MAX(ccu.TIME)
         FROM CARD_CLIP_USAGES ccu
         WHERE
                 ccu.CARD_CENTER = x.center
                 AND ccu.CARD_ID = x.id
                 AND ccu.CARD_SUBID = x.subid
   ),x.center), 'YYYY/MM/DD HH24:MI') AS LAST_USAGE_DATE,*/
   (
         SELECT
                 ccu2.DESCRIPTION
         FROM CARD_CLIP_USAGES ccu2
         WHERE
                 ccu2.CARD_CENTER = x.center
                 AND ccu2.CARD_ID = x.id
                 AND ccu2.CARD_SUBID = x.subid
                 AND ccu2.TIME =
         (
                 SELECT
                         MAX(ccu.TIME)
                 FROM CARD_CLIP_USAGES ccu
                 WHERE
                         ccu.CARD_CENTER = x.center
                         AND ccu.CARD_ID = x.id
                         AND ccu.CARD_SUBID = x.subid
         )
   ) AS LAST_USAGE_DESCRIPTION
 FROM
 (
 SELECT DISTINCT
 per.external_id "Persons external ID",
     c.center                center,
     c.id                    id,
     c.subid                 subid,
     c.owner_center          owner_center,
     c.owner_id              owner_id,
     pea_oldid.txtvalue               AS OLD_MEMBERNUMBER,
     c.clips_left,
     c.clips_initial,
     REPLACE(CASE cen.COUNTRY WHEN 'SE' THEN cast(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)),2) as text) WHEN 'FI' THEN CAST
     (ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)),2) as text) ELSE cast(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)
     , 2) as text) END,'.',',')as price_per_clip_card,
     REPLACE(CASE cen.COUNTRY WHEN 'SE' THEN cast(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(invl.RATE,0)),2) as text) WHEN 'FI' THEN 
     cast(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(invl.RATE,0)),2)as text) ELSE cast(ROUND(invls.TOTAL_AMOUNT /
     invls.QUANTITY, 2) as text) END,'.',',')as price_per_clip_card_spons,
     CASE invls.PERSON_CENTER || 'p' || invls.PERSON_ID WHEN 'p' THEN NULL ELSE invls.PERSON_CENTER || 'p' ||
     invls.PERSON_ID END                  pid_spons,
     LongToDate(c.valid_until) valid_until,
     p.name,
     p.ptype,
     CASE  WHEN insp.id IS NULL THEN 'No' ELSE 'Yes' END                                 AS "Installment Plan",
     CASE  WHEN insp.id IS NULL THEN '' ELSE insp.person_center ||'p'||insp.person_id END AS "Installment Plan on Person",
     insp.INSTALLEMENTS_COUNT                                        AS "Total Installments",
     COALESCE(insp.INSTALLEMENTS_COUNT, 0) - COALESCE(ar_per.ar_trans_count,0) AS "Total Inst. paid",
     COALESCE(ar_per.ar_trans_count,0)                                    AS "Total Inst. unpaid",
     CASE
         WHEN CASE  WHEN insp.id IS NULL THEN 'No' ELSE 'Yes' END = 'Yes'
         AND invl.TOTAL_AMOUNT> 0
         THEN ROUND(((invl.TOTAL_AMOUNT - COALESCE(ABS(ar_per.ar_trans_amount), 0))/invl.QUANTITY), 2)
         ELSE 0
     END AS "Total Inst. paid amount",
     CASE
         WHEN CASE  WHEN insp.id IS NULL THEN 'No' ELSE 'Yes' END = 'Yes'
         AND invl.TOTAL_AMOUNT> 0
         THEN COALESCE(ABS(ar_per.ar_trans_amount)/invl.QUANTITY, 0)
         ELSE 0
     END AS "Total Inst. unpaid amount"
 FROM
     CLIPCARDS c
 JOIN
     products p
 ON
     p.center = c.center
 AND p.id = c.id
 AND p.center NOT IN(570,571,581)
 Join PRODUCT_AND_PRODUCT_GROUP_LINK ppl
 on p.center = ppl.product_center
 and
 p.id = ppl.product_id
 join
 PRODUCT_GROUP pg
 on
 ppl.PRODUCT_GROUP_ID = pg.id
 join persons per on per.center = c.owner_center and per.id = c.owner_id
 LEFT JOIN
     PERSON_EXT_ATTRS pea_oldid
 ON
     pea_oldid.PERSONCENTER = c.owner_center
 AND pea_oldid.PERSONID = c.owner_id
 AND pea_oldid.name = '_eClub_OldSystemPersonId'
 LEFT JOIN
     INVOICELINES invl
 ON
     invl.CENTER = c.INVOICELINE_CENTER
 AND invl.ID = c.INVOICELINE_ID
 AND invl.SUBID = c.INVOICELINE_SUBID
 LEFT JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
 AND inv.ID = invl.ID
 LEFT JOIN
     INVOICELINES invls
 ON
     invls.CENTER = inv.SPONSOR_INVOICE_CENTER
 AND invls.ID = inv.SPONSOR_INVOICE_ID
 AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
 LEFT JOIN
     INSTALLMENT_PLANS insp
 ON
     insp.ID = invl.installment_plan_id
 LEFT JOIN
     CARD_CLIP_USAGES ccu
 ON
     c.CENTER = ccu.CARD_CENTER
     AND c.id = ccu.CARD_id
     AND c.SUBID = ccu.CARD_SUBID
 LEFT JOIN
     CENTERS cen
 ON
     cen.id = inv.CENTER
 LEFT JOIN
     (
         SELECT
             art.installment_plan_id,
             COUNT(*)                  AS ar_trans_count,
             SUM(art.UNSETTLED_AMOUNT) AS ar_trans_amount
         FROM
             account_receivables ar
         LEFT JOIN
             ar_trans art
         ON
             art.center = ar.center
         AND art.id = ar.id
         AND art.amount < 0
         AND art.status != 'CLOSED'
         AND art.UNSETTLED_AMOUNT < 0
         AND art.installment_plan_id IS NOT NULL
         WHERE
             ar.ar_type = 6
         GROUP BY
             art.installment_plan_id) ar_per
 ON
     ar_per.installment_plan_id = insp.id
 WHERE
     C.OWNER_CENTER IN (:scope)
 AND (
         c.clips_left > 0
     OR  (
             invl.TOTAL_AMOUNT> 0
         AND COALESCE(ar_per.ar_trans_count,0) >0) )
 AND c.cancelled =0
 and longtodate(c.VALID_UNTIL) >= current_timestamp
 and pg.id in (:product_group)
 AND (ccu.TYPE <> 'TRANSFER' or ccu.TYPE is null)
 ) x
 LEFT JOIN
 (
    SELECT SOURCE_CENTER, SOURCE_ID, SOURCE_SUBID, DEDUCTION_KEY, TARGET_CENTER  FROM
         (SELECT RANK() over (PARTITION BY SOURCE_CENTER, SOURCE_ID, SOURCE_SUBID ORDER BY USE_TIME DESC) AS myRANK, pu.*
           FROM PRIVILEGE_USAGES pu
           WHERE STATE <> 'CANCELLED'
           AND TARGET_SERVICE = 'Attend'
         ) t
    WHERE t.MYRANK = 1) last_usage
 ON
     last_usage.SOURCE_CENTER = x.CENTER
     AND last_usage.SOURCE_ID = x.ID
     AND last_usage.SOURCE_SUBID = x.SUBID
