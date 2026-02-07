WITH
    v_main AS
    (
        SELECT
            p.center || 'p' || p.id AS MemberId,
            p.fullname ,
            c.id ,
            c.shortname ,
            ext_debt.totalDue ,
            ext_debt.dueDate ,
            CASE
                WHEN TRUNC(ip.end_date) > TRUNC(exerpsysdate())
                THEN inst_prod.product_name
                ELSE NULL
            END AS ACTIVE_PROD_NAME,
            ip.end_date,
            ip.id AS inst_plan_id
        FROM
            PERSONS p
        JOIN
            PERSONS tp
        ON
            tp.transfers_current_prs_center = p.center
            AND tp.transfers_current_prs_id = p.id
        JOIN
            CENTERS c
        ON
            c.ID = p.CENTER
        JOIN
            installment_plans ip
        ON
            ip.person_center = tp.center
            AND ip.person_id = tp.id
        JOIN
            (
                SELECT
                    ar.customercenter,
                    ar.customerid,
                    SUM(art.UNSETTLED_AMOUNT)   AS totalDue,
                    MAX(art.due_date) AS dueDate
                FROM
                    ACCOUNT_RECEIVABLES ar
                JOIN
                    AR_TRANS art
                ON
                    art.CENTER = ar.CENTER
                    AND art.ID = ar.ID
                    AND ar.AR_TYPE = 5
                WHERE
                    art.DUE_DATE < exerpsysdate()
                    AND art.UNSETTLED_AMOUNT < 0
                GROUP BY
                    ar.customercenter,
                    ar.customerid ) ext_debt
        ON
            ext_debt.customercenter = p.center
            AND ext_debt.customerid = p.id
            -- Installment to invoicelines doesn't always has the link to get installment product. For API sales doesn't have the link
        JOIN
            (
                SELECT
                    installment_plan_id,
                    MIN(SUBSTR(art.text, 0, INSTR(art.text, '-')-1)) product_name
                FROM
                    ACCOUNT_RECEIVABLES ar
                JOIN
                    AR_TRANS art
                ON
                    art.CENTER = ar.CENTER
                    AND art.ID = ar.ID
                    AND ar.AR_TYPE = 6
                GROUP BY
                    art.installment_plan_id) inst_prod
        ON
            inst_prod.installment_plan_id = ip.id
        WHERE
            p.center IN ($$Scope$$)
    )
    ,
    v_pivot AS
    (
        SELECT
            v_main.* ,
            LEAD(ACTIVE_PROD_NAME,0) OVER (PARTITION BY MemberId ORDER BY end_date DESC) AS ActiveInstallmentPlan1 ,
            LEAD(ACTIVE_PROD_NAME,1) OVER (PARTITION BY MemberId ORDER BY end_date DESC) AS ActiveInstallmentPlan2 ,
            LEAD(ACTIVE_PROD_NAME,2) OVER (PARTITION BY MemberId ORDER BY end_date DESC) AS ActiveInstallmentPlan3,
            LEAD(ACTIVE_PROD_NAME,3) OVER (PARTITION BY MemberId ORDER BY end_date DESC) AS ActiveInstallmentPlan4,
            LEAD(ACTIVE_PROD_NAME,4) OVER (PARTITION BY MemberId ORDER BY end_date DESC) AS ActiveInstallmentPlan5,
            ROW_NUMBER() OVER (PARTITION BY MemberId ORDER BY end_date DESC)             AS installSEQ
        FROM
            v_main
    )
SELECT
    MemberId  AS "Member Id",
    fullname  AS "Member Name",
    id        AS "Home Club Id",
    shortname AS "Home Club Name",
    totalDue  AS "Overdue Debt",
    dueDate   AS "Overdue Due Date",
    ActiveInstallmentPlan1,
    ActiveInstallmentPlan2,
    ActiveInstallmentPlan3,
    ActiveInstallmentPlan4,
    ActiveInstallmentPlan5
FROM
    v_pivot
WHERE
    installSEQ=1