 SELECT
            ccr.CENTER,
            ccr.ID,
            ccr.SUBID
			
        FROM
            CASHCOLLECTION_REQUESTS ccr
            /* Only open cases */
        JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.CENTER = ccr.CENTER
            AND cc.ID = ccr.ID
            AND cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
		join centers c on c.id = ccr.center and c.country = 'GB'
        WHERE
            /* NEW and SEND */    
            ccr.STATE IN (-1,0)
            /* All with no reference to any payment request specification*/
            AND ccr.PAYMENT_REQUEST_CENTER IS NULL
            /* Only DEBT and not payments */
            AND ccr.REQ_AMOUNT > 0 
			