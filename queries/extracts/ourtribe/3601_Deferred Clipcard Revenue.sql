-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT CLIPCARDCENTER||'cc'||CLIPCARDID||'cc'||CLIPCARDSUBID AS Clipcard,
PERSONCENTER||'p'||PERSONID Person,
PRODUCTNAME AS Product, 
PRODUCTGROUPNAME AS ProductGroup, 
SALESTIMESTAMP AS SalesDate, 
(((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) AS   AmountExcludingVAT,
((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / GREATEST(CLIPCARDSCOUNT, 1)) AS AmountIncludingVAT,
CLIPSINITIAL AS OriginalClips, 
COALESCE(USEDCLIPS, 0) AS RealizedClips,
(CLIPSINITIAL -  COALESCE(USEDCLIPS, 0)) AS DeferredClips, 
((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1))/ GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL) AS    AmountPerClip,
(COALESCE(USEDCLIPS, 0) * ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1))/ GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL)) AS RealizedAmount, LEAST(((CLIPSINITIAL - COALESCE(USEDCLIPS, 0))* ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) /(COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) /   CLIPSINITIAL)), (((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 
        0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 
        1))) AS DeferredAmount ,      
        DeferredRevenueSalesAccount, 
		DeferredRevenueLiabilityAccount       
   
    from (
SELECT
            CC.CENTER                      AS CLIPCARDCENTER,
            CC.ID                          AS CLIPCARDID,
            CC.SUBID                       AS CLIPCARDSUBID,
            CC.CLIPS_INITIAL               AS CLIPSINITIAL,
            INV.TRANS_TIME                 AS SALESTIMESTAMP,
            CC.OWNER_CENTER                AS PERSONCENTER,
            CC.OWNER_ID                    AS PERSONID,
            PR.NAME                        AS PRODUCTNAME,
            PGN.NAME                       AS PRODUCTGROUPNAME,
            PAC.DEFER_REV_ACCOUNT_GLOBALID AS DEFERREDREVENUESALESACCOUNT,
            PAC.DEFER_LIA_ACCOUNT_GLOBALID AS DEFERREDREVENUELIABILITYACCOUNT,
            IL.TOTAL_AMOUNT                AS TOTALAMOUNT,
            IL2.TOTAL_AMOUNT               AS SPONSORTOTALAMOUNT,
            ILVATL.RATE                    AS VATRATE,
            (
                SELECT
                    COUNT(*) AS CLIPCARDSCOUNT
                FROM
                    CLIPCARDS AS CC1
                LEFT JOIN
                    CARD_CLIP_USAGES AS CCU1
                ON
                    (
                        CCU1.CARD_CENTER = CC1.CENTER
                    AND CCU1.CARD_ID = CC1.ID
                    AND CCU1.CARD_SUBID = CC1.SUBID
                    AND CCU1.TYPE = 'TRANSFER_TO')
                WHERE
                    (
                        CC1.INVOICELINE_CENTER = IL.CENTER
                    AND CC1.INVOICELINE_ID = IL.ID
                    AND CC1.INVOICELINE_SUBID = IL.SUBID
                    AND CC1.OWNER_CENTER = IL.PERSON_CENTER
                    AND CC1.OWNER_ID = IL.PERSON_ID
                    AND CCU1.ID IS NULL)) AS CLIPCARDSCOUNT,
            USEDCLIPS
        FROM
            CLIPCARDS AS CC
        INNER JOIN
            INVOICE_LINES_MT AS IL
        ON
            (
                CC.INVOICELINE_CENTER = IL.CENTER
            AND CC.INVOICELINE_ID = IL.ID
            AND CC.INVOICELINE_SUBID = IL.SUBID)
        LEFT JOIN
            (
                SELECT
                    CCU.CARD_CENTER AS CCU_CARD_CENTER,
                    CCU.CARD_ID     AS CCU_CARD_ID,
                    CCU.CARD_SUBID  AS CCU_CARD_SUBID,
                    -SUM(CCU.CLIPS) AS USEDCLIPS
                FROM
                    CARD_CLIP_USAGES AS CCU
                WHERE
                    (
                        CCU.STATE IN ('ACTIVE',
                                      'PLANNED')
                    AND CCU.TIME <= GETENDOFDAY(CAST(CAST($$cutdate$$ AS DATE) AS VARCHAR), CCU.CARD_CENTER))
                GROUP BY
                    CCU.CARD_CENTER,
                    CCU.CARD_ID,
                    CCU.CARD_SUBID) AS USED_CLIPS_QUERY
        ON
            (
                CCU_CARD_CENTER = CC.CENTER
            AND CCU_CARD_ID = CC.ID
            AND CCU_CARD_SUBID = CC.SUBID)
        INNER JOIN
            INVOICES AS INV
        ON
            (
                IL.CENTER = INV.CENTER
            AND IL.ID = INV.ID)
        INNER JOIN
            PRODUCTS AS PR
        ON
            (
                IL.PRODUCTCENTER = PR.CENTER
            AND IL.PRODUCTID = PR.ID)
        LEFT JOIN
            INVOICELINES_VAT_AT_LINK AS ILVATL
        ON
            (
                ILVATL.INVOICELINE_CENTER = IL.CENTER
            AND ILVATL.INVOICELINE_ID = IL.ID
            AND ILVATL.INVOICELINE_SUBID = IL.SUBID)
        INNER JOIN
            PRODUCT_GROUP AS PGN
        ON
            PR.PRIMARY_PRODUCT_GROUP_ID = PGN.ID
        LEFT JOIN
            PRODUCT_ACCOUNT_CONFIGURATIONS AS PAC
        ON
            PR.PRODUCT_ACCOUNT_CONFIG_ID = PAC.ID
        LEFT JOIN
            INVOICE_LINES_MT AS IL2
        ON
            (
                IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
            AND IL2.ID = INV.SPONSOR_INVOICE_ID
            AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID)
        WHERE
            (
                CC.CENTER IN ($$center$$)
           AND (
                    CC.CANCELLED = false
                OR  CC.CANCELLATION_TIME > GETENDOFDAY(CAST(CAST($$cutdate$$ AS DATE) AS VARCHAR), CC.CENTER))
          /*  AND (
                    USEDCLIPS < CC.CLIPS_INITIAL     OR  USEDCLIPS IS NULL)*/
            AND INV.TRANS_TIME <= GETENDOFDAY(CAST(CAST($$cutdate$$ AS DATE) AS VARCHAR), CC.CENTER)
            AND EXISTS
                (
                    SELECT
                        SCL.ID AS SCL_ID
                    FROM
                        STATE_CHANGE_LOG AS SCL
                    WHERE
                        (
                            SCL.ENTRY_TYPE = 6
                        AND SCL.CENTER = CC.CENTER
                        AND SCL.ID = CC.ID
                        AND SCL.SUBID = CC.SUBID
                        AND SCL.STATEID = 1
                        AND SCL.BOOK_START_TIME < GETENDOFDAY(CAST(CAST($$cutdate$$ AS DATE) AS VARCHAR), CC.CENTER)
                        AND (
                                SCL.BOOK_END_TIME IS NULL
                            OR  SCL.BOOK_END_TIME >= GETENDOFDAY(CAST(CAST($$cutdate$$ AS DATE) AS VARCHAR), CC.CENTER))
                        AND (
                                SCL.ENTRY_END_TIME IS NULL
                            OR  SCL.ENTRY_END_TIME >= 1666994399999)))
            AND CC.CLIPS_INITIAL > 0)
        ORDER BY
            CC.OWNER_CENTER,
            CC.OWNER_ID,
            CC.CLIPS_LEFT DESC
) AS subQuery 