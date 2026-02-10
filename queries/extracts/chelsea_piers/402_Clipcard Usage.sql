-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
  x.*, 
  TO_CHAR(LONGTODATEC(
  (
        SELECT
                MAX(ccu.TIME)
        FROM CARD_CLIP_USAGES ccu 
        WHERE
                ccu.CARD_CENTER = x.center
                AND ccu.CARD_ID = x.id
                AND ccu.CARD_SUBID = x.subid
  ),
  x.center), 'DD/MM/YYYY HH24:MI:SS')
--  NVL(last_usage.TARGET_CENTER, x.CENTER) AS LAST_USED_CENTER
FROM
(
SELECT DISTINCT
    c.center,c.id,c.subid , 
    c.center||'cc'||c.id||c.subid as clipcardid,
    c.owner_center          owner_center,
    c.owner_id              owner_id,
    c.clips_left,
    c.clips_initial,
    p.name as Product,
    case when 
    p.ptype = 4 then 'Clipcard'
    when p.ptype = 10 then 'Subscription'
    end as Product_Type

FROM
    CLIPCARDS c
JOIN
    products p
ON
    p.center = c.center
AND p.id = c.id

LEFT JOIN
    PERSON_EXT_ATTRS pea_oldid
ON
    pea_oldid.PERSONCENTER = c.owner_center
AND pea_oldid.PERSONID = c.owner_id
LEFT JOIN
    chelseapiers.invoice_lines_mt invl
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
    chelseapiers.invoice_lines_mt invls
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
(
        c.clips_left > 0
    OR  (
            invl.TOTAL_AMOUNT> 0
      --  AND NVL(ar_per.ar_trans_count,0) >0
        ) )
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
    last_usage.SOURCE_CENTER = x.CENTER
    AND last_usage.SOURCE_ID = x.ID
    AND last_usage.SOURCE_SUBID = x.SUBID