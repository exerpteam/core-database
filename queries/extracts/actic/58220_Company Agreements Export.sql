-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
    ,
    comp_agr AS
    (
        SELECT DISTINCT
            ca.*
        FROM
            plist p
        JOIN
            RELATIVES compAgr
        ON
            p.CENTER = compAgr.CENTER
        AND p.ID = compAgr.ID
        AND compAgr.RTYPE = 3
        AND compAgr.STATUS=1
        JOIN
            companyagreements ca
        ON
            ca.center = compAgr.RELATIVECENTER
        AND ca.id = compAgr.RELATIVEID
        AND ca.subid = compAgr.RELATIVESUBID
    )
    ,
    priv_set_map AS
    (
        SELECT
            ps.id   AS old_priv_set_id,
            ps.name AS old_priv_set_name,
            ps.id   AS new_priv_set_id,
            ps.name AS new_priv_set_name
        FROM
            privilege_sets ps
    )
SELECT
    row_number() over (ORDER BY CompanyId DESC) AS ID,
    t3.*
FROM
    (
        SELECT DISTINCT
            ca.CENTER || 'p' || ca.ID                      AS CompanyId,
            ca.CENTER || 'p' || ca.ID || 'rpt' || ca.SUBID AS CompanyAgreementId,
            ca.NAME                                        AS CompanyAgreementName,
            (ca.DOCUMENTATION_REQUIRED::INT)::text         AS DocumentationRequired,
            lower(CASE ca.DOCUMENTATION_INTERVAL_UNIT
                WHEN 0
                THEN 'WEEK'
                WHEN 1
                THEN 'DAY'
                WHEN 2
                THEN 'MONTH'
                WHEN 3
                THEN 'YEAR'
                WHEN 4
                THEN 'HOUR'
                WHEN 5
                THEN 'MINUTE'
                WHEN 6
                THEN 'SECOND'
                WHEN 7
                THEN 'MILLISECOND'
                ELSE 'Undefined'
            END)                       AS DocumentationIntervalUnit,
            ca.DOCUMENTATION_INTERVAL AS DocumentationInterval,
            ca.stop_new_date          AS StopNewDate,
            ps.new_priv_set_id        AS PrivilegeSetId,
            ps.new_priv_set_name      AS PrivilegeSetName,
            CASE pg.SPONSORSHIP_NAME
                WHEN 'FULL'
                THEN 'Full'
                WHEN 'NONE'
                THEN 'None'
                WHEN 'PERCENTAGE'
                THEN 'Percentage'
                WHEN 'FIXED'
                THEN 'Amount'
                ELSE NULL
            END                   AS SponsorshipType,
            pg.SPONSORSHIP_AMOUNT AS SponsorshipValue
        FROM
            comp_agr ca
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_CENTER = ca.CENTER
        AND pg.GRANTER_ID = ca.ID
        AND pg.GRANTER_SUBID = ca.SUBID
        AND pg.VALID_FROM < dateToLong(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-dd HH24:MI'))
        AND ( pg.VALID_TO >=dateToLong(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-dd HH24:MI'))
            OR  pg.VALID_TO IS NULL )
        AND pg.GRANTER_SERVICE = 'CompanyAgreement'
        LEFT JOIN
            priv_set_map ps
        ON
            ps.old_priv_set_id = pg.privilege_set ) t3