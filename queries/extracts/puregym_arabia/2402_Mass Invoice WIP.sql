-- The extract is extracted from Exerp on 2026-02-08
-- EC-3755
SELECT
    *
FROM
    (
        SELECT
            p.firstname || ' ' || p.lastname                         AS "Name",
            peat.txtvalue                                           AS "Email",
            p.address1 || ', ' || p.address2|| ', ' || p.address3                AS "Address",
            ''                                                                    AS "Invoice Type",
            prs.ref                                                              AS InvoiceNo,
            TO_CHAR(pr2.req_date, 'DD-Mon')                                  AS "InvoiceDate",
            ''                                                                    AS "Invoice Time",
            ''                                                                 AS "Customer VAT ID",
            pr2.ref                                                            AS "Reference",
            TO_CHAR(longtodateC(art.entry_time, art.center), 'DD-Mon')                AS "Date",
            COALESCE(il.TEXT,cl.TEXT)                                               AS Description,
            COALESCE(il.quantity,-cl.quantity)                                        AS "Qty",
            COALESCE(il.product_normal_price, -cl.product_normal_price)              AS "UnitPrice",
            COALESCE(il.TOTAL_AMOUNT-il.NET_AMOUNT,-( cl.TOTAL_AMOUNT-cl.NET_AMOUNT)) AS "VATValue"
            ,
            '15%'                                   AS "VAT rate",
            COALESCE(il.NET_AMOUNT, -cl.NET_AMOUNT) AS "TotalPrice",
            COALESCE(((il.product_normal_price * il.quantity)-il.TOTAL_AMOUNT),-(
            (cl.product_normal_price * cl.quantity)-cl.TOTAL_AMOUNT)) AS "Discount",
            COALESCE(il.TOTAL_AMOUNT, -cl.TOTAL_AMOUNT)               AS "GrandTotal",
            NULL                                                      AS "GrandDiscount",
            NULL                                                      AS "InvoiceTotal"
        FROM
            PAYMENT_REQUESTS pr2
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.center = pr2.center
        AND ar.id = pr2.id
        AND ar.AR_TYPE = 4
        AND pr2.request_type = 8
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            pr2.INV_COLL_CENTER = prs.CENTER
        AND pr2.INV_COLL_ID = prs.ID
        AND pr2.INV_COLL_SUBID = prs.subid
        JOIN
            AR_TRANS art
        ON
            art.PAYREQ_SPEC_CENTER = prs.CENTER
        AND art.PAYREQ_SPEC_ID = prs.ID
        AND art.PAYREQ_SPEC_SUBID = prs.SUBID
        AND art.REF_TYPE IN ('INVOICE',
                             'CREDIT_NOTE')
        LEFT JOIN
            INVOICES i
        ON
            art.REF_CENTER = i.CENTER
        AND art.REF_ID = i.ID
        AND art.REF_TYPE IN('INVOICE')
        LEFT JOIN
            CREDIT_NOTES cn
        ON
            art.REF_CENTER = cn.CENTER
        AND art.REF_ID = cn.ID
        AND art.REF_TYPE IN('CREDIT_NOTE')
        LEFT JOIN
            INVOICE_LINES_MT il
        ON
            art.REF_CENTER = il.CENTER
        AND art.REF_ID = il.ID
        AND art.REF_TYPE IN('INVOICE')
        LEFT JOIN
            (
                SELECT
                    cl.center,
                    cl.id,
                    cl.quantity,
                    cl.TOTAL_AMOUNT,
                    cl.NET_AMOUNT,
                    cl.TEXT,
                    il.product_normal_price
                FROM
                    credit_note_lines_mt cl
                JOIN
                    INVOICE_LINES_MT il
                ON
                    cl.invoiceline_center=il.center
                AND cl.invoiceline_id=il.id
                AND cl.invoiceline_subid=il.subid) cl
        ON
            art.REF_CENTER = cl.CENTER
        AND art.REF_ID = cl.ID
        AND art.REF_TYPE IN ('CREDIT_NOTE')
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
        AND p.id = ar.CUSTOMERID
        JOIN
            person_ext_attrs peat
        ON
            p.CENTER = peat.personCENTER
        AND p.id = peat.personID
        AND peat.name= '_eClub_Email'
        WHERE
            pr2.entry_time BETWEEN dateToLongTZ('2021-12-05 00:00','Asia/Riyadh') AND dateToLongTZ
            ('2021-12-16 23:59','Asia/Riyadh')
        UNION ALL
        SELECT
            p.firstname || ' ' || p.lastname                      AS "Name",
            peat.txtvalue                                         AS "Email",
            p.address1 || ', ' || p.address2|| ', ' || p.address3 AS "Address",
            ''                                                    AS "Invoice Type",
            prs.ref                                               AS InvoiceNo,
            TO_CHAR(pr2.req_date, 'DD-Mon')                       AS "InvoiceDate",
            ''                                                    AS "Invoice Time",
            ''                                                    AS "Customer VAT ID",
            pr2.ref                                               AS "Reference",
            ''                                                    AS "Date",
            subq.text                                             AS Description,
            NULL                                                  AS "Qty",
            NULL                                                  AS "UnitPrice",
            NULL                                                  AS "VATValue",
            NULL                                                  AS "VAT rate",
            NULL                                                  AS "TotalPrice",
            NULL                                                  AS "Discount",
            NULL                                                  AS "GrandTotal",
            subq3.totaldiscount                                   AS "GrandDiscount",
            prs.total_invoice_amount                              AS "InvoiceTotal"
        FROM
            PAYMENT_REQUESTS pr2
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.center = pr2.center
        AND ar.id = pr2.id
        AND ar.AR_TYPE = 4
        AND pr2.request_type = 8
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            pr2.INV_COLL_CENTER = prs.CENTER
        AND pr2.INV_COLL_ID = prs.ID
        AND pr2.INV_COLL_SUBID = prs.subid
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
        AND p.id = ar.CUSTOMERID
        JOIN
            person_ext_attrs peat
        ON
            p.CENTER = peat.personCENTER
        AND p.id = peat.personID
        AND peat.name= '_eClub_Email'
        CROSS JOIN
            (
                SELECT
                    'Invoice Total' AS text) subq
        JOIN
            (
                SELECT
                    subq2.center,
                    subq2.id,
                    subq2.subid,
                    SUM(subq2.Discount) AS totaldiscount
                FROM
                    (
                        SELECT
                            pr2.center,
                            pr2.id,
                            pr2.subid,
                            COALESCE(((il.product_normal_price * il.quantity)-il.TOTAL_AMOUNT),-(
                            (cl.product_normal_price * cl.quantity)-cl.TOTAL_AMOUNT)) AS Discount
                        FROM
                            PAYMENT_REQUESTS pr2
                        JOIN
                            ACCOUNT_RECEIVABLES ar
                        ON
                            ar.center = pr2.center
                        AND ar.id = pr2.id
                        AND ar.AR_TYPE = 4
                        AND pr2.request_type = 8
                        JOIN
                            PAYMENT_REQUEST_SPECIFICATIONS prs
                        ON
                            pr2.INV_COLL_CENTER = prs.CENTER
                        AND pr2.INV_COLL_ID = prs.ID
                        AND pr2.INV_COLL_SUBID = prs.subid
                        JOIN
                            AR_TRANS art
                        ON
                            art.PAYREQ_SPEC_CENTER = prs.CENTER
                        AND art.PAYREQ_SPEC_ID = prs.ID
                        AND art.PAYREQ_SPEC_SUBID = prs.SUBID
                        AND art.REF_TYPE IN ('INVOICE',
                                             'CREDIT_NOTE')
                        LEFT JOIN
                            INVOICES i
                        ON
                            art.REF_CENTER = i.CENTER
                        AND art.REF_ID = i.ID
                        AND art.REF_TYPE IN('INVOICE')
                        LEFT JOIN
                            CREDIT_NOTES cn
                        ON
                            art.REF_CENTER = cn.CENTER
                        AND art.REF_ID = cn.ID
                        AND art.REF_TYPE IN('CREDIT_NOTE')
                        LEFT JOIN
                            INVOICE_LINES_MT il
                        ON
                            art.REF_CENTER = il.CENTER
                        AND art.REF_ID = il.ID
                        AND art.REF_TYPE IN('INVOICE')
                        LEFT JOIN
                            (
                                SELECT
                                    cl.center,
                                    cl.id,
                                    cl.quantity,
                                    cl.TOTAL_AMOUNT,
                                    cl.NET_AMOUNT,
                                    cl.TEXT,
                                    il.product_normal_price
                                FROM
                                    credit_note_lines_mt cl
                                JOIN
                                    INVOICE_LINES_MT il
                                ON
                                    cl.invoiceline_center=il.center
                                AND cl.invoiceline_id=il.id
                                AND cl.invoiceline_subid=il.subid) cl
                        ON
                            art.REF_CENTER = cl.CENTER
                        AND art.REF_ID = cl.ID
                        AND art.REF_TYPE IN ('CREDIT_NOTE') ) subq2
                GROUP BY
                    subq2.center,
                    subq2.id,
                    subq2.subid)subq3
        ON
            pr2.center=subq3.center
        AND pr2.id=subq3.id
        AND pr2.subid=subq3.subid
        WHERE
            pr2.entry_time BETWEEN dateToLongTZ('2021-12-05 00:00','Asia/Riyadh') AND dateToLongTZ
            ('2021-12-16 23:59','Asia/Riyadh') ) query
ORDER BY
    query.InvoiceNo,
    CASE
        WHEN query.description='Invoice Total'
        THEN 1
        ELSE 0
    END