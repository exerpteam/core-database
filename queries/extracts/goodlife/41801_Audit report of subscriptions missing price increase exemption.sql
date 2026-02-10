-- The extract is extracted from Exerp on 2026-02-08
-- Extract indentifies applicable member subscriptions that were transferred within the last 1-90 days
SELECT
p_2.external_id
,sub_2.owner_center ||'p'|| sub_2.owner_id AS member_id_2
,CASE p_2.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
,CASE p_2.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
,sub_2.center ||'ss'||sub_2.id as subscription_2
,CASE sub_2.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE_2
,CASE sub_2.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE_2
,sub_2.is_price_update_excluded
,sub_2.subscription_price
,sub_1.center ||'ss'||sub_1.id as original_subscription
,CASE sub_1.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
,CASE sub_1.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE
,sub_1.is_price_update_excluded
,sub_1.subscription_price
,sub_2.creation_time as creationtime

FROM subscription_change sc LEFT JOIN subscription_change sc2 ON sc2.old_subscription_center =
sc.new_subscription_center
AND
sc2.old_subscription_id = sc.new_subscription_id
AND
sc2.type = 'TRANSFER' LEFT JOIN subscriptions sub_1 ON sub_1.center = sc.old_subscription_center
AND
sub_1.id = sc.old_subscription_id LEFT JOIN subscriptions sub_2 ON sub_2.center =
sc.new_subscription_center
AND
sub_2.id = sc.new_subscription_id LEFT JOIN persons AS p_1 ON sub_1.owner_center = p_1.center
AND
sub_1.owner_id = p_1.id LEFT JOIN persons AS p_2 ON sub_2.owner_center = p_2.center
AND
sub_2.owner_id = p_2.id WHERE sc.type = 'TRANSFER'
AND
sub_1.is_price_update_excluded = 'true' -- flag checked on oldest subscription
AND
sub_2.creation_time BETWEEN
CASE
WHEN :offset=-1 THEN
    0
ELSE
    CAST((CURRENT_DATE-:offset-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
END
AND
CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000