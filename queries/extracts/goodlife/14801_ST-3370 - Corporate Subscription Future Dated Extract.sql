SELECT
        t0.CompanyId                                                    AS "Company Person ID",
        t0.CompanyFullName                                              AS "Company Name",
        to_char(t0.BookDate,'YYYY-MM-DD')                               AS "Book Date",
        to_char(t0.BookDate,'YYYY-MM-DD HH24:MI:SS')                    AS "Book Time",
        t0.SubscriptionStart                                            AS "Subscription Start Date",
        t0.SubscriptionEnd                                              AS "Subscription End Date",  
        t0.TransactionText                                              AS "Transaction Description",
        t0.TotalSponsor-t0.VATSponsor                                   AS "Revenue Amount",
        t0.VATSponsor                                                   AS "Tax Amount",
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
                taux.CompanyId,
                taux.CompanyFullName,
                taux.BookDate,
                taux.SubscriptionStart,
                taux.SubscriptionEnd,
                taux.TransactionText,
                taux.TotalSponsor,
                COALESCE(SUM(acttran.amount),0) AS VATSponsor,
                taux.Province,
                taux.DeferAccount,
                taux.CompanyType
                ,taux.ARTransAmount
                ,taux.UnsettleAmount
            
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
                        ,art.amount + sum(COALESCE(arm.amount,0)) AS UnsettleAmount
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
                LEFT JOIN art_match arm
                        ON 
                                arm.art_paid_center = art.CENTER
                                AND arm.art_paid_id = art.ID
                                AND arm.art_paid_subid = art.SUBID
                                AND arm.entry_time <  datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center)
                                AND (arm.cancelled_time IS NULL OR arm.cancelled_time >= datetolongC(to_char(to_date(:cut_date,'YYYY-MM-DD') + 1,'YYYY-MM-DD HH24:MI:SS'),arm.art_paid_center))
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
                                spp.spp_state = 1
                                AND sub.start_date > :cut_date
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
                ORDER BY
                       invComp.payer_center,
                       invComp.payer_id
        ) taux
        LEFT JOIN invoicelines_vat_at_link ilvatspon 
                ON 
                        (ilvatspon.invoiceline_center = taux.ilsponCenter AND ilvatspon.invoiceline_id = taux.ilsponId AND ilvatspon.invoiceline_subid = taux.ilsponSubId)
        LEFT JOIN account_trans acttran 
                ON 
                        (ilvatspon.account_trans_center = acttran.CENTER AND ilvatspon.account_trans_id = acttran.ID AND ilvatspon.account_trans_subid = acttran.SUBID) 
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
                ,taux.UnsettleAmount   
) t0
