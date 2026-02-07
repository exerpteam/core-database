 WITH
         params AS
         (
          SELECT
                     /*+ materialize */
                     c.id                                                                                                AS centerid,
                     datetolongTZ (TO_CHAR (current_timestamp, 'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) - cast(90 as bigint) * 24 * 3600 * 1000 AS cutDate --minus 90 days
                FROM
                     centers c
                JOIN
                     countries co
                  ON
                     co.id = c.country
                     AND c.country = 'SE' --sweden
         )
  SELECT
             pe.center||'p'||pe.id AS "MEMBER ID",
             pe.fullname           AS "MEMBER NAME",
             prod.name             AS "MEMBERSHIP NAME",
             CASE CCC.CLOSED
                 WHEN 0
                 THEN 'Active'
                 WHEN 1
                 THEN 'Closed'
             END AS STATE,
             CASE CCC.HOLD
                 WHEN 0
                 THEN 'NO'
                 WHEN 1
                 THEN 'Yes'
             END           AS HOLD,
             CCC.STARTDATE AS "START DATE",
             CASE CCC.MISSINGPAYMENT
                 WHEN 0
                 THEN 'Missing agreement'
                 WHEN 1
                 THEN 'Debt collection'
             END AS "CASHCOLLECTION PROCEDURE TYPE",
             CASE pag1.STATE
                 WHEN 1
                 THEN 'Created'
                 WHEN 2
                 THEN 'Sent'
                 WHEN 3
                 THEN 'Failed'
                 WHEN 4
                 THEN 'OK'
                 WHEN 5
                 THEN 'Ended by bank'
                 WHEN 6
                 THEN 'Ended by clearing house'
                 WHEN 7
                 THEN 'Ended by debtor'
                 WHEN 8
                 THEN 'Cancelled = not sent'
                 WHEN 9
                 THEN 'Cancelled = sent'
                 WHEN 10
                 THEN 'Ended = creditor'
                 WHEN 11
                 THEN 'No agreement'
                 WHEN 12
                 THEN 'Cash payment (deprecated)'
                 WHEN 13
                 THEN 'Agreement not needed (invoice payment)'
                 WHEN 14
                 THEN 'Incomplete'
                 WHEN 15
                 THEN 'Transfer'
                 WHEN 16
                 THEN 'Agreement Recreated'
                 WHEN 17
                 THEN 'Signature missing'
                 ELSE 'UNDEFINED'
             END                                       AS "STATUS",
             PAG1.CREDITOR_ID                          AS "CLEARING HOUSE CREDITOR",
             ss.EMPLOYEE_CENTER||'emp'||ss.EMPLOYEE_ID AS "SALES EMPLOYEE",
             salep.fullname                            AS "SALES EMPLOYEE NAME",
             ss.sales_date                             AS "SALES DATE",
             s.billed_until_date                       AS "BILLED UNTIL",
             CASE
                 WHEN r.center IS NOT NULL
                 THEN r.center || 'p' || r.id
                 ELSE ' '
             END AS "OTHER PAYER"
        FROM
             CASHCOLLECTIONCASES CCC
        JOIN
             params
          ON
             params.CenterID = CCC.PERSONCENTER
  INNER JOIN
             relatives r
          ON
             CCC.PERSONCENTER = r.center
             AND CCC.PERSONID = r.id
             AND r.status = 1 --1 = Active (Documentation valid)
             AND r.rtype = 12 -- Other payer -- Customer paying (PERSONS.CENTER, PERSONS.ID)
        JOIN
             persons PE
          ON
             (
                 r.relativecenter = PE.CENTER
                 AND r.relativeid = PE.ID)
        JOIN
             ACCOUNT_RECEIVABLES AR
          ON
             (
                 AR.CUSTOMERCENTER = r.center
                 AND AR.CUSTOMERID = r.id
                 AND AR.AR_TYPE = 4)
             /*
             1 = Cash account
             4 = Payment account
             5 = Debt collection account
             6 = installment plan account
             */
   LEFT JOIN
             PAYMENT_ACCOUNTS PAA
          ON
             (
                 PAA.CENTER = AR.CENTER
                 AND PAA.ID = AR.ID)
   LEFT JOIN
             PAYMENT_AGREEMENTS PAG1
          ON
             (
                 PAA.ACTIVE_AGR_CENTER = PAG1.CENTER
                 AND PAA.ACTIVE_AGR_ID = PAG1.ID
                 AND PAA.ACTIVE_AGR_SUBID = PAG1.SUBID)
        JOIN
             subscriptions s
          ON
             s.owner_center = pe.center
             AND s.owner_id = pe.id
        JOIN
             subscriptiontypes st
          ON
             st.center = s.subscriptiontype_center
             AND st.ID = s.subscriptiontype_id
        JOIN
             products prod
          ON
             prod.center = st.center
             AND prod.id = st.id
        JOIN
             product_and_product_group_link ppgl
          ON
             prod.center = ppgl.product_center
             AND prod.id = ppgl.product_id
        JOIN
             product_group pg
          ON
             ppgl.product_group_id = pg.id
        JOIN
             subscription_sales ss
          ON
             s.center = ss.subscription_center
             AND s.id = ss.subscription_id
   LEFT JOIN
             employees emp
          ON
             ss.EMPLOYEE_CENTER = emp.center
             AND ss.EMPLOYEE_ID = emp.id
   LEFT JOIN
             persons salep
          ON
             emp.personcenter = salep.center
             AND emp.personid = salep.id
       WHERE
             CCC.MISSINGPAYMENT = 0 --0 missing agreement. 1 cash collection case
             AND pg.id = 99 --99 EFT Memberships
             AND s.sub_state != 6 --6 transferred
             AND CCC.CLOSED = 0
             AND CCC.CASHCOLLECTIONSERVICE IS NULL
             AND datetolongC (TO_CHAR (ss.start_date, 'YYYY-MM-DD HH24:MI'), s.center) >= params.cutDate
