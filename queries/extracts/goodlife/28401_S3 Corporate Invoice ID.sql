-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    longtodateC(pr.last_modified,990)AS lastmod,
    pr.s3key_formatted_doc, prs.ref
FROM
    goodlife.account_receivables ar
JOIN
    goodlife.payment_request_specifications prs
ON
    prs.center = ar.center
AND prs.id = ar.id
JOIN
    goodlife.payment_requests pr
ON
    pr.inv_coll_center = prs.center
AND pr.inv_coll_id = prs.id
AND pr.inv_coll_subid = prs.subid
WHERE
    prs.ref IN ($$ref_id$$)
