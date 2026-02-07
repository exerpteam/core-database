SELECT
        t0.CompanyId                                                    AS "Company Person ID",
        t0.CompanyFullName                                              AS "Company Name",
        to_char(t0.BookDate,'YYYY-MM-DD')                               AS "Book Date",
        to_char(t0.BookDate,'YYYY-MM-DD HH24:MI:SS')                    AS "Book Time",
        t0.SubscriptionStart                                            AS "Subscription Start Date",
        t0.SubscriptionEnd                                              AS "Subscription End Date",  
        t0.TransactionText                                              AS "Transaction Description",
        SUM(t0.TotalSponsor)-SUM(t0.VATSponsor)                         AS "Revenue Amount",
        SUM(t0.VATSponsor)                                              AS "Tax Amount",
        t0.Province                                                     AS "Province",
        t0.DeferAccount                                                 AS "Deferred Revenue Account",
        t0.CompanyType                                                  AS "Company Type"
        ,t0.ARTransAmount                                                  AS "AR Transaction amount"
        ,t0.UnsettleAmount                                             AS "AR Transaction Open Amount"
        ,t0.ARTransAmount - t0.UnsettleAmount                          AS "AR Transaction Settled amount"
        --t0.InvoicedStartDate                                            AS "Invoiced Start Date",
        --t0.InvoicedEndDate                                              AS "Invoiced End Date",
        --t0.InvoicedDays                                                 AS "Invoiced Days",
        --ROUND((t0.TotalSponsor-t0.VATSponsor)/(t0.InvoicedDays),2)      AS "Daily Price"
FROM
( 
        SELECT
                taux2.CompanyId,
                taux2.CompanyFullName,
                taux2.BookDate,
                taux2.SubscriptionStart,
                taux2.SubscriptionEnd,
                taux2.TransactionText,
                taux2.TotalSponsor,
                COALESCE(SUM(acttran.amount),0) AS VATSponsor,
                taux2.Province,
                taux2.DeferAccount,
                taux2.CompanyType
                ,taux2.ARTransAmount
                ,taux2.UnsettleAmount
            
        FROM
        (
                SELECT
                        taux.CompanyId,
                        taux.CompanyFullName,
                        taux.BookDate,
                        taux.SubscriptionStart,
                        taux.SubscriptionEnd,
                        taux.TransactionText,
                        taux.TotalSponsor,
                        taux.Province,
                        taux.DeferAccount,
                        taux.CompanyType
                        ,taux.ARTransAmount
                        ,taux.ARTransAmount + sum(COALESCE(arm.amount,0)) AS UnsettleAmount
                        , taux.ilsponCenter
                        , taux.ilsponId
                        , taux.ilsponSubid
                FROM
                (
                        SELECT
                                invComp.payer_center || 'p' || invComp.payer_id AS CompanyId,
                                comp.fullname AS CompanyFullName,
                                longtodateC(art.trans_time, art.center) AS BookDate,
                                sub.start_date AS SubscriptionStart,
                                sub.end_date AS SubscriptionEnd, 
                                art.text AS TransactionText,
                                COALESCE(SUM(ilspon.total_amount),0) AS TotalSponsor,
                                --COALESCE(SUM(acttran.amount),0) AS VATSponsor,
                                zc.province AS Province,
                                pacc.defer_rev_account_globalid AS DeferAccount,
                                compType.txtvalue AS CompanyType,
                                ilspon.center AS ilsponCenter,
                                ilspon.id AS ilsponId,
                                ilspon.subid AS ilsponSubid
                                ,art.amount AS ARTransAmount
                                , art.center AS ARTCenter, art.id AS ARTId, art.subid AS ARTSubId
                        FROM subscriptionperiodparts spp 
                        INNER JOIN subscriptions sub 
                                ON 
                                        (spp.center = sub.center AND spp.id = sub.id) 
                        LEFT JOIN spp_invoicelines_link sppil 
                                ON 
                                        (sppil.period_center = spp.center AND sppil.period_id = spp.id AND sppil.period_subid = spp.subid) 
                        LEFT JOIN invoice_lines_mt ilnospo
                                ON 
                                        (sppil.invoiceline_center = ilnospo.center AND sppil.invoiceline_id = ilnospo.id AND sppil.invoiceline_subid = ilnospo.subid)
                        LEFT JOIN invoices invoice
                                ON 
                                        (ilnospo.center = invoice.center AND ilnospo.id = invoice.id) 
                        INNER JOIN products prd 
                                ON 
                                        (ilnospo.productcenter = prd.center AND ilnospo.productid = prd.id) 
                        LEFT JOIN product_account_configurations pacc 
                                ON 
                                        prd.product_account_config_id = pacc.id 
                        JOIN invoice_lines_mt ilspon 
                                ON 
                                        (invoice.sponsor_invoice_center = ilspon.center AND invoice.sponsor_invoice_id = ilspon.id AND ilnospo.sponsor_invoice_subid = ilspon.subid) 
                        LEFT JOIN invoices invComp
                                ON
                                        ilspon.center = invComp.center AND ilspon.id = invComp.id
                        LEFT JOIN ar_trans art
                                ON
                                        art.ref_center = invComp.center AND art.ref_id = invComp.id AND art.ref_type='INVOICE'
                        LEFT JOIN persons comp
                                ON
                                        invComp.payer_center = comp.center AND invComp.payer_id = comp.id
                        LEFT JOIN centers cenSub
                                ON
                                        sub.center = cenSub.id
                        LEFT JOIN zipcodes zc
                                ON 
                                        cenSub.zipcode = zc.zipcode AND zc.country = 'CA'
                        LEFT JOIN person_ext_attrs compType
                                ON
                                        compType.personcenter = comp.center AND compType.personid = comp.id AND compType.name = 'COMPANYTYPE'
                        WHERE 
                                (
                                        --spp.spp_state = 1 AND 
                                        sub.start_date > to_date(:cut_date,'YYYY-MM-DD')
                                        AND art.trans_time < datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),art.center)
                                        AND ilspon.total_amount > 0
                                ) 
                        GROUP BY
                                invComp.payer_center,
                                invComp.payer_id,
                                comp.fullname,
                                art.trans_time,
                                art.center,
                                art.id,
                                sub.start_date, 
                                sub.end_date, 
                                art.text,
                                zc.province,
                                pacc.defer_rev_account_globalid,
                                compType.txtvalue,
                                ilspon.center,
                                ilspon.id,
                                ilspon.subid
                                ,art.amount
                                ,art.center, art.id, art.subid
                        ORDER BY
                               invComp.payer_center,
                               invComp.payer_id
                ) taux
                LEFT JOIN art_match arm
                        ON 
                                arm.art_paid_center = taux.ARTCenter
                                AND arm.art_paid_id = taux.ARTId
                                AND arm.art_paid_subid = taux.ARTSubId
                                AND arm.entry_time <  datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center)
                                AND (arm.cancelled_time IS NULL OR arm.cancelled_time >= datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center))
                GROUP BY
                        taux.CompanyId,
                        taux.CompanyFullName,
                        taux.BookDate,
                        taux.SubscriptionStart,
                        taux.SubscriptionEnd,
                        taux.TransactionText,
                        taux.TotalSponsor,
                        taux.Province,
                        taux.DeferAccount,
                        taux.CompanyType
                        ,taux.ARTransAmount
                        , taux.ilsponCenter
                        , taux.ilsponId
                        , taux.ilsponSubid
        ) taux2
        LEFT JOIN invoicelines_vat_at_link ilvatspon 
                ON 
                        (ilvatspon.invoiceline_center = taux2.ilsponCenter AND ilvatspon.invoiceline_id = taux2.ilsponId AND ilvatspon.invoiceline_subid = taux2.ilsponSubId)
        LEFT JOIN account_trans acttran 
                ON 
                        (ilvatspon.account_trans_center = acttran.CENTER AND ilvatspon.account_trans_id = acttran.ID AND ilvatspon.account_trans_subid = acttran.SUBID) 
        
        GROUP BY 
                taux2.CompanyId,
                taux2.CompanyFullName,
                taux2.BookDate,
                taux2.SubscriptionStart,
                taux2.SubscriptionEnd,
                taux2.TransactionText,
                taux2.TotalSponsor,
                taux2.Province,
                taux2.DeferAccount,
                taux2.CompanyType  
                ,taux2.ARTransAmount
                ,taux2.UnsettleAmount   
) t0
GROUP BY
        t0.CompanyId,
        t0.CompanyFullName,
        t0.BookDate,
        t0.BookDate,
        t0.SubscriptionStart,
        t0.SubscriptionEnd,  
        t0.TransactionText,
        t0.Province,
        t0.DeferAccount,
        t0.CompanyType,
        t0.ARTransAmount,
        t0.UnsettleAmount
UNION
SELECT
        t0.CompanyId                                                    AS "Company Person ID",
        t0.CompanyFullName                                              AS "Company Name",
        to_char(t0.BookDate,'YYYY-MM-DD')                               AS "Book Date",
        to_char(t0.BookDate,'YYYY-MM-DD HH24:MI:SS')                    AS "Book Time",
        t0.SubscriptionStart                                            AS "Subscription Start Date",
        t0.SubscriptionEnd                                              AS "Subscription End Date",  
        t0.TransactionText                                              AS "Transaction Description",
        -(t0.CreditNoteAmount-t0.VATSponsor)                            AS "Revenue Amount",
        -t0.VATSponsor                                                   AS "Tax Amount",
        t0.Province                                                     AS "Province",
        t0.DeferAccount                                                 AS "Deferred Revenue Account",
        t0.CompanyType                                                  AS "Company Type"
        ,t0.ARTransAmount                                                  AS "AR Transaction amount"
        ,t0.UnsettleAmount                                             AS "AR Transaction Open Amount"
        ,t0.ARTransAmount - t0.UnsettleAmount                          AS "AR Transaction Settled amount"
        --t0.InvoicedStartDate                                            AS "Invoiced Start Date",
        --t0.InvoicedEndDate                                              AS "Invoiced End Date",
        --t0.InvoicedDays                                                 AS "Invoiced Days",
        --ROUND((t0.TotalSponsor-t0.VATSponsor)/(t0.InvoicedDays),2)      AS "Daily Price"
FROM
( 
        SELECT
                taux2.CompanyId,
                taux2.CompanyFullName,
                taux2.BookDate,
                taux2.SubscriptionStart,
                taux2.SubscriptionEnd,
                taux2.TransactionText,
                taux2.TotalSponsor,
                taux2.CreditNoteAmount,
                COALESCE(SUM(acttranCN.amount),0) AS VATSponsor,
                taux2.Province,
                taux2.DeferAccount,
                taux2.CompanyType
                ,taux2.ARTransAmount
                ,taux2.UnsettleAmount
            
        FROM
        (
                SELECT
                        taux.CompanyId,
                        taux.CompanyFullName,
                        taux.BookDate,
                        taux.SubscriptionStart,
                        taux.SubscriptionEnd,
                        taux.TransactionText,
                        taux.TotalSponsor,
                        taux.CreditNoteAmount,
                        taux.Province,
                        taux.DeferAccount,
                        taux.CompanyType
                        ,taux.ARTransAmount
                        ,taux.ARTransAmount - sum(COALESCE(arm.amount,0)) AS UnsettleAmount
                        , taux.ilsponCenter
                        , taux.ilsponId
                        , taux.ilsponSubid
                FROM
                (
                        SELECT
                                invComp.payer_center || 'p' || invComp.payer_id AS CompanyId,
                                comp.fullname AS CompanyFullName,
                                longtodateC(artcn.trans_time, artcn.center) AS BookDate,
                                sub.start_date AS SubscriptionStart,
                                sub.end_date AS SubscriptionEnd, 
                                artcn.text AS TransactionText,
                                0 AS TotalSponsor,
                                cn.total_amount AS CreditNoteAmount,
                                zc.province AS Province,
                                pacc.defer_rev_account_globalid AS DeferAccount,
                                compType.txtvalue AS CompanyType,
                                cn.center AS ilsponCenter,
                                cn.id AS ilsponId,
                                cn.subid AS ilsponSubid
                                ,artcn.amount AS ARTransAmount
                                , artcn.center AS ARTCenter, artcn.id AS ARTId, artcn.subid AS ARTSubId
                        FROM subscriptionperiodparts spp 
                        INNER JOIN subscriptions sub 
                                ON 
                                        (spp.center = sub.center AND spp.id = sub.id) 
                        LEFT JOIN spp_invoicelines_link sppil 
                                ON 
                                        (sppil.period_center = spp.center AND sppil.period_id = spp.id AND sppil.period_subid = spp.subid) 
                        LEFT JOIN invoice_lines_mt ilnospo
                                ON 
                                        (sppil.invoiceline_center = ilnospo.center AND sppil.invoiceline_id = ilnospo.id AND sppil.invoiceline_subid = ilnospo.subid)
                        LEFT JOIN invoices invoice
                                ON 
                                        (ilnospo.center = invoice.center AND ilnospo.id = invoice.id) 
                        INNER JOIN products prd 
                                ON 
                                        (ilnospo.productcenter = prd.center AND ilnospo.productid = prd.id) 
                        LEFT JOIN product_account_configurations pacc 
                                ON 
                                        prd.product_account_config_id = pacc.id 
                        JOIN invoice_lines_mt ilspon 
                                ON 
                                        (invoice.sponsor_invoice_center = ilspon.center AND invoice.sponsor_invoice_id = ilspon.id AND ilnospo.sponsor_invoice_subid = ilspon.subid) 
                        LEFT JOIN invoices invComp
                                ON
                                        ilspon.center = invComp.center AND ilspon.id = invComp.id
                        JOIN goodlife.credit_note_lines_mt cn
                                ON
                                        (cn.invoiceline_center = ilspon.center AND cn.invoiceline_id = ilspon.id)
                        LEFT JOIN ar_trans artcn 
                                ON 
                                        artcn.ref_center = cn.center AND artcn.ref_id = cn.id AND artcn.ref_type = 'CREDIT_NOTE'
                        LEFT JOIN persons comp
                                ON
                                        invComp.payer_center = comp.center AND invComp.payer_id = comp.id
                        LEFT JOIN centers cenSub
                                ON
                                        sub.center = cenSub.id
                        LEFT JOIN zipcodes zc
                                ON 
                                        cenSub.zipcode = zc.zipcode AND zc.country = 'CA'
                        LEFT JOIN person_ext_attrs compType
                                ON
                                        compType.personcenter = comp.center AND compType.personid = comp.id AND compType.name = 'COMPANYTYPE'
                        WHERE 
                                (
                                        --spp.spp_state = 1 AND 
                                        sub.start_date > to_date(:cut_date,'YYYY-MM-DD')
                                        AND artcn.trans_time < datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),artcn.center)
                                        AND ilspon.total_amount > 0
                                ) 
                        ORDER BY
                               invComp.payer_center,
                               invComp.payer_id
                ) taux
                LEFT JOIN art_match arm
                        ON 
                                arm.art_paying_center = taux.ARTCenter
                                AND arm.art_paying_id = taux.ARTId
                                AND arm.art_paying_subid = taux.ARTSubId
                                AND arm.entry_time <  datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center)
                                AND (arm.cancelled_time IS NULL OR arm.cancelled_time >= datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center))
                GROUP BY
                        taux.CompanyId,
                        taux.CompanyFullName,
                        taux.BookDate,
                        taux.SubscriptionStart,
                        taux.SubscriptionEnd,
                        taux.TransactionText,
                        taux.TotalSponsor,                        
                        taux.CreditNoteAmount,
                        taux.Province,
                        taux.DeferAccount,
                        taux.CompanyType,
                        taux.ARTransAmount,
                        taux.ilsponCenter,
                        taux.ilsponId,
                        taux.ilsponSubid
        ) taux2
        LEFT JOIN goodlife.credit_note_line_vat_at_link cnvatspon 
                ON 
                        (cnvatspon.credit_note_line_center = taux2.ilsponCenter AND cnvatspon.credit_note_line_id = taux2.ilsponId AND cnvatspon.credit_note_line_subid = taux2.ilsponSubId)
        LEFT JOIN account_trans acttranCN 
                ON 
                        (cnvatspon.account_trans_center = acttranCN.CENTER AND cnvatspon.account_trans_id = acttranCN.ID AND cnvatspon.account_trans_subid = acttranCN.SUBID)         
        GROUP BY 
                taux2.CompanyId,
                taux2.CompanyFullName,
                taux2.BookDate,
                taux2.SubscriptionStart,
                taux2.SubscriptionEnd,
                taux2.TransactionText,
                taux2.TotalSponsor,
                taux2.CreditNoteAmount,
                taux2.Province,
                taux2.DeferAccount,
                taux2.CompanyType  
                ,taux2.ARTransAmount
                ,taux2.UnsettleAmount   
) t0

