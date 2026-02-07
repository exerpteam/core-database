SELECT
            ar.customercenter||'p'||ar.customerid as personkey, art.*
        FROM
            ar_trans art
        JOIN
            account_receivables ar
        ON
            ar.center=art.center
        AND ar.id=art.id
                JOIN payment_accounts pac
                ON ar.center = pac.center AND ar.id = pac.id
        JOIN payment_agreements pag
                ON pag.center = pac.active_agr_center AND pag.id = pac.active_agr_id AND pag.subid = pac.active_agr_subid
        WHERE
            art.employeecenter||'emp'||art.employeeid='6999emp807'
        AND art.entry_time>1756886546000
        and pag.active=true
        