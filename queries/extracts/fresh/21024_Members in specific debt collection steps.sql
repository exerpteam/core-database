 WITH
     v_debt_cust AS
     (
         SELECT
             per.sex ,
             ar.customercenter         AS center,
             ar.customerid             AS id,
             SUM(art.unsettled_amount) AS Total_Ext_Debt
         FROM
             ACCOUNT_RECEIVABLES ar
         JOIN
             PERSONS per
         ON
             per.center = ar.customercenter
             AND per.id = ar.customerid
         JOIN
             AR_TRANS art
         ON
             art.CENTER = ar.CENTER
             AND art.ID = ar.ID
             AND art.status != 'CLOSED'
         JOIN
             cashcollectioncases ccc
         ON
             ccc.personcenter = ar.customercenter
             AND ccc.personid = ar.customerid
             AND ccc.missingpayment = 1
             AND ccc.closed = 0
         WHERE
             ar.customercenter IN (:Scope)
             AND ar.AR_TYPE = 4
           AND art.DUE_DATE < current_date
           AND ccc.currentstep_type = :Debt_Step_Type
             AND ccc.currentstep_date BETWEEN :From_Date AND :To_Date
         GROUP BY
             ar.customercenter,
             ar.customerid,
             per.sex
     )
     ,
     v_debt_details AS
     (
         SELECT
             cust.*,
             pag.ref,
             ar.balance,
             TO_CHAR(ccc.startdate, 'YYYY-MM-DD')                                                                                                                           AS ccc_startdate,
             TO_CHAR(ccc.currentstep_date, 'YYYY-MM-DD')                                                                                                                    AS ccc_currentstep_date,
             case ccc.CURRENTSTEP_TYPE when -1 then 'None' when 0 then 'Message' when 1 then 'Reminder' when 2 then 'Blocked' when 3 then 'Request and Stop' when 4 then 'Debt collection' when 7 then 'Request Buyout and Stop' end AS ccc_currentstep_name,
             ccc.currentstep                                                                                                                                                AS ccc_currentstep
         FROM
             v_debt_cust cust
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.customercenter = cust.center
             AND ar.customerid = cust.id
             AND ar.ar_type = 4
         JOIN
             PAYMENT_ACCOUNTS pa
         ON
             pa.center = ar.center
             AND pa.id = ar.id
         JOIN
             PAYMENT_AGREEMENTS pag
         ON
             pa.ACTIVE_AGR_CENTER = pag.center
             AND pa.ACTIVE_AGR_ID = pag.id
             AND pa.ACTIVE_AGR_SUBID = pag.subid
         JOIN
             cashcollectioncases ccc
         ON
             ccc.personcenter = ar.customercenter
             AND ccc.personid = ar.customerid
             AND ccc.missingpayment = 1
             AND ccc.closed = 0
     )
     ,
     v_debt_all AS
     (
         SELECT
             cust.center AS personcenter,
             cust.id     AS personid,
             cust.*
         FROM
             v_debt_details cust
         WHERE
             cust.sex != 'C'
         UNION
         SELECT
             op.relativecenter AS personcenter,
             op.relativeid     AS personid,
             cust.*
         FROM
             v_debt_details cust
         JOIN
             RELATIVES op
         ON
             op.center = cust.center
             AND op.id = cust.id
             AND op.RTYPE = 12
             AND op.STATUS < 3
         UNION
         SELECT
             emp.relativecenter AS personcenter,
             emp.relativeid     AS personid,
             cust.*
         FROM
             v_debt_details cust
         JOIN
             RELATIVES emp
         ON
             emp.center = cust.center
             AND emp.id = cust.id
             AND emp.RTYPE = 2
             AND emp.STATUS < 3
     )
 SELECT DISTINCT
     per.center || 'p' || per.id                                   AS "Member Id",
     per.external_id                                               AS "External Id",
     per.fullname                                                  AS "Full Name",
     cust.ref                                                      AS "Agreement Ref",
     email.txtvalue                                                AS "Email Address",
     mobile.txtvalue                                               AS "Phone Number",
     pd.name                                                       AS "Clipcard Name",
     TO_CHAR(longtodatec(cc.valid_until, cc.center), 'YYYY-MM-DD') AS "Clip card Expiry date",
     cc.clips_left                                                 AS "Remaining Clips",
     (cc.clips_initial-cc.clips_left)                              AS "Clips Used",
     assign_staff.fullname                                         AS "Clipcard assign staff",
     clipc.name                                                    AS "Sold at",
     CASE
         WHEN has_op_rel.center IS NOT NULL
         THEN 'Y'
         ELSE 'N'
     END AS "Pays for others",
     CASE
         WHEN op.center IS NOT NULL
         THEN op.center || 'p' || op.id
         ELSE NULL
     END                              AS "Other payer id",
     op.fullname                      AS "Other payer full name",
     op.external_id                   AS "Other payer external id",
     op_email.txtvalue                AS "Other payer email address",
     op_mobile.txtvalue               AS "Other payer phone number",
     cust.balance                     AS "Payment account debt",
     cust.Total_Ext_Debt              AS "External account Debt",
     cust.balance+cust.Total_Ext_Debt AS "Total debt",
     cust.ccc_startdate               AS "Debt case start date",
     cust.ccc_currentstep_date        AS "Current step start date",
     cust.ccc_currentstep_name        AS "Current step name",
     cust.ccc_currentstep             AS "Current step number",
     CASE
         WHEN cag.CENTER IS NOT NULL
         THEN cag.CENTER || 'p' || cag.ID
         ELSE NULL
     END AS CompanyId,
     CASE
         WHEN cag.CENTER IS NOT NULL
         THEN cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID
         ELSE NULL
     END                 AS CompanyAgreementId,
     pg.SPONSORSHIP_NAME AS SponsorshipType
 FROM
     v_debt_all cust
 JOIN
     PERSONS per
 ON
     per.center = cust.personcenter
     AND per.id = cust.personid
 LEFT JOIN
     clipcards cc
 ON
     cc.owner_center = per.center
     AND cc.owner_id = per.id
     AND cc.finished = 0
     AND cc.cancelled = 0
     AND cc.BLOCKED = 0
     AND cc.clips_left > 0
 LEFT JOIN
     centers clipc
 ON
     clipc.id = cc.center
 LEFT JOIN
     CLIPCARDTYPES ct
 ON
     ct.center = cc.center
     AND ct.id = cc.id
 LEFT JOIN
     products pd
 ON
     pd.center = ct.center
     AND pd.id = ct.id
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     per.center=email.PERSONCENTER
     AND per.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     per.center=mobile.PERSONCENTER
     AND per.id=mobile.PERSONID
     AND mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     PERSONS assign_staff
 ON
     assign_staff.center = cc.assigned_staff_center
     AND assign_staff.id = cc.assigned_staff_id
 LEFT JOIN
     RELATIVES has_op_rel
 ON
     has_op_rel.center=per.center
     AND has_op_rel.id=per.id
     AND has_op_rel.RTYPE = 12
     AND has_op_rel.STATUS < 3
 LEFT JOIN
     RELATIVES op_rel
 ON
     op_rel.relativecenter=per.center
     AND op_rel.relativeid=per.id
     AND op_rel.RTYPE = 12
     AND op_rel.STATUS < 3
 LEFT JOIN
     PERSONS op
 ON
     op.center = op_rel.center
     AND op.id = op_rel.id
 LEFT JOIN
     PERSON_EXT_ATTRS op_email
 ON
     op.center=op_email.PERSONCENTER
     AND op.id=op_email.PERSONID
     AND op_email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS op_mobile
 ON
     op.center=op_mobile.PERSONCENTER
     AND op.id=op_mobile.PERSONID
     AND op_mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     RELATIVES cgr
 ON
     cgr.CENTER = per.center
     AND cgr.ID = per.id
     AND cgr.RTYPE = 3
     AND cgr.STATUS < 2
 LEFT JOIN
     COMPANYAGREEMENTS cag
 ON
     cag.CENTER = cgr.RELATIVECENTER
     AND cag.ID = cgr.RELATIVEID
     AND cag.SUBID = cgr.RELATIVESUBID
 LEFT JOIN
     PRIVILEGE_GRANTS pg
 ON
     pg.GRANTER_CENTER = cag.CENTER
     AND pg.GRANTER_ID = cag.ID
     AND pg.GRANTER_SUBID = cag.SUBID
     AND pg.GRANTER_SERVICE = 'CompanyAgreement'
