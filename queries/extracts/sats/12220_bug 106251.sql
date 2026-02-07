SELECT
    c.center as personCenter,
    c.id as personId,
    cr.ref,
    cr.REQ_DATE,
    cr.REQ_AMOUNT
FROM
    cashcollection_requests cr
JOIN CASHCOLLECTIONCASES c
ON
    c.center = cr.center
AND c.id = cr.id
JOIN persons p
ON
    c.PERSONCENTER = p.CENTER
AND c.PERSONID = p.ID
WHERE
    p.LASTNAME IS NULL
AND cr.center BETWEEN 100 AND 199
AND cr.REQ_DELIVERY IS NULL
AND cr.STATE = 0

