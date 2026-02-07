 SELECT
     t2.personcenter||'p'||t2.personid MemberID,
     t2.Club,
     t2.Member_Name,
     string_agg(pd.Name,' ; ' ORDER BY t2.personcenter, t2.personid) as Subscription_Names,
     t2.DebtAmount,
     t2.Balance,
     t2.Last_Payment_Request,
     t2.Last_Failed_Payment_Request,
     t2.Current_Payment_Agreement_State,
     t2.Last_Failed_Payment_Agreement_State,
     t2.Last_Failed_Payment_Agreement_Message,
     t2.last_XFR_INFO,
     t2.last_REQ_DATE AS PAYMENT_REQUEST_DATE,
     t2.EMAIL,
     t2.MOBILE,
     t2.Last_Checkin_Date,
     t2.Last_Open_Dates
 FROM
 (

WITH
    only_staff AS materialized
    (
        SELECT
            ps.center AS personcenter,
            ps.id     AS personid,
            ps.fullname,
            c.SHORTNAME,
            pea_email.txtvalue as EMAIL,
            pea_mobile.txtvalue as MOBILE
        FROM
            persons ps
        JOIN
            CENTERS c
        ON
            ps.center = c.ID
        LEFT JOIN
            PERSON_EXT_ATTRS pea_email
        ON
            pea_email.PERSONCENTER = ps.center
        AND pea_email.PERSONID = ps.id
        AND pea_email.NAME = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS pea_mobile
        ON
            pea_mobile.PERSONCENTER = ps.center
        AND pea_mobile.PERSONID = ps.id
        AND pea_mobile.NAME = '_eClub_PhoneSMS'
        WHERE
            ps.persontype = 2
    )
    ,
    eligable_members AS materialized
    (
        SELECT DISTINCT
            p.personcenter,
            p.personid,
            p.fullname,
            pag.center AS pagcenter,
            pag.id     AS pagid,
            art.center    acenter,
            art.id        aid,
            ar.balance ,
            pag.state AS current_pag_state,
            cc.AMOUNT AS DebtAmount,
            p.shortname,
            p.email,
            p.mobile
        FROM
            only_staff p
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            p.personcenter = ar.CUSTOMERCENTER
        AND p.personid = ar.CUSTOMERID
        AND ar.ar_type = 4
        JOIN
            PAYMENT_ACCOUNTS pac
        ON
            pac.center = ar.center
        AND pac.id = ar.id
        JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pag.center = pac.ACTIVE_AGR_center
        AND pag.id = pac.ACTIVE_AGR_id
        AND pag.SUBID = pac.ACTIVE_AGR_SUBID
        JOIN
            AR_TRANS art
        ON
            art.center = ar.center
        AND art.id = ar.id
        LEFT JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.PERSONCENTER = p.personcenter
        AND cc.PERSONID = p.personid
        AND cc.MISSINGPAYMENT = true
        AND cc.CLOSED = false
        WHERE
            cc.id IS NOT NULL
        OR  (
                pag.payment_cycle_config_id = 1401
            AND art.UNSETTLED_AMOUNT < 0
            AND art.due_date < CURRENT_TIMESTAMP )
    )
    ,
    base3 AS materialized
    (
        SELECT
            c.*,
            last_failed_pag.state                                     AS last_failed_pag_state,
            last_failed_pag.center                                    AS last_failed_pag_center,
            last_failed_pag.id                                        AS last_failed_pag_id,
            last_failed_pag.subid                                     AS last_failed_pag_subid,
            rank() over (partition BY center, id ORDER BY subid DESC) AS rnk3
        FROM
            eligable_members c
        LEFT JOIN
            payment_agreements last_failed_pag
        ON
            c.pagcenter = last_failed_pag.center
        AND c.pagid = last_failed_pag.id
        AND last_failed_pag.state != 4
    )
    ,
    base4 AS materialized
    (
        SELECT
            b.*,
            last_preq.state                                           AS last_preq_state,
            last_preq.XFR_INFO                                        AS last_XFR_INFO,
            last_preq.REQ_DATE                                        AS last_REQ_DATE,
            rank() over (partition BY center, id ORDER BY subid DESC) AS rnk4
        FROM
            base3 b
        LEFT JOIN
            PAYMENT_REQUESTS last_preq
        ON
            last_preq.center = b.pagcenter
        AND last_preq.id = b.pagid
        WHERE
            b.rnk3 = 1
    )
    ,
    base5 AS materialized
    (
        SELECT
            c.*,
            last_checkin.PERSON_CENTER,
            last_checkin.PERSON_ID,
            last_checkin.CHECKIN_TIME,
            rank() over (partition BY last_checkin.person_center,last_checkin.person_id ORDER BY
            last_checkin.CHECKIN_TIME DESC) AS rnk5
        FROM
            base4 c
        LEFT JOIN
            CHECKINS last_checkin
        ON
            last_checkin.person_center = c.personcenter
        AND last_checkin.person_id = c.personid
        WHERE
            rnk4 = 1
    )
    ,
    base6 AS materialized
    (
        SELECT
            b.*,
            last_failed_pa_msg.agreement_center,
            last_failed_pa_msg.agreement_id,
            last_failed_pa_msg.agreement_subid,
            last_failed_pa_msg.TEXT AS last_failed_pa_msg_TEXT,
            last_failed_pa_msg.state,
            rank() over (partition BY agreement_center, agreement_id ORDER BY id DESC) AS rnk6
        FROM
            base5 b
        LEFT JOIN
            AGREEMENT_CHANGE_LOG last_failed_pa_msg
        ON
            last_failed_pa_msg.state != 4
        AND last_failed_pa_msg.agreement_center = last_failed_pag_center
        AND last_failed_pa_msg.agreement_id = last_failed_pag_id
        AND last_failed_pa_msg.agreement_subid = last_failed_pag_subid
        WHERE
            rnk5 =1
    )
    ,
    base7 AS materialized
    (
        SELECT
            b.*,
            last_failed_preq.state AS last_failed_preq_state,
            last_failed_preq.XFR_INFO,
            last_failed_preq.REQ_DATE,
            rank() over (partition BY center, id ORDER BY subid DESC) AS rnk7
        FROM
            base6 b
        LEFT JOIN
            PAYMENT_REQUESTS last_failed_preq
        ON
            last_failed_preq.center = b.pagcenter
        AND last_failed_preq.id = b.pagid
        AND last_failed_preq.state > 4 
        WHERE
            b.rnk6 = 1
    )
    ,
    base8 AS
    (
        SELECT
            art.center,
            art.id,
            art.TRANS_TIME,
            d.*
        FROM
            base7 d
        LEFT JOIN
            AR_TRANS art
        ON
            art.center = d.acenter
        AND art.id = d.aid
        AND art.STATUS IN ('NEW',
                           'OPEN')
        where rnk7 = 1
    )
SELECT
    personcenter,
    personid,
    Shortname AS Club,
    fullname  AS Member_Name,
    DebtAmount,
    Balance,
    CASE last_preq_state WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN '
                             Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN '
                             Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed, sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported'
                              WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed
                             out' END as Last_Payment_Request,
    CASE last_failed_preq_state WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN '
                             Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN '
                             Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed, sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported'
                              WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed
                             out' END as Last_Failed_Payment_Request,
    CASE current_pag_state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN  'Signature missing'  ELSE 'UNDEFINED' END AS Current_Payment_Agreement_State,
    CASE last_failed_pag_state WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN  'Signature missing' END AS Last_Failed_Payment_Agreement_State,
    
    last_XFR_INFO,
    last_REQ_DATE,
    last_failed_pa_msg_TEXT  AS Last_Failed_Payment_Agreement_Message,
    EMAIL,
    MOBILE,
    longtodateTZ(CHECKIN_TIME,'Europe/London') AS Last_Checkin_Date,
    string_agg( TO_CHAR(longtodateTZ(TRANS_TIME,'Europe/London'),'YYYY-MM-DD'), ' ; '  ORDER BY personcenter, personid) AS Last_Open_Dates
FROM
    base8 
GROUP BY
    personcenter,
    personid,
    Shortname,
    fullname,
    DebtAmount,
    Balance,
    last_preq_state,
    last_failed_preq_state,
    current_pag_state,
    last_failed_pag_state,
    last_XFR_INFO,
    last_REQ_DATE,
    email,
    mobile,
    CHECKIN_TIME,
    last_failed_pa_msg_TEXT    
) t2
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = t2.personcenter
 AND s.OWNER_ID = t2.personid
 AND s.state IN (2,4,8)
 LEFT JOIN
     PRODUCTS pd
 ON
     pd.center = s.SUBSCRIPTIONTYPE_CENTER
 AND pd.id = s.SUBSCRIPTIONTYPE_ID
 GROUP BY
     t2.personcenter,
     t2.personid,
     t2.Club,
     t2.Member_Name,
     t2.DebtAmount,
     t2.Balance,
     t2.Last_Payment_Request,
     t2.Last_Failed_Payment_Request,
     t2.Current_Payment_Agreement_State,
     t2.Last_Failed_Payment_Agreement_State,
     t2.last_XFR_INFO,
     t2.last_REQ_DATE,
     t2.EMAIL,
     t2.MOBILE,
     t2.Last_Checkin_Date,
     t2.Last_Open_Dates,
     t2.Last_Failed_Payment_Agreement_Message
    