-- The extract is extracted from Exerp on 2026-02-08
-- ES-15254 - Simple extract to get campaign code usage
 SELECT DISTINCT
 pu.PERSON_CENTER ||'p'|| pu.PERSON_ID as  "PERSON_ID",
 c.name as "Club Name", 
 cc.ID,
 cc.CAMPAIGN_ID as "campaign_code_id",
 cc.CODE as "Campaign Code",
 cc.CAMPAIGN_TYPE,
 longtodate(pu.use_time) as "Usage date"
 
 from CAMPAIGN_CODES cc
 JOIN
 CAMPAIGN_CODE_USAGES ccu
 ON ccu.CAMPAIGN_CODE_ID = cc.ID
 JOIN
 PRIVILEGE_USAGES pu
 ON
 pu.CAMPAIGN_CODE_ID = cc.ID
join centers c
on
pu.person_center = c.id
 WHERE
CAST (cc.CAMPAIGN_ID AS VARCHAR) in (:campaign_code_id) and
 pu.use_time >= (:datefrom) and pu.use_time <= (:dateto)
and pu.target_service = 'InvoiceLine'