SELECT
    "ID",
    "CENTER_ID",
    "SALE_TYPE",
    "PERSON_ID",
    "COMPANY_ID",
    "IS_COMPANY",
    "SALE_PERSON_ID",
    "ENTRY_DATETIME",
    "BOOK_DATETIME",
    "PRODUCT_CENTER",
    "PRODUCT_ID",
    "PRODUCT_TYPE",
    "PRODUCT_NORMAL_PRICE",
    "QUANTITY",
    "NET_AMOUNT",
    "VAT_AMOUNT",
    "TOTAL_AMOUNT",
    "SPONSOR_SALE_LOG_ID",
    "GL_DEBIT_ACCOUNT",
    "GL_CREDIT_ACCOUNT",
    "SALE_COMMISSION",
    "SALE_UNITS",
    "PERIOD_COMMISSION",
    "SOURCE_TYPE",
    "CREDIT_SALE_LOG_ID",
    "SALE_ID",
    "CASH_REGISTER_CENTER_ID",
    "TTS",
    "ETS",
    "FLAT_RATE_COMMISSION",
    "EXTERNAL_ID",
    "PAYER_PERSON_ID",
	"AGGREGATED_TRANSACTION_KEY",
	"INSTALLMENT_PLAN_ID"
FROM
    (
        SELECT
            il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID "ID",
            i.CENTER                                        "CENTER_ID",
            'INVOICE'                                       "SALE_TYPE",
            CASE
                WHEN p.SEX <> 'C'
                THEN
                    CASE
                        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                        ELSE p.EXTERNAL_ID
                    END
                ELSE NULL
            END "PERSON_ID",
            CASE
                WHEN payer.SEX = 'C'
                THEN
                    CASE
                        WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                            OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                        ELSE payer.EXTERNAL_ID
                    END
                ELSE NULL
            END "COMPANY_ID",
            CAST(
                CASE
                    WHEN payer.SEX = 'C'
                    THEN 1
                    ELSE 0
                END AS SMALLINT) "IS_COMPANY",
            CASE
                WHEN (sales_person.CENTER != sales_person.TRANSFERS_CURRENT_PRS_CENTER
                    OR  sales_person.id != sales_person.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = sales_person.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = sales_person.TRANSFERS_CURRENT_PRS_ID)
                ELSE sales_person.EXTERNAL_ID
            END                                               "SALE_PERSON_ID",
            i.ENTRY_TIME                                      "ENTRY_DATETIME",
            i.TRANS_TIME                                      "BOOK_DATETIME",
            prod.CENTER                                       "PRODUCT_CENTER",
            prod.CENTER || 'prod' || prod.ID                  "PRODUCT_ID",
			CASE 
				WHEN prod.PTYPE = 1 THEN 'RETAIL'
				WHEN prod.PTYPE = 2 THEN 'SERVICE'
				WHEN prod.PTYPE = 4 THEN 'CLIPCARD'
				WHEN prod.PTYPE = 5 THEN 'JOINING_FEE'
				WHEN prod.PTYPE = 6 THEN 'TRANSFER_FEE'
				WHEN prod.PTYPE = 7 THEN 'FREEZE_PERIOD'
				WHEN prod.PTYPE = 8 THEN 'GIFTCARD'
				WHEN prod.PTYPE = 9 THEN 'FREE_GIFTCARD'
				WHEN prod.PTYPE = 10 THEN 'SUBS_PERIOD'
				WHEN prod.PTYPE = 12 THEN 'SUBS_PRORATA'
				WHEN prod.PTYPE = 13 THEN 'ADDON'
				WHEN prod.PTYPE = 14 THEN 'ACCESS'
			ELSE 'UNKNOWN'
			END AS "PRODUCT_TYPE",
            il.PRODUCT_NORMAL_PRICE                         AS "PRODUCT_NORMAL_PRICE",
            il.QUANTITY                                     AS "QUANTITY",
            ROUND(il.net_amount,2)                          AS "NET_AMOUNT",
            ROUND(il.TOTAL_AMOUNT,2)-ROUND(il.net_amount,2) AS "VAT_AMOUNT",
            ROUND(il.TOTAL_AMOUNT, 2)                       AS "TOTAL_AMOUNT",
            CASE
                WHEN il.SPONSOR_INVOICE_SUBID IS NOT NULL
                THEN i.SPONSOR_INVOICE_CENTER || 'inv' || i.SPONSOR_INVOICE_ID || 'ln' ||
                    il.SPONSOR_INVOICE_SUBID
                ELSE NULL
            END                    "SPONSOR_SALE_LOG_ID",
            debitacc.EXTERNAL_ID   "GL_DEBIT_ACCOUNT",
            credacc.EXTERNAL_ID    "GL_CREDIT_ACCOUNT",
            il.sales_commission        AS "SALE_COMMISSION",
            il.sales_units             AS "SALE_UNITS",
            il.period_commission       AS "PERIOD_COMMISSION",
            COALESCE(crg.TYPE,'OTHER') AS "SOURCE_TYPE",
            NULL                       AS "CREDIT_SALE_LOG_ID",
            il.center||'inv'||il.id    AS "SALE_ID",
            crg.center                 AS "CASH_REGISTER_CENTER_ID",
            i.TRANS_TIME                  "TTS",
            i.ENTRY_TIME                  "ETS",
            il.flat_rate_commission AS    "FLAT_RATE_COMMISSION",
            il.external_id          AS    "EXTERNAL_ID",
            CASE
                WHEN payer.SEX != 'C'
                THEN
                    CASE
                        WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                            OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                        ELSE payer.EXTERNAL_ID
                    END
                ELSE NULL
            END "PAYER_PERSON_ID",
			CASE WHEN AGGREGATED_TRANSACTION_CENTER IS NOT NULL THEN
				act.AGGREGATED_TRANSACTION_CENTER||'agt'||act.AGGREGATED_TRANSACTION_ID
			ELSE
			    null
			END AS "AGGREGATED_TRANSACTION_KEY",	
			il.installment_plan_id AS "INSTALLMENT_PLAN_ID"
        FROM
            invoice_lines_mt il
        JOIN
            INVOICES i
        ON
            il.center = i.center
        AND il.id = i.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
        AND prod.id = il.PRODUCTID
        JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = il.ACCOUNT_TRANS_CENTER
        AND act.ID = il.ACCOUNT_TRANS_ID
        AND act.SUBID = il.ACCOUNT_TRANS_SUBID
        JOIN
            ACCOUNTS credacc
        ON
            act.CREDIT_ACCOUNTCENTER = credacc.CENTER
        AND act.CREDIT_ACCOUNTID = credacc.ID
        JOIN
            ACCOUNTS debitacc
        ON
            act.DEBIT_ACCOUNTCENTER = debitacc.CENTER
        AND act.DEBIT_ACCOUNTID = debitacc.ID
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        LEFT JOIN
            PERSONS p
        ON
            p.center = il.PERSON_CENTER
        AND p.ID = il.PERSON_ID
        LEFT JOIN
            EMPLOYEES staff
        ON
            staff.center = i.EMPLOYEE_CENTER
        AND staff.id = i.EMPLOYEE_ID
        LEFT JOIN
            PERSONS sales_person
        ON
            sales_person.center = staff.personcenter
        AND sales_person.ID = staff.personid
        LEFT JOIN
            CASHREGISTERS crg
        ON
            crg.CENTER = i.CASHREGISTER_CENTER
        AND crg.ID = i.CASHREGISTER_ID
        LEFT JOIN
            PERSONS payer
        ON
            payer.center = i.PAYER_CENTER
        AND payer.id = i.PAYER_ID
        WHERE
            i.center = i.center
        UNION ALL
        SELECT
            cl.CENTER || 'cred' || cl.ID || 'cnl' || cl.SUBID "ID",
            c.CENTER                                          "CENTER_ID",
            'CREDIT_NOTE'                                     "SALE_TYPE",
            CASE
                WHEN p.SEX <> 'C'
                THEN
                    CASE
                        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                        ELSE p.EXTERNAL_ID
                    END
                ELSE NULL
            END "PERSON_ID",
            CASE
                WHEN payer.SEX = 'C'
                THEN
                    CASE
                        WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                            OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                        ELSE payer.EXTERNAL_ID
                    END
                ELSE NULL
            END "COMPANY_ID",
            CAST(
                CASE
                    WHEN payer.SEX = 'C'
                    THEN 1
                    ELSE 0
                END AS SMALLINT) "IS_COMPANY",
            CASE
                WHEN (sales_person.CENTER != sales_person.TRANSFERS_CURRENT_PRS_CENTER
                    OR  sales_person.id != sales_person.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = sales_person.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = sales_person.TRANSFERS_CURRENT_PRS_ID)
                ELSE sales_person.EXTERNAL_ID
            END                                               "SALE_PERSON_ID",
            c.ENTRY_TIME                                      "ENTRY_DATETIME",
            c.TRANS_TIME                                      "BOOK_DATETIME",
            prod.CENTER                                       "PRODUCT_CENTER",
            prod.CENTER || 'prod' || prod.ID                  "PRODUCT_ID",
			CASE 
				WHEN prod.PTYPE = 1 THEN 'RETAIL'
				WHEN prod.PTYPE = 2 THEN 'SERVICE'
				WHEN prod.PTYPE = 4 THEN 'CLIPCARD'
				WHEN prod.PTYPE = 5 THEN 'JOINING_FEE'
				WHEN prod.PTYPE = 6 THEN 'TRANSFER_FEE'
				WHEN prod.PTYPE = 7 THEN 'FREEZE_PERIOD'
				WHEN prod.PTYPE = 8 THEN 'GIFTCARD'
				WHEN prod.PTYPE = 9 THEN 'FREE_GIFTCARD'
				WHEN prod.PTYPE = 10 THEN 'SUBS_PERIOD'
				WHEN prod.PTYPE = 12 THEN 'SUBS_PRORATA'
				WHEN prod.PTYPE = 13 THEN 'ADDON'
				WHEN prod.PTYPE = 14 THEN 'ACCESS'
			ELSE 'UNKNOWN'
			END AS "PRODUCT_TYPE", 
            NULL                                             AS "PRODUCT_NORMAL_PRICE",
            - cl.QUANTITY                                    AS "QUANTITY",
            -ROUND(cl.net_amount,2)                          AS "NET_AMOUNT",
            -ROUND(cl.TOTAL_AMOUNT,2)+ROUND(cl.net_amount,2) AS "VAT_AMOUNT",
            -ROUND(cl.TOTAL_AMOUNT, 2)                       AS "TOTAL_AMOUNT",
            NULL                                             AS "SPONSOR_SALE_LOG_ID",
            debitacc.EXTERNAL_ID                                "GL_DEBIT_ACCOUNT",
            credacc.EXTERNAL_ID                                 "GL_CREDIT_ACCOUNT",
            cl.sales_commission            AS                              "SALE_COMMISSION",
            cl.sales_units                      AS                              "SALE_UNITS",
            cl.period_commission          AS                              "PERIOD_COMMISSION",
            COALESCE(crg.TYPE,'OTHER')                AS                              "SOURCE_TYPE",
            cl.INVOICELINE_CENTER||'inv'||cl.INVOICELINE_ID||'ln'||cl.INVOICELINE_SUBID AS
                                            "CREDIT_SALE_LOG_ID",
            cl.CENTER || 'cred' || cl.ID AS "SALE_ID",
            crg.center                   AS "CASH_REGISTER_CENTER_ID",
            c.TRANS_TIME                    "TST",
            c.ENTRY_TIME                    "EST",
            cl.flat_rate_commission AS      "FLAT_RATE_COMMISSION",
            NULL                    AS      "EXTERNAL_ID",
            CASE
                WHEN payer.SEX != 'C'
                THEN
                    CASE
                        WHEN (payer.CENTER != payer.TRANSFERS_CURRENT_PRS_CENTER
                            OR  payer.id != payer.TRANSFERS_CURRENT_PRS_ID )
                        THEN
                            (
                                SELECT
                                    EXTERNAL_ID
                                FROM
                                    PERSONS
                                WHERE
                                    CENTER = payer.TRANSFERS_CURRENT_PRS_CENTER
                                AND ID = payer.TRANSFERS_CURRENT_PRS_ID)
                        ELSE payer.EXTERNAL_ID
                    END
                ELSE NULL
            END "PAYER_PERSON_ID",
			CASE WHEN AGGREGATED_TRANSACTION_CENTER IS NOT NULL THEN
				act.AGGREGATED_TRANSACTION_CENTER||'agt'||act.AGGREGATED_TRANSACTION_ID
			ELSE
			    null
			END AS "AGGREGATED_TRANSACTION_KEY",
			cl.installment_plan_id AS "INSTALLMENT_PLAN_ID"
        FROM
            CREDIT_NOTES c
        JOIN
            credit_note_lines_mt cl
        ON
            cl.center = c.center
        AND cl.id = c.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
        AND prod.id = cl.PRODUCTID
        JOIN
            ACCOUNT_TRANS act
        ON
            act.CENTER = cl.ACCOUNT_TRANS_CENTER
        AND act.ID = cl.ACCOUNT_TRANS_ID
        AND act.SUBID = cl.ACCOUNT_TRANS_SUBID
        JOIN
            ACCOUNTS credacc
        ON
            act.CREDIT_ACCOUNTCENTER = credacc.CENTER
        AND act.CREDIT_ACCOUNTID = credacc.ID
        JOIN
            ACCOUNTS debitacc
        ON
            act.DEBIT_ACCOUNTCENTER = debitacc.CENTER
        AND act.DEBIT_ACCOUNTID = debitacc.ID
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        LEFT JOIN
            PERSONS p
        ON
            p.center = cl.PERSON_CENTER
        AND p.ID = cl.PERSON_ID
        LEFT JOIN
            EMPLOYEES staff
        ON
            staff.center = c.EMPLOYEE_CENTER
        AND staff.id = c.EMPLOYEE_ID
        LEFT JOIN
            PERSONS sales_person
        ON
            sales_person.center = staff.personcenter
        AND sales_person.ID = staff.personid
        LEFT JOIN
            CASHREGISTERS crg
        ON
            crg.CENTER = c.CASHREGISTER_CENTER
        AND crg.ID = c.CASHREGISTER_ID
        LEFT JOIN
            PERSONS payer
        ON
            payer.center = c.PAYER_CENTER
        AND payer.id = c.PAYER_ID
        WHERE
            c.center = c.center) x
	