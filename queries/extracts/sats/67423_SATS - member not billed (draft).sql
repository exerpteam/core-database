WITH target_agreement AS
(
   SELECT DISTINCT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            ar.BALANCE
        FROM
                PAYMENT_REQUESTS pr
        JOIN
                PAYMENT_AGREEMENTS pa
                ON pa.CENTER = pr.CENTER
                AND pa.ID = pr.ID
                AND pa.SUBID = pr.AGR_SUBID
                AND pa.STATE IN (6,10) -- ended by clearing house / creditor
        JOIN
                SATS.PAYMENT_ACCOUNTS pac
                ON pac.CENTER = pa.CENTER
                AND pac.ID = pa.ID
        JOIN
                SATS.ACCOUNT_RECEIVABLES ar        
                ON ar.CENTER = pac.CENTER
                AND ar.ID = pa.ID
        WHERE
                ar.CUSTOMERCENTER IN (:centers)
                AND pr.STATE = 12
                AND pr.ENTRY_TIME > :from_datetime
                AND pr.ENTRY_TIME < datetolong(getcentertime(pr.center)) - 30*24*60*60*1000
                AND ar.BALANCE < 0
)
select 
  p.CENTER || 'p' || p.id AS "Person ID",
  DECODE ( PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9, 'CHILD', 10, 'EXTERNAL_STAFF','UNKNOWN') AS "Person Type",
  DECODE (STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERRED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "Person Status",
  ta.balance AS "Payment Account Balance",
  CASE WHEN debtact.BALANCE IS NULL THEN 'No Debt Account' ELSE TO_CHAR(debtact.BALANCE) END AS "External Debt Account"
from 
  target_agreement ta
join 
  persons p
on
  p.center = ta.customercenter
  AND p.id = ta.customerid
left join
  ACCOUNT_RECEIVABLES debtact
ON 
  debtact.CUSTOMERCENTER = p.CENTER
  AND debtact.CUSTOMERID = p.ID
  AND debtact.AR_TYPE = 5
WHERE   
-- To exlude members with debt account created
  debtact.CENTER IS NULL 