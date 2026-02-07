
SELECT
    COALESCE(Source, '-'||'-GrandTotal') AS Source,
    COALESCE(SourceType, '-'||'-Total')  AS SourceType,
    LeadProspect                     AS "Leads and Prospects",
    CASE
        WHEN SourceType IS NOT NULL
        THEN TO_CHAR(COALESCE(ROUND(LeadProspect*100/NULLIF(TotalL,0), 2), 0), 'FM990.00') ||'%'
        WHEN TotalL = 0
        THEN '0.00%'
        ELSE '100%'
    END     AS "Leads and Prospects Precentage",
    Members AS "Members",
    CASE
        WHEN SourceType IS NOT NULL
        THEN TO_CHAR(COALESCE(ROUND(Members*100/NULLIF(TotalM,0), 2), 0), 'FM990.00') ||'%'
        WHEN TotalM = 0
        THEN '0.00%'
        ELSE '100%'
    END AS "Members Precentage"
FROM
    (
        SELECT
            Source,
            SourceType,
            SUM(
                CASE status
                    WHEN 1
                    THEN sourcetype_count
                    ELSE 0
                END) AS LeadProspect,
            SUM(
                CASE status
                    WHEN 2
                    THEN sourcetype_count
                    ELSE 0
                END) Members,
            SUM(
                CASE status
                    WHEN 1
                    THEN source_count
                    ELSE 0
                END) TotalL,
            SUM(
                CASE status
                    WHEN 2
                    THEN source_count
                    ELSE 0
                END) TotalM
        FROM
            (
                SELECT DISTINCT
                    COALESCE(pea.name,
                    CASE c.country
                        WHEN 'DE'
                        THEN 'SOURCES_DE'
                        WHEN 'AT'
                        THEN 'SOURCES_AT'
                        WHEN 'CH'
                        THEN 'SOURCES_CH'
                        WHEN 'CZ'
                        THEN 'SOURCES_CZ'
                        WHEN 'PL'
                        THEN 'SOURCES_PL'
                        ELSE 'UNKNOWN'
                    END)                                  AS Source,
                    COALESCE(pea.TXTVALUE, 'Not Selcted') AS SourceType ,
                    CASE p.status
                        WHEN 0
                        THEN 1
                        WHEN 6
                        THEN 1
                        WHEN 1
                        THEN 2
                        WHEN 3
                        THEN 2
                        ELSE 0
                    END AS status,
                    SUM(1) OVER (PARTITION BY COALESCE(pea.name,
                    CASE c.country
                        WHEN 'DE'
                        THEN 'SOURCES_DE'
                        WHEN 'AT'
                        THEN 'SOURCES_AT'
                        WHEN 'CH'
                        THEN 'SOURCES_CH'
                        WHEN 'CZ'
                        THEN 'SOURCES_CZ'
                        WHEN 'PL'
                        THEN 'SOURCES_PL'
                        ELSE 'UNKNOWN'
                    END) , COALESCE(pea.TXTVALUE, 'Not Selcted'),
                    CASE p.status
                        WHEN 0
                        THEN 1
                        WHEN 6
                        THEN 1
                        WHEN 1
                        THEN 2
                        WHEN 3
                        THEN 2
                        ELSE 0
                    END) AS sourcetype_count,
                    SUM(1) OVER (PARTITION BY COALESCE(pea.name,
                    CASE c.country
                        WHEN 'DE'
                        THEN 'SOURCES_DE'
                        WHEN 'AT'
                        THEN 'SOURCES_AT'
                        WHEN 'CH'
                        THEN 'SOURCES_CH'
                        WHEN 'CZ'
                        THEN 'SOURCES_CZ'
                        WHEN 'PL'
                        THEN 'SOURCES_PL'
                        ELSE 'UNKNOWN'
                    END) ,
                    CASE p.status
                        WHEN 0
                        THEN 1
                        WHEN 6
                        THEN 1
                        WHEN 1
                        THEN 2
                        WHEN 3
                        THEN 2
                        ELSE 0
                    END) AS source_count
                FROM
                    persons p
                JOIN
                    centers c
                ON
                    c.id = p.center
                LEFT JOIN
                    PERSON_EXT_ATTRS pea
                ON
                    pea.PERSONCENTER = p.center
                AND pea.PERSONID = p.id
                AND pea.name IN ('SOURCES_CH',
                                 'SOURCES_AT',
                                 'SOURCES_DE')
                LEFT JOIN
                    PERSON_EXT_ATTRS pea2
                ON
                    pea2.PERSONCENTER = p.center
                AND pea2.PERSONID = p.id
                AND pea2.name = 'CREATION_DATE'
                AND pea2.TXTVALUE IS NOT NULL
                WHERE
                    p.status IN (0,
                                 1,
                                 3,
                                 6)
                AND p.center IN ($$scope$$)
                AND to_date(pea2.TXTVALUE,'yyyy-MM-dd') BETWEEN $$from_date$$ AND $$to_date$$ )  z
        GROUP BY
            rollup (source,sourcetype)
        ORDER BY
            source,
            sourcetype ) z