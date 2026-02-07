 SELECT
     per.current_person_center || 'p' ||per.current_person_id AS MemberID,
     sub.end_date as Enddate,
     ar.balance as Debt
 FROM
     subscriptions sub
 JOIN
     persons per
 ON
     per.current_person_center=sub.owner_center
 AND per.current_person_id=sub.owner_id
 JOIN --subquery ranking the member's subscriptions with latest as 1
     (
         SELECT
             p.current_person_center,
             p.current_person_id,
             s.end_date,
             s.id,
             s.center,
             ROW_NUMBER() OVER (PARTITION BY current_person_center,current_person_id ORDER BY
             s.end_date DESC) ranked
         FROM
             subscriptions s
         JOIN
             persons p
         ON
             p.current_person_center=s.owner_center
         AND p.current_person_id=s.owner_id
         AND p.current_person_center IN (:Scope)
     ) latestsub
 ON
     per.current_person_center=latestsub.current_person_center
 AND per.current_person_id=latestsub.current_person_id
 AND latestsub.center=sub.center
 AND latestsub.id=sub.id
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     per.center = ar.CUSTOMERCENTER
 AND per.id = ar.CUSTOMERID
 WHERE
     sub.end_date IS NOT NULL
 AND latestsub.ranked=1 ---we want only members that have an end_date on most current subscription
 AND sub.end_date >= :FromDate
 AND sub.end_date <= :ToDate
 AND ar.AR_TYPE = 5 --debtaccount
 AND ar.BALANCE < 0
 ORDER BY
     per.current_person_center
