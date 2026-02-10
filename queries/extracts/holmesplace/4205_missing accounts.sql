-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    c.ID,
    c.SHORTNAME,
    CASE
        WHEN sales_acc.CENTER IS NULL
        THEN pac.SALES_ACCOUNT_GLOBALID || ' missing for ' || c.ID
        WHEN sales_acc.BLOCKED = 1
        THEN pac.SALES_ACCOUNT_GLOBALID || ' blocked for ' || c.ID
        ELSE 'OK'
    END AS sales_account,
    CASE
        WHEN expenses_acc.CENTER IS NULL
        THEN pac.EXPENSES_ACCOUNT_GLOBALID || ' missing for ' || c.ID
        WHEN expenses_acc.BLOCKED = 1
        THEN pac.EXPENSES_ACCOUNT_GLOBALID || ' blocked for ' || c.ID
        ELSE 'OK'
    END AS expenses_account,
    CASE
        WHEN refund_acc.CENTER IS NULL
        THEN pac.REFUND_ACCOUNT_GLOBALID || ' missing for ' || c.ID
        WHEN refund_acc.BLOCKED = 1
        THEN pac.REFUND_ACCOUNT_GLOBALID || ' blocked for ' || c.ID
        ELSE 'OK'
    END AS refund_account,
    CASE
        WHEN write_off_acc.CENTER IS NULL
        THEN pac.WRITE_OFF_ACCOUNT_GLOBALID || ' missing for ' || c.ID
        WHEN write_off_acc.BLOCKED = 1
        THEN pac.WRITE_OFF_ACCOUNT_GLOBALID || ' blocked for ' || c.ID
        ELSE 'OK'
    END AS write_off_account
FROM
    (
        SELECT
            c_inner.id
        FROM
            AREA_CENTERS ac
        JOIN CENTERS c_inner
        ON
            c_inner.ID = ac.CENTER
        WHERE
            ac.AREA IN
            (
                SELECT
                    a.id id
                FROM
                    AREAS a START
                WITH a.id IN
                    (
                        SELECT
                            mpr_inner.SCOPE_ID
                        FROM
                            MASTERPRODUCTREGISTER mpr_inner
                        WHERE
                            mpr_inner.GLOBALID = :GLOBAL_ID
                    )
                    CONNECT BY prior a.id = a.parent
            )
    )
    all_centers
JOIN CENTERS c
ON
    c.ID = all_centers.id
JOIN MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = :GLOBAL_ID
JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
    pac.ID = mpr.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN ACCOUNTS sales_acc
ON
    sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND sales_acc.CENTER = c.ID
LEFT JOIN ACCOUNTS expenses_acc
ON
    expenses_acc.GLOBALID = pac.EXPENSES_ACCOUNT_GLOBALID
    AND expenses_acc.CENTER = c.ID
LEFT JOIN ACCOUNTS refund_acc
ON
    refund_acc.GLOBALID = pac.REFUND_ACCOUNT_GLOBALID
    AND refund_acc.CENTER = c.ID
LEFT JOIN ACCOUNTS write_off_acc
ON
    write_off_acc.GLOBALID = pac.WRITE_OFF_ACCOUNT_GLOBALID
    AND write_off_acc.CENTER = c.ID
WHERE
    c.id IN(:scope)
