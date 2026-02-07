SELECT

p.center||'p'||p.id AS teen_id
,p.external_id AS teen_external_id
,p.fullname AS teen_name
,email_teen.txtvalue AS teen_email
,p2.center||'p'||p2.id AS parent_id 
,p2.external_id AS parent_external_id
,p2.fullname AS parent_name
,email_parent.txtvalue AS parent_email
,TO_CHAR(LONGTODATEC(scl.entry_start_time,990),'YYYY-MM-DD HH24:MI:SS') AS date_parent_added
,scl.employee_center||'emp'||scl.employee_id AS parent_link_creator
,ss.sales_date
,TO_CHAR(LONGTODATEC(s.creation_time,990),'YYYY-MM-DD HH24:MI:SS') AS date_subscription_created
,s.start_date
,s.end_date
,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS "State"
,bi_decode_field('SUBSCRIPTIONS', 'SUB_STATE', s.sub_state) AS "Sub_state"
,COUNT(*) OVER (PARTITION BY p.center,p.id) AS number_of_parent_links

FROM

subscription_sales ss

JOIN products pr
ON ss.subscription_type_center = pr.center
AND ss.subscription_type_id = pr.id
AND ss.type = 1
AND pr.ptype = 10
AND ss.sales_date >= '2025-01-01'
AND pr.name = 'Teen Fitness Access'

JOIN subscriptions s
ON ss.subscription_center = s.center
AND ss.subscription_id = s.id

JOIN persons p
ON s.owner_center = p.center
AND s.owner_id = p.id


LEFT JOIN relatives r
ON ss.owner_center = r.relativecenter
AND ss.owner_id = r.relativeid
AND r.rtype = 14
AND r.status = 1

LEFT JOIN state_change_log scl
ON r.center = scl.center
AND r.id = scl.id
AND r.subid = scl.subid
AND scl.entry_end_time IS NULL

LEFT JOIN persons p2
ON r.center = p2.center
AND r.id = p2.id

LEFT JOIN
    PERSON_EXT_ATTRS email_teen
ON
    p.center=email_teen.PERSONCENTER
    AND p.id=email_teen.PERSONID
    AND email_teen.name='_eClub_Email'

    LEFT JOIN
    PERSON_EXT_ATTRS email_parent
ON
    p2.center=email_parent.PERSONCENTER
    AND p2.id=email_parent.PERSONID
    AND email_parent.name='_eClub_Email'
