-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.external_id AS "Member ID",
    CASE je.JETYPE
        WHEN 1
        THEN 'Contract'
        WHEN 2
        THEN 'Document'
        WHEN 3
        THEN 'Note'
        WHEN 11
        THEN 'Payment agreement'
        WHEN 12
        THEN 'Cashout'
        WHEN 13
        THEN 'Freeze creation'
        WHEN 14
        THEN 'Freeze cancellation'
        WHEN 15
        THEN 'Freeze change'
        WHEN 16
        THEN 'Other payer start'
        WHEN 17
        THEN 'Other payer stop'
        WHEN 18
        THEN 'EFT subscription termination'
        WHEN 19
        THEN 'EFT cancel subscription termination'
        WHEN 20
        THEN 'Payment note'
        WHEN 21
        THEN 'Account payment note'
        WHEN 22
        THEN 'Saved free days use'
        WHEN 23
        THEN 'Free period assignment'
        WHEN 24
        THEN 'Free period cancellation'
        WHEN 25
        THEN 'Cash account credit'
        WHEN 26
        THEN 'Addon termination'
        WHEN 27
        THEN 'Addon termination cancellation'
        WHEN 28
        THEN 'Child relation contract'
        WHEN 29
        THEN 'Doctor note'
        WHEN 30
        THEN 'Addon contract'
        WHEN 31
        THEN 'Health certificate'
        WHEN 32
        THEN 'Credit card agreement contract'
        WHEN 33
        THEN 'Clipcard buyout'
        WHEN 34
        THEN 'Clipcard contract'
        WHEN 35
        THEN 'Reassign subscription contract'
        WHEN 36
        THEN 'Aggregated subscription contract'
        WHEN 37
        THEN 'Free period change'
        ELSE 'Undefined'
    END                                          AS "Document type",
    longtodatec(je.creation_time,p.center)::DATE AS "Docuemnt Creation Date",
    COUNT(js.id)                                 AS "Number of missing signatures"
FROM
    evolutionwellness.journalentries je
LEFT JOIN
    evolutionwellness.journalentry_signatures js
ON
    js.journalentry_id = je.id
JOIN
    evolutionwellness.persons p
ON
    p.center = je.person_center
AND p.id = je.person_id
WHERE
    js.signature_center IS NULL
AND je.signable
AND p.center = :scope
GROUP BY
    p.external_id,
    je.jetype,
    je.creation_time,
    p.center