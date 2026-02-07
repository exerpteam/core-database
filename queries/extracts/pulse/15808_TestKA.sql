SELECT
            pr.center,
            pr.XFR_INFO "text",
           /* COUNT(*)                     COUNT,
            SUM(pr.REQ_AMOUNT)           total,*/
            '5.2 Adyen Unpaid'    reportgroup,
            'Unpaid reason codes'        subgroup,
			ar.customercenter ||'p'|| ar.customerid as member,
			pr.*
        FROM
            PULSE.PAYMENT_REQUESTS pr
			JOIN
			account_receivables ar
			ON
			ar.center = pr.center
			AND ar.id = pr.id
        WHERE
            pr.REQ_DATE >= longtodateTZ(:FromDate, 'Europe/London')
        AND pr.REQ_DATE <= longtodateTZ(:ToDate, 'Europe/London')
        AND pr.REQUEST_TYPE IN (1,6)
        AND pr.state IN (5,6,7,17)
        AND pr.center IN (:Scope)
		AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609)
        /*GROUP BY
            pr.center,
            pr.XFR_INFO */