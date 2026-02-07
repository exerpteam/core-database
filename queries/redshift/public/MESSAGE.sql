SELECT
    m.center||'p'||m.id||'msg'||m.subid AS "ID",
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
    END            AS "COMPANY_ID",
    m.senttime     AS "CREATION_DATETIME",
    m.receivedtime AS "DELIVERY_DATETIME",
    CASE
        WHEN m.DELIVERYCODE = 0
        THEN ' UNDELIVERED'
        WHEN m.DELIVERYCODE = 0
        THEN 'UNDELIVERED'
        WHEN m.DELIVERYCODE = 1
        THEN 'STAFF'
        WHEN m.DELIVERYCODE = 2
        THEN 'EMAIL'
        WHEN m.DELIVERYCODE = 3
        THEN 'EXPIRED'
        WHEN m.DELIVERYCODE = 4
        THEN 'KIOSK'
        WHEN m.DELIVERYCODE = 5
        THEN 'WEB'
        WHEN m.DELIVERYCODE = 6
        THEN 'SMS'
        WHEN m.DELIVERYCODE = 7
        THEN 'CANCELED'
        WHEN m.DELIVERYCODE = 8
        THEN 'LETTER'
        WHEN m.DELIVERYCODE = 9
        THEN 'FAILED'
        WHEN m.DELIVERYCODE = 10
        THEN 'UNCHARGABLE'
        ELSE 'UNKNOWN'
    END AS "DELIVERY_METHOD",
    CASE
        WHEN (delivery_staff.CENTER != delivery_staff.TRANSFERS_CURRENT_PRS_CENTER
                OR delivery_staff.id != delivery_staff.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = delivery_staff.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = delivery_staff.TRANSFERS_CURRENT_PRS_ID)
        ELSE delivery_staff.EXTERNAL_ID
    END          AS "DELIVERED_BY_PERSON_ID",
    m.TEMPLATEID AS "TEMPLATE_ID",
    CASE
        WHEN m.MESSAGE_TYPE_ID IN(10)
        THEN 'STAFF_TO_CUSTOMER'
        WHEN m.MESSAGE_TYPE_ID IN(21)
        THEN 'CASH_COLLECTION_REQUEST_REMAINING_AND_STOP'
        WHEN m.MESSAGE_TYPE_ID IN(20)
        THEN 'CASH_COLLECTION_NOTIFICATION'
        WHEN m.MESSAGE_TYPE_ID IN(24)
        THEN 'CASH_COLLECTION_BLOCK'
        WHEN m.MESSAGE_TYPE_ID IN(30)
        THEN 'SANCTION_CLIP_PUNISHMENT'
        WHEN m.MESSAGE_TYPE_ID IN(31)
        THEN 'SANCTION_BOOKING_RESTRICTION_PUNISHMENT'
        WHEN m.MESSAGE_TYPE_ID IN(35)
        THEN 'SANCTION_BOOKING_RESTRICTION_WARNING'
        WHEN m.MESSAGE_TYPE_ID IN(37)
        THEN 'PARTICIPATION_MOVEDUP'
        WHEN m.MESSAGE_TYPE_ID IN(38)
        THEN 'SUBSCRIPTION_SALE'
        WHEN m.MESSAGE_TYPE_ID IN(39)
        THEN 'STAFF_CANCELATION'
        WHEN m.MESSAGE_TYPE_ID IN(40)
        THEN 'PARTICIPATION_CREATION'
        WHEN m.MESSAGE_TYPE_ID IN(42)
        THEN 'BOOKING_REMINDER_COURT'
        WHEN m.MESSAGE_TYPE_ID IN(43)
        THEN 'BOOKING_REMINDER_STAFF'
        WHEN m.MESSAGE_TYPE_ID IN(48)
        THEN 'FREEZE_CREATION'
        WHEN m.MESSAGE_TYPE_ID IN(50)
        THEN 'SUBSCRIPTION_TERMINATION'
        WHEN m.MESSAGE_TYPE_ID IN(58)
        THEN 'BOOKING_STAFF_CHANGE'
        WHEN m.MESSAGE_TYPE_ID IN(62)
        THEN 'CREDIT_CARD_AGREEMENT_FINISH_ONLINE'
        WHEN m.MESSAGE_TYPE_ID IN(63)
        THEN 'CHECK_IN'
        WHEN m.MESSAGE_TYPE_ID IN(71)
        THEN 'PARTICIPATION_STATE_CHANGED'
        WHEN m.MESSAGE_TYPE_ID IN(73)
        THEN 'BOOKING_CREATED'
        WHEN m.MESSAGE_TYPE_ID IN(78)
        THEN 'PRODUCT_SALE'
        WHEN m.MESSAGE_TYPE_ID IN(83)
        THEN 'NEW_ACTIVE_MEMBERS'
        WHEN m.MESSAGE_TYPE_ID IN(91)
        THEN 'SUBSCRIPTION_CHANGED'
        WHEN m.MESSAGE_TYPE_ID IN(92)
        THEN 'CLIPCARD_SOLD'
        WHEN m.MESSAGE_TYPE_ID IN(96)
        THEN 'ADVANCE_NOTICE'
        WHEN m.MESSAGE_TYPE_ID IN(97)
        THEN 'SQL_EVENT_JOB'
        WHEN m.MESSAGE_TYPE_ID IN(106)
        THEN 'PARTICIPATION_REMINDER'
        WHEN m.MESSAGE_TYPE_ID IN(107)
        THEN 'PARTICIPATION_CANCELLATION'
        WHEN m.MESSAGE_TYPE_ID IN(109)
        THEN 'PAYMENT_REQUEST_DELIVERY'
        WHEN m.MESSAGE_TYPE_ID IN(114)
        THEN 'SEND_PASSWORD_TOKEN'
        WHEN m.MESSAGE_TYPE_ID IN(121)
        THEN 'PAYMENT_REQUEST_NOTIFICATION_WITH_INVOICE'
        WHEN m.MESSAGE_TYPE_ID IN(130)
        THEN 'BULK_SUBSCRIPTION_CHANGED'
        WHEN m.MESSAGE_TYPE_ID IN(132)
        THEN 'BINDING_END_DATE_CHANGED'
        WHEN m.MESSAGE_TYPE_ID IN(134)
        THEN 'RECURRING_PARTICIPATIONS_CREATION'
        ELSE 'UNKNOWN'
    END AS "TYPE",
    CASE
        WHEN m.MESSAGE_TYPE_ID IN(20)
        THEN
            (
                SELECT
                    CASE
                        WHEN ccc.missingpayment = 1
                        THEN 'DEBT_CASE'
                        WHEN ccc.missingpayment = 0
                        THEN 'AGREEMENT_CASE'
                    END
                FROM
                    cashcollectioncases ccc
                WHERE
                    ccc.center = CAST(SUBSTRING(m.reference, 1, position('ccol' IN m.REFERENCE)-1) AS INTEGER)
                    AND ccc.id = CAST(SUBSTRING(m.reference, position('ccol' IN m.REFERENCE)+4) AS INTEGER))
        WHEN m.MESSAGE_TYPE_ID IN(21,24)
        THEN 'DEBT_CASE'
        WHEN m.MESSAGE_TYPE_ID IN(30,
                                  31,
                                  35)
        THEN 'ACCESS_PRIVILEGE_USAGE'
        WHEN m.MESSAGE_TYPE_ID IN(38,
                                  50,
                                  91,
                                  132)
        THEN 'SUBSCRIPTION'
        WHEN m.MESSAGE_TYPE_ID IN(39,
								  58,
                                  73)
        THEN 'BOOKING'
        WHEN m.MESSAGE_TYPE_ID IN(37,
                                  40,
                                  42,
                                  43,
                                  71,
                                  106,
                                  107,
                                  134)
        THEN 'PARTICIPATION'
        WHEN m.MESSAGE_TYPE_ID IN(48)
        THEN 'FREEZE_PERIOD'
        WHEN m.MESSAGE_TYPE_ID IN(78)
        THEN 'SALE_LOG'
        WHEN m.MESSAGE_TYPE_ID IN(92)
        THEN 'CLIPCARD'
        ELSE NULL
    END AS "REF_TYPE",
    CASE
        WHEN m.MESSAGE_TYPE_ID IN(20,21,24) -- cashcollection
        THEN m.REFERENCE
        WHEN m.MESSAGE_TYPE_ID IN(30,
                                  31,
                                  35) -- privilege usage
		THEN REPLACE(m.REFERENCE,'pu','')
        WHEN m.MESSAGE_TYPE_ID IN(38, --subscription
                                  50,
                                  91,
                                  132)
        THEN m.REFERENCE
        WHEN m.MESSAGE_TYPE_ID IN(39, -- booking
                                  58,
                                  73)
        THEN m.REFERENCE
        WHEN m.MESSAGE_TYPE_ID IN(37,
                                  40, -- participation
								  42,
                                  43,
                                  71,
                                  106,
                                  107,
                                  134)
        THEN m.REFERENCE
        WHEN m.MESSAGE_TYPE_ID IN(48) -- freeze creation
        THEN REPLACE(m.REFERENCE,'sfp','')
        WHEN m.MESSAGE_TYPE_ID IN(78) -- Sale log
        THEN m.REFERENCE
        WHEN m.MESSAGE_TYPE_ID IN(92) -- clipcard
        THEN substring(m.REFERENCE FROM '^\d*cc\d*')||'cc'||substring(m.REFERENCE FROM '(\d+)(?!.*\d)')
            --THEN REGEXP_SUBSTR(m.REFERENCE , '^\d*cc\d*')||'id'||REGEXP_SUBSTR(m.REFERENCE , '(\d+)(?!.*\d)')
        ELSE NULL
    END       AS "REF_ID",
    m.SUBJECT AS "SUBJECT",
    CASE
        WHEN (send_staff.CENTER != send_staff.TRANSFERS_CURRENT_PRS_CENTER
                OR send_staff.id != send_staff.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = send_staff.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = send_staff.TRANSFERS_CURRENT_PRS_ID)
        ELSE send_staff.EXTERNAL_ID
    END AS "FROM_PERSON_ID",
    CASE
        WHEN m.DELIVERYMETHOD = 0
        THEN 'STAFF'
        WHEN m.DELIVERYMETHOD = 1
        THEN 'EMAIL'
        WHEN m.DELIVERYMETHOD = 2
        THEN 'SMS'
        WHEN m.DELIVERYMETHOD = 3
        THEN 'PERSINTF'
        WHEN m.DELIVERYMETHOD = 4
        THEN 'BLOCKPERSINTF'
        WHEN m.DELIVERYMETHOD = 5
        THEN 'LETTER'
    END               AS "CHANNEL",
    m.MESSAGECATEGORY AS "MESSAGE_CATEGORY",
    m.center          AS "CENTER_ID",
    m.last_modified   AS "ETS"
FROM
    MESSAGES m
LEFT JOIN
    persons p
ON
    p.center = m.center
    AND p.id = m.id
LEFT JOIN
    persons delivery_staff
ON
    delivery_staff.center = m.DELIVERED_BY_CENTER
    AND delivery_staff.id = m.DELIVERED_BY_ID
LEFT JOIN
    persons send_staff
ON
    send_staff.center = m.SENDERCENTER
    AND send_staff.id = m.SENDERID
LEFT JOIN
    TEMPLATES temp
ON
    temp.ID = m.TEMPLATEID
