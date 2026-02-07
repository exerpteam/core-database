SELECT
        p.center,
        p.center || 'p' || p.id AS personid,
		p.fullname             AS "Member Name",
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        ar.balance,
        longtodatec(art.entry_time, art.center) AS entry_date,
        art.amount AS full_amount,
        art.unsettled_amount,
        art.due_date,
        art.ref_type,
        art.status,
        art.text,
        staff.fullname
FROM stjames.persons p
JOIN stjames.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN stjames.ar_trans art ON ar.center = art.center AND ar.id = art.id
LEFT JOIN stjames.employees emp ON emp.center = art.employeecenter AND emp.id = art.employeeid
LEFT JOIN stjames.persons staff ON staff.center = emp.personcenter AND staff.id = emp.personid
WHERE
        art.status NOT IN ('CLOSED')
        AND ar.balance <> 0