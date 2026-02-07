SELECT DISTINCT
    pu.PERSON_CENTER ||'p'|| pu.PERSON_ID AS  "PERSON_ID",
    cc.ID,
    cc.CAMPAIGN_ID AS "campaign_code_id",
    cc.CODE        AS "Campaign Code",
    cc.CAMPAIGN_TYPE
FROM
    CAMPAIGN_CODES cc
JOIN
    CAMPAIGN_CODE_USAGES ccu ON ccu.CAMPAIGN_CODE_ID = cc.ID
JOIN
    PRIVILEGE_USAGES pu ON pu.CAMPAIGN_CODE_ID = cc.ID
WHERE

CAST (cc.code AS VARCHAR) IN (:code)