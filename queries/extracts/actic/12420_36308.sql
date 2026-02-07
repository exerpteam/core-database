/**
* Creator: Exerp
* Note: Latest usage in 2013-12-02. Wait with further comments.
*/

sELECT
    p.CENTER || 'p' || p.ID as MEMBERID,
    p.ssn,
    p.firstname,
    p.lastname,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR',8,'GUEST','UNKNOWN') AS PERSONTYPE,
DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'other')as status,
    Payment_agreements.bank_regno,
    Payment_agreements.bank_accNo,
    Payment_agreements.ref,
ch.name,
    DECODE(Payment_Agreements.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended,
bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not
sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement
(deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice
payment)',14,'Agreement information incomplete') AS AgrState

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


left join clearinghouses ch
on ch.id = payment_agreements.clearinghouse
WHERE

    -- eft all countries or other payer
    (
        ClearingHouse > 0
     OR ClearingHouse IS NULL
    )
AND p.center in (:scope)
and length ( Payment_agreements.bank_regno)> 4
