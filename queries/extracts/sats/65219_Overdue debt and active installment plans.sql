WITH
    v_debt_cust AS
    (
        SELECT
            ar.customercenter,
            ar.customerid,
            ar.customercenter || 'p' || ar.customerid AS PersonId,
            SUM(art.unsettled_amount)                 AS Total_Ext_Debt
        FROM
            ACCOUNT_RECEIVABLES ar
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
            ar.customercenter IN ($$Scope$$)
            AND ar.AR_TYPE = 5
            AND art.DUE_DATE < exerpsysdate()
            AND ccc.currentstep_type = $$Debt_Step_Type$$
            AND ccc.currentstep_date BETWEEN $$From_Date$$ AND $$To_Date$$
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    sats.installment_plans ip
                WHERE
                    ip.person_center = ar.customercenter
                    AND ip.person_id = ar.customerid
                    AND ip.end_date > exerpsysdate())
        GROUP BY
            ar.customercenter,
            ar.customerid
    )
    ,
    v_install_bal AS
    (
        SELECT
            ar.customercenter,
            ar.customerid,
            SUM(art.amount)   AS Total_Inst_Bal,
            MAX(art.due_date) AS Last_Due_Date
        FROM
            ACCOUNT_RECEIVABLES ar
        JOIN
            v_debt_cust v_debt
        ON
            v_debt.customercenter = ar.customercenter
            AND v_debt.customerid = ar.customerid
        JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
            AND ar.AR_TYPE = 6
        WHERE
            art.status != 'CLOSED'
            AND art.DUE_DATE > exerpsysdate()
        GROUP BY
            ar.customercenter,
            ar.customerid
    )
SELECT
    cust.PersonId                                                 AS "Member Id",
    per.external_id                                               AS "External Id",
    per.fullname                                                  AS "Full Name",
    pag.ref                                                       AS "Agreement Ref",
    email.txtvalue                                                AS "Email Address",
    mobile.txtvalue                                               AS "Phone Number",
    pd.name                                                       AS "Clipcard Name",
    TO_CHAR(longtodatec(cc.valid_until, cc.center), 'YYYY-MM-DD') AS "Clip card Expiry date",
    cc.clips_left                                                 AS "Remaining Clips",
    (cc.clips_initial-cc.clips_left)                              AS "Clips Used",
    cust.Total_Ext_Debt                                           AS "Total External Debt",
    TO_CHAR(ccc.startdate, 'YYYY-MM-DD')                          AS "Debt case start date",
    TO_CHAR(ccc.currentstep_date, 'YYYY-MM-DD')                   AS "Current step start date",
    inst_bal.Total_Inst_Bal                                       AS "Installment plan balance",
    TO_CHAR(inst_bal.Last_Due_Date, 'YYYY-MM-DD')                 AS "Last Installment stop",
    assign_staff.fullname                                         AS "Clipcard assign staff",
    clipc.name                                                    AS "Sold at"
FROM
    v_debt_cust cust
JOIN
    PERSONS per
ON
    per.center = cust.customercenter
    AND per.id = cust.customerid
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.customercenter = per.center
    AND ar.customerid = per.id
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
JOIN
    clipcards cc
ON
    cc.owner_center = per.center
    AND cc.owner_id = per.id
    AND cc.finished = 0
    AND cc.cancelled = 0
    AND cc.BLOCKED = 0
    AND cc.clips_left > 0
JOIN
    centers clipc
ON
    clipc.id = cc.center
JOIN
    CLIPCARDTYPES ct
ON
    ct.center = cc.center
    AND ct.id = cc.id
JOIN
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
    v_install_bal inst_bal
ON
    per.center = inst_bal.customercenter
    AND per.id = inst_bal.customerid
LEFT JOIN
    sats.PERSONS assign_staff
ON
    assign_staff.center = cc.assigned_staff_center
    AND assign_staff.id = cc.assigned_staff_id