 -- Parameters: scope(SCOPE)
 SELECT
   x.*,
   COALESCE(last_usage.TARGET_CENTER::VARCHAR, x.CENTER) AS LAST_USED_CENTER,
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
                 ccu2.CARD_CENTER::VARCHAR = x.center
                 AND ccu2.CARD_ID::VARCHAR = x.id
                 AND ccu2.CARD_SUBID::VARCHAR = x.subid
                 AND ccu2.TIME =
         (
                 SELECT
                         MAX(ccu.TIME)
                 FROM CARD_CLIP_USAGES ccu
                 WHERE
                         ccu.CARD_CENTER::VARCHAR = x.center
                         AND ccu.CARD_ID::VARCHAR = x.id
                         AND ccu.CARD_SUBID::VARCHAR = x.subid
         )
   ) AS LAST_USAGE_DESCRIPTION
 FROM
 (
 SELECT DISTINCT
     c.center::VARCHAR                center,
     c.id::VARCHAR                    id,
     c.subid::VARCHAR                 subid,
     c.owner_center::VARCHAR          owner_center,
     c.owner_id              owner_id,
     pea_oldid.txtvalue               AS OLD_MEMBERNUMBER,
     c.clips_left,
     c.clips_initial,invl.QUANTITY quantity,/*  DECODE(cen.COUNTRY,'SE',TO_CHAR(ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)),2)),'FI',TO_CHAR
     (ROUND((invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)),2)),TO_CHAR((invl.TOTAL_AMOUNT / invl.QUANTITY))
     ) price_per_clip_card
 */     
     CASE cen.COUNTRY WHEN 'SE' THEN (invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)) WHEN 'FI' THEN (invl.TOTAL_AMOUNT / invl.QUANTITY)/(1+COALESCE(invl.RATE,0)) ELSE (invl.TOTAL_AMOUNT / invl.QUANTITY)
      END price_per_clip_card,
     invl.NET_AMOUNT net_amount,
     CASE cen.COUNTRY WHEN 'SE' THEN CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(invl.RATE,0)),2) AS VARCHAR) WHEN 'FI' THEN 
     CAST(ROUND((invls.TOTAL_AMOUNT / invls.QUANTITY)/(1+COALESCE(invl.RATE,0)),2) AS VARCHAR) ELSE CAST((invls.TOTAL_AMOUNT /
     invls.QUANTITY) AS VARCHAR) END price_per_clip_card_spons,
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
 AND p.GLOBALID NOT IN('PT45START1',
                       'PT45START2',
                       'SATSYOU1',
                       'SATSYOU_2',
                       'SATSYOU_3',
                       'MASSAGE_60_1_CLIP',
                       'MASSAGE_10_CLIP_60_MIN',
                       'MASSAGE_5_CLIP_60_MIN',
                       'MASSAGE_60_6_CLIP',
                       'MASSAGE_60_3_CLIP',
                       'REHAB_1_CLIP',
                       'REHAB_KLIPP_1_0KR',
                       'REHAB_POST_REHAB_10_CLIPS',
                       'REHAB_15_CLIP',
                       'REHAB_20_CLIPS',
                       'REHAB_KIG_3_CLIPS',
                       'REHAB_FOOT_6_CLIPS',
                       'REHAB_BACK_8_CLIPS',
                       'PT30INTRO',
                       'PT45INTRO')
 AND p.center NOT IN(570,571,581)
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
     C.OWNER_CENTER IN ($$scope$$)
 AND (
         c.clips_left > 0
     OR  (
             invl.TOTAL_AMOUNT> 0
         AND COALESCE(ar_per.ar_trans_count,0) >0) )
 AND c.cancelled =0
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
     last_usage.SOURCE_CENTER::VARCHAR = x.CENTER
     AND last_usage.SOURCE_ID::VARCHAR = x.ID
     AND last_usage.SOURCE_SUBID::VARCHAR = x.SUBID
