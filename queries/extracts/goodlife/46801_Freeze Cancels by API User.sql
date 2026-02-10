-- The extract is extracted from Exerp on 2026-02-08
-- Created on: 12.6.23
Created by: Sandra Gupta
Created for: to provide numbers to Julie for online vs in club freezes and cancel
Returns from start date entered to today/
SELECT

subscription_center||'ss'||subscription_id AS subscription_id
,state
,text
,type
,start_date
,end_date
-- Not in subscription_blocked_period table
-- ,CASE
--     WHEN entry_interface_type = 0
--     THEN 'System'
--     WHEN entry_interface_type = 1
--     THEN 'Exerp Desktop Client'
--     WHEN entry_interface_type = 2
--     THEN 'Web'
--     WHEN entry_interface_type = 3
--     THEN 'Kiosk'
--     WHEN entry_interface_type = 4
--     THEN 'Script'
--     WHEN entry_interface_type = 6
--     THEN 'Member App'
--     WHEN entry_interface_type = 7
--     THEN 'Staff App'
--     WHEN entry_interface_type IS NULL
--     THEN NULL
--     ELSE 'Unknown'
-- END AS entry_interface_type
,TO_CHAR(LONGTODATEC(entry_time,subscription_center),'YYYY-MM-DD HH24:MI:SS') AS entry_date_time
,TO_CHAR(LONGTODATEC(cancel_time,subscription_center),'YYYY-MM-DD HH24:MI:SS') AS cancel_date_time
,employee_center||'emp'||employee_id AS creator_employee
,cancel_employee_center||'emp'||cancel_employee_id AS cancel_employee
,CASE
    WHEN employee_center = 990 AND employee_id = 228 
    THEN CASE
        WHEN  cancel_employee_center = 990 AND cancel_employee_id = 228
        THEN TEXT 'CREATE_AND_CANCEL_FREEZE'
        ELSE TEXT 'CREATE_FREEZE'
    END
    WHEN  cancel_employee_center = 990 AND cancel_employee_id = 228
    THEN TEXT 'CANCEL_FREEZE'    
    ELSE 'UNKNOWN'
END AS "Action"

FROM

-- subscription_freeze_period
subscription_blocked_period
    -- Freezes resumed online do not add a cancellation entry to the subscription_freeze_period table, only the subscription_blocked_period table


WHERE

"type" = 'FREEZE'
-- Either API USer created or cancelled freeze (or Both)
AND (
    employee_center = 990
    AND employee_id = 228
    AND entry_time > CAST((:EntryStartTime-TO_DATE('1-1-1970','MM-DD-YYYY')) AS BIGINT) * 24 * 3600 * 1000
    AND text = 'Member Issued Self-Service Contractual Freeze'
)
OR 
(
    cancel_employee_center = 990
    AND cancel_employee_id = 228
    AND cancel_time >  CAST((:EntryStartTime-TO_DATE('1-1-1970','MM-DD-YYYY')) AS BIGINT) * 24 * 3600 * 1000
)

UNION ALL

SELECT

s.center||'ss'||s.id AS subscription_id
,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS STATE -- Custom Exerp Function - Possible values in View bi_decode_values
    -- Otherwise, values saved in Confluence for reference: https://goodlifefitness.atlassian.net/wiki/spaces/ITS/pages/1203666992/goodlife.subscriptions
,j.text
,TEXT '' AS type
,s.start_date
,s.end_date
-- ,TEXT '' AS entry_interface_type
,TO_CHAR(LONGTODATEC(j.creation_time,s.center),'YYYY-MM-DD HH24:MI:SS') AS entry_date_time
,NULL AS cancel_date_time
,s.creator_center||'emp'||s.creator_id AS creator_employee
,TEXT '990emp228' AS cancel_employee
,TEXT 'CANCEL_SUBSCRIPTION' AS "Action"

FROM

journalentries j

JOIN subscriptions s
ON j.ref_center = s.center
AND j.ref_id = s.id

WHERE

-- Locate API User cancellations based on Journal Note
    -- There is no other way to determine who cancelled a subscription
j.name = 'Pre-Authorized Payment subscription termination'
AND j.creatorcenter = 990 -- These two lines - employee id of API User - 990emp228
AND j.creatorid = 228
AND j.jetype = 18 -- PAP Subscription Termination
    -- https://goodlifefitness.atlassian.net/wiki/spaces/ITS/pages/1194426487/journalentries
AND j.creation_time > CAST((:EntryStartTime-TO_DATE('1-1-1970','MM-DD-YYYY')) AS BIGINT) * 24 * 3600 * 1000