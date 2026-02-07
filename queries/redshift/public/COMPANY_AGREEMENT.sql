SELECT DISTINCT
    ca.center||'p'||ca.id||'rpt'||ca.SUBID AS "ID",
    p.EXTERNAL_ID                          AS "COMPANY_ID",
    ca.NAME                                AS "NAME",
    CASE
        WHEN ca.STATE = 0
        THEN 'UNDER_TARGET'
        WHEN ca.STATE = 1
        THEN 'ACTIVE'
        WHEN ca.STATE = 2
        THEN 'STOP NEW'
        WHEN ca.STATE = 3
        THEN 'OLD'
        WHEN ca.STATE = 4
        THEN 'AWAITING ACTIVATION'
        WHEN ca.STATE = 5
        THEN 'BLOCKED'
        WHEN ca.STATE = 6
        THEN 'DELETED'
    END       AS "STATE",
    ca.center AS "CENTER_ID",
    CASE
        WHEN ca.FAMILY_CORPORATE_STATUS = 0
        THEN 'EMPLOYEE'
        WHEN ca.FAMILY_CORPORATE_STATUS = 1
        THEN 'EMPLOYEE_FAMILY'
        WHEN ca.FAMILY_CORPORATE_STATUS = 2
        THEN 'FAMILY'
    END                     AS "ALLOWED_RELATION",
    ca.MAX_FAMILY_CORPORATE AS "MAX_FAMILY",
    ca.REQUIRE_OTHER_PAYER  AS "FAMILY_REQUIRES_PAYER",
    ca.STOP_NEW_DATE        AS "STOP_NEW_DATE",
	ca.CREATION_DATE        AS "CREATION_DATE",
    ca.LAST_MODIFIED        AS "ETS",
    ca.external_id          AS "EXTERNAL_ID"
FROM
    COMPANYAGREEMENTS ca
JOIN
    PERSONS p
ON
    p.center = ca.center
    AND p.id = ca.id
