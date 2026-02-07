WITH
        PARAMS AS materialized
        (           
              SELECT
                    c.id   AS center_id,
                    c.name AS center_name,
                    CAST (dateToLongC (TO_CHAR ( (:fromDate) ::DATE, 'YYYY-MM-DD'), 100) AS BIGINT) AS fromDate,
                    CAST (dateToLongC (TO_CHAR ( (:toDate) ::DATE, 'YYYY-MM-DD'), 100) AS BIGINT)   AS toDate
                FROM
                    centers c
                WHERE
                    c.id IN (:scope)
        )
   
    SELECT
            params.center_id                      AS "center id",
            params.center_name                    AS "center name",
            il.person_center ||'p'|| il.person_id AS "personid",
            pr.name                               AS "subscription",
            s.state                               AS "subscriptionstate",
            ats.text                              AS "text",
            ats.amount                            AS "amount"                  
        FROM
            INVOICE_LINES_MT il
        JOIN
            account_trans ats ON il.account_trans_center = ats.center AND il.account_trans_id = ats.id AND il.account_trans_subid = ats.subid     
        JOIN
            params ON params.center_id = ats.center       
        JOIN
            persons p ON il.person_center = p.center AND il.person_id = p.id
        JOIN
            subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
        JOIN
            products pr ON pr.id = s.subscriptiontype_id AND pr.center = s.subscriptiontype_center
    	JOIN
        products feepr ON il.productcenter = feepr.center AND il.productid = feepr.id AND feepr.globalid = 'NO_SHOW_FEE'

        WHERE
           -- il.text = 'No Show fee' AND
            ats.trans_time BETWEEN params.fromDate AND params.toDate;