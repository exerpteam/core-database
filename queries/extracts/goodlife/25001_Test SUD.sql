WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            GETSTARTOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), C.ID) AS start_of_date,
            GETENDOFDAY(CAST (CAST ($$cutdate$$ AS DATE) AS TEXT), C.ID)   AS end_of_date,
            c.id                                                       AS center_id
        FROM
            goodlife.centers c
        WHERE
            c.id IN ($$scope$$)
    )
    ,
    clip_usage_mat AS materialized
    (
        SELECT
            CC.CENTER,
            CC.ID,
            CC.SUBID,
            cc.INVOICELINE_CENTER,
            cc.INVOICELINE_ID,
            cc.INVOICELINE_SUBID,
            cc.owner_center,
            cc.owner_id,
            cc.clips_initial,
            cc.clips_left,
            -SUM(
                CASE
                    WHEN ( b.starttime <= par.end_of_date
                        OR  b.starttime IS NULL)
                    THEN CCU.CLIPS
                    ELSE 0
                END) AS USEDCLIPS
        FROM
            CLIPCARDS CC
        JOIN
            PARAMS par
        ON
            par.center_id = cc.center
        INNER JOIN
            INVOICES INV
        ON
            ( CC.INVOICELINE_CENTER = INV.CENTER
            AND CC.INVOICELINE_ID = INV.ID)
        LEFT JOIN
            CARD_CLIP_USAGES CCU
        ON
            ( ccu.CARD_CENTER = CC.CENTER
            AND ccu.CARD_ID = CC.ID
            AND ccu.CARD_SUBID = CC.SUBID)
        AND CCU.STATE = 'ACTIVE'
        AND CCU.TIME <= par.end_of_date
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
            CC.CLIPS_INITIAL > 0
        AND ( CC.CANCELLED = 0
            OR  CC.CANCELLATION_TIME >= par.start_of_date)
        AND ( CC.VALID_UNTIL IS NULL
            OR  CC.VALID_UNTIL >= par.start_of_date)
        AND INV.TRANS_TIME <= par.end_of_date
        GROUP BY
            CC.CENTER,
            CC.ID,
            CC.SUBID,
            cc.INVOICELINE_CENTER,
            cc.INVOICELINE_ID,
            cc.INVOICELINE_SUBID,
            cc.owner_center,
            cc.owner_id,
            cc.clips_initial
    )
/*SELECT
*
FROM
clip_usage_mat
WHERE
usedclips IS NULL;*/
SELECT
    CC.CENTER                                      AS "Center",
    cent.NAME                                      AS "CenterName",
    CC.CENTER || 'cc' || CC.ID || 'id' || CC.SUBID   AS "Clipcard",
    CC.OWNER_CENTER || 'p' || CC.OWNER_ID            AS "Person",
    PR.NAME                                          AS "Product",
    PGN.NAME                                         AS "ProductGroup",
    TO_CHAR(longtodate(INV.TRANS_TIME),'YYYY-MM-DD') AS "SalesDate",
    ROUND(((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)),2)
                                                               AS "AmountExcludingVAT",
    ROUND((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)),2) AS "AmountIncludingVAT",
    CC.CLIPS_INITIAL                                           AS "OriginalClips",
    COALESCE(USEDCLIPS, 0)                                     AS "RealizedClips",
    (CC.CLIPS_INITIAL - COALESCE(USEDCLIPS, 0))                AS "DeferredClips",
    ROUND((COALESCE(USEDCLIPS, 0) * (((IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE
    (ILVATL.RATE, 0) + 1)) / CC.CLIPS_INITIAL)),2) AS "RealizedAmount",
    ROUND(LEAST(((CC.CLIPS_INITIAL - COALESCE(USEDCLIPS, 0)) * (((IL.TOTAL_AMOUNT + COALESCE
    (IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1)) / CC.CLIPS_INITIAL)), (
    (IL.TOTAL_AMOUNT + COALESCE(IL2.TOTAL_AMOUNT, 0)) / (COALESCE(ILVATL.RATE, 0) + 1))),2) AS
                                      "DeferredAmount",
    PAC.DEFER_REV_ACCOUNT_GLOBALID AS "DeferredRevenueAccount"
FROM
    clip_usage_mat CC
INNER JOIN
    INVOICE_LINES_MT IL
ON
    ( CC.INVOICELINE_CENTER = IL.CENTER
    AND CC.INVOICELINE_ID = IL.ID
    AND CC.INVOICELINE_SUBID = IL.SUBID)
INNER JOIN
    INVOICES INV
ON
    ( IL.CENTER = INV.CENTER
    AND IL.ID = INV.ID)
INNER JOIN
    PRODUCTS PR
ON
    ( IL.PRODUCTCENTER = PR.CENTER
    AND IL.PRODUCTID = PR.ID)
LEFT JOIN
    INVOICELINES_VAT_AT_LINK ILVATL
ON
    ( ILVATL.INVOICELINE_CENTER = IL.CENTER
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
    ( IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
    AND IL2.ID = INV.SPONSOR_INVOICE_ID
    AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID)
JOIN
    CENTERS cent
ON
    cent.id = CC.center
WHERE
    ( USEDCLIPS < CC.CLIPS_INITIAL
    OR  USEDCLIPS IS NULL)
ORDER BY
    CC.OWNER_CENTER,
    CC.OWNER_ID,
    CC.CLIPS_LEFT DESC