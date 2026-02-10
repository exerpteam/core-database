-- The extract is extracted from Exerp on 2026-02-08
--  
-- PARAMS
-- ------------
-- ClubId : integer
-- PersonId : integer
-- StartDate : date
-- EndDate : date

WITH 
    invoice_totals AS -- Grouping invoice totals to accomodate partial payment calculations towards an invoice
        (
            SELECT 
                invoice_line.center as center, 
                invoice_line.id as id, 
                SUM(invoice_line.total_amount) AS amount
            
            FROM invoice_lines_mt invoice_line

            JOIN ar_trans
                ON ar_trans.ref_type = 'INVOICE'
                AND ar_trans.ref_center = invoice_line.center
                AND ar_trans.ref_id = invoice_line.id

            JOIN account_receivables account
                ON account.center = ar_trans.center
                AND account.id = ar_trans.id

            JOIN persons person
                ON person.center = account.customercenter
                AND person.id = account.customerid

            WHERE person.center = :ClubId AND person.id = :PersonId

            GROUP BY 
                invoice_line.center, 
                invoice_line.id
        ),
    vat_totals AS -- Grouping tax rates to prevent duplicate lines on the receipt (e.g. GST and PST)
        (
            SELECT 
                vat_details.invoiceline_center AS center,
                vat_details.invoiceline_id AS id,
                vat_details.invoiceline_subid AS subid,
                SUM(vat_details.rate) AS combined_taxes
            
            FROM invoice_lines_mt invoice_line

            JOIN ar_trans
                ON ar_trans.ref_type = 'INVOICE'
                AND ar_trans.ref_center = invoice_line.center
                AND ar_trans.ref_id = invoice_line.id

            JOIN account_receivables account
                ON account.center = ar_trans.center
                AND account.id = ar_trans.id

            JOIN persons person
                ON person.center = account.customercenter
                AND person.id = account.customerid

            LEFT JOIN invoicelines_vat_at_link vat_details
                ON vat_details.invoiceline_center = invoice_line.center
                AND vat_details.invoiceline_id = invoice_line.id
                AND vat_details.invoiceline_subid = invoice_line.subid

            WHERE person.center = :ClubId AND person.id = :PersonId

            GROUP BY 
                vat_details.invoiceline_center,
                vat_details.invoiceline_id,
                vat_details.invoiceline_subid
        )

SELECT
    CASE
        WHEN 
            TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD') > TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD')
        THEN 
            TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD')
        ELSE
            TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD')
    END AS "entry_on",
    paying_art.center || '-' || paying_art.id || '-' || paying_art.subid AS "paying_art_id", 
    paid_art.center || '-' || paid_art.id || '-' || paid_art.subid AS "paid_art_id",
    inv_line.center || '-' || inv_line.id || '-' || inv_line.subid AS "invoice_line_id",
    --   paying_art.text AS paying_text,
    --   paid_art.text AS paid_art_text,
    CASE
        WHEN
            spp.from_date IS NOT NULL AND spp.to_date IS NOT NULL AND product.name <> 'PAP CREDIT'
        THEN
            CONCAT(product.name,': ', spp.from_date, ' - ', spp.to_date)
        WHEN
            spp.from_date IS NOT NULL AND spp.to_date IS NOT NULL AND product.name = 'PAP CREDIT'
        THEN
            CONCAT('Account Adjustment: ', spp.from_date, ' - ', spp.to_date)
        ELSE
			CASE
				WHEN
		            product.name <> 'PAP Credit'
				THEN
					product.name
				ELSE
					'Account Adjustment'
			END
    END AS "product_name",
    --product.name AS product_name,
    

    product.globalid as product_globalid,
    recipient.fullname AS recipient_name,
    recipient.external_id AS recipient_external_id,
    CONCAT(recipient.center, 'p', recipient.id) AS recipient_clubpersonid,
    ROUND((settlement.amount * (inv_line.total_amount / invoice_total.amount)) / (1 + COALESCE(vat_total.combined_taxes,0)),2) AS pretax_amount,
    ROUND((settlement.amount * (inv_line.total_amount / invoice_total.amount)) - ((settlement.amount * (inv_line.total_amount / invoice_total.amount)) / (1+COALESCE(vat_total.combined_taxes,0))),2) as tax_amount,
    ROUND((settlement.amount * (inv_line.total_amount / invoice_total.amount)) / (1 + COALESCE(vat_total.combined_taxes,0)),2) + ROUND((settlement.amount * (inv_line.total_amount / invoice_total.amount)) - ((settlement.amount * (inv_line.total_amount / invoice_total.amount)) / (1+COALESCE(vat_total.combined_taxes,0))),2) as total_amount
    -- vat_total.combined_taxes AS tax_rate
    --   'XXX sppInvLink', sppInvLink.*,
    --   'XXX spp', spp.*

FROM art_match settlement

JOIN ar_trans paying_art
    ON  paying_art.center = settlement.art_paying_center
    AND paying_art.id = settlement.art_paying_id
    AND paying_art.subid = settlement.art_paying_subid

JOIN ar_trans paid_art
    ON  paid_art.center = settlement.art_paid_center
    AND paid_art.id = settlement.art_paid_id
    AND paid_art.subid = settlement.art_paid_subid

JOIN account_receivables money_account
    ON money_account.center = paid_art.center
    AND money_account.id = paid_art.id

JOIN persons payor
    ON  payor.center = money_account.customercenter
    AND payor.id = money_account.customerid

JOIN invoice_lines_mt inv_line
    ON paid_art.ref_type = 'INVOICE'
    AND inv_line.center = paid_art.ref_center
    AND inv_line.id = paid_art.ref_id
    AND inv_line.net_amount <> 0 -- this solves some "duplicate" cases

LEFT JOIN spp_invoicelines_link sppInvLink
    ON inv_line.center = sppInvLink.invoiceline_center
    AND inv_line.id = sppInvLink.invoiceline_id
    AND inv_line.subid = sppInvLink.invoiceline_subid

LEFT JOIN subscriptionperiodparts spp
    ON spp.center = sppInvLink.period_center
    AND spp.id = sppInvLink.period_id
    AND spp.subid = sppInvLink.period_subid

LEFT JOIN credit_note_lines_mt cred_line -- link to the credit notes table to deal with Partial Credit Notes
    ON inv_line.center = cred_line.invoiceline_center
    AND inv_line.id = cred_line.invoiceline_id
    AND inv_line.subid = cred_line.invoiceline_subid

LEFT JOIN products product
    ON product.Center = inv_line.productcenter
    AND product.id = inv_line.productid

JOIN persons recipient
    ON recipient.center = inv_line.person_center
    AND recipient.id = inv_line.person_id

LEFT JOIN vat_totals vat_total
    ON vat_total.center = inv_line.center
    AND vat_total.id = inv_line.id
    AND vat_total.subid = inv_line.subid

LEFT JOIN invoice_totals invoice_total
    ON invoice_total.center = inv_line.center
    AND invoice_total.id = inv_line.id

LEFT JOIN -- Locating revoking transactions
    (
        SELECT 
            paying_art.center, 
            paying_art.id, 
            paying_art.subid

        FROM art_match settlement

        JOIN ar_trans paying_art
            ON  paying_art.center = settlement.art_paying_center
            AND paying_art.id = settlement.art_paying_id
            AND paying_art.subid = settlement.art_paying_subid

        JOIN ar_trans paid_art
            ON  paid_art.center = settlement.art_paid_center
            AND paid_art.id = settlement.art_paid_id
            AND paid_art.subid = settlement.art_paid_subid

        JOIN account_receivables ar
            ON ar.center = paying_art.center
            AND ar.id = paying_art.id

        JOIN persons person
            ON person.center = ar.customercenter
            AND person.id = ar.customerid

        WHERE person.center = :ClubId AND person.id = :PersonId
            AND paid_art.collected = 3

    ) revoke_match
    ON revoke_match.center = paying_art.center
    AND revoke_match.id = paying_art.id
    AND revoke_match.subid = paying_art.subid

LEFT JOIN -- Locating Free Credit Notes
    (

        SELECT 
            paying_art.center as paying_center_credit, 
            paying_art.id as paying_id_credit, 
            paying_art.subid paying_subid_credit, 
            paid_art.center as paid_center_credit, 
            paid_art.id as paid_id_credit, 
            paid_art.subid as paid_subid_credit

        FROM art_match settlement

        JOIN ar_trans paying_art
            ON  paying_art.center = settlement.art_paying_center
            AND paying_art.id = settlement.art_paying_id
            AND paying_art.subid = settlement.art_paying_subid

        JOIN ar_trans paid_art
            ON  paid_art.center = settlement.art_paid_center
            AND paid_art.id = settlement.art_paid_id
            AND paid_art.subid = settlement.art_paid_subid

        -- link to the credit notes table if paying_art.ref_type = 'CREDIT_NOTE'
        LEFT JOIN credit_note_lines_mt cred_line
            ON paying_art.ref_type = 'CREDIT_NOTE' 
            AND paying_art.ref_center = cred_line.center
            AND paying_art.ref_id = cred_line.id
            AND cred_line.invoiceline_id IS NULL -- free credit notes do not have a link to the cred_line table

        JOIN account_receivables money_account
            ON money_account.center = paid_art.center
            AND money_account.id = paid_art.id

        JOIN persons payor
            ON  payor.center = money_account.customercenter
            AND payor.id = money_account.customerid

        JOIN invoice_lines_mt inv_line
            ON paid_art.ref_type = 'INVOICE'
            AND inv_line.center = paid_art.ref_center
            AND inv_line.id = paid_art.ref_id
            AND inv_line.net_amount <> 0 -- this solves some "duplicate" cases

        WHERE payor.center = :ClubId AND payor.id = :PersonId
            AND cred_line.id IS NOT NULL
            AND
                (
                    (
                        CAST(TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD') AS DATE) BETWEEN :StartDate AND :EndDate
                        AND TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD') <= :EndDate
                    )
                    OR
                    (
                        CAST(TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD') AS DATE) BETWEEN :StartDate AND :EndDate
                        AND TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD') <= :EndDate
                    )
                )
    ) FreeCreditNote_match
    ON FreeCreditNote_match.paying_center_credit = paying_art.center
    AND FreeCreditNote_match.paying_id_credit = paying_art.id
    AND FreeCreditNote_match.paying_subid_credit = paying_art.subid
    AND FreeCreditNote_match.paid_center_credit = paid_art.center
    AND FreeCreditNote_match.paid_id_credit = paid_art.id
    AND FreeCreditNote_match.paid_subid_credit = paid_art.subid

LEFT JOIN -- Locating AR transaction reversals
    (
        SELECT
            paying_art.center || '-' || paying_art.id || '-' || paying_art.subid AS "paying_art_id"

        FROM art_match settlement

        JOIN ar_trans paying_art
            ON  paying_art.center = settlement.art_paying_center
            AND paying_art.id = settlement.art_paying_id
            AND paying_art.subid = settlement.art_paying_subid
         
        JOIN ar_trans paid_art
            ON  paid_art.center = settlement.art_paid_center
            AND paid_art.id = settlement.art_paid_id
            AND paid_art.subid = settlement.art_paid_subid

        JOIN account_receivables money_account
            ON money_account.center = paid_art.center
            AND money_account.id = paid_art.id
         
        JOIN persons payor
            ON  payor.center = money_account.customercenter
            AND payor.id = money_account.customerid

        WHERE payor.center = :ClubId AND payor.id = :PersonId 
            AND paid_art.match_info IS NOT NULL -- only show ar trans with match_info
            AND paying_art.center || 'ar' || paying_art.id || 'art' || paying_art.subid = paid_art.match_info -- specifies an AR transaction reversal
    ) ARTransaction_match
    ON ARTransaction_match.paying_art_id = (paying_art.center || '-' || paying_art.id || '-' || paying_art.subid)

WHERE payor.center = :ClubId AND payor.id = :PersonId 
    AND revoke_match.subid IS NULL -- Only include transactions that have not been revoked by the bank
    AND cred_line.invoiceline_id IS NULL -- Only include transactions that do not have a Partial Credit Note
    AND FreeCreditNote_match.paying_id_credit IS NULL -- Only include transactions that do not have a Free Credit Note
    AND ARTransaction_match.paying_art_id IS NULL -- Only include transactions that have not been reversed by an AR Transaction
    AND 
        (
            (
                CAST(TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD') AS DATE) BETWEEN :StartDate AND :EndDate
                AND TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD') <= :EndDate
            )
            OR
            (
                CAST(TO_CHAR(longtodatec(paid_art.trans_time, money_account.CENTER),'YYYY-MM-DD') AS DATE) BETWEEN :StartDate AND :EndDate
                AND TO_CHAR(longtodatec(paying_art.entry_time, money_account.CENTER),'YYYY-MM-DD') <= :EndDate
            )
        )