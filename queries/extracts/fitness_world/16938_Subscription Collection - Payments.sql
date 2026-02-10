-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    COUNT(DISTINCT pr_id) file_requests,
    subsRequested subs_Requested,
    -SUM(subsRequested) subs_total
FROM
    (
        SELECT DISTINCT
            center.id centerId,
            CASE
                WHEN pr.CENTER IS NOT NULL AND pr.REQUEST_TYPE = 1
                THEN ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID
                ELSE NULL
            END payerId,
            pr.center || 'pr' || pr.ID || 'id' || pr.SUBID pr_Id,
            COUNT(DISTINCT
            CASE
                WHEN SCL1.CENTER IS NOT NULL
                    AND pr.CENTER IS NOT NULL AND pr.REQUEST_TYPE = 1
                THEN SCL1.CENTER || 'ss' || SCL1.ID
                ELSE NULL
            END) subsRequested
        FROM
            FW.CENTERS center
        JOIN
            FW.PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.center = center.id
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            prs.CENTER = ar.CENTER
            AND prs.ID = ar.ID
        LEFT JOIN
            FW.AR_TRANS art
        ON
            art.PAYREQ_SPEC_CENTER = prs.CENTER
            AND art.PAYREQ_SPEC_ID = prs.ID
            AND art.PAYREQ_SPEC_SUBID = prs.SUBID
            AND art.REF_TYPE = 'INVOICE'
        LEFT JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.INV_COLL_CENTER = prs.CENTER
            AND pr.INV_COLL_ID = prs.ID
            AND pr.INV_COLL_SUBID = prs.SUBID
            AND pr.REQ_DATE = :DeductionDate
        LEFT JOIN
            FW.INVOICES inv
        ON
            inv.CENTER = art.REF_CENTER
            AND inv.ID = art.REF_ID
        LEFT JOIN
            FW.INVOICELINES il
        ON
            il.CENTER = inv.CENTER
            AND il.ID = inv.ID
        LEFT JOIN
            FW.SPP_INVOICELINES_LINK sppil
        ON
            sppil.INVOICELINE_CENTER = il.CENTER
            AND sppil.INVOICELINE_ID = il.ID
            AND sppil.INVOICELINE_SUBID = il.SUBID
        LEFT JOIN
            FW.SUBSCRIPTIONS su
        ON
            su.CENTER = sppil.PERIOD_CENTER
            AND su.ID = sppil.PERIOD_ID
        LEFT JOIN
            FW.SUBSCRIPTIONTYPES stype
        ON
            stype.CENTER = su.SUBSCRIPTIONTYPE_CENTER
            AND stype.ID = su.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            STATE_CHANGE_LOG SCL1
        ON
            SCL1.CENTER = SU.CENTER
            AND SCL1.ID = SU.ID
            AND stype.ST_TYPE = 1
            AND SCL1.ENTRY_TYPE = 2
            AND SCL1.STATEID IN (2,4,8)
            AND SCL1.BOOK_START_TIME < :CollectionDate + (1000*60*60*24)
            AND SCL1.ENTRY_START_TIME < :CollectionDate + (1000*60*60*24)
            AND (
                SCL1.BOOK_END_TIME IS NULL
                OR SCL1.BOOK_END_TIME >= :CollectionDate + (1000*60*60*24) )
        WHERE
        
            pr.REQ_DATE = :DeductionDate
            OR (
                prs.ENTRY_TIME >= :CollectionDate
                AND prs.ENTRY_TIME < :CollectionDate + (1000*60*60*24))
        GROUP BY
            center.id,
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            pr.center,
            pr.ID,
            pr.SUBID, pr.REQUEST_TYPE )
GROUP BY
    subsRequested
ORDER BY
    2
