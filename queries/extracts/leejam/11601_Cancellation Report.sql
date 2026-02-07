
 WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST($$FromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST($$ToDate$$ AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
              FROM
                  centers c
          )
SELECT
        cn.center,
cn.center||'cred'||cn.id Credit,
        pe.center||'p'||pe.id AS "Member id",
        pe.fullname           AS "Member name",
        pr.name               AS "Product name",
		null "Subscription start date",
		null "Original end date",
		null "New end date",
		null "Type",
		null "Reason",
        CASE
                WHEN cnl.total_amount IS NOT NULL THEN cnl.total_amount
                ELSE 0
        END AS "Credit amount",
null AS "Date processed(only for subscriptions)",
        longtodate(cn.trans_time) cancellation_time,
	    longtodate(inv.trans_time) sales_date , 
		empp.fullname AS "Cancelled by Employee",
        cnl.invoiceline_center||'inv'||cnl.invoiceline_id "Associated invoiceKey",
		CASE
                WHEN spempp2.fullname IS NOT NULL THEN spempp2.fullname 
               -- ELSE spempp.fullname 
        END AS "Original sales employee" ,
        inv.cash, 
        inv.cashregister_center,
        inv.cashregister_id,
        cn.cashregister_center, 
        cn.cashregister_id,
        cn.cash,
        CASE
                WHEN crt.CRTTYPE = 1 THEN 'CASH' 
                WHEN crt.CRTTYPE = 2 THEN 'CHANGE'
                WHEN crt.CRTTYPE = 3 THEN 'RETURN ON CREDIT' 
                WHEN crt.CRTTYPE = 4 THEN 'PAYOUT CASH' 
                WHEN crt.CRTTYPE = 5 THEN 'PAID BY CASH AR ACCOUNT' 
                WHEN crt.CRTTYPE = 6 THEN 'DEBIT CARD' 
                WHEN crt.CRTTYPE = 7 THEN 'CREDIT CARD' 
                WHEN crt.CRTTYPE = 8 THEN 'DEBIT OR CREDIT CARD' 
                WHEN crt.CRTTYPE = 9 THEN 'GIFT CARD' 
                WHEN crt.CRTTYPE = 10 THEN 'CASH ADJUSTMENT' 
                WHEN crt.CRTTYPE = 11 THEN 'CASH TRANSFER' 
                WHEN crt.CRTTYPE = 12 THEN 'PAYMENT AR' 
                WHEN crt.CRTTYPE = 13 THEN 'CONFIG PAYMENT METHOD' 
                WHEN crt.CRTTYPE = 14 THEN 'CASH REGISTER PAYOUT' 
                WHEN crt.CRTTYPE = 15 THEN 'CREDIT CARD ADJUSTMENT' 
                WHEN crt.CRTTYPE = 16 THEN 'CLOSING CASH ADJUST' 
                WHEN crt.CRTTYPE = 17 THEN 'VOUCHER' 
                WHEN crt.CRTTYPE = 18 THEN 'PAYOUT CREDIT CARD' 
                WHEN crt.CRTTYPE = 19 THEN 'TRANSFER BETWEEN REGISTERS' 
                WHEN crt.CRTTYPE = 20 THEN 'CLOSING CREDIT CARD ADJ' 
                WHEN crt.CRTTYPE = 21 THEN 'TRANSFER BACK CASH COINS' 
                WHEN crt.CRTTYPE = 22 THEN 'INSTALLMENT PLAN' 
                WHEN crt.CRTTYPE = 100 THEN 'INITIAL CASH' 
                WHEN crt.CRTTYPE = 101 THEN 'MANUAL' 
                ELSE 'Undefined' 
        END AS "Payment method",
        CASE
                WHEN pr.ptype IN (5,6,7,10,12,13) AND p.persontype != 4 AND inv.sponsor_invoice_center IS NULL THEN 'Individual'     
                WHEN pr.ptype IN (5,6,7,10,12,13) AND p.persontype = 4 AND inv.sponsor_invoice_center IS NULL THEN 'B2C'
                WHEN pr.ptype IN (5,6,7,10,12,13) AND p.persontype = 4 AND inv.sponsor_invoice_center IS NOT NULL THEN 'B2B'
                WHEN pr.ptype IN (1,2,4) THEN 'Retail' 
                ELSE 'Other'
        END AS "Sales Type"                           
       
FROM
        credit_notes cn
JOIN 
        params 
        ON params.CENTER_ID = cn.center 
JOIN
        credit_note_lines_mt cnl
        ON cn.center = cnl.center
        AND cn.id = cnl.id
JOIN
        spp_invoicelines_link sppinvlnk
        ON sppinvlnk.invoiceline_center = cnl.invoiceline_center
        AND sppinvlnk.invoiceline_id = cnl.invoiceline_id
        AND sppinvlnk.invoiceline_subid = cnl.invoiceline_subid
JOIN
        invoice_lines_mt invl 
        ON cnl.invoiceline_center = invl.center 
        AND cnl.invoiceline_id = invl.id 
        AND cnl.invoiceline_subid = invl.subid
JOIN 
        invoices inv 
        ON inv.center = invl.center 
        AND inv.id = invl.id
JOIN
        PRODUCTS PR
        ON cnl.PRODUCTCENTER = PR.CENTER
        AND cnl.PRODUCTID = PR.ID
JOIN
        EMPLOYEES EM
        ON (cn.EMPLOYEE_CENTER = EM.CENTER AND cn.EMPLOYEE_ID = EM.ID)
JOIN
        persons empp
        ON empp.center = em.personcenter
        AND empp.id = em.personid
JOIN
        persons PE
        ON PE.CENTER = cn.PAYER_CENTER
        AND PE.ID = cn.PAYER_ID
LEFT JOIN
        cashregistertransactions crt        
        ON crt.center = inv.cashregister_center
        AND crt.id = inv.cashregister_id
        AND crt.paysessionid = inv.paysessionid
JOIN
        persons p        
        ON p.center = cn.payer_center
        AND p.id = cn.payer_id
LEFT JOIN
        leejam.employees spemp2
        ON spemp2.center = inv.employee_center
        AND spemp2.id = inv.employee_id
LEFT JOIN
        leejam.persons spempp2
        ON spempp2.center = spemp2.personcenter
        AND spempp2.id = spemp2.personid
--order by cn.trans_time desc
--order by cn.trans_time desc
WHERE 
        cn.trans_time BETWEEN params.FromDate AND params.ToDate
        AND 
        cn.center IN (:scope)
   -- and p.center in (101101) and p.id in (10336, 42017)
    and pr.ptype   not in (5,10)  
UNION


SELECT DISTINCT
     creditnote.center,
creditnote.cn_center||'cred'||creditnote.cn_id Credit,
 p.center||'p'||p.id AS "Member id"
        ,p.fullname AS "Member name"
        ,prod.name AS "Product name"
        ,s.start_date AS "Subscription start date"
        ,oldend.effect_date AS "Original end date"
        ,sc.effect_date AS "New end date"
        ,CASE
                WHEN s.sub_state = 8 THEN 'Delete'
                Else 'Stop'
        END AS "Type"
        ,CASE -- SHOULD BE UPDATES ONCE CONFIGURED IN PRODUCTION
              WHEN qa.result_code = 'DUP' THEN 'Duplicate payment'
              WHEN qa.result_code = 'CLOSE' THEN 'Club closed or converted'
              WHEN qa.result_code = 'HEALTH' THEN 'Health issues/deceased'
              WHEN qa.result_code = 'PT' THEN 'PT classes not conducted/club reason' 
              WHEN qa.result_code = 'AGE' THEN 'Age related issues'  
              WHEN qa.result_code = 'LEGAL' THEN 'Disciplinary/Legal Status issues'  
              WHEN qa.result_code = 'CORP' THEN 'Corporate related issues'  
              WHEN qa.result_code = 'OTHER' THEN 'Other issues'                 
              Else qa.result_code
        END AS "Reason"
       /* ,CASE
                WHEN creditnote.total_amount IS NOT NULL THEN creditnote.total_amount
                ELSE 0
        END AS "Credit amount"*/
		,CASE
                WHEN creditnote.total_amount IS NOT NULL THEN creditnote.total_amount
                ELSE 0
        END AS "Credit amount",		
TO_CHAR(longtodate(sc.change_time),'dd-MM-yyyy') AS "Date processed(only for subscriptions)",
        longtodate(creditnote.cn_trans_time) cancellation_time,
       -- ,TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd') AS "Date processed",
	 longtodate(creditnote.inv_trans_time) sales_date 		
        ,empp.fullname AS "Cancelled by Employee",
		 creditnote.Associated_invoiceKey "Associated invoiceKey",
                 CASE
                WHEN spempp2.fullname IS NOT NULL THEN spempp2.fullname 
                ELSE spempp.fullname 
        END AS "Original sales employee"    ,		
		
		 creditnote.inv_cash "cash(invoice)", 
        creditnote.inv_cashregister_center "invoice cash register center",
        creditnote.inv_cashregister_id "invoice cash register id",
        creditnote.cn_cashregister_center "credit note cash register center", 
        creditnote.cn_cashregister_id "credit note cash register id",
        creditnote.cn_cash "cash(credit note)",
		
       
        		CASE
                WHEN crt.CRTTYPE = 1 THEN 'CASH' 
                WHEN crt.CRTTYPE = 2 THEN 'CHANGE'
                WHEN crt.CRTTYPE = 3 THEN 'RETURN ON CREDIT' 
                WHEN crt.CRTTYPE = 4 THEN 'PAYOUT CASH' 
                WHEN crt.CRTTYPE = 5 THEN 'PAID BY CASH AR ACCOUNT' 
                WHEN crt.CRTTYPE = 6 THEN 'DEBIT CARD' 
                WHEN crt.CRTTYPE = 7 THEN 'CREDIT CARD' 
                WHEN crt.CRTTYPE = 8 THEN 'DEBIT OR CREDIT CARD' 
                WHEN crt.CRTTYPE = 9 THEN 'GIFT CARD' 
                WHEN crt.CRTTYPE = 10 THEN 'CASH ADJUSTMENT' 
                WHEN crt.CRTTYPE = 11 THEN 'CASH TRANSFER' 
                WHEN crt.CRTTYPE = 12 THEN 'PAYMENT AR' 
                WHEN crt.CRTTYPE = 13 THEN 'CONFIG PAYMENT METHOD' 
                WHEN crt.CRTTYPE = 14 THEN 'CASH REGISTER PAYOUT' 
                WHEN crt.CRTTYPE = 15 THEN 'CREDIT CARD ADJUSTMENT' 
                WHEN crt.CRTTYPE = 16 THEN 'CLOSING CASH ADJUST' 
                WHEN crt.CRTTYPE = 17 THEN 'VOUCHER' 
                WHEN crt.CRTTYPE = 18 THEN 'PAYOUT CREDIT CARD' 
                WHEN crt.CRTTYPE = 19 THEN 'TRANSFER BETWEEN REGISTERS' 
                WHEN crt.CRTTYPE = 20 THEN 'CLOSING CREDIT CARD ADJ' 
                WHEN crt.CRTTYPE = 21 THEN 'TRANSFER BACK CASH COINS' 
                WHEN crt.CRTTYPE = 22 THEN 'INSTALLMENT PLAN' 
                WHEN crt.CRTTYPE = 100 THEN 'INITIAL CASH' 
                WHEN crt.CRTTYPE = 101 THEN 'MANUAL' 
                ELSE 'Undefined' 
        END AS "Payment method",
		CASE
                WHEN prod.ptype IN (5,6,7,10,12,13) AND p.persontype != 4 AND creditnote.sponsor_invoice_center IS NULL THEN 'Individual'     
                WHEN prod.ptype IN (5,6,7,10,12,13) AND p.persontype = 4 AND creditnote.sponsor_invoice_center IS NULL THEN 'B2C'
                WHEN prod.ptype IN (5,6,7,10,12,13) AND p.persontype = 4 AND creditnote.sponsor_invoice_center IS NOT NULL THEN 'B2B'
                WHEN prod.ptype IN (1,2,4) THEN 'Retail' 
                ELSE 'Other'
        END AS "Sales Type"               
FROM
        leejam.subscriptions s 
JOIN
        leejam.subscription_change sc
        ON sc.old_subscription_center = s.center
        AND sc.old_subscription_id = s.id
        AND sc.type = 'END_DATE'
        AND sc.cancel_time IS NULL
JOIN
        (SELECT
                max(sco.id) AS ID
                ,sco.old_subscription_center
                ,sco.old_subscription_id
        FROM
                leejam.subscription_change sco  
        WHERE
                sco.type = 'END_DATE'
                AND
                sco.cancel_time IS NOT NULL
        GROUP BY
                sco.old_subscription_center
                ,sco.old_subscription_id
        )prev
        ON prev.old_subscription_center = sc.old_subscription_center
        AND prev.old_subscription_id = sc.old_subscription_id
JOIN
        leejam.subscription_change oldend
        ON oldend.id = prev.ID
        AND oldend.old_subscription_center = prev.old_subscription_center 
        AND oldend.old_subscription_id = prev.old_subscription_id
JOIN
        leejam.persons p                                       
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN
        leejam.subscriptiontypes st
        ON s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id                        
JOIN                        
        leejam.products prod
        ON st.center = prod.center
        AND st.id = prod.id
JOIN
        leejam.employees emp
        ON emp.center = sc.employee_center
        AND emp.id = sc.employee_id
JOIN
        leejam.persons empp
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid
JOIN
        leejam.employees spemp
        ON spemp.center = s.creator_center
        AND spemp.id = s.creator_id
JOIN
        leejam.persons spempp
        ON spempp.center = spemp.personcenter
        AND spempp.id = spemp.personid
LEFT JOIN
        leejam.subscription_sales ss
        ON ss.subscription_center = s.center
        AND ss.subscription_id = s.id
LEFT JOIN
        leejam.employees spemp2
        ON spemp2.center = ss.employee_center
        AND spemp2.id = ss.employee_id
LEFT JOIN
        leejam.persons spempp2
        ON spempp2.center = spemp2.personcenter
        AND spempp2.id = spemp2.personid
LEFT JOIN
        (SELECT
        cnl.invoiceline_center||'inv'||cnl.invoiceline_id Associated_invoiceKey,
               cnl.total_amount
                ,cn.trans_time cn_trans_time
                ,s.center , cn.center cn_center, cn.id cn_id
                ,s.id  ,inv.trans_time inv_trans_time,
                inv.cash inv_cash, 
        inv.cashregister_center inv_cashregister_center,
        inv.cashregister_id inv_cashregister_id,
        cn.cashregister_center cn_cashregister_center, 
        cn.cashregister_id cn_cashregister_id,
        cn.cash cn_cash, 
        inv.paysessionid    , inv.sponsor_invoice_center         
        FROM
                leejam.credit_notes cn
        JOIN
                leejam.credit_note_lines_mt cnl
                ON cn.center = cnl.center
                AND cn.id = cnl.id 
        JOIN
                leejam.spp_invoicelines_link sppinvlnk
                ON sppinvlnk.invoiceline_center = cnl.invoiceline_center
                AND sppinvlnk.invoiceline_id = cnl.invoiceline_id
                AND sppinvlnk.invoiceline_subid = cnl.invoiceline_subid      
JOIN
        invoice_lines_mt invl 
        ON cnl.invoiceline_center = invl.center 
        AND cnl.invoiceline_id = invl.id 
        AND cnl.invoiceline_subid = invl.subid
JOIN 
        invoices inv 
        ON inv.center = invl.center 
        AND inv.id = invl.id				
        JOIN
                subscriptionperiodparts spp
                ON spp.center = sppinvlnk.period_center
                AND spp.id = sppinvlnk.period_id
                AND spp.subid = sppinvlnk.period_subid
        JOIN
                leejam.subscriptions s                
                ON s.center = spp.center
                AND s.id = spp.id
        JOIN 
                params 
                ON params.CENTER_ID = cn.center                
        WHERE
                cnl.reason IN (8,14)
                AND
                cn.trans_time BETWEEN params.FromDate AND params.ToDate
        )creditnote
        ON creditnote.center = s.center
        AND creditnote.id = s.id
        AND TO_CHAR(longtodate(creditnote.cn_trans_time),'yyyy-MM-dd') =  TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd')
		
LEFT JOIN
        cashregistertransactions crt        
        ON crt.center = creditnote.cn_cashregister_center
        AND crt.id = creditnote.cn_cashregister_id
        AND crt.paysessionid = creditnote.paysessionid
JOIN 
        params 
        ON params.CENTER_ID = p.center
JOIN
        journalentries jrn
        ON jrn.person_center = p.center
        AND jrn.person_id = p.id
        AND jrn.jetype = 18
        AND TO_CHAR(longtodate(jrn.creation_time),'yyyy-MM-dd') =  TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd')
LEFT JOIN
        (SELECT Max(Subid) as maxid,center,id 
        FROM questionnaire_answer
        WHERE questionnaire_campaign_id = 1 -- SHOULD BE UPDATES ONCE CONFIGURED IN PRODUCTION 
        GROUP BY center,id) q
        ON q.center = p.center
        AND q.id = p.id
LEFT JOIN 
        questionnaire_answer qa
        ON qa.center = q.center
        AND qa.id = q.id
        AND qa.subid = q.maxid                
WHERE
        sc.employee_center ||'emp'||sc.employee_id != '100emp1'
        AND
        sc.change_time BETWEEN params.FromDate AND params.ToDate
        AND
       p.center in (:scope)     
 --   and   p.center in (101101) and p.id in (10336, 42017)
and prod.ptype not in (5)