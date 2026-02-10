-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-1863
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$StartDate$$                      AS FromDate,
             ($$EndDate$$ + 86400 * 1000) - 1 AS ToDate
         
     )
 SELECT
     e.ref_center || 'gc' || e.ref_id                                                                                       AS "Gift Card Id",
     e.identity                                                                                                             AS "Gift Card Voucher",
     TO_CHAR(longtodateC(e.start_time, e.ref_center), 'HH24:MI')                                                    AS "Time Of Sale",
     TO_CHAR(longtodateC(e.start_time, e.ref_center), 'YYYY-MM-DD')                                                 AS "Date Of Sale",
     TO_CHAR(gc.expirationdate, 'YYYY-MM-DD')                                                                               AS "Expiry Date",
     gc.amount                                                                                                              AS "Gift Card Price",
     gc.amount - gc.amount_remaining                                                                                        AS "Credit Used",
     gc.amount_remaining                                                                                                    AS "Remaining Credit",
     gc.payer_center || 'p' || gc.payer_id                                                                                  AS "Owner Id",
     payer.fullname                                                                                                         AS "Owner Name",
     email.txtvalue                                                                                                         AS "Owner Email Address",
     COALESCE(gc_usage.total, 0)                                                                                                 AS "Number Of Usage",
     COALESCE(art2.info, 'Giftcard sale CLIENT')                                                                                  AS "Transaction Ref",
     TRUNC(longtodateC(e.start_time, e.ref_center)) - TRUNC(longtodateC(gc_usage.first_used, e.ref_center)) AS "Time Until First Usage",
     CASE
         WHEN CURRENT_TIMESTAMP > gc.expirationdate
             AND gc.amount_remaining > 0
         THEN 'Expried'
         WHEN gc.amount_remaining = 0
         THEN 'Finished'
         WHEN CURRENT_TIMESTAMP < gc.expirationdate
             AND gc.amount_remaining = gc.amount
         THEN 'Unused'
         WHEN CURRENT_TIMESTAMP < gc.expirationdate
             AND gc.amount_remaining != gc.amount
         THEN 'Used'
         ELSE 'Unknown'
     END AS "Gift Card Status"
 FROM
     entityidentifiers e
 CROSS JOIN
     params
 JOIN
     gift_cards gc
 ON
     gc.center = e.ref_center
     AND gc.id = e.ref_id
 JOIN
     persons payer
 ON
     payer.center = gc.payer_center
     AND payer.id = gc.payer_id
 LEFT JOIN
     (
         SELECT
             gcu.gift_card_id,
             COUNT(*)      AS total,
             MIN(gcu.time) AS first_used
         FROM
             gift_card_usages gcu
         GROUP BY
             gcu.gift_card_id )gc_usage
 ON
     gc_usage.gift_card_id = gc.id
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     payer.center=email.PERSONCENTER
     AND payer.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     ar_trans art
 ON
     art.REF_TYPE = 'INVOICE'
     AND art.REF_CENTER = gc.invoiceline_center
     AND art.REF_ID = gc.invoiceline_id
 LEFT JOIN
     AR_TRANS art2
 ON
     art2.center = art.center
     AND art2.id = art.id
     AND art2.TEXT = 'API Sale Transaction'
     AND art2.REF_TYPE = 'ACCOUNT_TRANS'
     AND art2.ENTRY_TIME between art.ENTRY_TIME -1000*5 and art.ENTRY_TIME +1000*5
 WHERE
     e.ref_type = 5
     AND e.start_time >= params.FromDate
     AND e.start_time <= params.ToDate
