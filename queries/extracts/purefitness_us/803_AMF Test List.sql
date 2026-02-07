SELECT
    /*+ NO_BIND_AWARE */
	*
FROM
    (
              SELECT DISTINCT
                    p.id,
					p.center,
					p.center||'p'||p.id 										AS "PERSONKEY",
                    MIN( sub.START_DATE)                                        AS "Subcription Start Date",
                    MIN( sub.START_DATE + 86)                         AS "After_3_Months",
                    CAST(longtodate(MAX(latest_sale.TRANS_TIME)) AS date)       AS "Last_Sale_Date"
                FROM
                    PERSONS p
		JOIN 
                    SUBSCRIPTIONS sub
                ON
                    sub.OWNER_CENTER = p.center
                    AND sub.OWNER_ID = p.id
                    AND sub.REFMAIN_CENTER IS NULL --?? 
                    AND sub.state IN (2,4,8)
                    AND sub.START_DATE <= current_date
		    AND (sub.END_DATE IS NULL OR sub.END_DATE >= current_date) 
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                    AND st.ST_TYPE = 1  -- EFT 
                    AND st.IS_ADDON_SUBSCRIPTION = 0  -- 
                JOIN
                    products pr
                ON
                    pr.center = st.center
                    AND pr.id = st.id
                LEFT JOIN
                    (
                        SELECT
                            ptrans.CURRENT_PERSON_CENTER,
                            ptrans.CURRENT_PERSON_ID,
                            MAX(i.TRANS_TIME) AS TRANS_TIME
                        FROM
                            INVOICE_LINES_MT il
                        JOIN
                            INVOICES i
                        ON
                            i.center = il.center
                            AND i.id = il.id
                        JOIN
                            PRODUCTS pd
                        ON
                            pd.CENTER = il.productCENTER
                            AND pd.ID = il.productid
                        JOIN
                            PERSONS ptrans
                        ON
                            il.PERSON_CENTER = ptrans.center
                            AND il.person_id = ptrans.id
                        WHERE
                            pd.GLOBALID = 'ANNUAL_MAINTENANCE_FEE'  
                        GROUP BY
                            ptrans.CURRENT_PERSON_CENTER,
                            ptrans.CURRENT_PERSON_ID ) latest_sale
                ON
                    (latest_sale.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                        AND latest_sale.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID)
				LEFT JOIN
				    PERSON_EXT_ATTRS pe
				ON
					pe.PERSONCENTER = p.CURRENT_PERSON_CENTER
					AND pe.PERSONID = p.CURRENT_PERSON_ID
					AND pe.NAME = 'noAMF'
                WHERE
                    p.center = :center
                    AND p.PERSONTYPE NOT IN (2, 4)
		    AND (pe.TXTVALUE IS NULL OR pe.TXTVALUE = 'false')
                GROUP BY
                    p.center,
                    p.id ) dat2
WHERE
    dat2."After_3_Months" <= current_date
    AND (
        dat2."Last_Sale_Date" IS NULL
        OR add_months(dat2."Last_Sale_Date", 12) <= current_date )
