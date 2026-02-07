
SELECT
    p.CENTER || 'p' || p.ID as MEMBERID,
    p.ssn,
    p.firstname,
    p.lastname,
CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'other'
    END AS status,
    
 prod.NAME productName,
    Payment_agreements.bank_regno,
    Payment_agreements.bank_accNo,
    Payment_agreements.ref,
ch.name,

     CASE Payment_Agreements.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'

    END      AS AgrState,
	p.prefer_invoice_by_email AS "InvoiceByEmail",
	email.txtvalue AS "email",
	Payment_Agreements.active as "Defualt"

FROM persons p


LEFT JOIN Account_receivables
ON
    p.Center = Account_receivables.CustomerCenter
AND p.Id = Account_receivables.CustomerId
AND AR_Type=4
LEFT JOIN Payment_Accounts
ON
    Account_Receivables.Center = Payment_Accounts.Center
AND Account_Receivables.Id = Payment_Accounts.Id
LEFT JOIN Payment_Agreements
ON
    Payment_agreements.Center = Payment_accounts.Active_Agr_Center
AND Payment_agreements.Id = Payment_accounts.Active_Agr_Id
AND Payment_agreements.SubId = Payment_accounts.Active_Agr_SubId

left join subscriptions s
on
s.owner_id = p.id and s.owner_center = p.center
and s.state in (2,4)

join SUBSCRIPTIONTYPES subType 
    on subType.CENTER = s.SUBSCRIPTIONTYPE_CENTER and subType.ID = s.SUBSCRIPTIONTYPE_ID
join PRODUCTS prod 
    on subType.CENTER = prod.CENTER and subType.ID = prod.ID

left join clearinghouses ch
on ch.id = payment_agreements.clearinghouse

LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
WHERE
    -- not ended
    p.status IN (1,3)
AND
    -- eft all countries or other payer
    (
        ClearingHouse > 0
     OR ClearingHouse IS NULL
    )
AND p.center in (:scope)
/* AND Payment_agreements.state <> 4 */
