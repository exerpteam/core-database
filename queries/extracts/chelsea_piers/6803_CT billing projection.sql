SELECT
        p.center AS "CENTER",
        pea.txtvalue AS "LEGEACY ID",
        p.center || 'p' || p.id AS "EXERP ID",
        pr.REQ_AMOUNT AS "AMOUNT EXERP",
        pag.REF AS "PAYMENT AGREMEENT REFERENCE ID",
        (CASE p.persontype 
                WHEN 0 THEN 'PRIVATE' 
                WHEN 1 THEN 'STUDENT' 
                WHEN 2 THEN 'STAFF' 
                WHEN 3 THEN 'FRIEND' 
                WHEN 4 THEN 'CORPORATE' 
                WHEN 5 THEN 'ONEMANCORPORATE' 
                WHEN 6 THEN 'FAMILY' 
                WHEN 7 THEN 'SENIOR' 
                WHEN 8 THEN 'GUEST' 
                WHEN 9 THEN 'CHILD' 
                WHEN 10 THEN 'EXTERNAL_STAFF' 
                ELSE 'Undefined' 
        END) AS "PERSON TYPE",
        pag.bank_accno AS "bank account/card number",
        ch.name AS "CLEARINGHOUSE TYPE",
        pag.clearinghouse_ref AS "TOKEN",
        pr.full_reference AS "PAYMENT REQUEST REF",
        (CASE pag.STATE
                WHEN 1 THEN 'Created'
                WHEN 2 THEN 'Sent'
                WHEN 3 THEN 'Failed'
                WHEN 4 THEN 'Ok'
                WHEN 10 THEN 'Ended, creditor'
        END) AS "PAYMENT AGREEMENT STATE",
        (CASE
                WHEN p.STATUS=0 THEN 'Lead'
                WHEN p.STATUS=1 THEN 'Active'
                WHEN p.STATUS=2 THEN 'Inactive'
                WHEN p.STATUS=3 THEN 'TemporaryInactive'
                WHEN p.STATUS=4 THEN 'Transferred'
                WHEN p.STATUS=5 THEN 'Duplicate'
                WHEN p.STATUS=6 THEN 'Prospect'
                WHEN p.STATUS=7 THEN 'Deleted'
                WHEN p.STATUS=8 THEN 'Anonymized'
                WHEN p.STATUS=9 THEN 'Contact'
                ELSE 'Undefined'
        END) AS "PERSON STATUS"
FROM chelseapiers.payment_requests pr
JOIN chelseapiers.payment_agreements pag ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
JOIN chelseapiers.clearinghouses ch ON pag.clearinghouse = ch.id
JOIN payment_request_specifications prs ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
JOIN account_receivables ar ON ar.center = prs.center AND ar.id = prs.id
JOIN chelseapiers.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
LEFT JOIN chelseapiers.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
WHERE
        p.center = 18 AND
        pr.req_date >= to_date(:Payment_Request_Date,'YYYY-MM-DD')
        ;