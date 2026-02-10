-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
                ss.sales_date,
				s.owner_center || 'p' ||s.owner_id AS Member,
				c.name,
                pag.state,
                ch.name,
				
                s.*
        FROM
                vivagym.subscription_sales ss
        JOIN
                vivagym.subscriptions s
                ON s.center = ss.subscription_center AND s.id = ss.subscription_id
		JOIN
				VIVAGYM.CENTERS c
				ON s.center = c.id
        JOIN
                vivagym.subscriptiontypes st
                ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id AND st.st_type = 1
        JOIN
                vivagym.products pr
                ON pr.center = s.subscriptiontype_center AND pr.id = s.subscriptiontype_id
        JOIN 
                vivagym.account_receivables ar ON ar.customercenter = s.owner_center AND ar.customerid = s.owner_id AND ar.ar_type = 4
        JOIN
                vivagym.payment_accounts pac ON pac.center = ar.center AND pac.id = ar.id
        JOIN
                vivagym.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
        JOIN
                vivagym.clearinghouses ch ON ch.id = pag.clearinghouse
        
        WHERE
                ss.sales_date =to_date(:fechaOriginal, 'YYYY-MM-DD')
                AND pr.globalid NOT IN ('DAYPASS')
                AND 
                ( 
                        s.end_date IS NULL
                        OR
                        (s.start_date < s.end_date)
                )
