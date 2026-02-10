-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
ar.customercenter ||'p'|| ar.customerid as memberid,
pea_oldid.txtvalue as oldid,
art.amount,
art.text, 
to_char(longtodate(art.entry_time), 'dd-mon-yyyy') AS entrydate,
to_char(longtodate(art.trans_time), 'dd-mon-yyyy') AS bookdate


FROM
account_receivables ar
JOIN
ar_trans art
ON
art.center = ar.center
AND art.id = ar.id
LEFT JOIN
    PERSON_EXT_ATTRS pea_oldid
ON
    pea_oldid.PERSONCENTER = ar.customercenter
AND pea_oldid.PERSONID = ar.customerid
AND pea_oldid.name = '_eClub_OldSystemPersonId'
join
cashcollectioncases ccc
on 
ar.customercenter = ccc.personcenter
and
ar.customerid = ccc.personid

WHERE
ar.customercenter = :scope
AND ar.ar_type = 4
and art.trans_time > :cutdate

order by
ar.customercenter,
art.amount