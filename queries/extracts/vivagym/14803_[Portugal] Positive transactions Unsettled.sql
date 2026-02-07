WITH PARAMS AS MATERIALIZED
(
        SELECT
                dateToLongC(to_char(to_date(getCenterTime(c.id),'YYYY-MM-DD'),'YYYY-MM-DD'), c.id)-1 AS cutDate,
                c.id,
                c.name AS clubname
        FROM vivagym.centers c
        WHERE
                c.country = 'PT'
),
v_main AS
(
        SELECT
                p.center || 'p' || p.id AS personid,
                CASE p.status WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED'
                              WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
                par.clubname,
                ar.balance AS paymentaccount_balance,
                art.center,
                art.id,
                art.subid,
                longtodatec(art.entry_time, art.center) AS transaction_entrytime,
                art.text AS transaction_text,
                art.amount AS transaction_total_amount,
                art.unsettled_amount,
                art.ref_type,
                art.status,
                art.collected, --706p41609
                s.start_date,
                s.end_date,
                s.subscription_price,
                pr.name AS product_name
        FROM vivagym.persons p
        JOIN params par ON p.center = par.id
        JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
        JOIN vivagym.ar_trans art ON ar.center = art.center AND ar.id = art.id
        LEFT JOIN vivagym.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id AND s.state IN (2,4,8)
        LEFT JOIN vivagym.products pr ON pr.center = s.subscriptiontype_center AND pr.id = s.subscriptiontype_id
        WHERE
                art.status NOT IN ('CLOSED')
                AND art.entry_time < par.cutDate
                AND art.amount > 0
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(product_name,1) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS product_name2,
                LEAD(start_date,1) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS start_date2,
                LEAD(end_date,1) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS end_date2,
                LEAD(subscription_price,1) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS subscription_price2,
                
                LEAD(product_name,2) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS product_name3,
                LEAD(start_date,2) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS start_date3,
                LEAD(end_date,2) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS end_date3,
                LEAD(subscription_price,2) OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS subscription_price3,
                
                ROW_NUMBER() OVER (PARTITION BY personid,center,id,subid ORDER BY start_date) AS ADDONSEQ
        FROM
                v_main
)
SELECT
        personid,
        person_status,
        clubname,
        paymentaccount_balance,
        transaction_entrytime,
        transaction_text,
        transaction_total_amount,
        unsettled_amount,
        ref_type,
        status,
        collected,
        product_name AS product_name1,
        start_date AS start_date1,
        end_date AS end_date1,
        subscription_price AS subscription_price1,
        product_name2,
        start_date2,
        end_date2,
        subscription_price2,
        product_name3,
        start_date3,
        end_date3,
        subscription_price3
FROM v_pivot
WHERE
        ADDONSEQ = 1