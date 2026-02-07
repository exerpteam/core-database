 --Query 1
SELECT
    ar.customercenter ||'p'|| ar.customerid as memberid,
    pea_oldid.txtvalue as oldid,
    art.amount,
    art.text, 
    to_char(longtodate(art.entry_time), 'dd-mon-yyyy') AS entrydate,
    to_char(longtodate(art.trans_time), 'dd-mon-yyyy') AS bookdate,
    - (ccc.amount) as CurrentExerpDebt,
    art.entry_time as ORDERED,
    Q2.LegacyDebt

FROM
    account_receivables ar

JOIN ar_trans art ON
    art.center = ar.center
    AND art.id = ar.id
  LEFT JOIN PERSON_EXT_ATTRS pea_oldid ON
    pea_oldid.PERSONCENTER = ar.customercenter
    AND pea_oldid.PERSONID = ar.customerid
    AND pea_oldid.name = '_eClub_OldSystemPersonId'
  JOIN cashcollectioncases ccc ON 
    ar.customercenter = ccc.personcenter
    and ar.customerid = ccc.personid

RIGHT JOIN
-- two for filter only negative sums of legacy debt
(SELECT
    ar.customerid as customer_ID,
    SUM(art.amount) as LegacyDebt

  FROM
    account_receivables ar

  JOIN ar_trans art ON
    art.center = ar.center
    AND art.id = ar.id
  JOIN cashcollectioncases ccc ON 
    ar.customercenter = ccc.personcenter
    and ar.customerid = ccc.personid

  WHERE
    ar.customercenter = :scope
    AND ar.ar_type = 4
    AND art.entry_time < :cutdate --This number does not work for some reasons
    AND ccc.amount > 0
 GROUP BY 
        customer_ID) as Q2

ON Q2.customer_ID = ar.customerid

WHERE
    ar.customercenter = :scope --in the client
    AND LegacyDebt < 0
    AND ar.ar_type = 4
    AND art.entry_time < :cutdate --in the client
    AND ccc.amount > 0

ORDER BY 
    ar.customerid ASC,
    ORDERED ASC
;