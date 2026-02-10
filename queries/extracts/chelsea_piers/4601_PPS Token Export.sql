-- The extract is extracted from Exerp on 2026-02-08
-- Export CP will use to add zip codes to PPS tokens.  EC-4537
SELECT
    p.center ||'p'|| p.id                             AS member,
    p.fullname,
	p.address1,
	p.address2,
	p.city,
    p.zipcode,
     CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
     --pa.subid as agreement_subid,
    CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended = bank' WHEN 6 THEN 'Ended = clearing house' WHEN 7 THEN 'Ended = debtor' WHEN 8 THEN 'Cancelled = not sent' WHEN 9 THEN 'Cancelled = sent' WHEN 10 THEN 'Ended = creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS AGREEMENT_STATE,
   
    creditor_id,
    pa.clearinghouse_ref as token,
    pa.bank_accno,
    pa.active
FROM
    PERSONs p
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    payment_agreements pa
ON
    ar.center = pa.center
AND ar.id = pa.id
WHERE
pa.clearinghouse_ref IS NOT NULL-- AND pa.individual_deduction_day is null
AND pa.state not in (3, 2) --Failed, Sent
order by member