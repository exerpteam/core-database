SELECT
    je.name,
    je.person_center AS center,
    je.person_center || 'p' || je.person_id AS person_key,
    convert_from(big_text, 'UTF8') AS "Ref",
    longtodatec(art.trans_time, je.person_center) AS book_date,
    art.amount AS total,
    artm.amount,
    artl.text AS "Text"
FROM journalentries je
JOIN account_receivables ar
    ON ar.customercenter = je.person_center
   AND ar.customerid     = je.person_id
   AND ar.ar_type        = 4  -- Payment account
JOIN ar_trans art
    ON ar.center = art.center
   AND ar.id     = art.id
   AND art.text  = convert_from(big_text, 'UTF8')
JOIN art_match artm
    ON art.center = artm.art_paying_center
   AND art.id     = artm.art_paying_id
   AND art.subid  = artm.art_paying_subid
JOIN ar_trans artl
    ON artl.center = artm.art_paid_center
   AND artl.id     = artm.art_paid_id
   AND artl.subid  = artm.art_paid_subid
JOIN invoices inv
    ON inv.center = art.ref_center
   AND inv.id     = artl.ref_id
WHERE je.creation_time BETWEEN $$fromdate$$ AND $$todate$$
  AND art.trans_time BETWEEN ($$fromdate$$ - 10 * 24 * 60 * 60 * 1000)::bigint  AND ($$todate$$ + 10 * 24 * 60 * 60 * 1000)::bigint -- date filter for improved performance
  AND je.person_center IN ($$center$$)
  AND je.jetype = 3  -- Note
  AND je.name = 'Debt Payment'
ORDER BY convert_from(big_text, 'UTF8');
