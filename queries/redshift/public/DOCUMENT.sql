SELECT
    je.id AS "ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE
        WHEN P.SEX = 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END              AS "COMPANY_ID",
    je.CREATION_TIME AS "CREATION_DATETIME",
    UPPER(
        CASE
            WHEN JE.JETYPE =1
            THEN 'SUBSCRIPTION_CONTRACT'
            WHEN JE.JETYPE =2
            THEN 'DOCUMENTATION'
            WHEN JE.JETYPE =3
            THEN 'NOTE'
            WHEN JE.JETYPE =8
            THEN 'STATUS'
            WHEN JE.JETYPE =11
            THEN 'PAYMENT_AGREEMENT_CONTRACT'
            WHEN JE.JETYPE =12
            THEN 'CASHOUT'
            WHEN JE.JETYPE =13
            THEN 'FREEZE_CREATION'
            WHEN JE.JETYPE =14
            THEN 'FREEZE_CANCELLATION'
            WHEN JE.JETYPE =15
            THEN 'FREEZE_CHANGE'
            WHEN JE.JETYPE =16
            THEN 'OTHER_PAYER_START'
            WHEN JE.JETYPE =17
            THEN 'OTHER_PAYER_STOP'
            WHEN JE.JETYPE =18
            THEN 'SUBSCRIPTION_TERMINATION'
            WHEN JE.JETYPE =19
            THEN 'SUBSCRIPTION_TERMINATION_CANCELLATION'
            WHEN JE.JETYPE =20
            THEN 'PAYMENT_NOTE'
            WHEN JE.JETYPE =21
            THEN 'ACCOUNT_PAYMENT_NOTE'
            WHEN JE.JETYPE = 22
            THEN 'SAVED_FREE_DAYS_USE'
            WHEN JE.JETYPE =23
            THEN 'FREE_PERIOD_ASSIGNMENT'
            WHEN JE.JETYPE = 24
            THEN 'FREE_PERIOD_CANCELLATION'
            WHEN JE.JETYPE =25
            THEN 'CASH_ACCOUNT_CREDIT'
            WHEN JE.JETYPE =26
            THEN 'ADDON_TERMINATION'
            WHEN JE.JETYPE =27
            THEN 'ADDON_TERMINATION_CANCELLATION'
            WHEN JE.JETYPE =28
            THEN 'CHILD_RELATION_CONTRACT'
            WHEN JE.JETYPE =29
            THEN 'DOCTOR_NOTE'
            WHEN JE.JETYPE =30
            THEN 'ADDON_CONTRACT'
            WHEN JE.JETYPE =31
            THEN 'HEALTH_CERTIFICATE'
            WHEN JE.JETYPE =32
            THEN 'CREDITCARD_AGREEMENT_CONTRACT'
            WHEN JE.JETYPE =33
            THEN 'CLIPCARD_BUYOUT'
            WHEN JE.JETYPE =34
            THEN 'CLIPCARD_CONTRACT'
            WHEN JE.JETYPE =35
            THEN 'REASSIGN_SUBSCRIPTION_CONTRACT'
            WHEN JE.JETYPE =36
            THEN 'AGGREGATED_SUBSCRIPTION_CONTRACT'
            WHEN JE.JETYPE =37
            THEN 'FREE_PERIOD_CHANGE'
            ELSE 'UNKNOWN'
        END) AS "TYPE",
    je.NAME  AS "SUBJECT",
    CASE WHEN je.text IS NOT NULL THEN je.text
      WHEN je.big_text IS NOT NULL AND LENGTH(je.big_text) < 65535 
	  THEN REGEXP_REPLACE(convert_from(je.big_text, 'UTF-8'), '\n', ' ', 'g')
      ELSE null
    END AS "DETAILS",
    CASE
        WHEN (staff.CENTER != staff.TRANSFERS_CURRENT_PRS_CENTER
                OR staff.id != staff.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = staff.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = staff.TRANSFERS_CURRENT_PRS_ID)
        ELSE staff.EXTERNAL_ID
    END AS "CREATOR_PERSON_ID",
    CAST(
        CASE
            WHEN je.SIGNABLE = 1
            THEN 1
            ELSE 0
        END AS SMALLINT) AS "REQUIRE_SIGNATURE",
    CAST(
        CASE
            WHEN je.SIGNABLE = 1
            THEN
                (
                    SELECT
                        COUNT(*)
                    FROM
                        journalentry_signatures jes
                    WHERE
                        jes.journalentry_id = je.id
                        AND jes.signature_center IS NOT NULL)
            ELSE 0
        END AS INTEGER) AS "SIGNATURES_SIGNED" ,
    CAST(
        CASE
            WHEN je.SIGNABLE = 1
            THEN
                (
                    SELECT
                        COUNT(*)
                    FROM
                        journalentry_signatures jes
                    WHERE
                        jes.journalentry_id = je.id
                        AND jes.signature_center IS NULL)
            ELSE 0
        END AS INTEGER) AS "SIGNATURES_MISSING" ,
    CASE
        WHEN je.SIGNABLE = 1
        THEN
            (
                SELECT
                    MAX(sig.creation_time)
                FROM
                    journalentry_signatures jes
                JOIN
                    signatures sig
                ON
                    sig.center = jes.signature_center
                    AND sig.id = jes.signature_id
                WHERE
                    jes.journalentry_id = je.id )
        ELSE NULL
    END              AS "LATEST_SIGNED_DATETIME" ,
    je.document_name AS "ATTACHED_FILE_NAME",
   	je.expiration_date   AS "EXPIRATION_DATE",
    COALESCE(je.person_center, je.REF_CENTER, je.CREATORCENTER) AS "CENTER_ID",
    (
        CASE
            WHEN JE.JETYPE IN (18,19,1) --ss
            THEN 'SUBSCRIPTION'
             WHEN JE.JETYPE IN (33,34) --cc
            THEN 'CLIPCARD'
            ELSE NULL
        END) AS "REFERENCE_TYPE",
    (
        CASE
            WHEN JE.JETYPE IN (18,19,1) --SUBSCRIPTION
            THEN je.ref_center ||'ss'||je.ref_id
            WHEN JE.JETYPE IN (33,34) --CLIPCARD 
            THEN je.ref_center ||'cc'||je.ref_id||'cc'||je.ref_subid
            ELSE NULL
        END)                                                  AS "REFERENCE_ID", 
    je.last_modified AS "ETS"
FROM
    journalentries je
LEFT JOIN
    persons p
ON
    p.center = je.person_center
    AND p.id = je.person_id
LEFT JOIN
    EMPLOYEES emp
ON
    je.CREATORCENTER = emp.center
    AND je.CREATORID = emp.id
LEFT JOIN
    persons staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
WHERE
    je.person_center is not null
