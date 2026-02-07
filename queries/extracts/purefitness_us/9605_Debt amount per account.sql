SELECT 
    *
FROM
    (   SELECT
            p.center||'p'||p.id p_number,
            p.external_id,
            cc.amount debt_amount,
            SUM(
            CASE
                WHEN art.unsettled_amount <0
                AND art.due_date <CURRENT_DATE
                THEN art.unsettled_amount
                WHEN art.unsettled_amount >0
                THEN art.unsettled_amount
            END)    *-1         acc_amount,
            'PAYMENT_ACC' AS account
        FROM
            cashcollectioncases cc
        JOIN
            persons p
        ON
            cc.personcenter=p.center
        AND cc.personid=p.id
        JOIN
            account_receivables ar
        ON
            ar.customercenter=p.center
        AND ar.customerid=p.id
        AND ar.ar_type=4
        AND ar.state=0
        AND ar.balance<0
        JOIN
            ar_trans art
        ON
            ar.center=art.center
        AND ar.id=art.id
        AND art.status!='CLOSED'
        WHERE
            cc.closed=false
        AND cc.missingpayment=true
        AND p.sex!='C'
        and cc.center in (:center)
        GROUP BY
            p.center||'p'||p.id ,
            p.external_id ,
            cc.amount
        
        UNION ALL
        
        SELECT
            p.center||'p'||p.id p_number,
            p.external_id,
            cc.amount debt_amount,
            SUM(
            CASE
                WHEN art_d.unsettled_amount <0
                AND art_d.due_date <CURRENT_DATE
                THEN art_d.unsettled_amount
                WHEN art_d.unsettled_amount >0
                THEN art_d.unsettled_amount
            END)  *-1        acc_amount,
            'DEBT_ACC' AS account
        FROM
            cashcollectioncases cc
        JOIN
            persons p
        ON
            cc.personcenter=p.center
        AND cc.personid=p.id
        JOIN
            account_receivables ar_d
        ON
            ar_d.customercenter=p.center
        AND ar_d.customerid=p.id
        AND ar_d.ar_type=5
        AND ar_d.state=0
        AND ar_d.balance<0
        JOIN
            ar_trans art_d
        ON
            ar_d.center=art_d.center
        AND ar_d.id=art_d.id
        AND art_d.status!='CLOSED'
        WHERE
            cc.closed=false
        AND cc.missingpayment=true
        AND p.sex!='C'
        and cc.center in (:center)
        GROUP BY
            p.center||'p'||p.id ,
            p.external_id ,
            cc.amount)t
ORDER BY 
    1