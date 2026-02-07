-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$,
                    'yyyy-MM-dd HH24:MI')) AS BIGINT)
            END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS
            BIGINT) AS TODATE
    )
SELECT
    p.EXTERNAL_ID                    "COMPANY_ID",
    CAST ( p.center AS VARCHAR(255)) "HOME_CENTER_ID",
    p.FULLNAME AS                    "NAME",
    p.COUNTRY                        "COUNTRY_ID",
    p.ZIPCODE                        "POSTAL_CODE",
    p.CITY AS                        "CITY",
    account_manager.EXTERNAL_ID      "ACCOUNT_MANAGER_ID",
    CASE
        WHEN p.STATUS = 7
        THEN 'DELETED'
        ELSE 'ACTIVE'
    END         "STATUS",
    z.COUNTY        AS "COUNTY",
    z.PROVINCE      AS "STATE",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"    
FROM
    params,
    PERSONS p
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
AND rel.ID = p.ID
AND rel.RTYPE = 10
AND rel.STATUS = 1
LEFT JOIN
    PERSONS account_manager
ON
    rel.RELATIVECENTER = account_manager.CENTER
AND rel.RELATIVEID = account_manager.ID
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = p.COUNTRY
AND z.ZIPCODE = p.ZIPCODE
AND z.CITY = p.CITY
WHERE
    p.SEX = 'C'
AND p.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE