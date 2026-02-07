SELECT
    longtodateTZ(art.entry_time, 'America/Toronto') TransactionTime,
    art.amount,
    art.text,
    art.ref_type,
    art.ref_center ||'inv'|| art.ref_id    invoiceID ,
    art.collect_agreement_subid         AS member_agreement_subid
FROM
    ar_trans art
WHERE
    art.center = 990
AND art.collect_agreement_center != 990
AND art.amount != 0
AND art.ref_type = 'CREDIT_NOTE'
AND art.collected = 0
AND (
        art.text LIKE '%(KAFP)%'
    OR  art.text LIKE '%(CERT)%')

    