-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-3797
SELECT
	DISTINCT
    p.center || 'p' || p.id                                                                                                        AS "Member Id",
    p.fullname                                                                                                                     AS "Member Name",
    p.center                                                                                                                       AS "Member Home Club Id",
    c.name                                                                                                                         AS "Member Home Club Name",
    DECODE(p.address1 || ' ' || p.address2 || ' ' || p.address3, '  ', NULL, p.address1 || ' ' || p.address2 || ' ' || p.address3) AS "Member Address",
    p.zipcode                                                                                                                      AS "Member Address Zipcode",
	DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9, 'CHILD', 10, 'EXTERNAL_STAFF','UNKNOWN') AS "Member Type",
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "Member Status",
	zip.COUNTRY AS "Country Zipcode"
FROM
    persons p
JOIN
    centers c
ON
    c.id = p.center
JOIN
   account_receivables ar
ON
   ar.customercenter = p.center
   AND ar.customerid = p.id
   AND ar.ar_type = 4  	
JOIN
  payment_agreements pag
ON
  pag.center = ar.center
  AND pag.id = ar.id       
LEFT JOIN
    zipcodes zip
ON
    zip.zipcode = p.zipcode
    AND zip.city = p.city   	
WHERE
    c.country = 'DK'
    AND p.center IN ($$Scope$$)
    AND p.status NOT IN (4,5,7,8)
    AND ((
            p.address1 IS NULL
            AND p.address2 IS NULL
            AND p.address3 IS NULL)
        OR p.zipcode IS NULL
        OR zip.country != 'DK')