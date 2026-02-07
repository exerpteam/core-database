SELECT DISTINCT
    c.name AS "Club Name",
    cnl.person_center || 'p' || cnl.person_id  AS "PersonID",
    p.fullname AS "Member Name",
    art.amount AS "Amount",
    TO_CHAR(longtodatec(art.trans_time, art.center), 'DD/MM/YYYY') AS "Date",
    prcn.name AS "Credit Product",
    cnl.cancel_reason AS "Reason",
    cn.coment AS "Reason Description",
    CASE
        WHEN cnl.canceltype = 0 THEN 'Wrong sale'
        WHEN cnl.canceltype = 1 THEN 'Faulty product'
        WHEN cnl.canceltype = 2 THEN 'Product returned'
        WHEN cnl.canceltype = 3 THEN 'Duplicate'
        WHEN cnl.canceltype = 4 THEN 'Fraudulent'
        WHEN cnl.canceltype = 5 THEN 'Member dissatisfaction'
        WHEN cnl.canceltype = 6 THEN 'Payment error'
        WHEN cnl.canceltype = 7 THEN 'Other'
        ELSE 'Unknown (' || cnl.canceltype || ')'
    END AS "Cancel Type",
    cnl.text AS "Credit Line Text",
    cn.text || ': ' || cn.coment AS "Cancellation Reason (Header Text)",
    pers.fullname AS "Employee Name"
FROM account_trans act
JOIN credit_note_lines_mt cnl
  ON cnl.account_trans_center = act.center
 AND cnl.account_trans_id     = act.id
 AND cnl.account_trans_subid  = act.subid
 AND act.trans_type = 5
JOIN ar_trans art
  ON art.ref_center = cnl.center
 AND art.ref_id    = cnl.id
 AND art.ref_type  = 'CREDIT_NOTE'
JOIN products prcn
  ON prcn.center = cnl.productcenter
 AND prcn.id     = cnl.productid
JOIN credit_notes cn
  ON cn.center = cnl.center
 AND cn.id     = cnl.id
JOIN persons p
  ON p.center = cnl.person_center
 AND p.id     = cnl.person_id
JOIN centers c
  ON c.id = cnl.center
LEFT JOIN employees emp
  ON emp.center = art.employeecenter
 AND emp.id     = art.employeeid
LEFT JOIN persons pers
  ON pers.center = emp.personcenter
 AND pers.id     = emp.personid
WHERE
      art.trans_time BETWEEN
          datetolongC(TO_CHAR(to_date(:From, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI'), art.center)
      AND datetolongC(TO_CHAR(to_date(:To,   'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI'), art.center) + 86400*1000
  AND cn.center IN (:Scope)
  AND cnl.canceltype <> 3  -- exclude 'Duplicate'
ORDER BY "Club Name", "Date", "Member Name";
