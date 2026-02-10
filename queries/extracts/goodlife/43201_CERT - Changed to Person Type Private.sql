-- The extract is extracted from Exerp on 2026-02-08
-- CAB Approval - ISSUE-38607



SELECT

scl.center||'p'||scl.id AS personid
,bi_decode_field('PERSONS', 'PERSONTYPE', per.persontype) AS current_persontype
,TO_CHAR(LONGTODATEC(scl.entry_start_time,990),'YYYY-MM-DD HH24:MI:SS') AS changed_at
,p.name AS product
,s.center||'ss'||s.id AS subscription_id



FROM

state_change_log scl

JOIN subscriptions s
ON s.owner_center = scl.center
AND s.owner_id = scl.id
AND s.state IN (2,4,8)

JOIN product_and_product_group_link ppgl
ON ppgl.product_center = s.subscriptiontype_center
AND ppgl.product_id = s.subscriptiontype_id
AND ppgl.product_group_id = 12603 -- Legacy CERT

JOIN products p
ON s.subscriptiontype_center = p.center
AND s.subscriptiontype_id = p.id

JOIN persons per
ON per.center = scl.center
AND per.id = scl.id


WHERE

scl.entry_type = 3 -- Person Type
AND scl.stateid IN (0,6) -- Person Types Private, Family

-- API User completed the change
AND scl.employee_center = 990
AND scl.employee_id = 228

-- Changes in last x days
AND scl.entry_start_time > 
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
