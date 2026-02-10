-- The extract is extracted from Exerp on 2026-02-08
--  
 -- Parameters: FromDate(LONG_DATE),ToDate(LONG_DATE),Scope(SCOPE)
WITH
    params AS
    (
        SELECT
           	      CAST(extract(epoch FROM timezone('Europe/London', CAST($$FromDate$$ AS timestamptz))) AS bigint)*1000 AS FROMDATE, 
          CAST(extract(epoch FROM timezone('Europe/London', CAST($$ToDate$$ AS timestamptz))) AS bigint)*1000 AS TODATE
    )
 SELECT
     c.SHORTNAME AS "CLUB",
     c.EXTERNAL_ID "Club code",
     curr_p.CENTER || 'p' || curr_p.ID "Member ID",
     curr_p.EXTERNAL_ID "Member external id",
     curr_p.FIRSTNAME "First name",
     curr_p.LASTNAME "Surname",
     TO_CHAR(curr_p.BIRTHDATE, 'YYYY-MM-DD') AS "DOB",
     pruEntityNo.TXTVALUE "Vitality Entity",
     CASE
         WHEN pruAuthoriseCode.TXTVALUE IS NOT NULL
         THEN pruAuthoriseCode.TXTVALUE
         WHEN pruAuthoriseCodeOverride.TXTVALUE IS NOT NULL
         THEN pruAuthoriseCodeOverride.TXTVALUE
         WHEN pruActivateErrorCode.TXTVALUE IS NOT NULL
         THEN 'Error: ' || pruActivateErrorCode.TXTVALUE
         ELSE NULL
     END "Vitality Auth Code",
     cag.EXTERNAL_ID "Vitality Plan ID",
     dataset.PRODUCT_NAME "Subscription Package Name",
     dataset.PRODUCT_TYPE "Product Type",
     dataset.SALES_TYPE "Sales Type",
     -- dataset.PRODUCT_PRICE,
     -- dataset.rack_rate_gross,
     TO_CHAR(dataset.JOIN_DATE, 'YYYY-MM-DD') "Join Date",
     TO_CHAR(dataset.START_DATE, 'YYYY-MM-DD') "Start Date",
     TO_CHAR(dataset.END_DATE, 'YYYY-MM-DD') "End date",
     dataset.BILLED_UNTIL_DATE "Billed Until Date",
     dataset.STATE "State",
     -- dataset.SUB_STATE,
     dataset.description "Product",
     NULL " ",
     dataset.remit_rack_gross_amount "Gross Rack Rate to Member",
     dataset.discount_rate "Member Discount",
     SUM(remit_gross_amount) "Vitality Rate to Member",
     SUM(remit_gross_amount) "Total Remittance",
     NULL " ",
     SUM(remit_gross_amount) "Member Payment",
     SUM(membership_fee) "Top Up Fee",
     SUM(admin_fee) "Admin Fee",
     SUM(sales_commission) "Sales Fee",
     SUM(pru_Assessment) "Fitness Assesment",
     SUM(COALESCE(remit_gross_amount, 0)) + SUM(COALESCE(membership_fee,0)) + SUM(COALESCE(admin_fee, 0)) + SUM(COALESCE(sales_commission, 0
     )) + SUM(COALESCE(pru_Assessment, 0)) "Total Invoice",
     NULL " ",
     SUM(COALESCE(membership_fee,0)) + SUM(COALESCE(admin_fee, 0)) + SUM(COALESCE(sales_commission, 0)) + SUM(COALESCE(pru_Assessment, 0))
     "Gross charge to Vitality",
     NULL " ",
     dataset.sales_id "Sales ID"
 FROM
     (
         SELECT /*+ materialize */
             p.CENTER person_center,
             p.ID person_Id,
             sales.PRODUCT_NAME,
             sales.PRODUCT_TYPE,
             longtodateTZ(subs.CREATION_TIME, 'Europe/London') join_date,
             subs.START_DATE,
             subs.END_DATE,
             CASE
                 WHEN subs.START_DATE IS NOT NULL
                 THEN CASE  SCL1.STATEID  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED'
                      ELSE '
 UNKNOWN' END
                 ELSE NULL
             END STATE,
             CASE
                 WHEN subs.START_DATE IS NOT NULL
                 THEN CASE  SCL1.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 
                     '
 DOWNGRADED'  WHEN 5 THEN  'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED'
                      ELSE 'UNKNOWN' END
                 ELSE NULL
             END SUB_STATE,
             TO_CHAR(subs.BILLED_UNTIL_DATE, 'YYYY-MM-DD') BILLED_UNTIL_DATE,
             sales.SALES_TYPE,
             CASE
                 WHEN inv.CENTER IS NOT NULL
                 THEN inv.TEXT
                 WHEN cred.CENTER IS NOT NULL
                 THEN cred.COMENT
                 ELSE NULL
             END description,
             prod.PRICE product_PRICE,
             CASE
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '50%') > 0
                 THEN ROUND(prod.price * 2, 2)
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '25%') > 0
                 THEN ROUND(prod.price * 4, 2)
                 ELSE NULL
             END rack_rate_gross,
             CASE
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT), 2)
                 ELSE NULL
             END remit_gross_amount,
             CASE
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '50%') > 0
                 THEN '50%'
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '25%') > 0
                 THEN '25%'
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                 THEN 'ERROR'
                 ELSE NULL
             END discount_rate,
             CASE
                 WHEN sales.PRODUCT_TYPE NOT IN ('JOINING_FEE')
                     AND instr(sales.PRODUCT_NAME, '50%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 2, 2)
                 WHEN sales.PRODUCT_TYPE NOT IN ('JOINING_FEE')
                     AND instr(sales.PRODUCT_NAME, '25%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 4, 2)
                 ELSE NULL
             END remit_rack_gross_amount,
             CASE
                 WHEN sales.PRODUCT_TYPE = 'JOINING_FEE'
                     AND sales.SALES_TYPE = 'INVOICE'
                 THEN 10.52
                 WHEN sales.PRODUCT_TYPE = 'JOINING_FEE'
                     AND sales.SALES_TYPE = 'CREDIT_NOTE'
                 THEN -10.52
                 ELSE NULL
             END sales_commission,
             CASE
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND (cag.EXTERNAL_ID IS NULL
                         OR cag.EXTERNAL_ID NOT LIKE 'VITPLNY%')
                     AND instr(sales.PRODUCT_NAME, '50%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 0.10 * 2, 2)
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND (cag.EXTERNAL_ID IS NULL
                         OR cag.EXTERNAL_ID NOT LIKE 'VITPLNY%')
                     AND instr(sales.PRODUCT_NAME, '25%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 0.10 * 4, 2)
                 ELSE NULL
             END membership_fee,
             CASE
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '50%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 0.02 * 2, 2)
                 WHEN sales.PRODUCT_TYPE IN ('SUBS_PERIOD',
                                             'SUBS_PRORATA')
                     AND instr(sales.PRODUCT_NAME, '25%') > 0
                 THEN ROUND(SUM(sales.TOTAL_AMOUNT) * 0.02 * 4, 2)
                 ELSE NULL
             END admin_fee,
             NULL pru_Assessment,
             sales.sales_type || '-' || sales.CENTER || '-' || sales.ID || '-' || sales.SUB_ID sales_id
         FROM
             persons p
         CROSS JOIN
             params
         JOIN
             RELATIVES comp_rel
         ON
             comp_rel.center=p.center
             AND comp_rel.id=p.id
             AND comp_rel.RTYPE = 3
            AND (comp_rel.STATUS < 3 or p.status = 4)
         JOIN
             COMPANYAGREEMENTS cag
         ON
             cag.center= comp_rel.RELATIVECENTER
             AND cag.id=comp_rel.RELATIVEID
             AND cag.subid = comp_rel.RELATIVESUBID
         JOIN
             persons comp
         ON
             comp.center = cag.center
             AND comp.id=cag.id
         LEFT JOIN
             SALES_VW sales
         ON
             p.CENTER = sales.PERSON_CENTER
             AND p.ID = sales.PERSON_ID
         LEFT JOIN
             INVOICES inv
         ON
             inv.CENTER = sales.CENTER
             AND inv.ID = sales.ID
             AND sales.SALES_TYPE = 'INVOICE'
         LEFT JOIN
             CREDIT_NOTES cred
         ON
             cred.CENTER = sales.CENTER
             AND cred.ID = sales.ID
             AND sales.SALES_TYPE = 'CREDIT_NOTE'
             AND cred.INVOICE_CENTER IS NOT NULL
         LEFT JOIN
             PRODUCTS prod
         ON
             sales.PRODUCT_CENTER = prod.CENTER
             AND sales.PRODUCT_ID = prod.ID
         LEFT JOIN
             SPP_INVOICELINES_LINK spil
         ON
             spil.INVOICELINE_CENTER = sales.CENTER
             AND spil.INVOICELINE_ID = sales.ID
             AND spil.INVOICELINE_SUBID = sales.SUB_ID
             AND sales.SALES_TYPE = 'INVOICE'
         LEFT JOIN
             SUBSCRIPTIONS subs
         ON
             subs.CENTER = spil.PERIOD_CENTER
             AND subs.ID = spil.PERIOD_ID
         LEFT JOIN
             STATE_CHANGE_LOG SCL1
         ON
             (
                 SCL1.CENTER = subs.CENTER
                 AND SCL1.ID = subs.ID
                 AND SCL1.ENTRY_TYPE = 2
                 AND SCL1.BOOK_START_TIME < params.TODATE + 2000
                 AND (
                     SCL1.BOOK_END_TIME IS NULL
                     OR SCL1.BOOK_END_TIME >= params.TODATE + 2000)
                 AND SCL1.ENTRY_START_TIME < params.TODATE )
         WHERE
             p.center IN ($$Scope$$)
             AND comp.center = 4
             AND comp.ID = 674
        --     AND sales.EMPLOYEE_CENTER || 'emp' || sales.EMPLOYEE_ID <> '100emp1'
             AND sales.ENTRY_TIME >= params.FROMDATE
             AND sales.ENTRY_TIME < params.TODATE
             AND (
                 prod.name ~'ProRata*(Vitality|Pru)*'
                 OR EXISTS
                 (
                     SELECT
                         *
                     FROM
                         PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                     WHERE
                         pgl.PRODUCT_CENTER = sales.PRODUCT_CENTER
                         AND pgl.PRODUCT_ID = sales.PRODUCT_ID
                         AND pgl.PRODUCT_GROUP_ID = 1601))
         GROUP BY
             p.CENTER,
             p.ID,
             prod.PRICE,
             sales.PRODUCT_NAME,
             sales.TEXT,
             subs.CREATION_TIME,
             subs.START_DATE,
             subs.END_DATE,
             subs.BILLED_UNTIL_DATE,
             sales.PRODUCT_TYPE,
             sales.SALES_TYPE,
             inv.CENTER,
             inv.TEXT,
             cred.CENTER,
             cred.COMENT,
             p.LAST_ACTIVE_START_DATE,
             sales.ENTRY_TIME,
             cag.EXTERNAL_ID,
             SCL1.STATEID,
             SCL1.SUB_STATE,
             sales.center,
             sales.id,
             sales.sub_id
         UNION ALL
         SELECT
             par.PARTICIPANT_CENTER PERSON_CENTER,
             par.PARTICIPANT_ID PERSON_ID,
             c.SHORTNAME || ' - ' || act.NAME || ': ' || TO_CHAR(longtodateTZ(bk.STARTTIME, 'Europe/London'),
             'YYYY-MM-DD HH24:MI') description,
             'PRU_ASSESSMENT' product_Type,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL bud,
             NULL,
             'INVOICE' SALES_TYPE,
             NULL period,
             0 product_PRICE,
             0 product_PRICEx,
             NULL gross_amount,
             NULL remit_rack_amount,
             NULL discount_rate,
             NULL sales_comm,
             NULL subs_fee,
             NULL admin_fee,
             9.50 pru_assessment,
             'ASSESS' || '-' || bk.CENTER || '-' || bk.ID sales_id
         FROM
             BOOKINGS bk
         CROSS JOIN
             params
         JOIN
             CENTERS c
         ON
             c.ID = bk.CENTER
         JOIN
             ACTIVITY act
         ON
             bk.ACTIVITY = act.ID
         JOIN
             ACTIVITY_GROUP actgr
         ON
             act.ACTIVITY_GROUP_ID = actgr.ID
         JOIN
             PARTICIPATIONS par
         ON
             par.BOOKING_CENTER = bk.CENTER
             AND par.BOOKING_ID = bk.ID
         WHERE
             act.ACTIVITY_TYPE = 4
             AND par.PARTICIPANT_CENTER IN ($$Scope$$)
             AND bk.STARTTIME > params.FROMDATE
             AND bk.STARTTIME < params.TODATE
             AND act.ID = 445
             AND par.center IS NOT NULL
             AND bk.state NOT IN ('CANCELLED')) dataset
 JOIN
     persons p
 ON
     p.CENTER = dataset.person_center
     AND p.ID = dataset.person_id
 JOIN
     persons curr_p
 ON
     p.current_person_center = curr_p.center
     AND p.current_person_id = curr_p.id
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 LEFT JOIN
     RELATIVES comp_rel
 ON
     comp_rel.center=curr_p.center
     AND comp_rel.id=curr_p.id
     AND comp_rel.RTYPE = 3
     AND comp_rel.STATUS < 3
 LEFT JOIN
     COMPANYAGREEMENTS cag
 ON
     cag.center= comp_rel.RELATIVECENTER
     AND cag.id=comp_rel.RELATIVEID
     AND cag.subid = comp_rel.RELATIVESUBID
 LEFT JOIN
     persons comp
 ON
     comp.center = cag.center
     AND comp.id=cag.id
 LEFT JOIN
     person_ext_attrs pruEntityNo
 ON
     curr_p.center = pruEntityNo.PERSONCENTER
     AND curr_p.id = pruEntityNo.PERSONID
     AND pruEntityNo.name = '_eClub_PBLookupPartnerPersonId'
 LEFT JOIN
     person_ext_attrs pruAuthoriseCode
 ON
     curr_p.center = pruAuthoriseCode.PERSONCENTER
     AND curr_p.id = pruAuthoriseCode.PERSONID
     AND pruAuthoriseCode.name = '_eClub_PBActivationAuthorizationCode'
 LEFT JOIN
     person_ext_attrs pruAuthoriseCodeOverride
 ON
     curr_p.center = pruAuthoriseCodeOverride.PERSONCENTER
     AND curr_p.id = pruAuthoriseCodeOverride.PERSONID
     AND pruAuthoriseCodeOverride.name = '_eClub_PBActivationAuthorizationCodeOverride'
 LEFT JOIN
     person_ext_attrs pruActivateErrorCode
 ON
     curr_p.center = pruActivateErrorCode.PERSONCENTER
     AND curr_p.id = pruActivateErrorCode.PERSONID
     AND pruActivateErrorCode.name = '_eClub_PBActivationPartnerErrorCode'
 GROUP BY
     c.SHORTNAME,
     c.EXTERNAL_ID,
     curr_p.CENTER,
     curr_p.ID,
     curr_p.EXTERNAL_ID,
     curr_p.FIRSTNAME,
     curr_p.LASTNAME,
     curr_p.BIRTHDATE,
     pruEntityNo.TXTVALUE,
     pruAuthoriseCode.TXTVALUE,
     pruAuthoriseCodeOverride.TXTVALUE,
     pruActivateErrorCode.TXTVALUE,
     cag.EXTERNAL_ID,
     dataset.PRODUCT_NAME,
     dataset.PRODUCT_PRICE,
     dataset.RACK_RATE_GROSS,
     dataset.JOIN_DATE,
     dataset.START_DATE,
     dataset.END_DATE,
     dataset.STATE,
     dataset.SUB_STATE,
     dataset.PRODUCT_TYPE,
     dataset.SALES_TYPE,
     dataset.description,
     dataset.BILLED_UNTIL_DATE,
     dataset.discount_rate,
     dataset.remit_rack_gross_amount,
     dataset.sales_id
 ORDER BY
     pruEntityNo.TXTVALUE
