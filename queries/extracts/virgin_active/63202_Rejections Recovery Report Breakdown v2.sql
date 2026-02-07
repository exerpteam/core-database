WITH
 params AS
    (
      SELECT
            /*+ materialize */
            CAST (dateToLongTZ(TO_CHAR(CAST(:fromDate AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome') AS BIGINT)                  AS FROMDATE,
            CAST((dateToLongTZ(TO_CHAR(CAST(:toDate AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/Rome')+ 86400 * 1000)-1 AS BIGINT) AS TODATE
     )
     ,
     v_paymethod AS
     (
         SELECT DISTINCT
             q.scope_id,
--             x.attributeid,
--             x.attributename
CAST(unnest(xpath('//attributes/attribute/@id',xmlparse(document convert_from(q.mimevalue, 'UTF-8')))) AS VARCHAR) as attributeid,
CAST(unnest(xpath('//attributes/attribute/@name',xmlparse(document convert_from(q.mimevalue, 'UTF-8')))) AS VARCHAR) as attributename
         FROM
             SYSTEMPROPERTIES Q,
             centers c
--             XMLTABLE('//attributes/attribute' passing XMLType(q.MIMEVALUE,871) columns attributeid VARCHAR2(100) PATH '@id', attributename VARCHAR2(100) PATH '@name' )x
         WHERE
             q.globalid = 'PaymentMethodsConfig'
             AND c.id = q.scope_id
             AND q.scope_type = 'C'
             AND c.country = 'IT'
             AND q.MIMETYPE = 'text/xml'
     )
 SELECT DISTINCT
     ar.CUSTOMERCENTER AS CENTER,
     ar.CUSTOMERID     AS ID,
     p.FULLNAME,
     longtodateC(art.TRANS_TIME,paid.center)  AS PAYMENT_TRANS_TIME,
     art.AMOUNT                               AS AMOUNT_PAID,
     arm.AMOUNT                               AS AMOUNT_MATCHED,
     paid.AMOUNT                              AS PAID_FOR_AMOUNT,
     paid.DUE_DATE                            AS PAID_FOR_DUE_DATE,
     paid.TEXT                                AS PAID_FOR_TEXT,
     longtodateC(paid.TRANS_TIME,paid.center) AS PAID_FOR_TRANS_TIME,
     CASE
         WHEN art.text IN ('FreeCreditnote: Insoluto Irrecuperabile','FreeCreditNote: Insoluto Irrecuperabile')
         THEN 'CREDIT_NOTE'
         WHEN art.text IN ('Manual registered payment of request: Payment open request')
         THEN 'MANUAL_PAYMENT_REQUEST'
         ELSE CASE crt.crttype WHEN 1 THEN 'CASH' WHEN 7 THEN 'CREDIT_CARD' WHEN 13 THEN CASE WHEN pm.scope_id IS NOT NULL THEN  pm.attributename ELSE  CASE crt.CONFIG_PAYMENT_METHOD_ID WHEN 0 THEN 'IVR' WHEN 1 THEN 'ASSEGNO' WHEN 2 THEN 'INTRUM'  WHEN 3 THEN 'Bank Transfer' END END ELSE 'UNKNOWN' END
     END                                                                                                                                                                                                        AS "PAYMENT_METHOD",
     CASE  paid_pr.state WHEN 1 THEN  'PS_NEW' WHEN 2 THEN  'PS_SENT' WHEN 3 THEN  'PS_DONE' WHEN 5 THEN  'PS_REJECTED_BY_CLEARINGHOUSE' WHEN 12 THEN  'PS_FAIL_NO_CREDITOR' WHEN 17 THEN  'PS_FAIL_REJ_DEB_REVOKED'  ELSE null END AS state ,
     paid_pr.rejected_reason_code,
     paid_pr.xfr_info AS REJECTION_REASON,
	(CASE request_type 
	WHEN 1 THEN 'PAYMENT'
	WHEN 6 THEN 'REPRESENTATION'
ELSE NULL
END) AS "Payment Request Type"
 FROM
     params,
     AR_TRANS art
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.center = art.center
     AND ar.id = art.id
 JOIN
     PERSONS p
 ON
     p.center = ar.CUSTOMERCENTER
     AND p.id = ar.CUSTOMERID
 LEFT JOIN
     ART_MATCH arm
 ON
     arm.ART_PAYING_CENTER = art.center
     AND arm.ART_PAYING_ID = art.id
     AND arm.ART_PAYING_SUBID = art.SUBID
 LEFT JOIN
     AR_TRANS paid
 ON
     paid.center = arm.ART_PAID_CENTER
     AND paid.ID = arm.ART_PAID_ID
     AND paid.SUBID = arm.ART_PAID_SUBID
 LEFT JOIN
     payment_request_specifications paid_prs
 ON
     paid_prs.center = paid.payreq_spec_center
     AND paid_prs.id = paid.payreq_spec_id
     AND paid_prs.subid = paid.payreq_spec_subid
 LEFT JOIN
     payment_requests paid_pr
 ON
     paid_pr.inv_coll_center = paid_prs.center
     AND paid_pr.inv_coll_id = paid_prs.id
     AND paid_pr.inv_coll_subid = paid_prs.subid
         AND paid_pr.state IN (1,2,3,5,12, 17)
         AND paid_pr.request_type in (1)
 LEFT JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     crt.ARTRANSCENTER= art.center
     AND crt.ARTRANSID = art.id
     AND crt.ARTRANSSUBID = art.SUBID
     AND crt.crttype NOT IN (2)
 LEFT JOIN
     v_paymethod pm
 ON
     pm.scope_id = crt.center
     AND pm.attributeid = CAST(crt.config_payment_method_id AS VARCHAR)
 WHERE
     p.center IN ($$scope$$)
     AND art.TRANS_TIME BETWEEN params.FROMDATE AND params.TODATE
    
     AND paid.DUE_DATE < longtodateC(art.TRANS_TIME,art.center)
