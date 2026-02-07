SELECT
    "SALES ACCOUNT",
    "SALES ACCOUNT VAT",
    "EXPENCE ACCOUNT",
    "EXPENCE ACCOUNT VAT",
    "WRITE OFF ACCOUNT",
    "WRITE OFF ACCOUNT VAT",
    "REFUND ACCOUNT",
    "REFUND ACCOUNT VAT",
    COUNT("WRITE OFF ACCOUNT") "AFFECTED PRODUCTS"
FROM
    (
        SELECT
            CASE
                WHEN sales_acc.CENTER IS NOT NULL
                THEN 'OK'
                ELSE pac.SALES_ACCOUNT_GLOBALID || ' is missing from center ' || p.CENTER
            END AS "SALES ACCOUNT",
            CASE
                WHEN sales_acc.VAT_CENTER IS NULL
                THEN 'OK'
                WHEN sales_acc.VAT_CENTER IS NOT NULL
                    AND sales_acc_vat.CENTER IS NOT NULL
                THEN 'OK'
                ELSE 'Missing'
            END AS "SALES ACCOUNT VAT",
            CASE
                WHEN exp_acc.CENTER IS NOT NULL
                THEN 'OK'
                ELSE pac.EXPENSES_ACCOUNT_GLOBALID || ' is missing from center ' || p.CENTER
            END AS "EXPENCE ACCOUNT",
            CASE
                WHEN exp_acc.VAT_CENTER IS NULL
                THEN 'OK'
                WHEN exp_acc.VAT_CENTER IS NOT NULL
                    AND exp_acc_vat.CENTER IS NOT NULL
                THEN 'OK'
                ELSE 'Missing'
            END AS "EXPENCE ACCOUNT VAT",
            CASE
                WHEN wri_acc.CENTER IS NOT NULL
                THEN 'OK'
                ELSE pac.WRITE_OFF_ACCOUNT_GLOBALID || ' is missing from center ' || p.CENTER
            END AS "WRITE OFF ACCOUNT",
            CASE
                WHEN wri_acc.VAT_CENTER IS NULL
                THEN 'OK'
                WHEN wri_acc.VAT_CENTER IS NOT NULL
                    AND wri_acc_vat.CENTER IS NOT NULL
                THEN 'OK'
                ELSE 'Missing'
            END AS "WRITE OFF ACCOUNT VAT",
            CASE
                WHEN ref_acc.CENTER IS NOT NULL
                THEN 'OK'
                ELSE pac.REFUND_ACCOUNT_GLOBALID || ' is missing from center ' || p.CENTER
            END AS "REFUND ACCOUNT",
            CASE
                WHEN ref_acc.VAT_CENTER IS NULL
                THEN 'OK'
                WHEN ref_acc.VAT_CENTER IS NOT NULL
                    AND ref_acc_vat.CENTER IS NOT NULL
                THEN 'OK'
                ELSE 'Missing'
            END AS "REFUND ACCOUNT VAT"
        FROM
            PRODUCTS p
        LEFT JOIN PRODUCT_GROUP pg
        ON
            pg.ID = p.PRIMARY_PRODUCT_GROUP_ID
        JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
        ON
            pac.ID = pg.PRODUCT_ACCOUNT_CONFIG_ID
        LEFT JOIN ACCOUNTS sales_acc
        ON
            sales_acc.CENTER = p.CENTER
            AND sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
            AND sales_acc.BLOCKED = 0
        LEFT JOIN ACCOUNTS sales_acc_vat
        ON
            sales_acc_vat.CENTER = sales_acc.VAT_CENTER
            AND sales_acc_vat.ID = sales_acc.VAT_ID
            AND sales_acc_vat.BLOCKED = 0
        LEFT JOIN ACCOUNTS exp_acc
        ON
            exp_acc.CENTER = p.CENTER
            AND exp_acc.GLOBALID = pac.EXPENSES_ACCOUNT_GLOBALID
            AND exp_acc.BLOCKED = 0
        LEFT JOIN ACCOUNTS exp_acc_vat
        ON
            exp_acc_vat.CENTER = exp_acc.VAT_CENTER
            AND exp_acc_vat.ID = exp_acc.VAT_ID
            AND exp_acc_vat.BLOCKED = 0
        LEFT JOIN ACCOUNTS ref_acc
        ON
            ref_acc.CENTER = p.CENTER
            AND ref_acc.GLOBALID = pac.REFUND_ACCOUNT_GLOBALID
            AND ref_acc.BLOCKED = 0
        LEFT JOIN ACCOUNTS ref_acc_vat
        ON
            ref_acc_vat.CENTER = ref_acc.VAT_CENTER
            AND ref_acc_vat.ID = ref_acc.VAT_ID
            AND exp_acc_vat.BLOCKED = 0
        LEFT JOIN ACCOUNTS wri_acc
        ON
            wri_acc.CENTER = p.CENTER
            AND wri_acc.GLOBALID = pac.WRITE_OFF_ACCOUNT_GLOBALID
            AND wri_acc.BLOCKED = 0
        LEFT JOIN ACCOUNTS wri_acc_vat
        ON
            wri_acc_vat.CENTER = wri_acc.VAT_CENTER
            AND wri_acc_vat.ID = wri_acc.VAT_ID
            AND wri_acc_vat.BLOCKED = 0
        WHERE
            p.PRODUCT_ACCOUNT_CONFIG_ID IS NULL
            AND p.BLOCKED = 0
            AND p.PTYPE = 1
            and p.center in (:scope)
    )
GROUP BY
    "SALES ACCOUNT",
    "SALES ACCOUNT VAT",
    "EXPENCE ACCOUNT",
    "EXPENCE ACCOUNT VAT",
    "WRITE OFF ACCOUNT",
    "WRITE OFF ACCOUNT VAT",
    "REFUND ACCOUNT",
    "REFUND ACCOUNT VAT"