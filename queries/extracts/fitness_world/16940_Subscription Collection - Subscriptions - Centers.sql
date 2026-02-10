-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    centerId,
    COUNT(DISTINCT subId) subscriptions,
    - COUNT(DISTINCT cashSubs) cash_subs,
    COUNT(DISTINCT ddSubs) dd_subs,
    - COUNT(DISTINCT ddFreezeNc) dd_freeze_nc,
    - COUNT(DISTINCT ddEndedNc) dd_ended_nc,
    - COUNT(DISTINCT ddFreeDaysNc) dd_freedays_nc,
    - COUNT(DISTINCT ddCorporateNc) dd_corporate_nc,
    - COUNT(DISTINCT ddNotRenewedNc) dd_NotRenewed_Nc,
    - COUNT(DISTINCT ddNotCollected) dd_NotCollected_Nc,
    - COUNT(DISTINCT ddPrepaidBelowMinNc) dd_prepaid_Nc,
    - COUNT(DISTINCT ddOtherBelowMinNc) dd_OtherBelowMin_Nc,
    - COUNT(DISTINCT ddDifferentDate) dd_Different_Date,
    COUNT(DISTINCT ddSubs) - COUNT(DISTINCT ddFreezeNc) - COUNT(DISTINCT ddEndedNc) - COUNT(DISTINCT ddFreeDaysNc) -
    COUNT(DISTINCT ddCorporateNc) - COUNT(DISTINCT ddNotRenewedNc) - COUNT(DISTINCT ddNotCollected) - COUNT(DISTINCT
    ddPrepaidBelowMinNc) - COUNT(DISTINCT ddOtherBelowMinNc) - COUNT(DISTINCT ddDifferentDate) dd_requestedSubs
FROM
    (
        SELECT DISTINCT
            center.ID centerId,
            SU.CENTER || 'ss' || SU.ID subId,
            CASE
                WHEN ST.ST_TYPE = 0
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END cashSubs,
            CASE
                WHEN ST.ST_TYPE = 1
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddSubs,
            CASE
                WHEN (prstate.prsCenter IS NULL
                        OR prstate.prId IS NULL)
                    AND ST.ST_TYPE = 1
                    AND spp.SPP_TYPE IN (2,7)
                    AND (SU.END_DATE IS NULL
                        OR SU.END_DATE >= :DeductionDate )
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddFreezeNc,
            CASE
                WHEN (prstate.prsCenter IS NULL
                        OR prstate.prId IS NULL)
                    AND ST.ST_TYPE = 1
                    AND SU.END_DATE < :DeductionDate
                    AND (spp.CENTER IS NULL
                        OR spp.SPP_TYPE NOT IN (2,3,7))
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddEndedNc,
            CASE
                WHEN (prstate.prsCenter IS NULL
                        OR prstate.prId IS NULL)
                    AND ST.ST_TYPE = 1
                    AND spp.SPP_TYPE IN (3)
                    AND (SU.END_DATE IS NULL
                        OR SU.END_DATE >= :DeductionDate)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddFreeDaysNc,
            -- Includes 100 sponsored
            CASE
                WHEN ( prstate.prsCenter IS NULL
                        OR prstate.prId IS NULL)
                    AND ST.ST_TYPE = 1
                    AND spp.CENTER IS NOT NULL
                    AND il.SPONSOR_INVOICE_SUBID IS NOT NULL
                    AND il.TOTAL_AMOUNT = 0
                    AND spp.SPP_TYPE NOT IN (2,3,7,8)
                    AND ( SU.END_DATE IS NULL
                        OR SU.END_DATE >= :DeductionDate)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddCorporateNc,
            CASE
                WHEN ( prstate.prsCenter IS NULL
                        OR prstate.prId IS NULL)
                    AND ST.ST_TYPE = 1
                    AND spp.CENTER IS NULL
                    AND (SU.END_DATE IS NULL
                        OR SU.END_DATE >= :DeductionDate)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddNotRenewedNc,
            CASE
                WHEN prstate.prsCenter IS NULL
                    AND ST.ST_TYPE = 1
                    AND spp.CENTER IS NOT NULL
                    AND il.SPONSOR_INVOICE_SUBID IS NULL
                    AND spp.SPP_TYPE NOT IN (2,3,7)
                    AND (SU.END_DATE IS NULL
                        OR SU.END_DATE >= :DeductionDate)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddNotCollected,
            CASE
                WHEN prstate.prsCenter IS NOT NULL
                    AND prstate.prId IS NULL
                    AND ST.ST_TYPE = 1
                    AND spp.SPP_TYPE IN (8)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddPrepaidBelowMinNc,
            CASE
                WHEN prstate.prsCenter IS NOT NULL
                    AND prstate.prId IS NULL
                    AND ST.ST_TYPE = 1
                    AND (spp.CENTER IS NULL
                        OR spp.SPP_TYPE NOT IN (2,3,7,8))
                    AND (su.END_DATE IS NULL
                        OR su.END_DATE >= :DeductionDate)
                    AND (il.SPONSOR_INVOICE_SUBID IS NULL)
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddOtherBelowMinNc,
            CASE
                WHEN prstate.prsCenter IS NOT NULL
                    AND prstate.prId IS NOT NULL
                    AND ST.ST_TYPE = 1
                    AND prstate.clDiffDate IS NOT NULL
                THEN SU.CENTER || 'ss' || SU.ID
                ELSE NULL
            END ddDifferentDate
        FROM
            FW.CENTERS center
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.CENTER = center.ID
        JOIN
            FW.STATE_CHANGE_LOG SCL1
        ON
            SCL1.CENTER = SU.CENTER
            AND SCL1.ID = SU.ID
            AND SCL1.ENTRY_TYPE = 2
            AND SCL1.STATEID IN (2,4,8)
            AND SCL1.BOOK_START_TIME < :CollectionDate + (1000*60*60*24)
            AND SCL1.ENTRY_START_TIME < :CollectionDate + (1000*60*60*24)
            AND (
                SCL1.BOOK_END_TIME IS NULL
                OR SCL1.BOOK_END_TIME >= :CollectionDate + (1000*60*60*24) )
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
        LEFT JOIN
            FW.SUBSCRIPTIONPERIODPARTS spp
        ON
            SU.CENTER = spp.CENTER
            AND SU.ID = spp.ID
            AND spp.FROM_DATE <= :DeductionDate
            AND spp.TO_DATE >= :DeductionDate
            AND spp.ENTRY_TIME < :CollectionDate + (1000*60*60*24)
            AND (
                spp.SPP_STATE = 1
                OR (
                    spp.SPP_STATE = 2
                    AND spp.CANCELLATION_TIME > :CollectionDate + (1000*60*60*24)))
        LEFT JOIN
            FW.SPP_INVOICELINES_LINK sppil
        ON
            spp.CENTER = sppil.PERIOD_CENTER
            AND spp.ID = sppil.PERIOD_ID
            AND spp.SUBID = sppil.PERIOD_SUBID
        LEFT JOIN
            FW.INVOICELINES il
        ON
            il.CENTER = sppil.INVOICELINE_CENTER
            AND il.ID = sppil.INVOICELINE_ID
            AND il.SUBID = sppil.INVOICELINE_SUBID
        LEFT JOIN
            (
                SELECT
                    prs.Center prsCenter,
                    prs.CENTER || 'prs' || prs.ID || 'id' || prs.SUBID prsId,
                    sppil.PERIOD_CENTER,
                    sppil.PERIOD_ID,
                    CASE
                        WHEN (pr.CENTER IS NULL
                                OR pr.REQUEST_TYPE <> 1)
                        THEN NULL
                        ELSE pr.CENTER || 'pr' || pr.ID || 'id' || pr.SUBID
                    END prId,
                    CASE
                        WHEN (pr.CENTER IS NOT NULL
                                OR pr.REQUEST_TYPE <> 1)
                            AND sppil.PERIOD_CENTER IS NOT NULL
                        THEN ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID
                        ELSE NULL
                    END payerId,
                    CASE
                        WHEN pr.CENTER IS NOT NULL
                            AND pr.REQ_DATE <> :DeductionDate
                        THEN sppil.PERIOD_CENTER || 'ss' || sppil.PERIOD_ID
                        ELSE NULL
                    END clDiffDate
                FROM
                    FW.PAYMENT_REQUEST_SPECIFICATIONS prs
                JOIN
                    ACCOUNT_RECEIVABLES ar
                ON
                    prs.CENTER = ar.CENTER
                    AND prs.ID = ar.ID
                LEFT JOIN
                    PAYMENT_REQUESTS pr
                ON
                    pr.INV_COLL_CENTER = prs.CENTER
                    AND pr.INV_COLL_ID = prs.ID
                    AND pr.INV_COLL_SUBID = prs.SUBID
                    --AND pr.REQ_DATE = :DeductionDate
                LEFT JOIN
                    FW.AR_TRANS art
                ON
                    art.PAYREQ_SPEC_CENTER = prs.CENTER
                    AND art.PAYREQ_SPEC_ID = prs.ID
                    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
                    AND art.REF_TYPE = 'INVOICE'
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
                    FW.SUBSCRIPTIONPERIODPARTS spp
                ON
                    sppil.PERIOD_CENTER = spp.CENTER
                    AND sppil.PERIOD_ID = spp.ID
                    AND sppil.PERIOD_SUBID = spp.SUBID
                LEFT JOIN
                    FW.SUBSCRIPTIONS subs
                ON
                    subs.CENTER = spp.CENTER
                    AND subs.ID = spp.ID
                WHERE
                    (
                        spp.CENTER IS NOT NULL
                        AND (
                            pr.REQ_DATE = :DeductionDate AND pr.REQUEST_TYPE = 1
                            OR (
                                prs.ENTRY_TIME >= :CollectionDate
                                AND prs.ENTRY_TIME < :CollectionDate + (1000*60*60*24))) ) ) prstate
        ON
            prstate.PERIOD_CENTER = SU.CENTER
            AND prstate.PERIOD_ID = SU.ID )
GROUP BY
    centerId