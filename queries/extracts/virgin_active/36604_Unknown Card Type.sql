SELECT
    c.COUNTRY,
    c.ID,
    ct.AMOUNT,
    crs.name,
    longtodatec(ct.transtime,ct.center),
    ct.*,
    ctr.*
FROM
    creditcardtransactions ct
JOIN
    centers c
ON
    c.id = ct.center
LEFT JOIN
    VA.CASHREGISTERTRANSACTIONS ctr
ON
    ctr.GLTRANSCENTER = ct.GL_TRANS_CENTER
AND ctr.GLTRANSID = ct.GL_TRANS_ID
AND ctr.GLTRANSSUBID = ct.GL_TRANS_SUBID
LEFT JOIN
    VA.CASHREGISTERS crs
ON
    crs.id = ctr.ID
AND crs.center = ctr.center
WHERE 
    ct.transtime > 1527711906000
AND ct.type IS NULL
AND c.COUNTRY = 'GB'
AND ct.TRANSACTION_ID is null