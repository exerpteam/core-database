SELECT
    CC.CENTER  AS "Center",
    cent.NAME  AS "CenterName",
    CC.CENTER || 'cc' || CC.ID || 'id' || CC.SUBID    AS "Clipcard",
    CC.OWNER_CENTER || 'p' || CC.OWNER_ID    AS "Person",
    PR.NAME  AS "Product",
    PGN.NAME  AS "ProductGroup",
    TO_CHAR(longtodate(INV.TRANS_TIME),'YYYY-MM-DD')   AS "SalesDate",
    ROUND(((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)),2) AS "AmountExcludingVAT",
    ROUND((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)),2) AS "AmountIncludingVAT",
    CC.CLIPS_INITIAL  AS "OriginalClips",
    COALESCE(USEDCLIPS, 0)   AS "RealizedClips",
    (CC.CLIPS_INITIAL - COALESCE(USEDCLIPS, 0))  AS "DeferredClips",
    ROUND((COALESCE(USEDCLIPS, 0) * (((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)) / CC.CLIPS_INITIAL)),2) AS "RealizedAmount",
    ROUND(LEAST(((CC.CLIPS_INITIAL - COALESCE(USEDCLIPS, 0)) * (((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)) / CC.CLIPS_INITIAL)), ((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1))),2) AS "DeferredAmount",
    PAC.DEFER_REV_ACCOUNT_GLOBALID   AS "DeferredRevenueAccount"
FROM
    CLIPCARDS CC
LEFT JOIN
    (
        SELECT
            CCU.CARD_CENTER AS CCU_CARD_CENTER,
            CCU.CARD_ID     AS CCU_CARD_ID,
            CCU.CARD_SUBID  AS CCU_CARD_SUBID,
            -SUM(CCU.CLIPS) AS USEDCLIPS
        FROM
            CARD_CLIP_USAGES CCU
        LEFT JOIN
            privilege_usages pu
        ON
            pu.id = ccu.ref
        LEFT JOIN
            participations part
        ON
            pu.target_service = 'Participation'
            AND pu.target_center = part.center
            AND pu.target_id = part.id
        LEFT JOIN
            bookings b
        ON
            b.center = part.booking_center
            AND b.id = part.booking_id
        WHERE
            (
			    CCU.CARD_CENTER IN ($$scope$$)
                AND CCU.STATE = 'ACTIVE'
                AND CCU.TIME <= GETENDOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), CCU.CARD_CENTER)
                AND (
                    b.starttime <= GETENDOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), CCU.CARD_CENTER)
                    OR b.starttime IS NULL))
        GROUP BY
            CCU.CARD_CENTER,
            CCU.CARD_ID,
            CCU.CARD_SUBID) SUBQUERY
ON
    (
        CCU_CARD_CENTER = CC.CENTER
        AND CCU_CARD_ID = CC.ID
        AND CCU_CARD_SUBID = CC.SUBID)
INNER JOIN
    INVOICE_LINES_MT IL
ON
    (
        CC.INVOICELINE_CENTER = IL.CENTER
        AND CC.INVOICELINE_ID = IL.ID
        AND CC.INVOICELINE_SUBID = IL.SUBID)
INNER JOIN
    INVOICES INV
ON
    (
        IL.CENTER = INV.CENTER
        AND IL.ID = INV.ID)
INNER JOIN
    PRODUCTS PR
ON
    (
        IL.PRODUCTCENTER = PR.CENTER
        AND IL.PRODUCTID = PR.ID)
LEFT JOIN
    INVOICELINES_VAT_AT_LINK ILVATL
ON
    (
        ILVATL.INVOICELINE_CENTER = IL.CENTER
        AND ILVATL.INVOICELINE_ID = IL.ID
        AND ILVATL.INVOICELINE_SUBID = IL.SUBID)
INNER JOIN
    PRODUCT_GROUP PGN
ON
    PR.PRIMARY_PRODUCT_GROUP_ID = PGN.ID
LEFT JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS PAC
ON
    PR.PRODUCT_ACCOUNT_CONFIG_ID = PAC.ID
LEFT JOIN
    INVOICE_LINES_MT IL2
ON
    (
        IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
        AND IL2.ID = INV.SPONSOR_INVOICE_ID
        AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID)
JOIN
    CENTERS cent
ON
    cent.id = CC.center
WHERE
    (
        CC.CENTER IN ($$scope$$)
        AND (
            CC.CANCELLED = 0
            OR CC.CANCELLATION_TIME >= GETSTARTOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), CC.CENTER))
        AND (
            USEDCLIPS < CC.CLIPS_INITIAL
            OR USEDCLIPS IS NULL)
        AND (
            CC.VALID_UNTIL IS NULL
            OR CC.VALID_UNTIL >= GETSTARTOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), CC.CENTER))
        AND INV.TRANS_TIME <= GETENDOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), INV.CENTER)
        AND CC.CLIPS_INITIAL > 0)
ORDER BY
    CC.OWNER_CENTER,
    CC.OWNER_ID,
    CC.CLIPS_LEFT DESC