-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    OWNER_CENTER || 'p' || OWNER_ID personID,
    SU_CENTER || 'ss' || SU_ID SubID,
    --COUNT(*) TOTAL,
    CASH,
    EFT,
    COLLECTED PR_YES,
    UNCOLLECTED PR_NO,
    UPFRONT UPFRONT,
    FROZEN FROZEN,
    FREEDAYS FREEDAYS,
    BELOW_MIN BELOW_MIN,
    OTHER_PAYER OTHER_PAYER,
    CORP_PAYER CORP_PAYER,
    ENDED ENDED,
    LATER LATER,
    
        CASE
            WHEN EFT = 1
                AND UNCOLLECTED = 1
                AND UPFRONT + CORP_PAYER + OTHER_PAYER + ENDED + FROZEN + FREEDAYS + LATER + BELOW_MIN = 0
            THEN 1
            ELSE 0
        END AS OTHER
/*    SUM(CASH) CASH,
    SUM(EFT) EFT,
    SUM(COLLECTED) PR_YES,
    SUM(UNCOLLECTED) PR_NO,
    SUM(UPFRONT) UPFRONT,
    SUM(FROZEN) FROZEN,
    SUM(FREEDAYS) FREEDAYS,
    SUM(BELOW_MIN) BELOW_MIN,
    SUM(OTHER_PAYER) OTHER_PAYER,
    SUM(CORP_PAYER) CORP_PAYER,
    SUM(ENDED) ENDED,
    SUM(LATER) LATER,
    SUM(
        CASE
            WHEN EFT = 1
                AND UNCOLLECTED = 1
                AND UPFRONT + CORP_PAYER + OTHER_PAYER + ENDED + FROZEN + FREEDAYS + LATER + BELOW_MIN = 0
            THEN 1
            ELSE 0
        END) AS OTHER
*/
FROM
    (
        SELECT DISTINCT
            SU.CENTER AS SU_CENTER,
            SU.ID AS SU_ID,
            SU.OWNER_CENTER AS OWNER_CENTER,
            SU.OWNER_ID AS OWNER_ID,
            DECODE(ST.ST_TYPE, 0, 'CASH', 1, 'EFT', 'ERROR') type,
            CASE
                WHEN ST.ST_TYPE = 0
                THEN 1
                ELSE 0
            END AS CASH,
            CASE
                WHEN ST.ST_TYPE = 1
                THEN 1
                ELSE 0
            END AS EFT,
            CASE
                WHEN AR.CUSTOMERCENTER = SU.OWNER_CENTER
                    AND AR.CUSTOMERID = SU.OWNER_ID
                    AND ST.ST_TYPE = 1
                    AND EXISTS
                    (
                        SELECT
                            *
                        FROM
                            FW.PAYMENT_REQUEST_SPECIFICATIONS PRS
                        LEFT JOIN PAYMENT_REQUESTS par
                        ON
                            par.INV_COLL_CENTER = PRS.CENTER
                            AND par.INV_COLL_ID = PRS.ID
                            AND par.INV_COLL_SUBID = PRS.SUBID
                        WHERE
                            ART.PAYREQ_SPEC_CENTER = PRS.CENTER
                            AND ART.PAYREQ_SPEC_ID = PRS.ID
                            AND ART.PAYREQ_SPEC_SUBID = PRS.SUBID
                            AND par.REQ_DATE = :DeductionDate
                    )
                THEN 1
                ELSE 0
            END AS COLLECTED,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND
                    (
                        AR.CUSTOMERCENTER <> SU.OWNER_CENTER
                        OR AR.CUSTOMERID <> SU.OWNER_ID
                        OR NOT EXISTS
                        (
                            SELECT
                                *
                            FROM
                                FW.PAYMENT_REQUEST_SPECIFICATIONS PRS
                            LEFT JOIN PAYMENT_REQUESTS par
                            ON
                                par.INV_COLL_CENTER = PRS.CENTER
                                AND par.INV_COLL_ID = PRS.ID
                                AND par.INV_COLL_SUBID = PRS.SUBID
                            WHERE
                                ART.PAYREQ_SPEC_CENTER = PRS.CENTER
                                AND ART.PAYREQ_SPEC_ID = PRS.ID
                                AND ART.PAYREQ_SPEC_SUBID = PRS.SUBID
                                AND par.REQ_DATE = :DeductionDate
                        )
                    )
                THEN 1
                ELSE 0
            END AS UNCOLLECTED,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND AR.CUSTOMERCENTER = SU.OWNER_CENTER
                    AND AR.CUSTOMERID = SU.OWNER_ID
                    AND IL.CENTER = SU.INVOICELINE_CENTER
                    AND IL.ID = SU.INVOICELINE_ID
                THEN 1
                ELSE 0
            END AS UPFRONT,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND IL.SPONSOR_INVOICE_SUBID IS NOT NULL
                THEN 1
                ELSE 0
            END AS CORP_PAYER,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND
                    (
                        AR.CUSTOMERCENTER <> SU.OWNER_CENTER
                        OR AR.CUSTOMERID <> SU.OWNER_ID
                    )
                THEN 1
                ELSE 0
            END AS OTHER_PAYER,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND AR.CUSTOMERCENTER = SU.OWNER_CENTER
                    AND AR.CUSTOMERID = SU.OWNER_ID
                    AND SPP.SPP_TYPE NOT IN (2,7)
                    AND SPP.SPP_TYPE NOT IN (3)
                    AND EXISTS
                    (
                        SELECT
                            *
                        FROM
                            FW.PAYMENT_REQUEST_SPECIFICATIONS prs
                        WHERE
                            ART.PAYREQ_SPEC_CENTER = prs.CENTER
                            AND ART.PAYREQ_SPEC_ID = prs.ID
                            AND ART.PAYREQ_SPEC_SUBID = prs.SUBID
                            AND
                            (
                                prs.REQUESTED_AMOUNT = 0
                                OR prs.REQUESTED_AMOUNT IS NULL
                            )
                    )
                THEN 1
                ELSE 0
            END AS BELOW_MIN,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND SU.END_DATE < :PeriodStartDate
                THEN 1
                ELSE 0
            END AS ENDED,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND SPP.SPP_TYPE IN (2,7)
                THEN 1
                ELSE 0
            END AS FROZEN,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND SPP.SPP_TYPE IN (3)
                THEN 1
                ELSE 0
            END AS FREEDAYS,
            CASE
                WHEN ST.ST_TYPE = 1
                    AND EXISTS
                    (
                        SELECT
                            *
                        FROM
                            FW.SUBSCRIPTIONPERIODPARTS SPP1
                        WHERE
                            SPP1.CENTER = SU.CENTER
                            AND SPP1.ID = SU.ID
                            AND SPP1.FROM_DATE <= :PeriodStartDate
                            AND SPP1.TO_DATE >= :PeriodStartDate
                            AND SPP1.ENTRY_TIME > :ActiveDate + (1000*60*60*24)
                    )
                THEN 1
                ELSE 0
            END AS LATER,
            SU.START_DATE AS SU_START_DATE,
            SU.SUBSCRIPTION_PRICE AS SU_SUBSCRIPTION_PRICE,
            PR.PRIMARY_PRODUCT_GROUP_ID AS PR_PRIMARY_PRODUCT_GROUP_ID,
            PR.GLOBALID AS PR_GLOBALID,
            PR.NAME AS PR_NAME,
            ST.ST_TYPE AS ST_ST_TYPE,
            ST.PERIODCOUNT AS ST_PERIODCOUNT,
            ST.PERIODUNIT AS ST_PERIODUNIT,
            SPP.SUBSCRIPTION_PRICE AS SPP_SUBSCRIPTION_PRICE,
            SCL1.STATEID AS SCL1_STATEID
        FROM
            SUBSCRIPTIONS SU
        INNER JOIN SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
            )
        INNER JOIN PRODUCTS PR
        ON
            (
                ST.CENTER = PR.CENTER
                AND ST.ID = PR.ID
            )
        INNER JOIN STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2
            )
        LEFT JOIN SUBSCRIPTIONPERIODPARTS SPP
        ON
            (
                SPP.CENTER = SU.CENTER
                AND SPP.ID = SU.ID
                AND SPP.FROM_DATE <= :PeriodStartDate
                AND SPP.TO_DATE >= :PeriodStartDate
                AND SPP.ENTRY_TIME < :ActiveDate + (1000*60*60*24)
                AND
                (
                    (
                        SPP.SPP_STATE = 1
                    )
                    OR
                    (
                        SPP.SPP_STATE <> 1
                        AND SPP.CANCELLATION_TIME > :ActiveDate + (1000*60*60*24)
                    )
                )
            )
        LEFT JOIN SPP_INVOICELINES_LINK SIL
        ON
            SPP.CENTER = SIL.PERIOD_CENTER
            AND SPP.ID = SIL.PERIOD_ID
            AND SPP.SUBID = SIL.PERIOD_SUBID
        LEFT JOIN INVOICELINES IL
        ON
            IL.CENTER = SIL.INVOICELINE_CENTER
            AND IL.ID = SIL.INVOICELINE_ID
            AND IL.SUBID = SIL.INVOICELINE_SUBID
        LEFT JOIN INVOICES INV
        ON
            IL.CENTER = INV.CENTER
            AND IL.ID = INV.ID
        LEFT JOIN AR_TRANS ART
        ON
            ART.REF_CENTER = INV.CENTER
            AND ART.REF_ID = INV.ID
            AND ART.REF_TYPE = 'INVOICE'
        LEFT JOIN ACCOUNT_RECEIVABLES AR
        ON
            AR.CENTER = ART.CENTER
            AND AR.ID = ART.ID
        WHERE
            (
                SU.CENTER = :Center
                AND SCL1.ENTRY_TYPE = 2
                AND SCL1.STATEID IN (2, 4)
                AND SCL1.BOOK_START_TIME < :ActiveDate + (1000*60*60*24)
                AND
                (
                    SCL1.BOOK_END_TIME IS NULL
                    OR SCL1.BOOK_END_TIME >= :ActiveDate + (1000*60*60*24)
                )
                AND SCL1.ENTRY_START_TIME < :ActiveDate + (1000*60*60*24)
            )
    )