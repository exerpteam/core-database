-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    open_invoices AS
    (
        SELECT
            MIN(t1.due_date) AS duedate ,
            t1.center ,
            t1.id
        FROM
            (
                SELECT
                    act.center||'acc'||act.id||'tr'||act.subid AS TransactionID ,
                    -act.amount                                AS amount ,
                    art.due_date ,
                    p.center ,
                    p.id
                FROM
                    evolutionwellness.account_trans act
                JOIN
                    evolutionwellness.ar_trans art
                ON
                    art.ref_center = act.center
                AND art.ref_id = act.id
                AND art.ref_subid = act.subid
                AND art.ref_type = 'ACCOUNT_TRANS'
                JOIN
                    evolutionwellness.account_receivables ar
                ON
                    ar.center = art.center
                AND ar.id = art.id
                JOIN
                    persons p
                ON
                    p.center = ar.customercenter
                AND p.id = ar.customerid
				AND p.center IN (:Scope)
                WHERE
                    art.status != 'CLOSED'
                UNION ALL
                SELECT
                    inv.center||'inv'||inv.id AS TransactionID ,
                    -invl.total_amount        AS amount ,
                    art.due_date ,
                    p.center ,
                    p.id
                FROM
                    evolutionwellness.invoices inv
                JOIN
                    evolutionwellness.invoice_lines_mt invl
                ON
                    invl.center = inv.center
                AND inv.id = invl.id
                JOIN
                    evolutionwellness.ar_trans art
                ON
                    art.ref_center = invl.center
                AND art.ref_id = invl.id
                AND art.ref_type = 'INVOICE'
                JOIN
                    persons p
                ON
                    p.center = inv.payer_center
                AND p.id = inv.payer_id
				AND p.center IN (:Scope)
                WHERE
                    art.status != 'CLOSED' )t1
        GROUP BY
            t1.center ,
            t1.id
    )
    ,
    Reject_reason AS
    (
        SELECT
			ranked.*
		FROM (
			SELECT
				pr.xfr_info AS RejectReason,
				pr.req_date,
				pr.center,
				pr.id,
				pr.subid,
				pr.req_amount,
				pr.rejected_reason_code,
				p.center AS personcenter,
				p.id AS personid,
				ROW_NUMBER() OVER (
					PARTITION BY pr.center, pr.id, p.center, p.id
					ORDER BY pr.subid DESC
				) AS rn
			FROM
				evolutionwellness.payment_agreements pag
			JOIN
				evolutionwellness.account_receivables ar
					ON ar.center = pag.center AND ar.id = pag.id
			JOIN
				evolutionwellness.persons p
					ON p.center = ar.customercenter AND p.id = ar.customerid
					AND p.center IN (:Scope)
			JOIN
				evolutionwellness.payment_requests pr
					ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
			WHERE
				pr.state IN (5, 6, 7, 8, 12, 17, 19, 21, 22)
		) ranked
		WHERE ranked.rn = 1
    )
    ,
    reject_count AS
    (
		SELECT
			p.center AS personcenter,
			p.id AS personid,
			COUNT(*) AS reject_count
		FROM
			evolutionwellness.payment_agreements pag
		JOIN
			evolutionwellness.account_receivables ar
			ON ar.center = pag.center AND ar.id = pag.id
		JOIN
			evolutionwellness.persons p
			ON p.center = ar.customercenter AND p.id = ar.customerid
			AND p.center IN (:Scope)
		JOIN
			evolutionwellness.payment_requests pr
			ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
		WHERE
			pr.state IN (5, 6, 7, 8, 12, 17, 19, 21, 22)
		GROUP BY
			p.center,
			p.id
    )
    ,
    last_access AS
    (
	SELECT 
    	ck.person_center,
    	ck.person_id,
    	longtodatec(MAX(ck.checkin_time), ck.person_center) AS last_checkin
	FROM 
 	   evolutionwellness.checkins ck
	WHERE EXISTS (
 	 	  SELECT 1
   		  FROM open_invoices oi
   		  WHERE oi.center = ck.person_center
     		  AND oi.id = ck.person_id
		     )
GROUP BY 
    ck.person_center,
    ck.person_id 
)

SELECT
    p.external_id       AS "External ID" ,
    p.center||'p'||p.id AS "Person ID" ,
    CASE
        WHEN CURRENT_DATE - open_invoices.duedate < 31
        THEN 1
        WHEN CURRENT_DATE - open_invoices.duedate > 30
        AND CURRENT_DATE - open_invoices.duedate < 61
        THEN 2
        WHEN CURRENT_DATE - open_invoices.duedate > 60
        AND CURRENT_DATE - open_invoices.duedate < 91
        THEN 3
        ELSE 4
    END                                          AS "DebtStageCode" ,
    open_invoices.duedate                        AS "Date Entered Current Debt Stage" ,
    CURRENT_DATE                                 AS "Date Report Run" ,
    cou.name                                     AS "ClubDivisionName" ,
    a.name                                       AS "ClubRegionName" ,
    c.name                                       AS "Club Name" ,
    p.firstname                                  AS "First Name" ,
    p.lastname                                   AS "Last Name" ,
    p.sex                                        AS "Gender" ,
    p.address1||' '||p.address2||' '||p.address3 AS "Address" ,
    p.zipcode                                    AS "Postcode" ,
    peeaHome.txtvalue                            AS "Home Phone Number" ,
    peeaMobile.txtvalue                          AS "Mobile Phone Number" ,
    peeaWork.txtvalue                            AS "Work Phone Number" ,
    email.txtvalue                               AS "Email Address" ,
    ''                                           AS "Last Call Update Reason" ,
    ''                                           AS "Last Call Update Date" ,
    ''                                           AS "Number of Calls in Stage" ,
    -cc.amount                                   AS "Arrears Amount" ,
    COALESCE(s.subscription_price,0) * -(
        CASE
            WHEN s.binding_end_date > CURRENT_DATE
            THEN EXTRACT(MONTH FROM AGE(NOW(), s.binding_end_date))
            ELSE 0
        END)                   AS "CCV Amount" ,
    ar.balance                 AS "Total Balance Outstanding" ,
    s.subscription_price       AS "Member Dues" ,
    Reject_reason.RejectReason AS "Original Reject Reason" ,
    Reject_reason.req_amount   AS "Last Billed Amount" ,
    Reject_reason.req_amount   AS "Latest Rejection Amount" ,
    Reject_reason.req_date     AS "Latest Reject Date" ,
    Reject_reason.rejectreason AS "Latest Reject Reason" ,
    CASE
        WHEN Reject_reason.RejectReason IN ('901 - Invalid Merchant Account',
                                            'Unknown',
                                            'Refused',
                                            'Referral',
                                            'Acquirer Error',
                                            'Expired Card',
                                            'Invalid Amount',
                                            'Insufficient Funds',
                                            'Issuer Unavailable',
                                            'Not supported',
                                            '3D Not Authenticated',
                                            'Not enough balance',
                                            'Cancelled',
                                            'Shopper Cancelled',
                                            'Invalid Pin',
                                            'Pin tries exceeded',
                                            'Pin validation not possible',
                                            'Not Submitted',
                                            'Transaction Not Permitted',
                                            'CVC Declined',
                                            'Declined Non Generic',
                                            'Withdrawal amount exceeded',
                                            'Withdrawal count exceeded',
                                            'AVS Declined',
                                            'Card requires online pin',
                                            'Authentication required',
                                            '10',
                                            '20',
                                            '21',
                                            '31',
                                            '40',
                                            '42',
                                            '43',
                                            '44',
                                            '45',
                                            '46',
                                            '47',
                                            '50',
                                            '51',
                                            '61',
                                            '70',
                                            '71',
                                            '72',
                                            '73',
                                            '74',
                                            '75',
                                            '76',
                                            '90',
                                            '99',
                                            '1010',
                                            '1042',
                                            '1051',
                                            '1070',
                                            '1074',
                                            '1100',
                                            '1101',
                                            '1102',
                                            '1106',
                                            '1107',
                                            '1114',
                                            '1161',
                                            '1162',
                                            '1163',
                                            '1164',
                                            '1165',
                                            '1166',
                                            '1168',
                                            '1169',
                                            '1170',
                                            '1171',
                                            '1172',
                                            '1181',
                                            '1200',
                                            '1202',
                                            '1203',
                                            '1205',
                                            '1206',
                                            '1207',
                                            '1208',
                                            '1209',
                                            '1211',
                                            '1212',
                                            '1213',
                                            '1214',
                                            '1215',
                                            '1216',
                                            '1217',
                                            '1218',
                                            '1219',
                                            '1237',
                                            '1238',
                                            '1239',
                                            '1242',
                                            '1243',
                                            '1245',
                                            '1248',
                                            '1251',
                                            '1252',
                                            '1253',
                                            '1255',
                                            '1257',
                                            '1258',
                                            '1259',
                                            '1260',
                                            '1262',
                                            '1267',
                                            '1909',
                                            '1930',
                                            '9800',
                                            '9801',
                                            '9803',
                                            '9807',
                                            '9811',
                                            '9812',
                                            '9813',
                                            '9814',
                                            '9828',
                                            '9844',
                                            '9875',
                                            '9876',
                                            '9877',
                                            '9888',
                                            '9899',
                                            '9902',
                                            '9903',
                                            '9904',
                                            '9905',
                                            '9906',
                                            '9909',
                                            '9913',
                                            '9946',
                                            '9947',
                                            '9950',
                                            '9951',
                                            '9964',
                                            '9965',
                                            '9966',
                                            '9967',
                                            'Acquirer Error',
                                            'Not enough balance',
                                            'Refused',
                                            '901 - Invalid Merchant Account',
                                            'Saldo tidak cukup',
                                            'SALDO TIDAK CUKUP',
                                            'Refused',
                                            'Declined Non Generic',
                                            'Not enough balance',
                                            'Withdrawal count exceeded',
                                            'Withdrawal amount exceeded',
                                            'Insufficient Funds',
                                            'Uncollected Funds',
                                            'Unknown',
                                            'Referral',
                                            'Acquirer Error',
                                            'Expired Card',
                                            'Invalid Amount',
                                            'Issuer Unavailable',
                                            'Invalid Pin',
                                            'Pin tries exceeded',
                                            'Not Submitted',
                                            'READABLE',
                                            '000 - Read timed out')
        OR  rejected_reason_code = 'Customer Buyer Arrangement Not Maintained'
        THEN 2
        WHEN rejected_reason_code IS NULL
        THEN NULL
        ELSE 1
    END                       AS "Category of Reject" ,
    reject_count.reject_count AS "Bank Reject Count" ,
    cc.startdate              AS "Arrears StartDate" ,
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Membership Status" ,
    CASE s.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING_ACTIVATION'
        WHEN 3
        THEN 'UPGRADED'
        WHEN 4
        THEN 'DOWNGRADED'
        WHEN 5
        THEN 'EXTENDED'
        WHEN 6
        THEN 'TRANSFERRED'
        WHEN 7
        THEN 'REGRETTED'
        WHEN 8
        THEN 'CANCELLED'
        WHEN 9
        THEN 'BLOCKED'
        WHEN 10
        THEN 'CHANGED'
        ELSE 'Undefined'
    END                                   AS "Payment Status" ,
    prod.name                             AS "Plan" ,
    longtodatec(s.creation_time,s.center) AS "Member Join Date" ,
    s.start_date                          AS "Contract Start Date" ,
    s.binding_end_date                    AS "Minimum Contract End Date" ,
    s.end_date                            AS "Cancellation Date",
    last_access.last_checkin              AS "Last Access Date"
FROM
    evolutionwellness.persons p
JOIN
    evolutionwellness.centers c
ON
    c.id = p.center
JOIN
    evolutionwellness.area_centers ac
ON
    ac.center = c.id
JOIN
    evolutionwellness.areas a
ON
    a.id = ac.area
AND a.root_area = 99 --reporting scope tree
JOIN
    evolutionwellness.countries cou
ON
    cou.id = c.country
LEFT JOIN
    evolutionwellness.person_ext_attrs peeaMobile
ON
    peeaMobile.personcenter = p.center
AND peeaMobile.personid = p.id
AND peeaMobile.name = '_eClub_PhoneSMS'
JOIN
    evolutionwellness.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    evolutionwellness.cashcollectioncases cc
ON
    cc.personcenter = p.center
AND cc.personid = p.id
AND cc.closed IS FALSE
AND cc.missingpayment IS TRUE
LEFT JOIN
    evolutionwellness.person_ext_attrs email
ON
    email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    evolutionwellness.subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (1,2,4,7,8)
LEFT JOIN
    evolutionwellness.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
LEFT JOIN
    evolutionwellness.products prod
ON
    prod.center = st.center
AND prod.id = st.id
JOIN
    open_invoices
ON
    open_invoices.center = p.center
AND open_invoices.id = p.id
LEFT JOIN
    Reject_reason
ON
    Reject_reason.personcenter = p.center
AND Reject_reason.personid = p.id
LEFT JOIN
    reject_count
ON
    reject_count.personcenter = p.center
AND reject_count.personid = p.id
LEFT JOIN
    last_access
ON
    last_access.person_center = p.center
    AND last_access.person_id = p.id
LEFT JOIN
    evolutionwellness.person_ext_attrs peeaHome
ON
    peeaHome.personcenter = p.center
AND peeaHome.personid = p.id
AND peeaHome.name = '_eClub_PhoneHome'
LEFT JOIN
    evolutionwellness.person_ext_attrs peeaWork
ON
    peeaWork.personcenter = p.center
AND peeaWork.personid = p.id
AND peeaWork.name = '_eClub_PhoneWork'
WHERE
    ar.balance < 0
AND cc.closed IS FALSE
AND p.sex != 'C'
AND p.center IN (:Scope)