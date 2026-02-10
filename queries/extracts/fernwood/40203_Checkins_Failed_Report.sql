-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    person_center,
    person_id,
    checkin_center,
    TO_TIMESTAMP(checkin_time / 1000) AS checkin_datetime,
    TO_TIMESTAMP(checkout_time / 1000) AS checkout_datetime,
    checked_out,
    card_checked_in,
    checkin_result,
    identity_method,
    last_modified,
    origin,
    checkout_reminder_count,
    person_type,
    checkin_failed_reason
FROM checkins
WHERE checkin_failed_reason IS NOT NULL 
    AND TO_TIMESTAMP(checkin_time / 1000)::date BETWEEN :From::date AND :To::date
LIMIT 100000;