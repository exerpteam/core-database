 WITH
     params AS materialized
     (
         SELECT
             CAST($$StartDate$$ AS DATE)                                                                                AS StartDate,
             CAST($$EndDate$$ AS DATE)                                                                                   AS EndDate,
             CAST(datetolongTZ(TO_CHAR(CAST($$StartDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London')  AS BIGINT)  AS StartDateLong,
             CAST((datetolongTZ(TO_CHAR(CAST($$EndDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS BIGINT) AS EndDateLong
         
     )
     ,
     v_deduction_change AS
     (
         SELECT
             ar.customercenter || 'p' || ar.customerid       AS PersonId,
             acl.employee_center || 'emp' || acl.employee_id AS Employee,
             'Amend direct debit date'                       AS feature
         FROM
             account_receivables ar
         JOIN
             persons p
         ON
             p.center = ar.customercenter
             AND p.id = ar.customerid
             AND p.status NOT IN (2)
         CROSS JOIN
             params
         JOIN
             payment_agreements pag
         ON
             pag.center = ar.center
             AND pag.id = ar.id
         JOIN
             agreement_change_log acl
         ON
             acl.agreement_center = pag.center
             AND acl.agreement_id = pag.id
             AND acl.agreement_subid = pag.subid
             AND acl.employee_center || 'emp' || acl.employee_id NOT IN ('100emp1')
         JOIN
             state_change_log scl
         ON
             scl.center = p.center
             AND scl.id = p.id
             AND scl.entry_type = 1
             AND scl.stateid = 1
             AND acl.entry_time BETWEEN scl.entry_start_time AND COALESCE(scl.entry_end_time, acl.entry_time)
         WHERE
             ar.ar_type = 4
             AND ar.customercenter IN ($$Scope$$)
             AND acl.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND acl.employee_id != 1
             AND acl.entry_time BETWEEN params.StartDateLong AND params.EndDateLong
             AND acl.text LIKE 'Deduction day change%'
     )
     ,
     bank_change AS
     (
         SELECT
             ar.customercenter,
             ar.customerid,
             pag.center,
             pag.id,
             pag.subid,
             pag.bank_account_details,
             pag.creation_time,
             CASE
                 WHEN LAG(pag.bank_account_details) over (partition BY ar.center,ar.id ORDER BY pag.creation_time) != pag.bank_account_details
                 THEN 1
                 ELSE 0
             END AS IS_CHANGE
         FROM
             account_receivables ar
         JOIN
             payment_agreements pag
         ON
             pag.center = ar.center
             AND pag.id = ar.id
         WHERE
             ar.customercenter IN ($$Scope$$)
             AND ar.ar_type = 4
     )
     ,
     v_bank_change AS
     (
         SELECT DISTINCT
             customercenter || 'p' || customerid     AS PersonId,
             employee_center || 'emp' || employee_id AS Employee,
             'Amend bank details'                    AS feature
         FROM
             (
                 SELECT
                     v_bank.customercenter,
                     v_bank.customerid,
                     acl.employee_center,
                     acl.employee_id,
                     acl.entry_time,
                     rank() over (partition BY acl.agreement_center, acl.agreement_id, acl.agreement_subid ORDER BY acl.entry_time) AS rnk,
                     longtodatec(acl.entry_time, v_bank.customercenter)                                                             AS entrytime,
                     v_bank.creation_time,
                     acl.entry_time AS ACl_ENTRY
                 FROM
                     bank_change v_bank
                 CROSS JOIN
                     params
                 JOIN
                     agreement_change_log acl
                 ON
                     acl.agreement_center = v_bank.center
                     AND acl.agreement_id = v_bank.id
                     AND acl.agreement_subid = v_bank.subid
                     AND acl.state = 1
                 WHERE
                     v_bank.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
                     AND v_bank.IS_CHANGE = 1 ) t2
         WHERE
             rnk = 1
             AND employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND employee_id != 1
             /* Member should be active during time of change */
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     state_change_log scl
                 WHERE
                     scl.center = customercenter
                     AND scl.id = customerid
                     AND scl.entry_type = 1
                     AND scl.stateid = 1
                     AND entry_time BETWEEN scl.entry_start_time AND COALESCE(scl.entry_end_time, entry_time))
     )
 SELECT
     *
 FROM
     v_deduction_change
 UNION ALL
 SELECT
     *
 FROM
     v_bank_change
 UNION ALL
 SELECT
     *
 FROM
     v_bank_change
