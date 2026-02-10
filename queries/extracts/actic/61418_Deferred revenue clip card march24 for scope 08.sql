-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    RECURSIVE CC_TRANS AS
    (
    (
        SELECT
            CC.CENTER                        AS CC_CENTER,
            CC.ID                            AS CC_ID,
            CC.SUBID                         AS CC_SUBID,
            CC.TRANSFER_FROM_CLIPCARD_CENTER AS CC_TRANSFER_FROM_CLIPCARD_CENTER,
            CC.TRANSFER_FROM_CLIPCARD_ID     AS CC_TRANSFER_FROM_CLIPCARD_ID,
            CC.TRANSFER_FROM_CLIPCARD_SUBID  AS CC_TRANSFER_FROM_CLIPCARD_SUBID,
            CC.CENTER                        AS CURRENT_CC_CENTER,
            CC.ID                            AS CURRENT_CC_ID,
            CC.SUBID                         AS CURRENT_CC_SUBID
        FROM
            CLIPCARDS AS CC
        LEFT JOIN
            CLIPCARDS AS CC1
        ON
            (
                CC.CENTER = CC1.TRANSFER_FROM_CLIPCARD_CENTER
            AND CC.ID = CC1.TRANSFER_FROM_CLIPCARD_ID
            AND CC.SUBID = CC1.TRANSFER_FROM_CLIPCARD_SUBID)
        WHERE
            (
                CC1.ID IS NULL
            AND (
                    CC.CANCELLED = false
                OR  CC.CANCELLATION_TIME > GETENDOFDAY('2024-04-02', CC.CENTER))
            AND CC.CLIPS_INITIAL > 0
            AND CC.CENTER IN (8) /*and cc.id = 54401 and cc.subid = 4004*/)
    )
UNION ALL
    (
        SELECT
            CC.CENTER                        AS CC_CENTER,
            CC.ID                            AS CC_ID,
            CC.SUBID                         AS CC_SUBID,
            CC.TRANSFER_FROM_CLIPCARD_CENTER AS CC_TRANSFER_FROM_CLIPCARD_CENTER,
            CC.TRANSFER_FROM_CLIPCARD_ID     AS CC_TRANSFER_FROM_CLIPCARD_ID,
            CC.TRANSFER_FROM_CLIPCARD_SUBID  AS CC_TRANSFER_FROM_CLIPCARD_SUBID,
            CC_TRANS.CURRENT_CC_CENTER,
            CC_TRANS.CURRENT_CC_ID,
            CC_TRANS.CURRENT_CC_SUBID
        FROM
            CLIPCARDS AS CC
        INNER JOIN
            CC_TRANS
        ON
            (
                CC.CENTER = CC_TRANS.CC_TRANSFER_FROM_CLIPCARD_CENTER
            AND CC.ID = CC_TRANS.CC_TRANSFER_FROM_CLIPCARD_ID
            AND CC.SUBID = CC_TRANS.CC_TRANSFER_FROM_CLIPCARD_SUBID) )
    )
    ,
    CTE AS MATERIALIZED
    (
        SELECT
            SCL.CENTER AS SCL_CENTER,
            SCL.ID     AS SCL_ID,
            SCL.SUBID  AS SCL_SUBID,
            CC_TRANS.CC_CENTER,
            CC_TRANS.CC_ID,
            CC_TRANS.CC_SUBID
        FROM
            STATE_CHANGE_LOG AS SCL
        INNER JOIN
            CC_TRANS
        ON
            (
                SCL.CENTER = CC_TRANS.CURRENT_CC_CENTER
            AND SCL.ID = CC_TRANS.CURRENT_CC_ID
            AND SCL.SUBID = CC_TRANS.CURRENT_CC_SUBID)
        WHERE
            (
                SCL.ENTRY_TYPE = 6
            AND SCL.STATEID = 1
            AND SCL.BOOK_START_TIME < GETENDOFDAY('2024-03-31', SCL.CENTER)
            AND (
                    SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= GETENDOFDAY('2024-03-31', SCL.CENTER))
            AND (
                    SCL.ENTRY_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= 1712078459000))
    )
    ,
    CC_USED AS
    (
        SELECT
            CTE.SCL_CENTER               AS CENTER,
            CTE.SCL_ID                   AS ID,
            CTE.SCL_SUBID                AS SUBID,
           COALESCE(-SUM(CCU.CLIPS), 0) AS USEDCLIPS
          
        FROM
            CARD_CLIP_USAGES AS CCU
        RIGHT JOIN
            CTE
        ON
            (
                CCU.CARD_CENTER = CTE.CC_CENTER
            AND CCU.CARD_ID = CTE.CC_ID
            AND CCU.CARD_SUBID = CTE.CC_SUBID
            AND CCU.TYPE NOT IN ('TRANSFER_TO',
                                 'TRANSFER_FROM')
            AND ((
                        CCU.ACTIVATION_TIMESTAMP IS NULL
                    AND CCU.STATE <> 'PLANNED'
                    AND CCU.TIME <= GETENDOFDAY('2024-03-31', CCU.CARD_CENTER))
                OR  CCU.ACTIVATION_TIMESTAMP <= GETENDOFDAY('2024-03-31', CCU.CARD_CENTER))
            AND (
                    CCU.CANCELLATION_TIMESTAMP IS NULL
               /* OR  CCU.CANCELLATION_TIMESTAMP < GETENDOFDAY('2024-04-02', CCU.CARD_CENTER)*/))
        GROUP BY
            CTE.SCL_CENTER,
            CTE.SCL_ID,
            CTE.SCL_SUBID
           
    )
SELECT
    CLIPCARDCENTER,
    CLIPCARDID,
    CLIPCARDSUBID,
    SALESTIMESTAMP,
    PERSONCENTER,
    PERSONID,
    PRODUCTNAME,
    PRODUCTGROUPNAME,
    DEFERREDREVENUESALESACCOUNT,
    DEFERREDREVENUELIABILITYACCOUNT,
    ((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / GREATEST(CLIPCARDSCOUNT, 1)) AS
    AMOUNTINCLUDINGVAT,
    (((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST
    (CLIPCARDSCOUNT, 1))                    AS AMOUNTEXCLUDINGVAT,
    CLIPSINITIAL                            AS ORIGINALCLIPS,
    COALESCE(USEDCLIPS, 0)                  AS REALIZEDCLIPS,
    (CLIPSINITIAL - COALESCE(USEDCLIPS, 0)) AS DEFERREDCLIPS,
    ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST
    (CLIPCARDSCOUNT, 1)) / CLIPSINITIAL) AS AMOUNTPERCLIP,
    (COALESCE(USEDCLIPS, 0) * ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE
    (VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL)) AS REALIZEDAMOUNT,
    LEAST(((CLIPSINITIAL - COALESCE(USEDCLIPS, 0)) * ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT,
    0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL)), ((
    (TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST
    (CLIPCARDSCOUNT, 1))) AS DEFERREDAMOUNT
FROM
    (
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
            CC_USED
        ON
            (
                CC.CENTER = CC_USED.CENTER
            AND CC.ID = CC_USED.ID
            AND CC.SUBID = CC_USED.SUBID)
        INNER JOIN
            INVOICE_LINES_MT AS IL
        ON
            (
                CC.INVOICELINE_CENTER = IL.CENTER
            AND CC.INVOICELINE_ID = IL.ID
            AND CC.INVOICELINE_SUBID = IL.SUBID)
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
                CC.CENTER IN (8)
            AND (
                    CC.CANCELLED = false
                OR  CC.CANCELLATION_TIME < GETENDOFDAY('2024-04-02', CC.CENTER))
            AND (
                    USEDCLIPS < CC.CLIPS_INITIAL
                OR  USEDCLIPS IS NULL)
            AND INV.TRANS_TIME <= GETENDOFDAY('2024-03-31', CC.CENTER)
            AND CC.CLIPS_INITIAL > 0)
        ORDER BY
            CC.OWNER_CENTER,
            CC.OWNER_ID,
            CC.CLIPS_LEFT DESC) AS subQuery