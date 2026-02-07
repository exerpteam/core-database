-- This is the version from 2026-02-05
--  
 SELECT DISTINCT
     comp.fullname                                                                                                                                                                   AS "Company Name",
     comp.center || 'p' || comp.id                                                                                                                                                   AS "Company Exerp Id",
comp.ssn as "Company ID",
P.CENTER||'p'||P.ID     as "Member ID",
     p.fullname as "Member Name",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "Member Status",
     companyAgreementEmpNumber.txtvalue                                                                                                                                              AS "Employee Number",
     par.individual_deduction_day                                                                                                                                                    AS "Deduction Day",
     CASE par.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended by clearing house' WHEN 7 THEN 'Ended by debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Termination sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN  'Signature missing'  ELSE NULL END AS "Payment Agreement State",
     s.subscription_price                                                                                                                                                            AS "Subscription Price",
     TO_CHAR(s.start_date, 'yyyy-MM-dd')                                                                                                                                             AS "Subscription Start Date",
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE NULL END                                                                                               AS "Subscription State"
 FROM
     persons p
 JOIN
     relatives r
 ON
     p.center = r.relativecenter
     AND p.id = r.relativeid
     AND r.rtype = 2
     AND r.status != 3
 JOIN
     persons comp
 ON
     comp.center = r.center
     AND comp.id = r.id
 LEFT JOIN
     PERSON_EXT_ATTRS companyAgreementEmpNumber
 ON
     p.center=companyAgreementEmpNumber.PERSONCENTER
     AND p.id=companyAgreementEmpNumber.PERSONID
     AND companyAgreementEmpNumber.name='COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
 LEFT JOIN
     subscriptions s
 ON
     s.owner_center = p.center
     AND s.owner_id = p.id
     AND s.state IN (2,4,8)
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
     AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_AGREEMENTS par
 ON
     par.CENTER = ar.CENTER
     AND par.ID = ar.ID
     AND par.active = 1
