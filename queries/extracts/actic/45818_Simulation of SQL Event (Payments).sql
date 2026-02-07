SELECT
   CUSTOMERCENTER AS CENTER,
   CUSTOMERID AS ID,
   PERSONID AS "PERSONKEY",
   INVOICELINE AS PAYMENTLIST,
   to_char(TOTAL_AMOUNT, 'FM9G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr' AS PAYMENTLISTTOTAL,
   to_char(TOTAL_AMOUNT-NET_AMOUNT, 'FM9G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr' AS PAYMENTLISTVAT,
   to_char(NET_AMOUNT, 'FM9G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr' AS PAYMENTLISTNET,
   to_char(TOTAL_AMOUNT-REQ_AMOUNT, 'FM9G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr' AS ALREADYPAID,
   to_char(REQ_AMOUNT, 'FM9G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr' AS TO_BE_PAID,
   DUE_DATE AS PAYMENTLISTDUE
FROM
(
SELECT
    center,
    id,
    subid,
    CUSTOMERCENTER,
    CUSTOMERID,
    PERSONID,
    REQ_AMOUNT,
	AGR_SUBID,
	prev_AGR_SUBID,
    TO_CHAR(DUE_DATE,'YYYY-MM-DD') DUE_DATE,
    NET_AMOUNT,
	TOTAL_AMOUNT,
    prev_amount,
    linescount,
    lead(linescount) over (partition BY center,id ORDER BY subid DESC) AS prev_linescount,
    rnk,
    invoiceline
FROM
    (
        SELECT
            center,
            id,
            subid,
            REQ_AMOUNT,
            DUE_DATE,
			AGR_SUBID,
            CUSTOMERCENTER,
            CUSTOMERID,
            PERSONID,
            SUM(NET_AMOUNT) AS NET_AMOUNT,
			SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT,
            COUNT(*)                                                           AS linescount,
            lead(REQ_AMOUNT) over (partition BY center,id ORDER BY subid DESC) AS prev_amount,
			lead(AGR_SUBID) over (partition BY center,id ORDER BY subid DESC) AS prev_AGR_SUBID,
            rank() over (partition BY center,id ORDER BY subid DESC)           AS rnk,
            listagg(
                CASE
                    WHEN line_rnk < 30
                    THEN REPLACE(REPLACE(TEXT,'!',' '),'£',' ')||' ! ' ||  to_char(NET_AMOUNT, 'FM9G999G999D00', 'NLS_NUMERIC_CHARACTERS='',.''')||' kr ! ' 
					|| to_char(ROUND (TOTAL_AMOUNT - NET_AMOUNT, 2), 'FM9G999G999D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||' kr ! '||to_char(TOTAL_AMOUNT, 'FM9G999G999D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||' kr  ' || '£'
                    -- to eliminate the problem of 4.000 characters in a column
                    WHEN line_rnk = 30
                    THEN 'There are more items, please see the full list on Web page. £'
                    ELSE ''
                END) WITHIN GROUP (ORDER BY center,id,subid) AS invoiceline
        FROM
            (
                SELECT
                    pr2.center AS center,
                    pr2.id     AS id,
                    pr2.subid  AS subid ,
                    pr2.REQ_AMOUNT,
                    pr.DUE_DATE,
					pr2.AGR_SUBID,
                    ar.CUSTOMERCENTER,
                    ar.CUSTOMERID,
                    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS PERSONID,
                    art.center                            AS artcenter,
                    art.id                                AS artid ,
                    art.subid                             AS artsubid,
                    ROW_NUMBER() over (partition BY pr2.center,pr2.id ORDER BY art.subid DESC) AS line_rnk,
                    COALESCE(i.TEXT,cn.TEXT) AS TEXT,
                    COALESCE(il.NET_AMOUNT, -cl.NET_AMOUNT)     AS NET_AMOUNT,
                    COALESCE(il.TOTAL_AMOUNT, -cl.TOTAL_AMOUNT) AS TOTAL_AMOUNT
                FROM
                    PAYMENT_REQUESTS pr
                JOIN
                    ACCOUNT_RECEIVABLES ar
                ON
                    ar.center = pr.center
                AND ar.id = pr.id
                AND ar.AR_TYPE = 4
                JOIN 
                    PERSON_EXT_ATTRS email
                ON
                    email.PERSONCENTER = ar.CUSTOMERCENTER
                    AND email.PERSONID = ar.CUSTOMERID
                    AND email.NAME = '_eClub_Email'    
                LEFT JOIN
                    PAYMENT_REQUESTS pr2
                ON
                    pr2.center = pr.center
                AND pr2.id = pr.id
                AND (
                        pr2.subid = pr.subid
                    OR  pr2.subid = pr.subid -1)
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
                    credit_note_lines_mt cl
                ON
                    art.REF_CENTER = cl.CENTER
                AND art.REF_ID = cl.ID
                AND art.REF_TYPE IN ('CREDIT_NOTE')
                WHERE
                    art.REF_TYPE IN ('INVOICE', 'CREDIT_NOTE')
                AND email.TXTVALUE IS NOT NULL
                AND pr.STATE NOT IN (1,8,12) 
                    -- Step 1 Payment request states to be
                    -- excluded 1 = New, 8 = Cancelled, 12 = Failed, not creditor/ could not be sent
                AND pr.CLEARINGHOUSE_ID IN (201, 2003)
                    -- Auto Giro, Adyen
                AND 
               (
                 pr.DUE_DATE = trunc(:target_date-1) AND pr.CLEARINGHOUSE_ID = 2003
                 OR
                 pr.DUE_DATE = trunc(:target_date+2) AND pr.CLEARINGHOUSE_ID = 201
               )
             
                AND pr.center IN (:center)
                
            )
        GROUP BY
            center,
            id,
            subid,
            REQ_AMOUNT,
			AGR_SUBID,
            DUE_DATE,
            CUSTOMERCENTER,
            CUSTOMERID,
            PERSONID )
 ) 
  temp1
WHERE 
   rnk = 1
AND 
   REQ_AMOUNT <> 0
AND  
   
(
   -- Step 2 Always send on the first deduction 
   SUBID = 1 
   OR
   --Step 3 (if the amount is greater than previous one)
   REQ_AMOUNT > PREV_AMOUNT
   OR
   -- Step 4 Number of invoice lines greater than in the previous payment request.
   LINESCOUNT > PREV_LINESCOUNT
   OR
   -- Step 5 New payment agreement
   AGR_SUBID > PREV_AGR_SUBID
)