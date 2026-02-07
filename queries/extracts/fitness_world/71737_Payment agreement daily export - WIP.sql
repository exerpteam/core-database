-- This is the version from 2026-02-05
-- EC-2819
WITH
    PARAMS AS
    (
        SELECT
/*+ materialize */
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE)-:offset, 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen') AS
            FROMDATE, --midnight yesterday
            datetolongTZ(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen') AS
            TODATE --midnight today
        FROM
            dual
    )
SELECT
    p.External_ID                                                   AS "External ID" ,
    TO_CHAR(longtodatec(pa.creation_time, pa.center), 'dd.mm.yyyy') AS "Latest Pa",
    CASE
        WHEN cc.closed IS NOT NULL
        THEN 'Manglende aftale'
        ELSE NULL
    END AS "Missing agreement case" ,
    CASE
        WHEN pa.STATE = 1
        THEN 'Created'
        WHEN pa.STATE = 2
        THEN 'Sent'
        WHEN pa.STATE = 3
        THEN 'Failed'
        WHEN pa.STATE = 4
        THEN 'OK'
        WHEN pa.STATE = 5
        THEN 'Ended = bank'
        WHEN pa.STATE = 6
        THEN 'Ended = clearing house'
        WHEN pa.STATE = 7
        THEN 'Ended = debtor'
        WHEN pa.STATE = 8
        THEN 'Cancelled = not sent'
        WHEN pa.STATE = 9
        THEN 'Cancelled = sent'
        WHEN pa.STATE = 10
        THEN 'Ended = creditor'
        WHEN pa.STATE = 11
        THEN 'No agreement'
        WHEN pa.STATE = 12
        THEN 'Cash payment (deprecated)'
        WHEN pa.STATE = 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN pa.STATE = 14
        THEN 'Agreement information incomplete'
        WHEN pa.STATE = 15
        THEN 'Transfer'
        WHEN pa.STATE = 16
        THEN 'Agreement Recreated'
        WHEN pa.STATE = 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                       AS "PA status",
    pa.Creditor_ID                            AS "Clearing house",
    TO_CHAR(pa.Expiration_Date, 'dd.mm.yyyy') AS "Card expiry date",
    CASE
        WHEN rop.center IS NOT NULL
        THEN 'IS_OTHER_PAYER'
        WHEN rnp.relativeCENTER IS NOT NULL
        THEN 'HAS_OTHER_PAYER'
        ELSE 'NO'
    END AS "Other payer",
   
CASE --show refusal reason
        WHEN pa.state IN ('3',
                          '5',
                          '6',
                          '7',
                          '8',
                          '9',
                          '10',
                          '11')
        THEN
            CASE
                WHEN pa.state=acl.state AND acl.text NOT IN ('Standard','Transfer','Default')
                THEN acl.text
                ELSE pa.ENDED_REASON_TEXT
            END
    END AS "PA"
FROM
    PARAMS,
    Payment_agreements pa
JOIN
    Account_receivables ar
ON
    ar.center = pa.center
AND ar.id = pa.id
AND ar.ar_type=4
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND p.status NOT IN ('7',
                     '8',
                     '4',
                     '5') --not deleted, anonymized, transferred, duplicate
AND p.center IN (:scope)
LEFT JOIN
    cashcollectioncases cc --find open missing agrement cases
ON
    cc.personid=p.id
AND cc.personcenter= p.center
AND cc.closed=0
AND Missingpayment=0
LEFT JOIN
    (
        SELECT DISTINCT
            center,
            id
        FROM
            Relatives
        WHERE
            RTYPE = 12
        AND STATUS = 1 ) rop --find other payer
ON
    p.CENTER = rop.CENTER
AND p.id = rop.id
LEFT JOIN
    (
        SELECT DISTINCT
            relativeCENTER,
            relativeid
        FROM
            Relatives
        WHERE
            RTYPE = 12
        AND STATUS = 1 ) rnp --find payed for
ON
    p.CENTER = rnp.relativeCENTER
AND p.id = rnp.relativeid
JOIN
    (
        SELECT
            text,
            agreement_center,
            agreement_id,
            agreement_subid,
            ROW_NUMBER() OVER (PARTITION BY agreement_center, agreement_id, agreement_subid
            ORDER BY entry_time DESC) ranked,
			entry_time,
			state
        FROM
            agreement_change_log ) acl
ON
    pa.center=acl.agreement_center
AND pa.id=acl.agreement_id
AND pa.subid=acl.agreement_subid
WHERE
    pa.active=1 -- only active payment agreement
AND acl.entry_time >= PARAMS.FROMDATE
AND acl.entry_time < PARAMS.TODATE
AND acl.ranked= 1