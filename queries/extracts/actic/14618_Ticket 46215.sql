-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TYPE,
    INVID,
    CASH_REGISTER_ID,
    RECEIPT_ID,
    RECEIPT_TIME,
    ORG_NR,
    "COPY/NORMAL",
    NVL(CONTROL_DEVICE_ID,MAX (CONTROL_DEVICE_ID) over (PARTITION BY CASHREGISTER_CENTER,CASHREGISTER_ID)) CONTROL_DEVICE_ID,
    TOTAL_AMOUNT                                                                                           RECEIPT_AMOUNT,
    SUM(
        CASE
            WHEN VAT_PERCENT = 0
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_0,
    SUM(
        CASE
            WHEN VAT_PERCENT = 5
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_5,
    SUM(
        CASE
            WHEN VAT_PERCENT = 6
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_6,
    SUM(
        CASE
            WHEN VAT_PERCENT = 12
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_12,
    SUM(
        CASE
            WHEN VAT_PERCENT = 25
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_25
FROM
    (
        SELECT
            inv.CASHREGISTER_CENTER,
            inv.CASHREGISTER_ID,
            'INVOICE'                                                             TYPE,
            inv.CENTER || 'inv' || inv.ID                                         invid,
            'CL-ACTIC-' || inv.CASHREGISTER_CENTER || 'cr' || inv.CASHREGISTER_ID CASH_REGISTER_ID,
            inv.RECEIPT_ID,
            exerpro.longToDate(inv.ENTRY_TIME) receipt_time,
            c.ORG_CODE                         org_nr,
            'NORMAL' "COPY/NORMAL",
            NVL(inv.CONTROL_DEVICE_ID,crr.CONTROL_DEVICE_ID) CONTROL_DEVICE_ID,
            invl.TOTAL_AMOUNT,
            act.AMOUNT  NONE_VAT_AMOUNT,
            act2.AMOUNT VAT_AMOUNT,
            CASE
                WHEN act.AMOUNT != 0
                THEN ROUND(((invl.TOTAL_AMOUNT / act.AMOUNT) -1) * 100)
                ELSE 0
            END AS VAT_PERCENT
        FROM
            INVOICES inv
        JOIN
            INVOICELINES invl
        ON
            invl.CENTER = inv.CENTER
            AND invl.ID = inv.ID
        LEFT JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = invl.ACCOUNT_TRANS_CENTER
            AND act.ID = invl.ACCOUNT_TRANS_ID
            AND act.SUBID = invl.ACCOUNT_TRANS_SUBID
        LEFT JOIN
            ACCOUNT_TRANS act2
        ON
            act2.MAIN_TRANSCENTER = act.CENTER
            AND act2.MAIN_TRANSID = act.ID
            AND act2.MAIN_TRANSSUBID = act.SUBID
        LEFT JOIN
            CASHREGISTERREPORTS crr
        ON
            inv.ENTRY_TIME BETWEEN crr.STARTTIME AND crr.REPORTTIME
            AND crr.CENTER = inv.CASHREGISTER_CENTER
            AND crr.ID = inv.CASHREGISTER_ID
        JOIN
            CENTERS c
        ON
            c.id = inv.CASHREGISTER_CENTER
        JOIN
            SYSTEMPROPERTIES sp
        ON
            sp.GLOBALID = 'ControlUnitRequired'
            AND sp.TXTVALUE = 'true'
            AND sp.SCOPE_ID = c.ID
        WHERE

            inv.ENTRY_TIME BETWEEN 1386543600000 AND 1414015200000
            /* Swedish clubs */
            AND inv.CASHREGISTER_CENTER BETWEEN 1 AND 200

            /* The transactin should have gone via the cash regsiter */
            AND inv.CASHREGISTER_CENTER IS NOT NULL )
GROUP BY
    CASHREGISTER_ID,
    CASHREGISTER_CENTER,
    INVID,
    CASH_REGISTER_ID,
    RECEIPT_ID,
    RECEIPT_TIME,
    ORG_NR,
    "COPY/NORMAL",
    CONTROL_DEVICE_ID,
    TOTAL_AMOUNT,
    TYPE
UNION
SELECT
    TYPE,
    INVID,
    CASH_REGISTER_ID,
    RECEIPT_ID,
    RECEIPT_TIME,
    ORG_NR,
    "COPY/NORMAL",
    NVL(CONTROL_DEVICE_ID,MAX (CONTROL_DEVICE_ID) over (PARTITION BY CASHREGISTER_CENTER,CASHREGISTER_ID)) CONTROL_DEVICE_ID,
    TOTAL_AMOUNT                                                                                           RECEIPT_AMOUNT,
    SUM(
        CASE
            WHEN VAT_PERCENT = 0
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_0,
    SUM(
        CASE
            WHEN VAT_PERCENT = 5
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_5,
    SUM(
        CASE
            WHEN VAT_PERCENT = 6
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_6,
    SUM(
        CASE
            WHEN VAT_PERCENT = 12
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_12,
    SUM(
        CASE
            WHEN VAT_PERCENT = 25
            THEN VAT_AMOUNT
            ELSE 0
        END) AS VAT_25
FROM
    (
        SELECT
            'CREDIT_NOTE' TYPE,
            cn.CASHREGISTER_CENTER,
            cn.CASHREGISTER_ID,
            cn.CENTER || 'cn' || cn.ID                                          invid,
            'CL-ACTIC-' || cn.CASHREGISTER_CENTER || 'cr' || cn.CASHREGISTER_ID CASH_REGISTER_ID,
            cn.RECEIPT_ID,
            exerpro.longToDate(cn.ENTRY_TIME) receipt_time,
            c.ORG_CODE                        org_nr,
            'NORMAL' "COPY/NORMAL",
            NVL(cn.CONTROL_DEVICE_ID,crr.CONTROL_DEVICE_ID) CONTROL_DEVICE_ID,
            cnl.TOTAL_AMOUNT,
            act.AMOUNT  NONE_VAT_AMOUNT,
            act2.AMOUNT VAT_AMOUNT,
            CASE
                WHEN act.AMOUNT != 0
                THEN ROUND(((cnl.TOTAL_AMOUNT / act.AMOUNT) -1) * 100)
                ELSE 0
            END AS VAT_PERCENT
        FROM
            CREDIT_NOTES cn
        JOIN
            CREDIT_NOTE_LINES cnl
        ON
            cnl.CENTER = cn.CENTER
            AND cnl.ID = cn.ID
        LEFT JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = cnl.ACCOUNT_TRANS_CENTER
            AND act.ID = cnl.ACCOUNT_TRANS_ID
            AND act.SUBID = cnl.ACCOUNT_TRANS_SUBID
        LEFT JOIN
            ACCOUNT_TRANS act2
        ON
            act2.MAIN_TRANSCENTER = act.CENTER
            AND act2.MAIN_TRANSID = act.ID
            AND act2.MAIN_TRANSSUBID = act.SUBID
        LEFT JOIN
            CASHREGISTERREPORTS crr
        ON
            cn.ENTRY_TIME BETWEEN crr.STARTTIME AND crr.REPORTTIME
            AND crr.CENTER = cn.CASHREGISTER_CENTER
            AND crr.ID = cn.CASHREGISTER_ID
        JOIN
            CENTERS c
        ON
            c.id = cn.CASHREGISTER_CENTER
        JOIN
            SYSTEMPROPERTIES sp
        ON
            sp.GLOBALID = 'ControlUnitRequired'
            AND sp.TXTVALUE = 'true'
            AND sp.SCOPE_ID = c.ID
        WHERE

            cn.ENTRY_TIME BETWEEN 1386543600000 AND 1414015200000
            /* Swedish clubs */
            AND cn.CASHREGISTER_CENTER BETWEEN 1 AND 200

            /* The transactin should have gone via the cash regsiter */
            AND cn.CASHREGISTER_CENTER IS NOT NULL)
GROUP BY
    CASHREGISTER_CENTER,
    CASHREGISTER_ID,
    INVID,
    CASH_REGISTER_ID,
    RECEIPT_ID,
    RECEIPT_TIME,
    ORG_NR,
    "COPY/NORMAL",
    CONTROL_DEVICE_ID,
    TOTAL_AMOUNT,
    TYPE