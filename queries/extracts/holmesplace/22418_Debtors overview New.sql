
SELECT
    p.center ||'p'|| p.id as "_eClub_PERSON_ID",
	c.name as "Center Name",
    p.fullname ,
    mobile_phone.TXTVALUE AS mobile_phone,
    CASE
        WHEN home_phone.TXTVALUE IS NOT NULL
        THEN home_phone.TXTVALUE
        ELSE work_phone.TXTVALUE
    END                                                                                                                                                               other_phone,
    email.TXTVALUE                                                                                                                                                    e_mail,
CASE
        WHEN p.ADDRESS2 IS NOT NULL
        THEN p.ADDRESS1 || ', ' || p.ADDRESS2
        ELSE p.ADDRESS1
    END Street,
    p.ZIPCODE zipcode,
    p.CITY city,
    
    case p.status
        when 0 then 'lead'
        when 1 then 'active'
        when 2 then 'inactive'
        when 3 then 'temp inactive'
        when 4 then 'transferred'
        when 5 then 'duplicate'
        when 6 then 'prospect'
        when 7 then 'blocked'
        when 8 then 'anonymized'
        when 9 then 'contact'
        else 'undefined'
    end as Member_Status,
    CASE
        WHEN cc.amount IS NOT NULL
        THEN cc.amount
        ELSE (sum_unsettled.unsettledamount*-1)
    END                                                                                                                                     AS OverdueDebt,
    ar.balance                                                                                                                                                     AS CurrentBalance,
sum_unsettled.unsettledamount as balance_overdue_amount,
closestdue.last_due as latest_due_date,
CASE
        WHEN cc.STARTDATE IS NOT NULL
        THEN cc.STARTDATE
        ELSE closedcc.maxstartdate
    END AS startdate,   
    TO_CHAR(longtodate(m_warn1.SENTTIME), 'DD.MM.YYYY')                                                AS Warning_1st_Date ,
    CASE m_warn1.DELIVERYMETHOD
       WHEN 0 THEN 'STAFF'
       WHEN 1 THEN 'EMAIL'
       WHEN 2 THEN 'SMS'
       WHEN 5 THEN 'LETTER'
       WHEN NULL THEN NULL
       ELSE 'OTHER'
    END AS Warning_1st_Channel,
    TO_CHAR(longtodate(m_warn2.SENTTIME), 'DD.MM.YYYY')                                                AS Warning_2nd_Date ,
    
    CASE m_warn2.DELIVERYMETHOD
        WHEN  0 THEN 'STAFF'
        WHEN  1 THEN 'EMAIL'
        WHEN  2 THEN 'SMS'
        WHEN  5 THEN 'LETTER'
        WHEN  NULL THEN NULL
        ELSE 'OTHER'
    END  AS Warning_2st_Channel,
    debt_call_1.txtvalue                                                                               AS DebtCall_1,
    debt_call_2.txtvalue                                                                               AS DebtCall_2,
    debt_call_3.txtvalue                                                                               AS DebtCall_3,
    debtComment.txtvalue                                                                               AS DebtComment,
    MT_SALESMAN.txtvalue                                                                               AS MT_SALESMAN,
    	debtstatus.txtvalue
AS	StatusDebtor,
    p.BLACKLISTED,
    CASE
        WHEN active_agr_ch.id IS NOT NULL
        THEN active_agr_ch.NAME
        ELSE 'MISSING'
    END AS CurrentAgreementType,
    active_agr.ref,
    CASE
        WHEN active_agr.center IS NOT NULL
        THEN CASE active_agr.state 
                 WHEN 4 THEN 'OK'
                 WHEN 3 THEN 'OK'
                 WHEN 13 THEN 'OK'
                 WHEN 16 THEN 'OK'
                 WHEN 14 THEN 'INCOMPLETE'
                 ELSE 'INVALID'
              END   
        ELSE 'MISSING'
    END                                    AS CurrentAgreementState,
    last_file_sentpayment_request.req_date AS LastRejectionDate,
    last_file_sentpayment_request.ch_name  AS LastRejectionType,
    last_file_sentpayment_request.xfr_info AS LastRejectionReason,
    last_payment_request.req_date          AS LastPaymentRequestDate,
    CASE
        WHEN last_payment_request.state = 12
        THEN 'Invalid agreement'
        ELSE last_payment_request.ch_name
    END AS LastPaymentRequestType
FROM
    PERSONS p
JOIN
    centers c
ON 
    c.id = p.center	
left JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.center
    AND cc.personid = p.id
    AND cc.CLOSED = 0
    AND cc.MISSINGPAYMENT = 1
LEFT JOIN
    HP.MESSAGES m_warn1
ON
    m_warn1.CENTER = p.center
    AND m_warn1.id = p.id
    AND m_warn1.REFERENCE = cc.center || 'ccol' || cc.id
    AND m_warn1.TEMPLATETYPE = 13
	AND NOT EXISTS
    (
        SELECT
            1
        FROM
            HP.MESSAGES warn1
        WHERE
            warn1.CENTER = m_warn1.CENTER
        AND warn1.id = m_warn1.id
        AND warn1.REFERENCE = m_warn1.REFERENCE
        AND warn1.TEMPLATETYPE = m_warn1.TEMPLATETYPE
        AND warn1.SENTTIME < m_warn1.SENTTIME)
LEFT JOIN
    HP.MESSAGES m_warn2
ON
    m_warn2.CENTER = p.center
    AND m_warn2.id = p.id
    AND m_warn2.REFERENCE = cc.center || 'ccol' || cc.id
    AND m_warn2.TEMPLATETYPE = 67
LEFT JOIN
    PERSON_EXT_ATTRS home_phone
ON
    home_phone.PERSONCENTER=p.center
    AND home_phone.PERSONID=p.id
    AND home_phone.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS work_phone
ON
    work_phone.PERSONCENTER=p.center
    AND work_phone.PERSONID=p.id
    AND work_phone.name='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS mobile_phone
ON
    mobile_phone.PERSONCENTER=p.center
    AND mobile_phone.PERSONID=p.id
    AND mobile_phone.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS MT_SALESMAN
ON
    MT_SALESMAN.PERSONCENTER=p.center
    AND MT_SALESMAN.PERSONID=p.id
    AND MT_SALESMAN.name='MT_SALESMAN'
LEFT JOIN
    PERSON_EXT_ATTRS debt_call_1
ON
    debt_call_1.PERSONCENTER=p.center
    AND debt_call_1.PERSONID=p.id
    AND debt_call_1.name='COMM_1.DEBT CALL'
LEFT JOIN
    PERSON_EXT_ATTRS debt_call_2
ON
    debt_call_2.PERSONCENTER=p.center
    AND debt_call_2.PERSONID=p.id
    AND debt_call_2.name='COMM_2.DEBT CALL'
LEFT JOIN
    PERSON_EXT_ATTRS debt_call_3
ON
    debt_call_3.PERSONCENTER=p.center
    AND debt_call_3.PERSONID=p.id
    AND debt_call_3.name='COMM_3.DEBT CALL'
LEFT JOIN
    PERSON_EXT_ATTRS debtComment
ON
    debtComment.PERSONCENTER=p.center
    AND debtComment.PERSONID=p.id
    AND debtComment.name='COMM_DEBT Comment'
LEFT JOIN
    PERSON_EXT_ATTRS OldDebtStatus
ON
    oldDebtStatus.PERSONCENTER=p.center
    AND oldDebtStatus.PERSONID=p.id
    AND oldDebtStatus.name='OLD debt status'
LEFT JOIN
    PERSON_EXT_ATTRS debtstatus
ON
    debtstatus.PERSONCENTER=p.center
    AND debtstatus.PERSONID=p.id
    AND debtstatus.name='STATUS_DEBTOR'

JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    ar.customerCENTER = p.CENTER
    AND ar.customerID = p.ID
    AND ar.AR_TYPE = 4
    AND ar.state = 0
left join
( Select
ar2.center,
ar2.id,
sum(art.unsettled_amount) as unsettledamount
from
ACCOUNT_RECEIVABLES ar2
join
 ar_trans  art 
on 
ar2.center = art.center
and
ar2.id = art.id
and
due_date < current_date
group by
ar2.center,
ar2.id ) sum_unsettled
on 
ar.center = sum_unsettled.center
and
ar.id = sum_unsettled.id

left join
( Select
ar3.center,
ar3.id,
max(art3.due_date) as last_due
from
ACCOUNT_RECEIVABLES ar3
join
 ar_trans  art3 
on
ar3.center = art3.center
and
ar3.id = art3.id
and
due_date < current_date
-- and unsettled_amount > 0
group by
ar3.center,
ar3.id ) closestdue
on 
ar.center = closestdue.center
and
ar.id = closestdue.id


left JOIN
(select
cc2.personcenter,
cc2.personid,
max(cc2.startdate) as maxstartdate

from
    CASHCOLLECTIONCASES cc2
where
    cc2.CLOSED = 1
group by
cc2.personcenter,
cc2.personid ) closedcc
on
closedcc.personcenter = p.center
and
closedcc.personid = p.id

LEFT JOIN
    HP.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.center
    AND pac.id = ar.id
LEFT JOIN
    HP.PAYMENT_AGREEMENTS active_agr
ON
    active_agr.CENTER = pac.ACTIVE_AGR_CENTER
    AND active_agr.ID = pac.ACTIVE_AGR_ID
    AND active_agr.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    HP.CLEARINGHOUSES active_agr_ch
ON
    active_agr.CLEARINGHOUSE = active_agr_ch.ID
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.id,
            pr.state,
            ch.name AS ch_name,
            pr.REQ_DATE,
            pr.XFR_DATE,
            pr.XFR_INFO
        FROM
            HP.PAYMENT_REQUESTS pr
        JOIN
            HP.CLEARINGHOUSES ch
        ON
            pr.CLEARINGHOUSE_ID = ch.id
        WHERE
            pr.REQUEST_TYPE IN (1,6)
            AND pr.state NOT IN (1,2)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.PAYMENT_REQUESTS pr2
                WHERE
                    pr2.center = pr.center
                    AND pr2.id = pr.id
                    AND pr2.request_type IN (1,6)
                    AND pr2.state NOT IN (1,2)
                    AND pr2.subid > pr.subid ) ) last_payment_request
ON
    last_payment_request.center = ar.center
    AND last_payment_request.id = ar.id
LEFT JOIN
    (
        SELECT
            pr.center,
            pr.id,
            pr.state,
            ch.name AS ch_name,
            pr.REQ_DATE,
            pr.XFR_DATE,
            pr.XFR_INFO
        FROM
            HP.PAYMENT_REQUESTS pr
        JOIN
            HP.CLEARINGHOUSES ch
        ON
            pr.CLEARINGHOUSE_ID = ch.id
        WHERE
            pr.REQUEST_TYPE IN (1,6)
            AND pr.state NOT IN (1,2,3,4)
            AND pr.REQ_DELIVERY IS NOT NULL
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    HP.PAYMENT_REQUESTS pr2
                WHERE
                    pr2.center = pr.center
                    AND pr2.id = pr.id
                    AND pr2.request_type IN (1,6)
                    AND pr2.state NOT IN (1,2,3,4)
                    AND pr2.REQ_DELIVERY IS NOT NULL
                    AND pr2.subid > pr.subid ) ) last_file_sentpayment_request
ON
    last_file_sentpayment_request.center = ar.center
    AND last_file_sentpayment_request.id = ar.id
WHERE
    p.center IN (:scope)
    
and sum_unsettled.unsettledamount < 0
 