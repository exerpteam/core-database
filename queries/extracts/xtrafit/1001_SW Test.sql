(( --Query 1
  SELECT
    ar.customercenter ||'p'|| ar.customerid as memberid,
    pea_oldid.txtvalue as oldid,
    art.amount,
    art.text, 
    to_char(longtodate(art.entry_time), 'dd-mon-yyyy') AS entrydate,
    to_char(longtodate(art.trans_time), 'dd-mon-yyyy') AS bookdate,
    ccc.amount as totaldebt,
    art.entry_time as ORDERED,
    0 as total_leg

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

  WHERE
    ar.customercenter = 230
    AND ar.ar_type = 4
    AND art.entry_time <= 1572566400000 --This number does not work for some reasons
    AND ccc.amount > 0
    --AND ar.customerid =837
    --AND ar.customercenter= 230
  --ORDER BY 
    --customerid ASC,
    --art.entry_time ASC
)
UNION
(-- Second part of the query, after the 27 of november 
  SELECT
    ar.customercenter ||'p'|| ar.customerid as memberid,
    pea_oldid.txtvalue as oldid,
    art.amount,
    art.text, 
    to_char(longtodate(art.entry_time), 'dd-mon-yyyy') AS entrydate,
    to_char(longtodate(art.trans_time), 'dd-mon-yyyy') AS bookdate,
    ccc.amount as totaldebt,
    art.entry_time as ORDERED,
    0 as total_leg

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

  WHERE
    ar.ar_type = 5
    AND art.amount > 0
    AND art.entry_time > 1572566400000
    --AND ar.customerid =837
    --AND ar.customercenter= 230
)
UNION
(
-- Query for individual member sums
SELECT
    ar.customercenter ||'p'|| ar.customerid as memberid,
    pea_oldid.txtvalue as oldid,
    0 AS amount,
    'N/A' AS text, 
    'N/A' AS entrydate,
    'N/A' AS bookdate,
    0 as totaldebt,
    0 as ORDERED,
    SUM(art.amount) as total_leg

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

  WHERE
    ar.customercenter = 230
    AND ar.ar_type = 4
    AND art.entry_time <= 1572566400000 --This number does not work for some reasons
    AND ccc.amount > 0
 GROUP BY 
        ar.customerid, ar.customercenter, pea_oldid.txtvalue
))
ORDER BY 
    memberid ASC,
    ORDERED ASC
;




