SELECT
        total.*,
        (CASE
                WHEN 
                        total.transaction_group = 'Payment Requests from Current Month' 
                        AND total.vivagym_definition IN ('Reclaim / NotSentToBank','Reclaim / NoSentToBank','Reclaims/Recoveries (Not sent to bank)') 
                THEN total.total_amount
                ELSE 0
        END) AS not_sent_to_bank,
        (CASE
                WHEN 
                        total.transaction_group IN ('Payment Requests from Current Month')
                        AND total.vivagym_definition IN ('Denied','Denied + Recovery','OK: Reclaim + Recovery','Reclaim','Reclaim + Recovery') 
                        AND total.exerp_comment NOT IN ('Exclude: there is a more recent payment request')
                THEN total.total_amount
                WHEN 
                        total.transaction_group IN ('Payment Requests from Previous Month')
                        AND total.vivagym_definition IN ('Denied','Denied + Recovery','OK: Reclaim + Recovery','Reclaim','Reclaim + Recovery') 
                THEN -total.total_amount
                ELSE 0
        END) AS reclaims,
        (CASE   
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND total.contain_cargo_devolucion = 0
                        AND total.pr_paid_for IS NULL
                THEN 0
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND total.contain_cargo_devolucion = 0
                        AND total.pr_paid_for IS NOT NULL
                        AND total.entry_time < total.pr_paid_for
                THEN 0
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND 
                        (
                                total.text IN 
                                        (       
                                                'API Register remaining money from payment request',
                                                'Manual registered payment of request: Solicitud de pago abierta',
                                                --'Pago en cuenta',
                                                'Manual registered payment of request: '
                                        )
                                OR total.text like 'Pago registrado en Adyen%'
                                OR total.text like 'Lenient match from Adyen%'
                                OR total.text LIKE 'Manual registered payment of request:%'
                                OR total.text LIKE '%(Cancelled Recurring)'
                        )
                        AND total.contain_cargo_devolucion = 1
                THEN total.total_amount - 3
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND 
                        (
                                total.text IN 
                                        (       
                                                'API Register remaining money from payment request',
                                                'Manual registered payment of request: Solicitud de pago abierta',
                                                --'Pago en cuenta',
                                                'Manual registered payment of request: '
                                        )
                                OR total.text like 'Pago registrado en Adyen%'
                                OR total.text like 'Lenient match from Adyen%'
                                OR total.text LIKE 'Manual registered payment of request:%'
                                OR total.text LIKE '%(Cancelled Recurring)'
                        )
                        AND total.contain_cargo_devolucion = 0
                THEN total.total_amount
                
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND total.text = 'Pago en cuenta'
                        --AND total.pr_paid_for IS NOT NULL
                        AND total.contain_cargo_devolucion = 1
                THEN total.total_amount - 3
                WHEN 
                        total.transaction_group = 'CreditCard transactions on payment account' 
                        AND total.text = 'Pago en cuenta'
                        --AND total.pr_paid_for IS NOT NULL
                        AND total.contain_cargo_devolucion = 0
                THEN total.total_amount
                WHEN
                        total.transaction_group = 'Payment Requests from Current Month'
                        AND total.exerp_comment = 'Payment Request PAID: status DONE'
                        AND total.vivagym_definition = 'OK: Reclaim + Recovery'
                THEN total.total_amount - 3
                ELSE 0
        END) AS recoveries,
        TO_CHAR(total.entry_time,'YYYY-MM-DD HH24:MI') AS new_entry_time
FROM
(
        WITH params AS MATERIALIZED
                (
                        SELECT
                                d2.fromDate,
                                d2.toDate,
                                CAST(dateToLongC(TO_CHAR(d2.fromDate,'YYYY-MM-DD'),d2.center_id) AS BIGINT) AS fromDateLong,
                                CAST(dateToLongC(TO_CHAR(d2.toDate + interval '1 days','YYYY-MM-DD'),d2.center_id)-1 AS BIGINT) AS toDateLong,
                                d2.center_id,
                                d2.center_name
                                
                        FROM
                        (
                                SELECT
                                        (CASE
                                                WHEN d1.current_day = 1 THEN
                                                        d1.firstPreviousMonth
                                                ELSE
                                                        d1.firstMonth
                                        END) AS fromDate,
                                        (CASE
                                                WHEN d1.current_day = 1 THEN
                                                        d1.endPreviousMonth
                                                ELSE
                                                        d1.endMonth
                                        END) AS toDate,
                                        d1.center_id,
                                        d1.center_name
                                FROM    
                                (
                                        SELECT
                                                EXTRACT(DAY FROM TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS current_day,
                                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD')) AS firstMonth,
                                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + interval '1 month') - interval '1 day' AS endMonth,
                                                DATE_TRUNC('month', TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day') AS firstPreviousMonth,
                                                TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - interval '1 day' AS endPreviousMonth,
                                                c.id AS center_id,
                                                c.name as center_name
                                        FROM 
                                                vivagym.centers c
                                        WHERE
                                                c.country = 'ES'
											    AND c.id IN (:Scope)
                                ) d1
                        ) d2
                ),
                
        find_request AS MATERIALIZED
        (
        
                SELECT
                        art_list.*
                        ,MIN(pr.req_date) as pr_paid_for
                FROM
                (
                        SELECT
                                art.center,
                                art.id,
                                art.subid
                        FROM vivagym.persons p
                        JOIN params par
                                ON p.center = par.center_id
                        JOIN vivagym.account_receivables ar 
                                ON p.center = ar.customercenter AND p.id = ar.customerid
                        JOIN vivagym.ar_trans art
                                ON ar.center = art.center AND ar.id = art.id
                        JOIN vivagym.persons cp
                                        ON p.current_person_center  = cp.center
                                        AND p.current_person_id = cp.id
                        LEFT JOIN  creditcardtransactions cct
                        ON
                                art.center = cct.gl_trans_center
                                AND art.id = cct.gl_trans_id
                                AND art.subid = cct.gl_trans_subid
                                AND cct.method = 4
                        LEFT JOIN vivagym.account_trans act
                                ON act.center = Art.ref_center
                                 AND act.id = art.ref_id 
                                 AND act.subid = art.ref_subid
                                 AND art.ref_type = 'ACCOUNT_TRANS'
                        WHERE
                                ar.ar_type = 4
                                AND art.entry_time between par.fromDateLong AND par.toDateLong
                                AND art.amount != 0
                                AND art.ref_type = 'ACCOUNT_TRANS'
                                AND 
                                (
                                        art.text IN (
                                        'API Register remaining money from payment request',
                                        'API Sale Transaction',
                                        'Manual registered payment of request: Solicitud de pago abierta',
                                        'Pago en cuenta',
                                        'Manual registered payment of request: '
                                        )
                                        OR
                                        art.text LIKE 'Lenient match from Adyen%'
                                        OR
                                        art.text LIKE 'Pago registrado en Adyen%'
                                        OR
                                        art.text LIKE 'Manual registered payment of request:%'
                                        OR
                                        art.text LIKE '%(Cancelled Recurring)'
                                )
                                AND (art.text, act.info) NOT IN (('Pago en cuenta','Transfer'))
                                AND (art.text, act.info) NOT IN (('API Sale Transaction','Transfer'))
                ) art_list
                LEFT JOIN vivagym.art_match artm
                        ON artm.art_paying_center = art_list.center
                        AND artm.art_paying_id = art_list.id
                        AND artm.art_paying_subid = art_list.subid
                LEFT JOIN vivagym.ar_trans art2
                        ON art2.center = artm.art_paid_center
                        AND art2.id = artm.art_paid_id
                        AND art2.subid = artm.art_paid_subid
                left join vivagym.payment_request_specifications prs2
                        ON prs2.center = art2.payreq_spec_center
                        AND prs2.id = art2.payreq_spec_id
                        AND prs2.subid = art2.payreq_spec_subid
                left join vivagym.payment_requests pr
                        ON prs2.center = pr.inv_coll_center
                        AND prs2.id = pr.inv_coll_id
                        AND prs2.subid = pr.inv_coll_subid
                GROUP BY       
                        art_list.center,
                        art_list.id,
                        art_list.subid
        )
        SELECT
                r1.*
        FROM
        (
                -- NO PAYMENT ACCOUNT
                SELECT  
                        'Stand Alone Transaction' AS Transaction_Group,
                        (CASE 
								WHEN crt.crttype = 1 THEN CAST('CASH' AS TEXT)
                                WHEN (i.employee_center, i.employee_id) IN ((100,8603)) THEN CAST('ELGYMIBERIAECOM' AS TEXT)
                                ELSE CAST('ELGYMIBERIAPOS' AS TEXT)
                        END) AS Transaction_type,
                        CAST('MANUAL' AS TEXT) AS Transaction_subtype,
                        par.center_id,
                        par.center_name,
                        --TO_CHAR(longToDateC(i.entry_time, i.center),'YYYY-MM-DD HH24:MI') AS entry_time,
                        longToDateC(i.entry_time, i.center) AS entry_time,
                        payer.center || 'p' || payer.id AS Person_Id,
                        cp.external_id,
                        il.total_amount,
                        il.center || 'inv' || il.id AS Referencia,
                        il.text,
                        CAST(NULL AS TEXT) AS Exerp_Comment,
                        CAST(NULL AS TEXT) AS VivaGym_Definition,
                        1 is_in_the_bank,
                        CAST(NULL AS DATE) AS Request_Date,
                        CAST(NULL AS TEXT) AS Request_State,
                        CAST(NULL AS TEXT) AS Xfr_info,
                        CAST(NULL AS TEXT) AS Rejected_Reason_Code,
                        CAST(NULL AS NUMERIC) AS Open_amount,
                        CAST(NULL AS TIMESTAMP) AS Latest_Settlement,
                        CAST(NULL AS INT) AS contain_cargo_Devolucion, 
                        CAST(NULL AS TEXT) AS request_type,
                        CAST(NULL AS DATE) AS pr_paid_for,
                        par.fromDate,
                        par.toDate,
                        (CASE 
                                WHEN (i.employee_center,i.employee_id) IN ((100,8603)) THEN cct.transaction_id
                                ELSE NULL
                        END) AS PSP
                FROM invoice_lines_mt il
                JOIN params par
                        ON par.center_id = il.center
                JOIN vivagym.invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                LEFT JOIN vivagym.persons payer
                        ON payer.center = i.payer_center
                        AND payer.id = i.payer_id
                LEFT JOIN vivagym.cashregistertransactions crt
                        ON crt.paysessionid = i.paysessionid
                LEFT JOIN vivagym.persons cp
                        ON payer.current_person_center  = cp.center
                        AND payer.current_person_id = cp.id
				LEFT JOIN vivagym.creditcardtransactions cct
                        ON cct.invoice_center = i.center
                        AND cct.invoice_id = i.id
                WHERE
                        -- anadir condicion from and to respecto a una columna de tiempo
                        il.net_amount != '0'
                        AND i.entry_time >= par.fromDateLong
                        AND i.entry_time <= par.toDateLong
                        AND NOT EXISTS
                        (
                                SELECT 1 FROM vivagym.ar_trans art
                                WHERE art.ref_center = i.center
                                AND art.ref_id = i.id
                                AND art.ref_type = 'INVOICE'              
                        )
        ) r1
        UNION ALL
        ----------------------------   CASH ACCOUNT  --------------------------------
        SELECT
                r2.*
        FROM
        (
                -- NO PAYMENT ACCOUNT
                SELECT  
                        'CreditCard transactions on cash account' AS Transaction_Group,
                        CAST('ELGYMIBERIAECOM' AS TEXT) AS Transaction_type,
                        CAST('MANUAL' AS TEXT) AS Transaction_subtype,
                        par.center_id,
                        par.center_name,
                        --TO_CHAR(longToDateC(art.entry_time, art.center),'YYYY-MM-DD HH24:MI') AS entry_time,
                        longToDateC(art.entry_time, art.center) AS entry_time,
                        payer.center || 'p' || payer.id AS Person_Id,
                        cp.external_id,
                        art.amount,
                        art.ref_center || 'act' || art.ref_id AS Referencia,
                        art.text,
                        CAST(NULL AS TEXT) AS Exerp_Comment,
                        CAST(NULL AS TEXT) AS VivaGym_Definition,
                        1 Include_count,
                        CAST(NULL AS DATE) AS Request_Date,
                        CAST(NULL AS TEXT) AS Request_State,
                        CAST(NULL AS TEXT) AS Xfr_info,
                        CAST(NULL AS TEXT) AS Rejected_Reason_Code,
                        CAST(NULL AS NUMERIC) AS Open_Amount,
                        CAST(NULL AS TIMESTAMP) AS Latest_Settlement,
                        CAST(NULL AS INT) AS contain_cargo_Devolucion, 
                        CAST(NULL AS TEXT) AS request_type,
                        CAST(NULL AS DATE) AS pr_paid_for,
                        par.fromDate,
                        par.toDate,
                        NULL AS PSP
                FROM vivagym.account_receivables ar
                JOIN params par
                        ON par.center_id = ar.center
                JOIN vivagym.ar_trans art
                        ON art.center = ar.center
                        AND art.id = ar.id
                        AND art.ref_type = 'ACCOUNT_TRANS'
                LEFT JOIN vivagym.persons payer
                        ON payer.center = ar.customercenter
                        AND payer.id = ar.customerid
                LEFT JOIN vivagym.persons cp
                        ON payer.current_person_center  = cp.center
                        AND payer.current_person_id = cp.id
                WHERE
                        art.amount != 0
                        AND ar.ar_type = 1
                        AND art.entry_time >= par.fromDateLong
                        AND art.entry_time <= par.toDateLong
                        AND art.text IN ('Subscription sale API','API Sale Transaction')
        ) r2
        UNION ALL
        SELECT
                r3.*
        FROM
        (
                SELECT
                        'CreditCard transactions on payment account' as Transaction_Group,
                        (CASE
                                WHEN art.text IN 
                                (
                                        'Manual registered payment of request: Solicitud de pago abierta',
                                        'Pago en cuenta',
                                        'Manual registered payment of request: '
                                ) 
                                THEN 'ELGYMIBERIAPOS'
                                WHEN art.text IN
                                (
                                        'API Register remaining money from payment request',
                                        'API Sale Transaction'
                                        
                                )
                                THEN 'ELGYMIBERIAECOM'
                                WHEN art.text LIKE 'Lenient match from Adyen%' THEN 'ELGYMIBERIAECOM'
                                WHEN art.text LIKE '%(Cancelled Recurring)' THEN 'ELGYMIBERIAECOM'
                                WHEN art.text LIKE 'Pago registrado en Adyen%' THEN 'ELGYMIBERIAECOM'
                                ELSE 'UNKNOWN'
                        END) AS Transaction_type,
                        CAST('MANUAL' AS TEXT) AS Transaction_subtype,
                        par.center_id,
                        par.center_name,
                        --TO_CHAR(longToDateC(art.entry_time, art.center),'YYYY-MM-DD HH24:MI') AS entry_time,
                        longToDateC(art.entry_time, art.center) AS entry_time,
                        p.center || 'p' || p.id AS Person_Id,
                        cp.external_id,
                        art.amount,
                        art.center || 'art' || art.id AS Referencia,
                        art.text,
                        CAST(NULL AS TEXT) AS Exerp_Comment,
                        CAST(NULL AS TEXT) AS VivaGym_Definition,
                        (CASE
                                WHEN art.text IN 
                                (       
                                        'API Register remaining money from payment request',
                                        'API Sale Transaction',
                                        'Manual registered payment of request: Solicitud de pago abierta',
                                        'Pago en cuenta',
                                        'Manual registered payment of request: '
                                )
                                THEN 1
                                WHEN art.text like 'Pago registrado en Adyen%' THEN 1
                                WHEN art.text like 'Lenient match from Adyen%' THEN 1
                                WHEN art.text LIKE 'Manual registered payment of request:%' THEN 1
                                WHEN art.text LIKE '%(Cancelled Recurring)' THEN 1
								WHEN art.text LIKE 'Debt payment%' THEN 1
                                ELSE 5
                        END) include_count,
                        CAST(NULL AS DATE) AS Request_Date,
                        CAST(NULL AS TEXT) AS Request_State,
                        CAST(NULL AS TEXT) AS Xfr_info,
                        CAST(NULL AS TEXT) AS Rejected_Reason_Code,
                        CAST(NULL AS NUMERIC) AS Open_Amount,
                        CAST(NULL AS TIMESTAMP) AS Latest_Settlement,
                        (CASE WHEN
                                 EXISTS
                                (
                                        SELECT
                                                1
                                        FROM 
                                                vivagym.art_match artm 
                                        WHERE
                                                art.center = artm.art_paying_center 
                                                and art.id = artm.art_paying_id 
                                                AND art.subid = artm.art_paying_subid
                                                and artm.amount = 3
                                )
                                THEN 1
                                ELSE 0
                        END) AS contain_cargo_Devolucion,
                        CAST(NULL AS TEXT) AS request_type,
                        fr.pr_paid_for,
                        par.fromDate,
                        par.toDate,
                        NULL AS PSP
                FROM vivagym.persons p
                JOIN params par
                        ON p.center = par.center_id
                JOIN vivagym.account_receivables ar 
                        ON p.center = ar.customercenter AND p.id = ar.customerid
                JOIN vivagym.ar_trans art
                        ON ar.center = art.center AND ar.id = art.id
                JOIN vivagym.persons cp
                                ON p.current_person_center  = cp.center
                                AND p.current_person_id = cp.id
                LEFT JOIN  creditcardtransactions cct
                ON
                        art.center = cct.gl_trans_center
                        AND art.id = cct.gl_trans_id
                        AND art.subid = cct.gl_trans_subid
                        AND cct.method = 4
                LEFT JOIN vivagym.account_trans act
                        ON act.center = Art.ref_center
                         AND act.id = art.ref_id 
                         AND act.subid = art.ref_subid
                         AND art.ref_type = 'ACCOUNT_TRANS'
                 LEFT JOIN find_request fr
                        ON fr.center = art.center
                        AND fr.id = art.id
                        AND fr.subid = art.subid
                WHERE
                        ar.ar_type = 4
                        AND art.entry_time between par.fromDateLong AND par.toDateLong
                        AND art.amount != 0
                        AND art.ref_type = 'ACCOUNT_TRANS'
                        AND 
                        (
                                art.text IN (
                                'API Register remaining money from payment request',
                                'API Sale Transaction',
                                'Manual registered payment of request: Solicitud de pago abierta',
                                'Pago en cuenta',
                                'Manual registered payment of request: '
                                )
                                OR
                                art.text LIKE 'Lenient match from Adyen%'
                                OR
                                art.text LIKE 'Pago registrado en Adyen%'
                                OR
                                art.text LIKE 'Manual registered payment of request:%'
                                OR
                                art.text LIKE '%(Cancelled Recurring)'
									OR 
                art.text LIKE 'Debt payment%'
                        )
                        AND (art.text, act.info) NOT IN (('Pago en cuenta','Transfer'))
                        AND (art.text, act.info) NOT IN (('API Sale Transaction','Transfer'))
        ) r3
        UNION ALL
        SELECT 
                r4.* 
        FROM
        (
                -- 130p21673
                -- 125p29792: Caso muy raro
                -- Done manually = should we exclude them from Member count as they will be in the postive account transactions?
                -- 142p3687: example of payment and representation
                -- 509p22650 example of a positive amount, we need to check the full amount on settlement , scenario: Exclude: this has not been paid (Rejected)
                -- CN on payment account 101p817
                -- Payment requests from before Oct --> that have been settled in Oct (specify amount) --> Recoveries
                -- Payment requests from before Oct --> that get REVOKED in October
                -- Payment account POsitive transactions from MemberWeb + "Pago En Cuenta(credit card)"
                -- PAYMENT ACCOUNT
                SELECT 
                        'Payment Requests from Current Month' AS Transaction_Group,
                        CAST('ELGYMIBERIAECOM' AS TEXT) AS Transaction_type, 
                        CAST('REMESAS' AS TEXT) AS Transaction_subtype,
                        t1.center_id,
                        t1.center_name,
                        --TO_CHAR(longToDateC(t1.entry_time, t1.center),'YYYY-MM-DD HH24:MI') AS entry_time,
                        longToDateC(t1.entry_time, t1.center) AS entry_time,
                        t1.person_id,
                        t1.external_id,
                        t1.req_amount AS Amount,
                        t1.full_reference AS Referencia,
                        CAST(NULL AS TEXT) AS text,
                        (CASE
                                        WHEN t1.ranking > 1 THEN 'Exclude: there is a more recent payment request'
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement between t1.fromDateLong AND t1.toDateLong THEN 'Payment Request PAID: status DONE'
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement not between t1.fromDateLong AND t1.toDateLong THEN 'Done but Settle outside: IGNORE'
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NULL THEN 'Paid Manually'
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NOT NULL THEN 'Payment Rejected and Paid before Representation'
                /*DONE PARTIAL*/        WHEN t1.state = 18 AND t1.open_amount = 0 THEN 'Payment Rejected and Paid before Representation'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount = 0 THEN 'ChargeBack/Refund + Paid afterwards'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NOT NULL THEN 'ChargeBack/Refund + Paid afterwards'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NULL THEN 'ChargeBack/Refund + Unpaid'
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount = 0 THEN 'Rejected + Paid Manually afterwards' --502p26869
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount != 0 THEN 'Rejected + Unpaid'
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount = 0 THEN 'Failed + Paid Manually afterwards'
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount != 0 THEN 'Failed + Unpaid'
                /*NEW*/                 WHEN t1.state = 1 THEN 'Exclude: NEW NOT SENT TO BANK YET'
                                        ELSE 'Investigate'
                        END) Exerp_Comment,
                        (CASE
                                        WHEN t1.ranking > 1 THEN 'Denied'
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement between t1.fromDateLong AND t1.toDateLong AND t1.request_type = 1 THEN 'OK'
                                        WHEN t1.state = 3 AND t1.max_latest_settlement between t1.fromDateLong AND t1.toDateLong AND t1.request_type = 6 THEN 'OK: Reclaim + Recovery'
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement not between t1.fromDateLong AND t1.toDateLong THEN 'Ignore for now'
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NULL AND t1.request_type = 1 THEN 'Reclaims/Recoveries (Not sent to bank)'
                                        WHEN t1.state = 4 AND t1.rejected_reason_code IS NULL AND t1.request_type = 6 THEN 'OK*:Reclaim + Recovery'
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NOT NULL THEN 'Denied + Recovery'
                /*DONE PARTIAL*/        WHEN t1.state = 18 AND t1.open_amount = 0 THEN 'Denied + Recovery'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount = 0 THEN 'Reclaim + Recovery'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NOT NULL THEN 'Reclaim + Recovery'
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NULL THEN 'Reclaim'
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount = 0 THEN 'Denied + Recovery' --502p26869
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount != 0 THEN 'Reclaim'
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount = 0 THEN 'Reclaim + Recovery'
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount != 0 THEN 'Reclaim / NotSentToBank'
                /*NEW*/                 WHEN t1.state = 1 THEN 'Reclaim / NoSentToBank'
                                        ELSE 'Investigate'
                        END) VivaGym_Definition,
                        (CASE
                                        WHEN t1.ranking > 1 THEN 0
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement between t1.fromDateLong AND t1.toDateLong THEN 1
                /*DONE*/                WHEN t1.state = 3 AND t1.max_latest_settlement not between t1.fromDateLong AND t1.toDateLong THEN 0
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NULL THEN 0
                /*DONE MANUAL*/         WHEN t1.state = 4 AND t1.rejected_reason_code IS NOT NULL THEN 0
                /*DONE PARTIAL*/        WHEN t1.state = 18 AND t1.open_amount = 0 THEN 0
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount = 0 THEN 0
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NOT NULL THEN 0
                /*REVOKED*/             WHEN t1.state = 17 AND t1.open_amount != 0 AND t1.max_latest_settlement IS NULL THEN 0
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount = 0 THEN 0 --502p26869
                /*REJECTED*/            WHEN t1.state IN (5,6,7) AND t1.open_amount != 0 THEN 0
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount = 0 THEN 0
                /*FAILED*/              WHEN t1.state = 12 AND t1.open_amount != 0 THEN 0
                /*NEW*/                 WHEN t1.state = 1 THEN 0
                                        ELSE 2
                        END) Include_count,
                        t1.req_date,
                        t1.pr_state AS request_state,
                        t1.xfr_info,
                        t1.rejected_reason_code,
                        t1.open_amount,
                        t1.latest_settlement,
                        t1.test AS contain_cargo_Devolucion, 
                        (case t1.request_type
                                when 1 then 'Payment'
                                when 6 then 'Representation'
                        end) as request_type,
                        CAST(NULL AS DATE) AS pr_paid_for,
                        t1.fromDate,
                        t1.toDate,
                        t1.clearinghouse_payment_ref AS PSP
                FROM 
                (
                        SELECT
                                rank() over (partition by prs.center,prs.id,prs.subid ORDER BY pr.req_date DESC) ranking,
                                ar.customercenter || 'p' || ar.customerid AS Person_Id,
                                (CASE pr.state
                                        WHEN 1 THEN 'New' 
                                        WHEN 2 THEN 'Sent' 
                                        WHEN 3 THEN 'Done' 
                                        WHEN 4 THEN 'Done, manual' 
                                        WHEN 5 THEN 'Rejected, clearinghouse' 
                                        WHEN 6 THEN 'Rejected, bank' 
                                        WHEN 7 THEN 'Rejected, debtor' 
                                        WHEN 8 THEN 'Cancelled' 
                                        WHEN 10 THEN 'Reversed, new' 
                                        WHEN 11 THEN 'Reversed , sent' 
                                        WHEN 12 THEN 'Failed, not creditor' 
                                        WHEN 13 THEN 'Reversed, rejected' 
                                        WHEN 14 THEN 'Reversed, confirmed' 
                                        WHEN 17 THEN 'Failed, payment revoked' 
                                        WHEN 18 THEN 'Done Partial' 
                                        WHEN 19 THEN 'Failed, Unsupported' 
                                        WHEN 20 THEN 'Require approval' 
                                        WHEN 21 THEN 'Fail, debt case exists' 
                                        WHEN 22 THEN 'Failed, timed out' 
                                        ELSE 'Undefined' 
                                END) AS pr_state,
                                pr.state,
                                pr.request_type,
                                prs.center,
                                pr.req_amount,
                                pr.entry_time,
                                pr.req_date,
                                pr.xfr_info,
                                pr.rejected_reason_code,
                                prs.open_amount,
                                longToDateC(MAX(settlement.latest_settlement), prs.center) AS latest_settlement,
                                SUM(settlement.total_amount_settled),
                                MAX(settlement.latest_settlement) AS max_latest_settlement,
                                par.fromDateLong,
                                par.toDateLong,
                                cp.external_id,
                                pr.full_reference,
                                par.center_id,
                                par.center_name,
                                par.fromDate,
                                par.toDate,
                                pr.clearinghouse_payment_ref,
                                (CASE
                                        WHEN EXISTS (SELECT
                                        1
                                 FROM vivagym.ar_trans art
                                 WHERE
                                        art.payreq_spec_center = prs.center
                                        AND art.payreq_spec_id = prs.id
                                        AND art.payreq_spec_subid = prs.subid
                                        AND art.text = 'Cargo de devolución') 
                                        THEN 1 ELSE 0 END) test
                        FROM 
                                vivagym.payment_requests pr
                        JOIN params par
                                ON par.center_id = pr.center
                        JOIN payment_request_specifications prs
                                ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
                        JOIN ar_trans art
                                ON art.payreq_spec_center = prs.center AND art.payreq_spec_id = prs.id AND art.payreq_spec_subid = prs.subid
                        JOIN invoices i
                                ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'              
                        JOIN vivagym.clearinghouses ch 
                                ON ch.id = pr.clearinghouse_id
                        JOIN vivagym.payment_agreements pag 
                                ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
                        JOIN vivagym.payment_accounts pac 
                                ON pag.center = pac.center AND pag.id = pac.id
                        JOIN vivagym.account_receivables ar 
                                ON pac.center = ar.center AND pac.id = ar.id
                        JOIN vivagym.persons p 
                                ON ar.customercenter = p.center AND ar.customerid = p.id
                        JOIN vivagym.persons cp
                                ON p.current_person_center  = cp.center
                                AND p.current_person_id = cp.id
                        LEFT JOIN
                        (
                                SELECT
                                        s1.center,
                                        s1.id,
                                        s1.subid,
                                        s1.latest_settlement,
                                        s1.total_amount_settled
                                FROM
                                (
                                        SELECT
                                                art.center,
                                                art.id,
                                                art.subid,
                                                art.amount,
                                                max(artm.entry_time) AS latest_settlement,
                                                sum(artm.amount) AS total_amount_settled
                                        FROM vivagym.ar_trans art
                                        JOIN params par
                                                ON par.center_id = art.center
                                        JOIN vivagym.art_match artm 
                                                ON artm.art_paid_center = art.center
                                                AND artm.art_paid_id = art.id
                                                AND artm.art_paid_subid = art.subid
                                        WHERE   
                                                art.ref_type = 'INVOICE'
                                                AND artm.cancelled_time IS NULL
                                        GROUP BY
                                                art.center,
                                                art.id,
                                                art.subid
                                ) s1
                                WHERE s1.amount = -(s1.total_amount_settled)
                        ) settlement
                                ON art.center = settlement.center
                                AND art.id = settlement.id
                                AND art.subid = settlement.subid
                        WHERE
                                pr.req_date >= par.fromDate
                                AND pr.req_date <= par.toDate
                                AND pr.req_amount != 0
                                AND pr.clearinghouse_id IN (1,3002,3201,3601,4402,3803,4001,4201,5201,4601,7402)
                        GROUP BY
                                ar.customercenter,
                                ar.customerid,
                                pr.state,
                                pr.request_type,
                                pr.req_amount,
                                pr.entry_time,
                                pr.req_date,
                                pr.xfr_amount,
                                pr.xfr_date,
                                pr.xfr_info,
                                pr.rejected_reason_code,
                                par.fromDateLong,
                                par.toDateLong,
                                prs.open_amount,
                                cp.external_id,
                                pr.full_reference,
                                par.center_id,
                                par.center_name,
                                prs.center,
                                prs.id,
                                prs.subid,
                                par.fromDate,
                                par.toDate,
                                pr.clearinghouse_payment_ref
                ) t1
        ) r4
        UNION ALL
        SELECT
                r5.* 
        FROM 
        (
                -- CONFIRM NO DUPLICATES
                -- Payment requests from before Oct --> that get REVOKED in October
                -- PAYMENT ACCOUNT
                SELECT
                        'Payment Requests from Previous Month' AS Transaction_Group,
                        CAST('ELGYMIBERIAECOM' AS TEXT) AS Transaction_type, 
                        CAST('REMESAS' AS TEXT) AS Transaction_subtype,
                        par.center_id,
                        par.center_name,
                        --TO_CHAR(cin.received_date,'YYYY-MM-DD HH24:MI') AS entry_time,
                        cin.received_date AS entry_time,
                        ar.customercenter || 'p' || ar.customerid AS Person_id,
                        cp.external_id,
                        pr.req_amount* (-1) AS Amount,
                        prs.center || 'prs' || prs.id || 'pr' || prs.subid AS Referencia,
                        CAST(NULL AS TEXT) AS text,
                        (CASE
                                WHEN prs.open_amount !=0 THEN 'ChargeBack & Still not paid'
                                WHEN prs.open_amount =0 THEN 'ChargeBack & Paid afterwards'
                        END) AS Exerp_Comment,
                        (CASE
                                WHEN prs.open_amount !=0 THEN 'Reclaim'
                                WHEN prs.open_amount =0 THEN 'Reclaim + Recovery'
                        END) AS VivaGym_Definition,
                        CAST(1 AS INT) AS is_in_the_bank,
                        pr.req_date,
                        (CASE pr.state
                                WHEN 1 THEN 'New' 
                                WHEN 2 THEN 'Sent' 
                                WHEN 3 THEN 'Done' 
                                WHEN 4 THEN 'Done, manual' 
                                WHEN 5 THEN 'Rejected, clearinghouse' 
                                WHEN 6 THEN 'Rejected, bank' 
                                WHEN 7 THEN 'Rejected, debtor' 
                                WHEN 8 THEN 'Cancelled' 
                                WHEN 10 THEN 'Reversed, new' 
                                WHEN 11 THEN 'Reversed , sent' 
                                WHEN 12 THEN 'Failed, not creditor' 
                                WHEN 13 THEN 'Reversed, rejected' 
                                WHEN 14 THEN 'Reversed, confirmed' 
                                WHEN 17 THEN 'Failed, payment revoked' 
                                WHEN 18 THEN 'Done Partial' 
                                WHEN 19 THEN 'Failed, Unsupported' 
                                WHEN 20 THEN 'Require approval' 
                                WHEN 21 THEN 'Fail, debt case exists' 
                                WHEN 22 THEN 'Failed, timed out' 
                                ELSE 'Undefined' 
                        END) AS request_state,
                        pr.xfr_info,
                        pr.rejected_reason_code, 
                        prs.open_amount,
                        CAST(NULL AS TIMESTAMP) AS latest_settlement,
                        (CASE
                                WHEN EXISTS (SELECT
                                1
                         FROM vivagym.ar_trans art
                         WHERE
                                art.payreq_spec_center = prs.center
                                AND art.payreq_spec_id = prs.id
                                AND art.payreq_spec_subid = prs.subid
                                AND art.text = 'Cargo de devolución') 
                                THEN 1 ELSE 0 
                        END) contain_cargo_Devolucion,
                        (CASE pr.request_type
                                when 1 then 'Payment'
                                when 6 then 'Representation'
                        END) AS request_type,
                        CAST(NULL AS DATE) AS pr_paid_for,
                        par.fromDate,
                        par.toDate,
                        NULL AS PSP
                                    
                FROM 
                        vivagym.payment_requests pr
                JOIN params par
                        ON par.center_id = pr.center
                JOIN payment_request_specifications prs
                        ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
                JOIN ar_trans art
                        ON art.payreq_spec_center = prs.center AND art.payreq_spec_id = prs.id AND art.payreq_spec_subid = prs.subid
                JOIN invoices i
                        ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                JOIN vivagym.clearinghouses ch 
                        ON ch.id = pr.clearinghouse_id
                JOIN vivagym.payment_agreements pag 
                        ON pag.center = pr.center AND pag.id = pr.id AND pag.subid = pr.agr_subid
                JOIN vivagym.payment_accounts pac 
                        ON pag.center = pac.center AND pag.id = pac.id
                JOIN vivagym.account_receivables ar 
                        ON pac.center = ar.center AND pac.id = ar.id
                JOIN vivagym.persons p 
                        ON ar.customercenter = p.center AND ar.customerid = p.id
                JOIN vivagym.clearing_in cin
                        ON cin.id = pr.xfr_delivery
                JOIN vivagym.persons cp
                                ON p.current_person_center  = cp.center
                                AND p.current_person_id = cp.id
                WHERE
                        pr.req_amount != 0
                        --AND pr.state = 17
                        AND pr.xfr_delivery IS NOT NULL
                        AND pr.req_date < par.fromDate
                        AND cin.received_date between par.fromDate AND par.toDate
                        AND pr.clearinghouse_id IN (1,3002,3201,3601,4402,3803,4001,4201,5201,4601,7402)
                GROUP BY
                        ar.customercenter,
                        ar.customerid,
                        pr.state,
                        ch.name,
                        pr.creditor_id,
                        pr.request_type,
                        pr.req_amount,
                        pr.center,pr.id, 
                        pr.subid,
                        pr.entry_time,
                        pr.center,
                        pr.req_date,
                        pr.xfr_amount,
                        pr.xfr_date,
                        pr.xfr_info,
                        pr.rejected_reason_code,
                        par.fromDateLong,
                        par.toDateLong,
                        prs.open_amount,
                        prs.center,
                        prs.id,
                        prs.subid,
                        cin.received_date,
                        cp.external_id,
                        par.center_id,
                        par.center_name,
                        par.fromDate,
                        par.toDate
        ) r5
) total