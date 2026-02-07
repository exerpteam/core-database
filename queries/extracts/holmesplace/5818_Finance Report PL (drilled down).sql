SELECT
    lines."INVOICE ID" "INVOICE/CREDIT NOTE",
    lines.RECEIPT_ID as "ParagonNo",
    '' "CREDITED INVOICE",
    lines."DATE OF INVOICE" "DATE",
    lines."Member/Company name",
    lines.ProductName as "Product",
    lines.PKWiU as "PKWiU",
    lines.quantity as "Quantity",
    SUM(lines."NET AMOUNT VAT 0.08") "NET AMOUNT VAT 0.08",
    SUM(lines."VAT AMOUNT VAT 0.08") "VAT AMOUNT VAT 0.08",
    SUM(lines."TOTAL AMOUNT VAT 0.08") "TOTAL AMOUNT VAT 0.08",
    SUM(lines."NET AMOUNT VAT 0.23") "NET AMOUNT VAT 0.23",
    SUM(lines."VAT AMOUNT VAT 0.23") "VAT AMOUNT VAT 0.23",
    SUM(lines."TOTAL AMOUNT VAT 0.23") "TOTAL AMOUNT VAT 0.23",
    SUM(lines."NET AMOUNT VAT 0") "NET AMOUNT VAT 0",
    SUM(lines."VAT AMOUNT VAT 0") "VAT AMOUNT VAT 0",
    SUM(lines."TOTAL AMOUNT VAT 0") "TOTAL AMOUNT VAT 0",
    lines."TOTAL_AMOUNT" " Total gross amount of invoice"
FROM
    (
        SELECT
            inv.CENTER || 'inv' || inv.id "INVOICE ID",
            inv.RECEIPT_ID,
            longToDate(inv.TRANS_TIME) "DATE OF INVOICE",
            CASE
                WHEN p.SEX = 'C'
                THEN p.LASTNAME
                WHEN p.CENTER IS NULL
                THEN 'Anonymous sale'
                ELSE p.FIRSTNAME || ' ' || p.LASTNAME
            END AS "Member/Company name",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.08
                    THEN ROUND(invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE),2)
                    ELSE 0
                END) AS "NET AMOUNT VAT 0.08",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.08
                    THEN ROUND(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE)),2)
                    ELSE 0
                END) AS "VAT AMOUNT VAT 0.08",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.08
                    THEN invl.TOTAL_AMOUNT
                    ELSE 0
                END) AS "TOTAL AMOUNT VAT 0.08",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.23
                    THEN ROUND(invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE),2)
                    ELSE 0
                END) AS "NET AMOUNT VAT 0.23",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.23
                    THEN ROUND(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE)),2)
                    ELSE 0
                END) AS "VAT AMOUNT VAT 0.23",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0.23
                    THEN invl.TOTAL_AMOUNT
                    ELSE 0
                END) AS "TOTAL AMOUNT VAT 0.23",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0
                    THEN ROUND(invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE),2)
                    ELSE 0
                END) AS "NET AMOUNT VAT 0",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0
                    THEN ROUND(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT / (1+invl.ORIG_RATE)),2)
                    ELSE 0
                END) AS "VAT AMOUNT VAT 0",
            SUM(
                CASE
                    WHEN invl.ORIG_RATE = 0
                    THEN invl.TOTAL_AMOUNT
                    ELSE 0
                END) AS "TOTAL AMOUNT VAT 0",
            SUM(invl.TOTAL_AMOUNT) TOTAL_AMOUNT,
			prod.name as ProductName,
			prod.EXTERNAL_ID as PKWiU,
			sum(invl.quantity) as quantity

        FROM
            HP.INVOICES inv
        JOIN HP.INVOICELINES invl
        ON
            invl.CENTER = inv.CENTER
            AND invl.id = inv.ID
        LEFT JOIN HP.PERSONS p
        ON
            p.CENTER = invl.PERSON_CENTER
            AND p.ID = invl.PERSON_ID
        JOIN HP.PRODUCTS prod
        ON
            prod.CENTER = invl.PRODUCTCENTER
            AND prod.ID = invl.PRODUCTID
        WHERE
                        (
                            (
                                $$device$$ = 'Y'
                                AND inv.CONTROL_DEVICE_ID IS NOT NULL
                            )
                            OR
                            (
                                $$device$$ = 'N'
                                AND inv.CONTROL_DEVICE_ID IS NULL
                            )
                        )
                        AND 
            inv.CENTER IN ($$scope$$)
            and inv.ENTRY_TIME between $$startDate$$ and ($$toDate$$ + (1000*60*60*24))

        GROUP BY
            inv.CENTER,
            inv.id ,
            longToDate(inv.TRANS_TIME),
            CASE
                WHEN p.SEX = 'C'
                THEN p.LASTNAME
                WHEN p.CENTER IS NULL
                THEN 'Anonymous sale'
                ELSE p.FIRSTNAME || ' ' || p.LASTNAME
            END,
			prod.name, prod.EXTERNAL_ID, inv.RECEIPT_ID
			

    )
    lines
GROUP BY
    lines."INVOICE ID",
    lines.receipt_id,
    lines."DATE OF INVOICE",
    lines."Member/Company name",
    lines."TOTAL_AMOUNT",
    lines.ProductName,
    lines.PKWiU,
    lines.quantity

union 
SELECT
    lines."CREDIT NOTE ID",
    null as "ParagonNo",
    lines."INVOICE ID" "CREDITED INVOICE",
    lines."DATE OF CREDIT NOTE",
    lines."Member/Company name",
    lines.ProductName as "Product",
    lines.PKWiU as "PKWiU",
    lines.quantity as "Quantity",
    -1 * SUM(lines."NET AMOUNT VAT 0.08") "NET AMOUNT VAT 0.08",
    -1 * SUM(lines."VAT AMOUNT VAT 0.08") "VAT AMOUNT VAT 0.08",
    -1 * SUM(lines."TOTAL AMOUNT VAT 0.08") "TOTAL AMOUNT VAT 0.08",
    -1 * SUM(lines."NET AMOUNT VAT 0.23") "NET AMOUNT VAT 0.23",
    -1 * SUM(lines."VAT AMOUNT VAT 0.23") "VAT AMOUNT VAT 0.23",
    -1 * SUM(lines."TOTAL AMOUNT VAT 0.23") "TOTAL AMOUNT VAT 0.23",
    -1 * SUM(lines."NET AMOUNT VAT 0") "NET AMOUNT VAT 0",
    -1 * SUM(lines."VAT AMOUNT VAT 0") "VAT AMOUNT VAT 0",
    -1 * SUM(lines."TOTAL AMOUNT VAT 0") "TOTAL AMOUNT VAT 0",
    -1 * lines."TOTAL_AMOUNT" " Total gross amount"
FROM
    (

        SELECT
            cn.CENTER || 'cred' || cn.id "CREDIT NOTE ID",
            case when cn.invoice_center is not null then cn.INVOICE_CENTER || 'inv' || cn.INVOICE_id else '' end "INVOICE ID",
            longToDate(cn.TRANS_TIME) "DATE OF CREDIT NOTE",
            CASE
                WHEN p.SEX = 'C'
                THEN p.LASTNAME
                WHEN p.CENTER IS NULL
                THEN 'Anonymous credit'
                ELSE p.FIRSTNAME || ' ' || p.LASTNAME
            END AS "Member/Company name",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.08
                THEN ROUND(cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE),2)
                ELSE 0
            END) AS "NET AMOUNT VAT 0.08",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.08
                THEN ROUND(cnl.TOTAL_AMOUNT - (cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE)),2)
                ELSE 0
            END) AS "VAT AMOUNT VAT 0.08",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.08
                THEN cnl.TOTAL_AMOUNT
                ELSE 0
            END) AS "TOTAL AMOUNT VAT 0.08",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.23
                THEN ROUND(cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE),2)
                ELSE 0
            END) AS "NET AMOUNT VAT 0.23",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.23
                THEN ROUND(cnl.TOTAL_AMOUNT - (cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE)),2)
                ELSE 0
            END) AS "VAT AMOUNT VAT 0.23",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0.23
                THEN cnl.TOTAL_AMOUNT
                ELSE 0
            END) AS "TOTAL AMOUNT VAT 0.23",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0
                THEN ROUND(cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE),2)
                ELSE 0
            END) AS "NET AMOUNT VAT 0",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0
                THEN ROUND(cnl.TOTAL_AMOUNT - (cnl.TOTAL_AMOUNT / (1+cnl.ORIG_RATE)),2)
                ELSE 0
            END) AS "VAT AMOUNT VAT 0",
            sum(CASE
                WHEN cnl.ORIG_RATE = 0
                THEN cnl.TOTAL_AMOUNT
                ELSE 0
            END) AS "TOTAL AMOUNT VAT 0",
            sum(cnl.TOTAL_AMOUNT) TOTAL_AMOUNT,
			prod.name as ProductName,
			prod.EXTERNAL_ID as PKWiU,
			sum(-cnl.quantity) as quantity

        FROM
            HP.CREDIT_NOTES cn
        JOIN HP.CREDIT_NOTE_LINES cnl
        ON
            cnl.CENTER = cn.CENTER
            AND cnl.id = cn.ID
        LEFT JOIN HP.PERSONS p
        ON
            p.CENTER = cnl.PERSON_CENTER
            AND p.ID = cnl.PERSON_ID
        JOIN HP.PRODUCTS prod
        ON
            prod.CENTER = cnl.PRODUCTCENTER
            AND prod.ID = cnl.PRODUCTID
        WHERE
                        (
                            (
                                $$device$$ = 'Y'
                                AND cn.CONTROL_DEVICE_ID IS NOT NULL
                            )
                            OR
                            (
                                $$device$$ = 'N'
                                AND cn.CONTROL_DEVICE_ID IS NULL
                            )
                        )
                        AND 
            cn.CENTER IN ($$scope$$)
            and cn.ENTRY_TIME between $$startDate$$ and ($$toDate$$ + (1000*60*60*24))

            group by
            cn.CENTER, cn.id ,cn.invoice_center, cn.invoice_id,
            longToDate(cn.TRANS_TIME),
            CASE
                WHEN p.SEX = 'C'
                THEN p.LASTNAME
                WHEN p.CENTER IS NULL
                THEN 'Anonymous credit'
                ELSE p.FIRSTNAME || ' ' || p.LASTNAME
            END,
			prod.name, prod.EXTERNAL_ID

    )
    lines
GROUP BY
    lines."CREDIT NOTE ID",
    lines."INVOICE ID",
    lines."DATE OF CREDIT NOTE",
    lines."Member/Company name",
    lines."TOTAL_AMOUNT",
    lines.PKWiU,
    	lines.ProductName,
	lines.quantity