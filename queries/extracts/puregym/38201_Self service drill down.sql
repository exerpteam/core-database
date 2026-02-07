 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             CAST($$StartDate$$ as DATE)                                                                                        AS StartDate,
             CAST($$EndDate$$ as DATE)                                                                                          AS EndDate,
             datetolongTZ(TO_CHAR(CAST($$StartDate$$ as DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London')                          AS StartDateLong,
             (datetolongTZ(TO_CHAR(CAST($$EndDate$$ as DATE), 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1          AS EndDateLong
     )
     ,
     v_sub_change AS
     (
         SELECT DISTINCT
             s_new.OWNER_CENTER || 'p' || s_new.OWNER_ID AS PersonId,
             longToDate(sc.CHANGE_TIME)                  AS change_time,
             sc.employee_center||'emp'||sc.employee_id   AS employee,
             CASE
                 WHEN pg_old.name = 'Off Peak'
                     AND pg_new.name = 'Standard Products'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from off-peak to standard'
                 WHEN pg_old.name = 'Standard Products'
                     AND pg_new.name = 'Multi Products (MS Reporting)'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from standard to multi'
                 WHEN pg_old.name = 'Multi Products (MS Reporting)'
                     AND pg_new.name = 'Extra Subscriptions MS'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from multi to extra'
                 WHEN pg_old.name = 'Off Peak'
                     AND pg_new.name = 'Extra Subscriptions MS'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from off-peak to extra'
                 WHEN pg_old.name = 'Standard Products'
                     AND pg_new.name = 'Extra Subscriptions MS'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from standard to extra'
                 WHEN pg_old.name = 'Multi Products (MS Reporting)'
                     AND pg_new.name = 'Multi Products (MS Reporting)'
                 THEN 'Changing from multi to multi'
                 WHEN pg_old.name = 'Multi Products (MS Reporting)'
                     AND pg_new.name = 'Standard Products'
                 THEN 'Changing from multi to standard'
                 WHEN pg_old.name = 'Off Peak'
                     AND pg_new.name = 'Multi Products (MS Reporting)'
                     AND s_old.sub_state = 3
                 THEN 'Upgrading from off-peak to multi'
                 WHEN pg_old.name = 'Standard Products'
                     AND pg_new.name = 'Off Peak'
                     AND s_old.sub_state = 4
                 THEN 'Downgrading from standard to off-peak'
                 WHEN pg_old.name = 'Multi Products (MS Reporting)'
                     AND pg_new.name = 'Off Peak'
                     AND s_old.sub_state = 4
                 THEN 'Downgrading from multi to off-peak'
                 WHEN pg_old.name = 'Extra Subscriptions MS'
                     AND pg_new.name = 'Extra Subscriptions MS'
                 THEN 'Changing from extra to extra'
                 WHEN pg_old.name = 'Extra Subscriptions MS'
                     AND pg_new.name = 'Multi Products (MS Reporting)'
                     AND s_old.sub_state = 4
                 THEN 'Downgrading from extra to multi'
                 WHEN pg_old.name = 'Extra Subscriptions MS'
                     AND pg_new.name = 'Standard Products'
                     AND s_old.sub_state = 4
                 THEN 'Downgrading from extra to standard'
                 WHEN pg_old.name = 'Extra Subscriptions MS'
                     AND pg_new.name = 'Off Peak'
                     AND s_old.sub_state = 4
                 THEN 'Downgrading from extra to off-peak'
                 ELSE NULL
             END             change_type,
             pro_old.name AS changed_from,
             pro_new.name AS changed_to
         FROM
             subscription_change sc
         CROSS JOIN
             params
         JOIN
             subscriptions s_new
         ON
             s_new.CENTER = sc.NEW_SUBSCRIPTION_CENTER
             AND s_new.ID = sc.NEW_SUBSCRIPTION_ID
         JOIN
             products pro_new
         ON
             pro_new.center = s_new.subscriptiontype_center
             AND pro_new.id = s_new.subscriptiontype_id
         JOIN
             product_and_product_group_link pglink_new
         ON
             pglink_new.product_center = pro_new.center
             AND pglink_new.product_id = pro_new.id
         JOIN
             product_group pg_new
         ON
             pg_new.id = pglink_new.product_group_id
         JOIN
             subscriptions s_old
         ON
             s_old.CENTER = sc.OLD_SUBSCRIPTION_CENTER
             AND s_old.ID = sc.OLD_SUBSCRIPTION_ID
         JOIN
             products pro_old
         ON
             pro_old.center = s_old.subscriptiontype_center
             AND pro_old.id = s_old.subscriptiontype_id
         JOIN
             product_and_product_group_link pglink_old
         ON
             pglink_old.product_center = pro_old.center
             AND pglink_old.product_id = pro_old.id
         JOIN
             product_group pg_old
         ON
             pg_old.id = pglink_old.product_group_id
         WHERE
             s_new.owner_center IN ($$Scope$$)
             AND sc.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND sc.employee_id != 1
             AND sc.type LIKE 'TYPE'
             AND sc.cancel_time IS NULL
             AND pg_old.name IN ('Off Peak',
                                 'Standard Products',
                                 'Multi Products (MS Reporting)',
                                 'Extra Subscriptions MS')
             AND pg_new.name IN ('Standard Products',
                                 'Multi Products (MS Reporting)',
                                 'Extra Subscriptions MS',
                                 'Off Peak')
             AND sc.CHANGE_TIME BETWEEN params.StartDateLong AND params.EndDateLong
             /* Member should have an active subscription during the change */
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = s_new.CENTER
                     AND SCL.ID = s_new.ID
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.STATEID IN (2,4,
                                         8)
                     AND SCL.ENTRY_START_TIME <= sc.CHANGE_TIME
                     AND (
                         SCL.ENTRY_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME > sc.CHANGE_TIME ) )
             /* Member shouldn't be joiner or rejoiner during time of change */
             AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = s_new.OWNER_CENTER
                     AND SCL.ID = s_new.OWNER_ID
                     AND SCL.ENTRY_TYPE = 5
                     AND SCL.STATEID = 2
                     AND scl.sub_state IN (1,3)
                     AND SCL.ENTRY_START_TIME <= sc.CHANGE_TIME
                     AND (
                         SCL.ENTRY_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME > sc.CHANGE_TIME ) )
     )
     ,
     v_sub_change_1 AS
     (
         SELECT
             PersonId,
             employee        AS employee,
             sub.change_type AS feature
         FROM
             v_sub_change sub
         WHERE
             sub.change_type IS NOT NULL
     )
     ,
     v_freeze AS
     (
         SELECT
             s.owner_center || 'p' || s.owner_id          AS PersonId,
             sfp.employee_center||'emp'|| sfp.employee_id AS Employee,
             'Members freezing'                           AS feature
         FROM
             subscription_freeze_period sfp
         CROSS JOIN
             params
         JOIN
             subscriptions s
         ON
             s.center = sfp.subscription_center
             AND s.id = sfp.subscription_id
         WHERE
             s.owner_center IN ($$Scope$$)
             AND sfp.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND sfp.employee_id != 1
             AND sfp.state = 'ACTIVE'
             AND sfp.entry_time BETWEEN params.StartDateLong AND params.EndDateLong
         GROUP BY
             s.owner_center,
             s.owner_id,
             sfp.state,
             sfp.employee_center||'emp'|| sfp.employee_id
         UNION
         SELECT
             s.owner_center || 'p' || s.owner_id                        AS PersonId,
             sfp.cancel_employee_center||'emp'|| sfp.cancel_employee_id AS Employee,
             'Un-freeze membership'                                     AS feature
         FROM
             subscription_freeze_period sfp
         CROSS JOIN
             params
         JOIN
             subscriptions s
         ON
             s.center = sfp.subscription_center
             AND s.id = sfp.subscription_id
         WHERE
             s.owner_center IN ($$Scope$$)
             AND sfp.cancel_employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND sfp.cancel_employee_id != 1
             AND sfp.state = 'CANCELLED'
             AND sfp.cancel_time BETWEEN params.StartDateLong AND params.EndDateLong
         GROUP BY
             s.owner_center,
             s.owner_id,
             sfp.state,
             sfp.cancel_employee_center||'emp'|| sfp.cancel_employee_id
     )
     ,
     v_personchange AS
     (
         SELECT
             pcl.person_center || 'p' || pcl.person_id       AS PersonId,
             pcl.employee_center || 'emp' || pcl.employee_id AS Employee,
             'Update personal details'                       AS feature
         FROM
             PERSON_CHANGE_LOGS pcl
         JOIN
             PERSON_CHANGE_LOGS prepcl
         ON
             prepcl.id = pcl.previous_entry_id
             AND trim(prepcl.new_value) != trim(pcl.new_value)
         JOIN
             subscriptions s
         ON
             s.owner_center = pcl.person_center
             AND s.owner_id = pcl.person_id
         CROSS JOIN
             params
         WHERE
             pcl.CHANGE_ATTRIBUTE IN ('E_MAIL',
                                      'MOB_PHONE')
             AND pcl.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND pcl.employee_id != 1
             AND pcl.ENTRY_TIME BETWEEN params.StartDateLong AND params.EndDateLong
             AND pcl.person_center IN ($$Scope$$)
             /* Member should have an active subscription during the change */
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = s.CENTER
                     AND SCL.ID = s.ID
                     AND SCL.ENTRY_TYPE = 2
                     AND SCL.STATEID IN (2,4,
                                         8)
                     AND SCL.ENTRY_START_TIME <= pcl.ENTRY_TIME
                     AND (
                         SCL.ENTRY_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME > pcl.ENTRY_TIME ) )
             /* Member shouldn't be joiner or rejoiner during time of change */
             AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = pcl.person_center
                     AND SCL.ID = pcl.person_id
                     AND SCL.ENTRY_TYPE = 5
                     AND SCL.STATEID = 2
                     AND scl.sub_state IN (1,3)
                     AND SCL.ENTRY_START_TIME <= pcl.ENTRY_TIME
                     AND (
                         SCL.ENTRY_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME > pcl.ENTRY_TIME ) )
     )
     ,
     v_transfer_mem AS
     (
         SELECT
             scl.center,
             scl.id,
             scl.employee_center || 'emp' || scl.employee_id AS Employee,
             scl.ENTRY_START_TIME
         FROM
             STATE_CHANGE_LOG SCL
         CROSS JOIN
             params
         WHERE
             scl.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND scl.employee_id != 1
             AND scl.ENTRY_START_TIME >= params.StartDateLong
             AND scl.ENTRY_START_TIME <= params.EndDateLong
             AND scl.center IN ($$Scope$$)
             AND SCL.ENTRY_TYPE = 1
             AND SCL.STATEID = 4
     )
     ,
     v_transfer AS
     (
         SELECT DISTINCT
             transfer.PersonId,
             transfer.Employee,
             'Transfer member' AS feature
         FROM
             (
                 SELECT
                     t.center || 'p' || t.id AS PersonId,
                     t.Employee,
                     longtodatec(t.ENTRY_START_TIME, scl.center) AS EntryTime,
                     scl.stateid,
                     rank() over (partition BY scl.center, scl.id ORDER BY scl.entry_start_time DESC) AS rnk
                 FROM
                     v_transfer_mem t
                 JOIN
                     STATE_CHANGE_LOG SCL
                 ON
                     scl.center = t.center
                     AND scl.id = t.id
                     AND SCL.ENTRY_TYPE = 1
                     AND scl.entry_start_time < t.entry_start_time )transfer
         WHERE
             transfer.stateid = 1
             AND transfer.rnk = 1
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
             v_bank.customercenter || 'p' || v_bank.customerid AS PersonId,
             acl.employee_center || 'emp' || acl.employee_id   AS Employee,
             'Amend bank details'                              AS feature
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
         JOIN
             state_change_log scl
         ON
             scl.center = v_bank.customercenter
             AND scl.id = v_bank.customerid
             AND scl.entry_type = 1
             AND scl.stateid = 1
             AND acl.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND acl.employee_id != 1
             AND acl.entry_time BETWEEN scl.entry_start_time AND COALESCE(scl.entry_end_time, acl.entry_time)
         WHERE
             v_bank.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
             AND v_bank.IS_CHANGE = 1
             /* Member shouldn't be joiner or rejoiner during time of change */
             AND NOT EXISTS
             (
                 SELECT
                     1
                 FROM
                     STATE_CHANGE_LOG SCL
                 WHERE
                     SCL.CENTER = v_bank.customercenter
                     AND SCL.ID = v_bank.customerid
                     AND SCL.ENTRY_TYPE = 5
                     AND SCL.STATEID = 2
                     AND scl.sub_state IN (1,3)
                     AND SCL.ENTRY_START_TIME <= acl.entry_time
                     AND (
                         SCL.ENTRY_END_TIME IS NULL
                         OR SCL.ENTRY_END_TIME > acl.entry_time ))
     )
     ,
     v_debtonline AS
     (
         SELECT
             j.person_center||'p'||j.person_id       AS PersonId,
             j.creatorcenter || 'emp' || j.creatorid AS Employee,
             'Pay debt on-line'                      AS feature
         FROM
             journalentries j
         CROSS JOIN
             params
         WHERE
             j.person_center IN ($$Scope$$)
             AND j.creatorcenter = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND j.creatorid != 1
             AND j.jetype = 3
             AND j.name IN ('Debt Payment Sage Pay', 'Debt Payment')
             AND j.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
     )
     ,
     v_bolton AS
     (
         SELECT DISTINCT
             s.owner_center || 'p' || s.owner_id                           AS PersonId,
             longtodatec(sa.creation_time, sa.center_id)                   AS creation_time,
             sa.employee_creator_center || 'emp' || sa.employee_creator_id AS Employee,
             'Add or cancel a Bolt on'                                     AS feature
         FROM
             SUBSCRIPTION_ADDON sa
         CROSS JOIN
             params
         JOIN
             masterproductregister m
         ON
             sa.addon_product_id = m.id
         JOIN
             products prod
         ON
             m.globalid = prod.globalid
         JOIN
             product_and_product_group_link pglink
         ON
             pglink.product_center = prod.center
             AND pglink.product_id = prod.id
         JOIN
             product_group pg
         ON
             pg.id = pglink.product_group_id
         JOIN
             subscriptions s
         ON
             sa.subscription_center= s.CENTER
             AND sa.subscription_id = s.id
         WHERE
             s.owner_center IN ($$Scope$$)
             AND sa.employee_creator_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND sa.employee_creator_id != 1
             AND pg.NAME IN( 'Add-ons')
             AND sa.creation_time BETWEEN params.StartDateLong AND params.EndDateLong
     )
     ,
     v_class AS
     (
         SELECT DISTINCT
             sales.owner_center || 'p' || sales.owner_id         AS PersonId,
             sales.employee_center || 'emp' || sales.employee_id AS Employee,
             'Add a course'                                      AS feature
         FROM
             SUBSCRIPTION_SALES sales
         CROSS JOIN
             params
         JOIN
             SUBSCRIPTIONS sub
         ON
             sales.SUBSCRIPTION_CENTER = sub.CENTER
             AND sales.SUBSCRIPTION_ID = sub.ID
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.center = sales.SUBSCRIPTION_TYPE_CENTER
             AND st.id = sales.SUBSCRIPTION_TYPE_ID
         JOIN
             products prod
         ON
             prod.center = st.center
             AND prod.id = st.id
         JOIN
             product_and_product_group_link pglink
         ON
             pglink.product_center = prod.center
             AND pglink.product_id = prod.id
         JOIN
             product_group pg
         ON
             pg.id = pglink.product_group_id
         WHERE
             sales.owner_center IN ($$Scope$$)
             AND sales.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND sales.employee_id != 1
             AND sales.sales_date BETWEEN params.StartDate AND params.EndDate
             AND prod.ptype IN (10)
             AND pg.name = 'Courses'
             AND sub.state IN (2,3,4,8)
         UNION
         SELECT DISTINCT
             c.owner_center || 'p' || c.owner_id         AS PersonId,
             i.employee_center || 'emp' || i.employee_id AS Employee,
             'Add a course'                              AS feature
         FROM
             INVOICES I
         CROSS JOIN
             params
         JOIN
             INVOICELINES IL
         ON
             I.CENTER=IL.CENTER
             AND I.ID=IL.ID
         JOIN
             CLIPCARDS C
         ON
             IL.CENTER=C.INVOICELINE_CENTER
             AND IL.ID=C.INVOICELINE_ID
             AND IL.SUBID=C.INVOICELINE_SUBID
         JOIN
             products prod
         ON
             prod.center = IL.PRODUCTCENTER
             AND prod.id = IL.PRODUCTID
         JOIN
             product_and_product_group_link pglink
         ON
             pglink.product_center = prod.center
             AND pglink.product_id = prod.id
         JOIN
             product_group pg
         ON
             pg.id = pglink.product_group_id
         WHERE
             prod.ptype IN (4)
             AND i.employee_center = 100
             /* Changes made by employee at center 100 and not 100emp1 */
             AND i.employee_id != 1
             AND pg.name = 'Courses'
             AND c.owner_center IN ($$Scope$$)
             AND I.TRANS_TIME BETWEEN params.StartDateLong AND params.EndDateLong
     )
     ,
     v_pin AS
     (
         SELECT
             m.center || 'p' || m.id AS PersonId,
             NULL                    AS Employee,
             'PIN Reminder'          AS feature
         FROM
             messages m
         CROSS JOIN
             params
         WHERE
             m.subject = 'PIN Reminder'
             AND m.center IN ($$Scope$$)
             AND m.senttime BETWEEN params.StartDateLong AND params.EndDateLong
     )
 SELECT
     *
 FROM
     v_sub_change_1
 UNION ALL
 SELECT
     *
 FROM
     v_freeze
 UNION ALL
 SELECT
     *
 FROM
     v_personchange
 UNION ALL
 SELECT
     *
 FROM
     v_transfer
 UNION ALL
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
     v_debtonline
 UNION ALL
 SELECT
     b.PersonId,
     b.Employee,
     b.feature
 FROM
     v_bolton b
 UNION ALL
 SELECT
     *
 FROM
     v_class
 UNION ALL
 SELECT
     *
 FROM
     v_pin
