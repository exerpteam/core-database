WITH
    recursive params AS materialized
    (
        SELECT
            id                                          AS center,
            TO_CHAR($$cut_date$$::DATE, 'YYYY-MM-DD')             AS cut_date,
            GETENDOFDAY(TO_CHAR($$cut_date$$::DATE, 'YYYY-MM-DD') , ID)                            cut_end_of_day,
            datetolong(TO_CHAR($$cut_date$$::DATE ,'YYYY-MM-DD')) AS cut_datetime
        FROM
            centers
        WHERE
            id IN ($$scope$$)
    )
    ,
    cc_trans AS
    (
        SELECT
            cc.center,
            cc.id,
            cc.subid,
            cc.transfer_from_clipcard_center,
            cc.transfer_from_clipcard_id,
            cc.transfer_from_clipcard_subid,
            cc.center AS current_cc_center,
            cc.id        current_cc_id,
            cc.subid  AS current_cc_subid,
            params.cut_date,
            params.cut_end_of_day,
            params.cut_datetime
        FROM
            params
        JOIN
            clipcards cc
        ON
            cc.center = params.center
        LEFT JOIN
            clipcards cc2
        ON
            cc.center = cc2.transfer_from_clipcard_center
        AND cc.id = cc2.transfer_from_clipcard_id
        AND cc.subid = cc2.transfer_from_clipcard_subid
        WHERE
            cc2.id IS NULL
        AND (CC.CANCELLED = false
            OR  CC.CANCELLATION_TIME > params.cut_end_of_day)
        AND CC.CLIPS_INITIAL > 0
        AND cc.center IN ($$scope$$)
        UNION ALL
        SELECT
            cc.center,
            cc.id,
            cc.subid,
            cc.transfer_from_clipcard_center,
            cc.transfer_from_clipcard_id,
            cc.transfer_from_clipcard_subid,
            cc_trans.current_cc_center,
            cc_trans.current_cc_id,
            cc_trans.current_cc_subid,
            cc_trans.cut_date,
            cc_trans.cut_end_of_day,
            cc_trans.cut_datetime
        FROM
            clipcards cc
        JOIN
            cc_trans
        ON
            cc.center = cc_trans.transfer_from_clipcard_center
        AND cc.id = cc_trans.transfer_from_clipcard_id
        AND cc.subid = cc_trans.transfer_from_clipcard_subid
    )
    ,
    CTE AS MATERIALIZED
    (
        SELECT DISTINCT
            SCL.CENTER AS SCL_CENTER,
            SCL.ID     AS SCL_ID,
            SCL.SUBID  AS SCL_SUBID,
            cc_trans.center,
            cc_trans.id,
            cc_trans.subid,
            cut_date,
            cut_end_of_day,
            cut_datetime
        FROM
            cc_trans
        JOIN
            STATE_CHANGE_LOG AS SCL
        ON
            scl.center = cc_trans.current_cc_center
        AND scl.id = cc_trans.current_cc_id
        AND scl.subid= cc_trans.current_cc_subid
        WHERE
            (SCL.ENTRY_TYPE = 6
            AND SCL.STATEID = 1
            AND SCL.BOOK_START_TIME < cc_trans.cut_end_of_day
            AND (SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= cc_trans.cut_end_of_day
                AND (SCL.ENTRY_END_TIME IS NULL
                    OR  SCL.ENTRY_END_TIME >= cc_trans.cut_datetime)) )
    )
    ,
    cc_used AS
    (
        SELECT
            CTE.SCL_CENTER AS center,
            CTE.SCL_ID     AS id,
            CTE.SCL_SUBID  AS subid,
            cut_date,
            cut_end_of_day,
            cut_datetime,
            COALESCE(-SUM(CCU.CLIPS),0) AS USEDCLIPS
        FROM
            CTE
        LEFT JOIN
            CARD_CLIP_USAGES AS CCU
        ON
            (ccu.CARD_CENTER = CTE.center
            AND ccu.CARD_ID = CTE.id
            AND ccu.CARD_SUBID = CTE.subid
            AND CCU.TYPE NOT IN ('TRANSFER_TO',
                                 'TRANSFER_FROM'))
        AND (CCU.STATE IN ('ACTIVE',
                           'PLANNED')
            AND CCU.TIME <= cte.cut_end_of_day )
        GROUP BY
            CTE.SCL_CENTER ,
            CTE.SCL_ID ,
            CTE.SCL_SUBID,
            cut_date,
            cut_end_of_day,
            cut_datetime
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
    LEAST(((CLIPSINITIAL - COALESCE(USEDCLIPS, 0)) * ((((TOTALAMOUNT + COALESCE (SPONSORTOTALAMOUNT
    , 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL)), ((
    (TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE (VATRATE, 0) + 1)) / GREATEST
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
                    (CCU1.CARD_CENTER = CC1.CENTER
                    AND CCU1.CARD_ID = CC1.ID
                    AND CCU1.CARD_SUBID = CC1.SUBID
                    AND CCU1.TYPE = 'TRANSFER_TO')
                WHERE
                    (CC1.INVOICELINE_CENTER = IL.CENTER
                    AND CC1.INVOICELINE_ID = IL.ID
                    AND CC1.INVOICELINE_SUBID = IL.SUBID
                    AND CC1.OWNER_CENTER = IL.PERSON_CENTER
                    AND CC1.OWNER_ID = IL.PERSON_ID
                    AND CCU1.ID IS NULL)) AS CLIPCARDSCOUNT,
            USEDCLIPS
        FROM
            cc_used
        JOIN
            clipcards AS CC
        ON
            cc.center = cc_used.center
        AND cc.id = cc_used.id
        AND cc.subid= cc_used.subid
        INNER JOIN
            INVOICE_LINES_MT AS IL
        ON
            (CC.INVOICELINE_CENTER = IL.CENTER
            AND CC.INVOICELINE_ID = IL.ID
            AND CC.INVOICELINE_SUBID = IL.SUBID)
        INNER JOIN
            INVOICES AS INV
        ON
            (IL.CENTER = INV.CENTER
            AND IL.ID = INV.ID)
        INNER JOIN
            PRODUCTS AS PR
        ON
            (IL.PRODUCTCENTER = PR.CENTER
            AND IL.PRODUCTID = PR.ID)
        LEFT JOIN
            INVOICELINES_VAT_AT_LINK AS ILVATL
        ON
            (ILVATL.INVOICELINE_CENTER = IL.CENTER
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
            (IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
            AND IL2.ID = INV.SPONSOR_INVOICE_ID
            AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID)
        WHERE
            ((CC.CANCELLED = false
                OR  CC.CANCELLATION_TIME > cc_used.cut_end_of_day)
            AND (USEDCLIPS < CC.CLIPS_INITIAL
                OR  USEDCLIPS IS NULL)
            AND INV.TRANS_TIME <= cc_used.cut_end_of_day
            AND CC.CLIPS_INITIAL > 0 )
        ORDER BY
            CC.OWNER_CENTER,
            CC.OWNER_ID,
            CC.CLIPS_LEFT DESC) AS subQuery