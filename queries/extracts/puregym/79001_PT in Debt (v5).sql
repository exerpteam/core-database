-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    only_staff AS materialized
    (
        SELECT
            ps.center ,
            ps.id ,
            ps.fullname
        FROM
            persons ps
        WHERE
            ps.persontype = 2
        --AND ps.center = 2 AND ps.id = 295010
    )
    ,
    eligable_members AS materialized
    (
        SELECT DISTINCT
            p.center,
            p.id,
            p.fullname,
            /*rank(
            ) over (partition BY p.center, p.id order by (pag.SUBID = pac.ACTIVE_AGR_SUBID)::
            integer desc) AS current_pag_state_rnk,*/
            pag2.state AS current_pag_state,
            --     rank( ) over (partition BY p.center, p.id ORDER BY pag.subid DESC)
            -- AS last_failed_pag_rnk,
            last_preq.state    AS last_preq_state,
            last_preq.XFR_INFO AS last_XFR_INFO,
            last_preq.REQ_DATE AS last_REQ_DATE,
            pag.center         AS pagcenter,
            pag.id             AS pagid,
            ar.center         AS acenter,
            ar.id             AS aid,
            ar.balance ,
            cc.AMOUNT AS DebtAmount,
            c.shortname,
            last_failed_pa_msg.TEXT  AS last_failed_pa_msg_TEXT,
            last_failed_pa_msg.state AS last_failed_pag_state,
            /*CAST(last_failed_pa_msg.state != 4 AS INTEGER),
            pag.subid , last_failed_pa_msg.id ,*/
            last_failed_preq.state                                        AS last_failed_preq_state,
            rank() over (partition BY last_failed_preq.center, last_failed_preq.id ORDER BY last_failed_preq.subid desc) AS
            last_failed_preq_rnk,
            rank( ) over (partition BY p.center, p.id ORDER BY last_preq.subid DESC) AS
            last_preq_rnk,
            rank() over (partition BY pag.center, pag.id ORDER BY CAST(pag.state != 4 AS INTEGER)
            DESC , pag.subid DESC, last_failed_pa_msg.id DESC) AS last_failed_pa_msg_rnk,
            pea_email.txtvalue                                 AS EMAIL,
            pea_mobile.txtvalue                                AS MOBILE/*,
            last_failed_preq.center                                   AS last_preq_center,
            last_failed_preq.id                                       AS last_preq_id,
            last_failed_preq.subid                                    AS last_preq_subid*/
        FROM
            only_staff p
        JOIN
            CENTERS c
        ON
            p.center = c.ID
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            p.center = ar.CUSTOMERCENTER
        AND p.id = ar.CUSTOMERID
        AND ar.ar_type = 4
        JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.center = ar.center
        AND pac.id = ar.id
        LEFT JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pag.center = ar.center
        AND pag.id = ar.id
       AND pag.state != 4
        LEFT JOIN
            PAYMENT_AGREEMENTS pag1
        ON
            pag1.center = ar.center
        AND pag1.id = ar.id
            --    and pag.state != 4
        JOIN
            PAYMENT_AGREEMENTS pag2
        ON
            pag2.center = pac.ACTIVE_AGR_center
        AND pag2.id = pac.ACTIVE_AGR_id
        AND pag2.SUBID = pac.ACTIVE_AGR_SUBID
        LEFT JOIN
            AR_TRANS art
        ON
            art.center = ar.center
        AND art.id = ar.id
        AND pag2.payment_cycle_config_id = 1401
        AND art.UNSETTLED_AMOUNT < 0
        AND art.due_date < CURRENT_TIMESTAMP
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.center
        AND cc.PERSONID = p.id
        AND cc.MISSINGPAYMENT = true
        AND cc.CLOSED = false
        LEFT JOIN
            PERSON_EXT_ATTRS pea_email
        ON
            pea_email.PERSONCENTER = p.center
        AND pea_email.PERSONID = p.id
        AND pea_email.NAME = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS pea_mobile
        ON
            pea_mobile.PERSONCENTER = p.center
        AND pea_mobile.PERSONID = p.id
        AND pea_mobile.NAME = '_eClub_PhoneSMS'
        LEFT JOIN
            PAYMENT_REQUESTS last_preq
        ON
            last_preq.center = pag1.center
        AND last_preq.id = pag1.id
        LEFT JOIN
            AGREEMENT_CHANGE_LOG last_failed_pa_msg
        ON
            last_failed_pa_msg.state != 4
        AND last_failed_pa_msg.agreement_center = pag.center
        AND last_failed_pa_msg.agreement_id = pag.id
        AND last_failed_pa_msg.agreement_subid = pag.subid
            --   AND pag.state != 4
        LEFT JOIN
            PAYMENT_REQUESTS last_failed_preq
        ON
            last_failed_preq.center = pag2.center
        AND last_failed_preq.id = pag2.id
        AND last_failed_preq.state > 4
        WHERE
            cc.id IS NOT NULL
        OR  art.id IS NOT NULL
    )
    /*
SELECT
*    
FROM
    eligable_members
    where last_preq_rnk = 1
    AND last_failed_pa_msg_rnk = 1
    AND last_failed_preq_rnk = 1
    --   and last_failed_pag_rnk = 1
    ;
    */
    ,
    last_checkin AS materialized
    (
        SELECT
            c.center,
            c.id,
            MAX(last_checkin.CHECKIN_TIME) AS CHECKIN_TIME
        FROM
            eligable_members c
        LEFT JOIN
            CHECKINS last_checkin
        ON
            last_checkin.person_center = c.center
        AND last_checkin.person_id = c.id
        GROUP BY
            c.center,
            c.id
    )
SELECT
    t2.center||'p'||t2.id    MemberID,
    t2.Shortname          AS Club,
    t2.fullname           AS Member_Name,
    t2.Subscription_Names,
    t2.DebtAmount,
    t2.Balance,
    CASE last_preq_state
        WHEN 1
        THEN 'New'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Done'
        WHEN 4
        THEN 'Done, manual'
        WHEN 5
        THEN '                             
Rejected, clearinghouse'
        WHEN 6
        THEN 'Rejected, bank'
        WHEN 7
        THEN 'Rejected, debtor'
        WHEN 8
        THEN '                             
Cancelled'
        WHEN 10
        THEN 'Reversed, new'
        WHEN 11
        THEN 'Reversed, sent'
        WHEN 12
        THEN 'Failed, not creditor'
        WHEN 13
        THEN 'Reversed, rejected'
        WHEN 14
        THEN 'Reversed, confirmed'
        WHEN 17
        THEN 'Failed, payment revoked'
        WHEN 18
        THEN 'Done Partial'
        WHEN 19
        THEN 'Failed, Unsupported'
        WHEN 20
        THEN 'Require approval'
        WHEN 21
        THEN 'Fail, debt case exists'
        WHEN 22
        THEN 'Failed, timed                             
out'
    END AS Last_Payment_Request,
    CASE last_failed_preq_state
        WHEN 1
        THEN 'New'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Done'
        WHEN 4
        THEN 'Done, manual'
        WHEN 5
        THEN '                             
Rejected, clearinghouse'
        WHEN 6
        THEN 'Rejected, bank'
        WHEN 7
        THEN 'Rejected, debtor'
        WHEN 8
        THEN '                             
Cancelled'
        WHEN 10
        THEN 'Reversed, new'
        WHEN 11
        THEN 'Reversed, sent'
        WHEN 12
        THEN 'Failed, not creditor'
        WHEN 13
        THEN 'Reversed, rejected'
        WHEN 14
        THEN 'Reversed, confirmed'
        WHEN 17
        THEN 'Failed, payment revoked'
        WHEN 18
        THEN 'Done Partial'
        WHEN 19
        THEN 'Failed, Unsupported'
        WHEN 20
        THEN 'Require approval'
        WHEN 21
        THEN 'Fail, debt case exists'
        WHEN 22
        THEN 'Failed, timed                             
out'
    END AS Last_Failed_Payment_Request,
    CASE current_pag_state
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END AS Current_Payment_Agreement_State,
    CASE last_failed_pag_state
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
    END                     AS Last_Failed_Payment_Agreement_State,
    last_failed_pa_msg_TEXT AS Last_Failed_Payment_Agreement_Message,
    t2.last_XFR_INFO,
    t2.last_REQ_DATE AS PAYMENT_REQUEST_DATE,
    t2.EMAIL,
    t2.MOBILE,
    t2.Last_Checkin_Date,
    t2.Last_Open_Dates

FROM
    (
        SELECT
            eligable_members.*,
            longtodateTZ(last_checkin.CHECKIN_TIME,'Europe/London') AS Last_Checkin_Date,
            string_agg( TO_CHAR(longtodateTZ(TRANS_TIME,'Europe/London'),'YYYY-MM-DD'), ' ; '
            ORDER BY eligable_members.center, eligable_members.id) AS Last_Open_Dates,
            string_agg(DISTINCT pd.Name,' ; ')                     AS Subscription_Names
        FROM
            eligable_members
        LEFT JOIN
            last_checkin
        ON
            last_checkin.center = eligable_members.center
        AND last_checkin.id = eligable_members.id
        LEFT JOIN
            AR_TRANS art
        ON
            art.center = eligable_members.acenter
        AND art.id = eligable_members.aid
        AND art.STATUS IN ('NEW',
                           'OPEN')
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = eligable_members.center
        AND s.OWNER_ID = eligable_members.id
        AND s.state IN (2,4,8)
        LEFT JOIN
            PRODUCTS pd
        ON
            pd.center = s.SUBSCRIPTIONTYPE_CENTER
        AND pd.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            /*last_failed_pag_rnk = 1
            AND*/
            last_preq_rnk = 1
        AND last_failed_pa_msg_rnk = 1
        AND last_failed_preq_rnk = 1
        GROUP BY
            eligable_members.center,
            eligable_members.id,
            eligable_members.fullname,
            eligable_members.current_pag_state,
            eligable_members.last_failed_pag_state,
            --eligable_members.failed_pag_rnk,
            eligable_members.last_preq_state,
            eligable_members.last_xfr_info,
            eligable_members.last_req_date,
            eligable_members.last_preq_rnk,
            eligable_members.pagcenter,
            eligable_members.pagid,
            eligable_members.acenter,
            eligable_members.aid,
            eligable_members.balance,
            eligable_members.current_pag_state,
            eligable_members.debtamount,
            eligable_members.shortname,
            eligable_members.last_failed_pa_msg_text,
            --eligable_members.state,
            eligable_members.last_failed_pa_msg_rnk,
            eligable_members.last_failed_preq_state,
            eligable_members.last_failed_preq_rnk,
            eligable_members.email,
            eligable_members.mobile,
            last_checkin.CHECKIN_TIME) t2