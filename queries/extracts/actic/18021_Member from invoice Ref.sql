SELECT
    p.CENTER AS CENTER,
    p.ID AS ID,
    p.CENTER || 'p' || p.ID AS memberId,
    FIRSTNAME,
    LASTNAME
FROM
    PERSONS p
JOIN 
    ACCOUNT_RECEIVABLES ar on 
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
	p.CENTER in (:Scope)
    AND (EXISTS(
        select * from PAYMENT_AGREEMENTS pa where pa.center = ar.center and pa.id = ar.id and pa.BANK_ACCNO = :Text
    )
    OR EXISTS(
        select * from PAYMENT_REQUEST_SPECIFICATIONS prs where prs.center = ar.center and prs.id = ar.id and prs.REF = :Text
    ))