-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id                                                           AS centerId,
            TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - INTERVAL '90 day' AS cutDate
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    eligible_agreements AS
    (
        SELECT
            acl.agreement_center,
            acl.agreement_id,
            acl.agreement_subid,
            acl.state,
            acl.log_date,
            rank () over( PARTITION BY acl.agreement_center, acl.agreement_id, acl.agreement_subid
            ORDER BY acl.log_date DESC) AS latest_change
        FROM
            params
        JOIN
            goodlife.agreement_change_log acl
        ON
            acl.agreement_center = params.centerId
        AND acl.log_date <= params.cutdate
        WHERE
            acl.state IN (14,17,15,3,8,9,5,6,7,10) )
            
SELECT DISTINCT
    p.center ||'p'|| p.id AS member,
    ea.log_date,
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS PERSON_STATUS,
    pa.*,
    CASE pa.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END AS "Payment Agreement STATE"
FROM
    eligible_agreements ea
JOIN
    payment_agreements pa
ON
    ea.agreement_center = pa.center
AND ea.agreement_id = pa.id
AND ea.agreement_subid = pa.subid
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    pa.CENTER = ar.CENTER
AND pa.ID = ar.ID
JOIN
    PERSONS p
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
LEFT JOIN
    goodlife.subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.state IN (2,4,8)
WHERE
    pa.bank_accno IS NOT NULL
AND pa.state IN (14,15,17,3,8,9,5,6,7,10) 
AND p.status NOT IN (1,3)
AND s.center IS NULL
AND ea.latest_change = 1

