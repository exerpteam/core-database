-- The extract is extracted from Exerp on 2026-02-08
-- Created by Simon Jackson for integration with Dynamics CRM
 SELECT
     p.CENTER || 'p' || p.id "PERSON_HOME_CENTER_ID"
   , p.FULLNAME "PERSON_FULLNAME"
   , pa.REF "PERSON_AGREEMENT_REF"
   , bac."AGREEMENT_CASE_ID"
   , pc.SHORTNAME "CENTER_NAME"
   , pa.STATE "AGREEMENT_STATE"
   ,CASE pa.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 
     'Agreement information incomplete' END "AGREEMENT_STATE_NAME"
   , CASE WHEN paid.CENTER IS NULL THEN NULL ELSE paid.CENTER || 'p' || paid.ID END "RELATIVE_HOME_CENTER_ID"
   , paid.FULLNAME "RELATIVE_FULLNAME"
 FROM
     PAYMENT_AGREEMENTS pa
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.ACTIVE_AGR_CENTER = pa.CENTER
     AND pac.ACTIVE_AGR_ID = pa.ID
     AND pac.ACTIVE_AGR_SUBID = pa.SUBID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = pac.CENTER
     AND ar.id = pac.ID
     AND ar.AR_TYPE = 4
 JOIN
     PERSONS p
 ON
     p.CENTER = ar.CUSTOMERCENTER
     AND p.id = ar.CUSTOMERID
 JOIN
                 ( SELECT ((cc.center || 'ccol'::text) || cc.id) AS "AGREEMENT_CASE_ID", cc.center AS "CENTER_ID", CASE WHEN ((p.sex)::text <> 'C'::text) THEN CASE WHEN ((p.center <> p.transfers_current_prs_center) OR (p.id <> p.transfers_current_prs_id)) THEN ( SELECT persons.external_id FROM persons WHERE ((persons.center = p.transfers_current_prs_center) AND (persons.id = p.transfers_current_prs_id))) ELSE p.external_id END ELSE NULL::character varying END AS "PERSON_ID", CASE WHEN ((p.sex)::text = 'C'::text) THEN CASE WHEN ((p.center <> p.transfers_current_prs_center) OR (p.id <> p.transfers_current_prs_id)) THEN ( SELECT persons.external_id FROM persons WHERE ((persons.center = p.transfers_current_prs_center) AND (persons.id = p.transfers_current_prs_id))) ELSE p.external_id END ELSE NULL::character varying END AS "COMPANY_ID", to_char(longtodatec((cc.start_datetime)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "START_DATE", CASE WHEN (cc.closed = 0) THEN 'FALSE'::text WHEN (cc.closed = 1) THEN 'TRUE'::text ELSE NULL::text END AS "CLOSED", to_char(longtodatec((cc.closed_datetime)::double precision, (cc.center)::double precision), 'yyyy-MM-dd'::text) AS "CLOSED_DATE", cc.last_modified AS "ETS" FROM ((cashcollectioncases cc JOIN persons p ON (((p.center = cc.personcenter) AND (p.id = cc.personid)))) JOIN persons cp ON (((cp.center = p.current_person_center) AND (cp.id = p.current_person_id)))) WHERE (cc.missingpayment = 0) ) bac
 ON
                 bac."PERSON_ID" = p.EXTERNAL_ID
 JOIN
     CENTERS pc
 ON
     pc.ID = p.CENTER
 LEFT JOIN
     RELATIVES rel
 ON
     rel.CENTER = ar.CUSTOMERCENTER
     AND rel.id = ar.CUSTOMERID
     AND rel.RTYPE = 12
     AND rel.STATUS = 1
 LEFT JOIN
     PERSONS paid
 ON
     paid.CENTER = rel.RELATIVECENTER
     AND paid.ID = rel.RELATIVEID
 WHERE
                 pa.CENTER in (2,6,9,12,13,15,16,27,29,30,33,34,35,36,38,39,40,47,48,51,56,57,59,60,61,68,69,71,75,76,405,408,410,415,421,422,425,437,438,452,953,954,955)
                 AND bac."CLOSED" = 'FALSE'
