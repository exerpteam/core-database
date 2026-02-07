WITH
    RECURSIVE CTE AS MATERIALIZED
    (
        SELECT DISTINCT
            SCL.CENTER AS SCL_CENTER,
            SCL.ID     AS SCL_ID,
            SCL.SUBID  AS SCL_SUBID
        FROM
            STATE_CHANGE_LOG AS SCL
        JOIN
            (
                SELECT DISTINCT
                ON
                    (
                        act.center) act.center,
                    act.entry_time AS time_of_deferral
                FROM
                    deferrals AS de
                JOIN
                    account_trans AS act
                ON
                    de.defer_acc_trans_center = act.center
                AND de.defer_acc_trans_id = act.id
                AND de.defer_acc_trans_subid = act.subid
                WHERE
                    act.trans_time = GETENDOFDAY((:cutoff)::DATE::VARCHAR, act.CENTER)
                AND de.revenue_type = 'CLIPCARD'
                ORDER BY
                    act.center,
                    act.entry_time) dft
        ON
            dft.center=scl.center
        WHERE
            (
                SCL.ENTRY_TYPE = 6
            AND SCL.STATEID = 1
            AND SCL.BOOK_START_TIME < GETENDOFDAY((:cutoff)::DATE::VARCHAR, SCL.CENTER)
            AND (
                    SCL.BOOK_END_TIME IS NULL
                OR  SCL.BOOK_END_TIME >= GETENDOFDAY((:cutoff)::DATE::VARCHAR, SCL.CENTER))
            AND (
                    SCL.ENTRY_END_TIME IS NULL
                OR  SCL.ENTRY_END_TIME >= dft.time_of_deferral )
            AND SCL.CENTER IN (:scope) )
    )
    ,
    CC_TRANS AS MATERIALIZED
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
        INNER JOIN
            CTE
        ON
            (
                CC.CENTER = CTE.SCL_CENTER
            AND CC.ID = CTE.SCL_ID
            AND CC.SUBID = CTE.SCL_SUBID)
        WHERE
            ((
                    CC.CANCELLED = false
                OR  CC.CANCELLATION_TIME > GETENDOFDAY((:cutoff)::DATE::VARCHAR, CC.CENTER))
            AND CC.CLIPS_INITIAL > 0)
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
    CC_USED AS
    (
        SELECT
            CC_TRANS.CURRENT_CC_CENTER   AS CENTER,
            CC_TRANS.CURRENT_CC_ID       AS ID,
            CC_TRANS.CURRENT_CC_SUBID    AS SUBID,
            COALESCE(-SUM(CCU.CLIPS), 0) AS USEDCLIPS
        FROM
            CARD_CLIP_USAGES AS CCU
        JOIN
            (
                SELECT DISTINCT
                ON
                    (
                        act.center) act.center,
                    act.entry_time AS time_of_deferral
                FROM
                    deferrals AS de
                JOIN
                    account_trans AS act
                ON
                    de.defer_acc_trans_center = act.center
                AND de.defer_acc_trans_id = act.id
                AND de.defer_acc_trans_subid = act.subid
                WHERE
                    act.trans_time = GETENDOFDAY((:cutoff)::DATE::VARCHAR, act.CENTER)
                AND de.revenue_type = 'CLIPCARD'
                ORDER BY
                    act.center,
                    act.entry_time) dft
        ON
            ccu.card_center=dft.center
        RIGHT JOIN
            CC_TRANS
        ON
            (
                CCU.CARD_CENTER = CC_TRANS.CC_CENTER
            AND CCU.CARD_ID = CC_TRANS.CC_ID
            AND CCU.CARD_SUBID = CC_TRANS.CC_SUBID
            AND CCU.TYPE NOT IN ('TRANSFER_TO',
                                 'TRANSFER_FROM')
            AND ((
                        CCU.ACTIVATION_TIMESTAMP IS NULL
                    AND CCU.STATE <> 'PLANNED'
                    AND CCU.TIME <= GETENDOFDAY((:cutoff)::DATE::VARCHAR, CCU.CARD_CENTER))
                OR  CCU.ACTIVATION_TIMESTAMP <= GETENDOFDAY((:cutoff)::DATE::VARCHAR,
                    CCU.CARD_CENTER))
            AND (
                    CCU.CANCELLATION_TIMESTAMP IS NULL
                OR  CCU.CANCELLATION_TIMESTAMP > GETENDOFDAY((:cutoff)::DATE::VARCHAR,
                    CCU.CARD_CENTER)
                AND CCU.CANCELLATION_TIMESTAMP < dft.time_of_deferral ) )
        GROUP BY
            CC_TRANS.CURRENT_CC_CENTER,
            CC_TRANS.CURRENT_CC_ID,
            CC_TRANS.CURRENT_CC_SUBID
    )
    ,
    report AS
    (
        SELECT
            CLIPCARDCENTER                                            AS "Center",
            CENTERNAME                                                AS "Center name",
            CLIPCARDCENTER ||'cc'|| CLIPCARDID ||'cc'|| CLIPCARDSUBID AS "Clipcard",
            longtodateC(SALESTIMESTAMP, CLIPCARDCENTER)               AS "Sales time",
            PERSONCENTER ||'p'|| PERSONID                             AS "Member ID",
            PRODUCTNAME                                               AS "Product name" ,
            PRODUCTGROUPNAME                                          AS "Product group",
            DEFERREDREVENUESALESACCOUNT                               AS "Deferred revenue account",
            DEFERREDREVENUESALESACCOUNTID                               AS "Deferred revenue account ID"
            ,
            DEFERREDREVENUELIABILITYACCOUNT AS "Deferred liability account",
            DEFERREDREVENUELIABILITYACCOUNTID AS "Deferred liability account ID",
            ((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / GREATEST(CLIPCARDSCOUNT, 1))::
            DECIMAL(12,2) AS "Amount including VAT",
            (((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) /
            GREATEST (CLIPCARDSCOUNT, 1))::DECIMAL(12,2) AS "Amount excluding VAT",
            CLIPSINITIAL                                 AS "Inital clips",
            COALESCE(USEDCLIPS, 0)                       AS "Realized clips",
            (CLIPSINITIAL - COALESCE(USEDCLIPS, 0))      AS "DeferredClips",
            ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) /
            GREATEST (CLIPCARDSCOUNT, 1)) / CLIPSINITIAL)::DECIMAL(12,2) AS "Amount per clip",
            (COALESCE(USEDCLIPS, 0) * ((((TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) /
            (COALESCE (VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) / CLIPSINITIAL))::DECIMAL
            (12,2) AS "Realized amount",
            LEAST(((CLIPSINITIAL - COALESCE(USEDCLIPS, 0)) * ((((TOTALAMOUNT + COALESCE
            (SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE, 0) + 1)) / GREATEST(CLIPCARDSCOUNT, 1)) /
            CLIPSINITIAL)), (( (TOTALAMOUNT + COALESCE(SPONSORTOTALAMOUNT, 0)) / (COALESCE(VATRATE,
            0) + 1)) / GREATEST (CLIPCARDSCOUNT, 1)))::DECIMAL(12,2) AS "Deferred amount"
        FROM
            (
                SELECT
                    c.shortname                    AS CENTERNAME,
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
                    acc_1.external_id              AS DEFERREDREVENUESALESACCOUNTID,
                    PAC.DEFER_LIA_ACCOUNT_GLOBALID AS DEFERREDREVENUELIABILITYACCOUNT,
                    acc_2.external_id              AS DEFERREDREVENUELIABILITYACCOUNTID,
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
                JOIN
                    centers c
                ON
                    cc.center=c.id
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
                    accounts acc_1
                ON
                    pac.DEFER_REV_ACCOUNT_GLOBALID=acc_1.globalid
                AND il.center=acc_1.center
                LEFT JOIN
                    accounts acc_2
                ON
                    pac.DEFER_LIA_ACCOUNT_GLOBALID=acc_2.globalid
                AND il.center=acc_2.center
                LEFT JOIN
                    INVOICE_LINES_MT AS IL2
                ON
                    (
                        IL2.CENTER = INV.SPONSOR_INVOICE_CENTER
                    AND IL2.ID = INV.SPONSOR_INVOICE_ID
                    AND IL2.SUBID = IL.SPONSOR_INVOICE_SUBID)
                WHERE
                    (
                        CC.CENTER IN (:scope)
                    AND (
                            CC.CANCELLED = false
                        OR  CC.CANCELLATION_TIME > GETENDOFDAY((:cutoff)::DATE::VARCHAR, CC.CENTER)
                        )
                    AND (
                            USEDCLIPS < CC.CLIPS_INITIAL
                        OR  USEDCLIPS IS NULL)
                    AND INV.TRANS_TIME <= GETENDOFDAY((:cutoff)::DATE::VARCHAR, CC.CENTER)
                    AND CC.CLIPS_INITIAL > 0)
                ORDER BY
                    CC.OWNER_CENTER,
                    CC.OWNER_ID,
                    CC.CLIPS_LEFT DESC) AS subQuery
    )
SELECT
    *
FROM
    report