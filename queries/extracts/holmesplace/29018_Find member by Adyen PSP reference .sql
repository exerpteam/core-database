SELECT
		p.center || 'p' || p.id AS PersonId,
		p.external_id,
        art.amount,
		art.info,
		art.text,
		longtodatec(art.entry_time, art.center) AS EntryTime,
		art.status
FROM hp.account_receivables ar 
JOIN hp.ar_trans art ON ar.CENTER = art.CENTER AND ar.ID = art.ID
JOIN persons p ON ar.customercenter = p.center AND ar.customerid = p.id
WHERE
        art.info IN (:Info)