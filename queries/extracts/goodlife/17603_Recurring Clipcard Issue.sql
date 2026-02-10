-- The extract is extracted from Exerp on 2026-02-08
--  
WITH clip_invoice AS (
        SELECT  
                c.invoiceline_center, c.invoiceline_id,
                c.owner_center || 'p' || c.owner_id as personid
        FROM
                goodlife.invoices inv
        JOIN    goodlife.clipcards c ON inv.center = c.invoiceline_center AND inv.id = c.invoiceline_id --AND c.clips_initial = c2.clips_initial
        JOIN    goodlife.invoice_lines_mt il ON il.center = c.invoiceline_center AND il.id = c.invoiceline_id AND il.subid = c.invoiceline_subid
        JOIN    goodlife.spp_invoicelines_link link ON link.invoiceline_center = il.center AND link.invoiceline_id = il.id AND link.invoiceline_subid = il.subid
        JOIN    goodlife.subscriptionperiodparts spp ON spp.center = link.period_center AND spp.id = link.period_id AND spp.subid = link.period_subid and spp.spp_state = 1
        JOIN    goodlife.subscriptions sub on sub.center = spp.center and sub.id = spp.id 
        JOIN    goodlife.subscriptiontypes st on st.center = sub.subscriptiontype_center and st.id = sub.subscriptiontype_id
        WHERE
                spp.spp_state = 1
                AND c.cancelled = 0
        GROUP BY 
               c.owner_center, c.owner_id,c.invoiceline_center, c.invoiceline_id
        HAVING COUNT(*) > 1 
                AND 
                (
                        (max(st.periodunit) = 0 AND sum((spp.to_date - spp.from_date) + 1) IN (14)) -- Biweekly
                        OR 
                        (max(st.periodunit) = 2 AND sum((spp.to_date - spp.from_date) + 1) IN (28,30,31,29)) -- Monthly
                )
) 

SELECT
        TO_CHAR(longtodateC(clipToFix.valid_from, clipToFix.center),'YYYY-MM-DD') AS "ValidFrom",
        clipToFix.*, clipToFix.clips_initial - clipToFix.clips_left,
        clipToFix.owner_center || 'p' || clipToFix.owner_id as PersonId
FROM goodlife.clipcards clipToFix
WHERE
        (clipToFix.invoiceline_center,clipToFix.invoiceline_id,clipToFix.valid_from)
        IN
        (
                -- All clipcards from which we should exclude the one with earliest ValidFrom
                SELECT
                        clip.invoiceline_center, clip.invoiceline_id, clip.valid_from
                FROM 
                        goodlife.clipcards clip
                JOIN clip_invoice ci on clip.invoiceline_center = ci.invoiceline_center and clip.invoiceline_id = ci.invoiceline_id

                EXCEPT
                
                -- Excluding the good one.
                SELECT
                        clip.invoiceline_center, clip.invoiceline_id, min(clip.valid_from)
                FROM 
                        goodlife.clipcards clip
                JOIN clip_invoice ci on clip.invoiceline_center = ci.invoiceline_center and clip.invoiceline_id = ci.invoiceline_id
                group by clip.invoiceline_center, clip.invoiceline_id
       ) 
AND clipToFix.cancelled=0 
AND clipToFix.finished=0

ORDER BY clipToFix.valid_from

