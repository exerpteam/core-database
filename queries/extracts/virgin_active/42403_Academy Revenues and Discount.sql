-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6037
 SELECT DISTINCT
	p.fullname AS "Full Name",
    s.center || 'ss' ||s.id AS "Subscription ID",
    p.center || 'p' || p.id AS "Person ID",
    CASE  p.STATUS  
		WHEN 0 THEN 'LEAD'  
		WHEN 1 THEN 'ACTIVE'  
		WHEN 2 THEN 'INACTIVE'  
		WHEN 3 THEN 'TEMPORARYINACTIVE'  
		WHEN 4 THEN 'TRANSFERED'  
		WHEN 5 THEN 'DUPLICATE'  
		WHEN 6 THEN 'PROSPECT'  
		WHEN 7 THEN 'DELETED' 
		WHEN 8 THEN  'ANONYMIZED'  
		WHEN 9 THEN  'CONTACT'  
		ELSE 'UNKNOWN' 
	END AS "Person Status",
    CASE  s.STATE  
		WHEN 2 THEN 'ACTIVE'  
		WHEN 3 THEN 'ENDED'  
		WHEN 4 THEN 'FROZEN'  
		WHEN 7 THEN 'WINDOW'  
		WHEN 8 THEN 'CREATED' 
		ELSE 'UNKNOWN' 
	END AS "Subscription Status",
    CASE  s.SUB_STATE  
		WHEN 1 THEN 'NONE'  
		WHEN 2 THEN 'AWAITING_ACTIVATION'  
		WHEN 3 THEN 'UPGRADED'  
		WHEN 4 THEN 'DOWNGRADED'  
		WHEN 5 THEN 'EXTENDED'  
		WHEN 6 THEN  'TRANSFERRED' 
		WHEN 7 THEN 'REGRETTED' 
		WHEN 8 THEN 'CANCELLED' 
		WHEN 9 THEN 'BLOCKED' 
		WHEN 10 THEN 'CHANGED' 
		ELSE 'UNKNOWN' 
	END AS "Subscription Sub State",
    p.ssn AS "SSN",
    percomment.txtvalue AS "VAT Number",
    inv.center||'inv'||inv.id AS "Invoice Number",
    cinv.invoice_reference AS "Invoice Reference",
    c.shortname AS "Subscription Home Center",
    email.txtvalue AS "Email",
    mobile.txtvalue AS "Mobile Phone",
    subprod.name AS "Subscription Name",
    s.subscription_price AS "Subscription Price",
    TO_CHAR(s.start_date, 'DD-MM-YYYY') AS "Start Date",
    TO_CHAR(s.end_date, 'DD-MM-YYYY') AS "Stop Date",
    TO_CHAR(s.binding_end_date, 'DD-MM-YYYY') AS "Binding Date",
    TO_CHAR(longtodatec(inv.trans_time, inv.center), 'DD-MM-YYYY') AS "Transaction Date",
    invc.shortname AS "Transaction Center",
    ccprod.name AS "Product Name",
    clipcard.clips_initial AS "Quantity",
    ccprod.price AS "Fixed Current Price Incl VAT",
    invl.total_amount AS "Amount Paid Incl VAT",
    ccprod.price - invl.total_amount AS "Discount Amount Incl VAT",
    bc.name AS "Bundle Campaign Name",
	pu.campaign_code_id AS "Campaign Code Id",
    CASE crt.CRTTYPE 
		WHEN 1 THEN 'CASH' 
		WHEN 2 THEN 'CHANGE' 
		WHEN 3 THEN 'RETURN ON CREDIT' 
		WHEN 4 THEN 'PAYOUT CASH' 
		WHEN 5 THEN 'PAID BY CASH AR ACCOUNT' 
		WHEN 6 THEN 'DEBIT CARD' 
		WHEN 7 THEN 'CREDIT CARD' 
		WHEN 8 THEN 'DEBIT OR CREDIT CARD' 
		WHEN 9 THEN 'GIFT CARD' 
		WHEN 10 THEN 'CASH ADJUSTMENT' 
		WHEN 11 THEN 'CASH TRANSFER' 
		WHEN 12 THEN 'PAYMENT AR' 
		WHEN 13 THEN 'CONFIG PAYMENT METHOD' 
		WHEN 14 THEN 'CASH REGISTER PAYOUT' 
		WHEN 15 THEN 'CREDIT CARD ADJUSTMENT' 
		WHEN 16 THEN 'CLOSING CASH ADJUST' 
		WHEN 17 THEN 'VOUCHER' 
		WHEN 18 THEN 'PAYOUT CREDIT CARD' 
		WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS' 
		WHEN 20 THEN 'CLOSING CREDIT CARD ADJ' 
		WHEN 21 THEN 'TRANSFER BACK CASH COINS' 
		ELSE 'UNKNOWN' 
	END AS "Payment Method"
 FROM
     persons p
 JOIN
     clipcards clipcard
 ON
     p.center = clipcard.owner_center
     AND p.id = clipcard.owner_id
 JOIN
     products ccprod
 ON
     ccprod.center = clipcard.center
     AND ccprod.id = clipcard.id
 JOIN
     INVOICELINES invl
 ON
     invl.center = clipcard.invoiceline_center
     AND invl.id = clipcard.invoiceline_id
     AND invl.subid = clipcard.invoiceline_subid
 JOIN
     invoices inv
 ON
     inv.center = invl.center
     AND inv.id = invl.id
 JOIN
     centers invc
 ON
     invc.id = inv.center
 JOIN
     CASHREGISTERTRANSACTIONS CRT
 ON
     CRT.CENTER = INV.CASHREGISTER_CENTER
     AND CRT.ID = INV.CASHREGISTER_ID
     AND CRT.PAYSESSIONID = INV.PAYSESSIONID
 LEFT JOIN
     subscriptions s
 ON
     s.owner_center = p.center
     AND s.owner_id = p.id
     AND s.state = 2
 LEFT JOIN
     centers c
 ON
     c.id = s.center
 LEFT JOIN
     products subprod
 ON
     subprod.center = s.subscriptiontype_center
     AND subprod.id = s.subscriptiontype_id
 LEFT JOIN
     customer_invoice cinv
 ON
     cinv.reference_center = inv.center
     AND cinv.reference_id = inv.id
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     p.center=mobile.PERSONCENTER
     AND p.id=mobile.PERSONID
     AND mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS percomment
 ON
     p.center=percomment.PERSONCENTER
     AND p.id=percomment.PERSONID
     AND percomment.name='_eClub_Comment'
 LEFT JOIN
     PRIVILEGE_USAGES pu
 ON
     pu.TARGET_CENTER = invl.center
     AND pu.TARGET_ID =invl.id
     AND pu.TARGET_SUBID = invl.subid
     AND pu.TARGET_SERVICE = 'InvoiceLine'
 LEFT JOIN
     bundle_campaign bc
 ON
     bc.id = pu.campaign_code_id
 WHERE
     p.center IN ($$Scope$$)
     AND inv.trans_time BETWEEN $$From_date$$ AND $$To_date$$
     AND EXISTS
     (
         SELECT
             1
         FROM
             PRODUCT_AND_PRODUCT_GROUP_LINK prlink,
             product_group pg
         WHERE
             prlink.PRODUCT_CENTER = ccprod.center
             AND prlink.product_id = ccprod.id
             AND prlink.product_group_id = pg.id
             AND pg.name IN ('Academy'))
