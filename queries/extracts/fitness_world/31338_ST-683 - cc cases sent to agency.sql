-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.ID center,
    c.NAME center_name,
    paid.CENTER || 'p' || paid.ID member_id,
    payer.CENTER || 'p' || payer.ID paid_by
FROM
    CASHCOLLECTIONCASES cc
join PERSONS payer on payer.CENTER = cc.PERSONCENTER and payer.ID = cc.PERSONID    
join CENTERS c on c.ID = payer.CENTER
join RELATIVES rel on rel.CENTER = cc.PERSONCENTER and rel.ID = cc.PERSONID and rel.RTYPE = 12 and rel.STATUS = 1
join PERSONS paid on paid.CENTER = rel.RELATIVECENTER and paid.ID = rel.RELATIVEID
WHERE
    cc.MISSINGPAYMENT = 1
    AND cc.CLOSED = 0
    AND cc.CASHCOLLECTIONSERVICE IS NOT NULL
    and cc.PERSONCENTER in ($$scope$$)
union 
SELECT
    c.ID center,
    c.NAME center_name,
        payer.CENTER || 'p' || payer.ID  member_id,
null paid_by
FROM
    CASHCOLLECTIONCASES cc
join PERSONS payer on payer.CENTER = cc.PERSONCENTER and payer.ID = cc.PERSONID    
join CENTERS c on c.ID = payer.CENTER
WHERE
    cc.MISSINGPAYMENT = 1
    AND cc.CLOSED = 0
    AND cc.CASHCOLLECTIONSERVICE IS NOT NULL
    and cc.PERSONCENTER in ($$scope$$)